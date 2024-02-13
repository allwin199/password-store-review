// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {ReentrancyVictim, ReentrancyAttacker} from "../../src/reentrancy/Reentrancy.sol";

contract DosTest is Test {
    ReentrancyVictim victimContract;
    ReentrancyAttacker attackContract;

    address victimUser = makeAddr("victim");
    address attacker = makeAddr("attacker");
    uint256 private constant STARTING_BALANCE = 10 ether;
    uint256 private constant AMOUNT_TO_DEPOSITED = 5 ether;

    function setUp() external {
        victimContract = new ReentrancyVictim();
        attackContract = new ReentrancyAttacker(victimContract);

        vm.deal(victimUser, STARTING_BALANCE);
        vm.deal(attacker, STARTING_BALANCE);
    }

    function test_Reentrancy() public {
        vm.startPrank(victimUser);
        victimContract.deposit{value: AMOUNT_TO_DEPOSITED}();
        vm.stopPrank();

        // attacker is attacking the victim contract
        vm.startPrank(attacker);
        attackContract.attack{value: 1 ether}();
        vm.stopPrank();

        assertEq(address(attackContract).balance, AMOUNT_TO_DEPOSITED + 1 ether);
        assertEq(address(victimContract).balance, 0);

        vm.startPrank(victimUser);
        vm.expectRevert();
        victimContract.withdrawBalance();
        vm.stopPrank();
    }
}
