// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";
import {StatelessFuzzCatches} from "../../src/invariant-break/StatelessFuzzCatches.sol";

contract StatelessFuzzCatchesTest is Test {
    StatelessFuzzCatches private statelessFuzzCatches;

    function setUp() external {
        statelessFuzzCatches = new StatelessFuzzCatches();
    }

    // function test_FuzzCatchesBug_Stateless(uint128 randomNumber) public {
    //     uint256 returnVal = statelessFuzzCatches.doMath(randomNumber);
    //     assertEq(returnVal, 1);
    // }
}
