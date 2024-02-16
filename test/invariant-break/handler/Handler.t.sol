// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";
import {HandlerStatefulFuzzCatches} from "../../../src/invariant-break/HandlerStatefulFuzzCatches.sol";
import {MockUSDC} from "../../mocks/MockUSDC.sol";
import {YeildERC20} from "../../mocks/YieldERC20.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Handler is Test {
    HandlerStatefulFuzzCatches handlerStatefulFuzzCatches;
    MockUSDC mockUSDC;
    YeildERC20 yeildERC20;
    address user;
    uint256 startingAmount;

    constructor(
        HandlerStatefulFuzzCatches _handlerStatefulFuzzCatches,
        MockUSDC _mockUSDC,
        YeildERC20 _yeildERC20,
        address _user
    ) {
        handlerStatefulFuzzCatches = _handlerStatefulFuzzCatches;
        mockUSDC = _mockUSDC;
        yeildERC20 = _yeildERC20;
        user = _user;
        startingAmount = yeildERC20.INITIAL_SUPPLY();
    }

    function depositYeildERC20(uint256 amount) public {
        amount = bound(amount, 0, yeildERC20.balanceOf(user));

        vm.startPrank(user);

        yeildERC20.approve(address(handlerStatefulFuzzCatches), amount);
        handlerStatefulFuzzCatches.depositToken(yeildERC20, amount);

        vm.stopPrank();
    }

    function depositMockUSDC(uint256 amount) public {
        amount = bound(amount, 0, mockUSDC.balanceOf(user));

        vm.startPrank(user);

        mockUSDC.approve(address(handlerStatefulFuzzCatches), amount);
        handlerStatefulFuzzCatches.depositToken(mockUSDC, amount);

        vm.stopPrank();
    }

    function withdrawYeildERC20() public {
        vm.startPrank(user);
        handlerStatefulFuzzCatches.withdrawToken(yeildERC20);
        vm.stopPrank();
    }

    function withdrawMockUSDC() public {
        vm.startPrank(user);
        handlerStatefulFuzzCatches.withdrawToken(mockUSDC);
        vm.stopPrank();
    }
}
