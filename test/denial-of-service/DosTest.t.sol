// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Dos} from "../../src/denial-of-service/Dos.sol";

contract DosTest is Test {
    Dos dos;
    address warmUpAddress = makeAddr("warmup");
    address personA = makeAddr("A");
    address personB = makeAddr("B");
    address personC = makeAddr("C");

    function setUp() external {
        dos = new Dos();
    }

    function test_Enter() public {
        uint256 gasStartWarmup = gasleft();
        vm.startPrank(warmUpAddress);
        dos.enter();
        vm.stopPrank();
        uint256 gasCostWarmUp = gasStartWarmup - gasleft();

        uint256 gasStartA = gasleft();
        vm.startPrank(personA);
        dos.enter();
        vm.stopPrank();
        uint256 gasCostA = gasStartA - gasleft();

        uint256 gasStartB = gasleft();
        vm.startPrank(personB);
        dos.enter();
        vm.stopPrank();
        uint256 gasCostB = gasStartB - gasleft();

        uint256 gasStartC = gasleft();
        vm.startPrank(personC);
        dos.enter();
        vm.stopPrank();
        uint256 gasCostC = gasStartC - gasleft();

        console.log("Warmup Gas Cost", gasCostWarmUp);
        console.log("Gas Cost A", gasCostA);
        console.log("Gas Cost B", gasCostB);
        console.log("Gas Cost C", gasCostC);

        // Logs:
        //     Warmup Gas Cost 55010
        //     Gas Cost A 26804
        //     Gas Cost B 27436
        //     Gas Cost C 28068
    }

    function test_enter_MultipleEntrants() public {
        uint256 gasStartWarmup = gasleft();
        vm.startPrank(warmUpAddress);
        dos.enter();
        vm.stopPrank();
        uint256 gasCostWarmUp = gasStartWarmup - gasleft();

        uint256 gasStartA = gasleft();
        vm.startPrank(personA);
        dos.enter();
        vm.stopPrank();
        uint256 gasCostA = gasStartA - gasleft();

        uint256 gasStartB = gasleft();
        vm.startPrank(personB);
        dos.enter();
        vm.stopPrank();
        uint256 gasCostB = gasStartB - gasleft();

        // 1000 entrants
        for (uint160 i = 0; i < 1000; i++) {
            vm.startPrank(address(i));
            dos.enter();
            vm.stopPrank();
        }

        uint256 gasStartC = gasleft();
        vm.startPrank(personC);
        dos.enter();
        vm.stopPrank();
        uint256 gasCostC = gasStartC - gasleft();

        console.log("Warmup Gas Cost", gasCostWarmUp);
        console.log("Gas Cost A", gasCostA);
        console.log("Gas Cost B", gasCostB);
        console.log("Gas Cost C", gasCostC);

        // Logs:
        //     Warmup Gas Cost 55010
        //     Gas Cost A 26804
        //     Gas Cost B 27436
        //     Gas Cost C 662053
    }

    // For 3 people to enter -> 27,436
    // After 1000  patricipants entered
    // To 1001 patricipant to enter
    // gas Cost -> 662,053
    // which is significatly high.
}
