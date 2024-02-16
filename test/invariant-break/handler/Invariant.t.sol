// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {Handler} from "./Handler.t.sol";
import {MockUSDC} from "../../mocks/MockUSDC.sol";
import {YeildERC20} from "../../mocks/YieldERC20.sol";
import {HandlerStatefulFuzzCatches} from "../../../src/invariant-break/HandlerStatefulFuzzCatches.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Invariant is StdInvariant, Test {
    HandlerStatefulFuzzCatches handlerStatefulFuzzCatches;
    Handler handler;

    MockUSDC mockUSDC;
    YeildERC20 yeildERC20;

    IERC20[] supportedTokens;

    address private user = makeAddr("user");
    uint256 private startingAmount;

    function setUp() external {
        vm.startPrank(user);
        yeildERC20 = new YeildERC20();
        mockUSDC = new MockUSDC();
        startingAmount = yeildERC20.INITIAL_SUPPLY();
        mockUSDC.mint(user, startingAmount);
        vm.stopPrank();

        supportedTokens.push(mockUSDC);
        supportedTokens.push(yeildERC20);

        handlerStatefulFuzzCatches = new HandlerStatefulFuzzCatches(supportedTokens);

        handler = new Handler(handlerStatefulFuzzCatches, mockUSDC, yeildERC20, user);
        // targetContract(address(handler));

        bytes4[] memory selectors = new bytes4[](4);
        selectors[0] = handler.depositYeildERC20.selector;
        selectors[1] = handler.depositMockUSDC.selector;
        selectors[2] = handler.withdrawYeildERC20.selector;
        selectors[3] = handler.withdrawMockUSDC.selector;

        targetSelector(FuzzSelector({addr: address(handler), selectors: selectors}));
        targetContract(address(handler));
    }

    function invariant_StatefulFuzz_testBreaksHandler() public {
        vm.startPrank(user);
        handlerStatefulFuzzCatches.withdrawToken(mockUSDC);
        handlerStatefulFuzzCatches.withdrawToken(yeildERC20);
        vm.stopPrank();

        // since the user called withdraw, `handlerStatefulFuzzCatches` should have 0 balance.
        assertEq(mockUSDC.balanceOf(address(handlerStatefulFuzzCatches)), 0);
        assertEq(yeildERC20.balanceOf(address(handlerStatefulFuzzCatches)), 0);

        // user should have the same amount they started with, because everything is withdrawn
        assertEq(startingAmount, yeildERC20.balanceOf(user));
        assertEq(startingAmount, mockUSDC.balanceOf(user));
    }
}
