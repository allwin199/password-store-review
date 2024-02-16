// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {StatefulFuzzCatches} from "../../src/invariant-break/StatefulFuzzCatches.sol";

contract StatefulFuzzCatchesTest is StdInvariant, Test {
    StatefulFuzzCatches private statefulFuzzCatches;

    function setUp() external {
        statefulFuzzCatches = new StatefulFuzzCatches();
        targetContract(address(statefulFuzzCatches));
    }

    // function test_DoMoreMathAgain(uint128 randomNumber) public {
    //     uint256 returnVal = statefulFuzzCatches.doMoreMathAgain(randomNumber);
    //     assertGt(returnVal, 0);
    // }

    function statefulFuzz_CatchesInvariant() public view {
        uint256 storedVal = statefulFuzzCatches.storedValue();
        assert(storedVal != 0);
    }
    // this test will randomly call all the functions inside the target contract
    // If the test calls, `changeValue(0)` and `doMoreMathAgain(0)` this will break.
    // also, keep `fail_on_revert = false`
}
