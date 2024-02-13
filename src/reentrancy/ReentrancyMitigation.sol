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

    // CEI
    function withdrawBalance() public {
        // Checks

        // Effects
        uint256 balance = userBalance[msg.sender];
        userBalance[msg.sender] = 0;
        // Instead of updating users balance after sending. we update the balance and then send ETH.
        // By this way If attacker calls `withdraw` again. Balance will be 0 and Ether will not be exploited.

        // Interactions
        (bool success,) = msg.sender.call{value: balance}("");
        if (!success) {
            revert();
        }
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
