// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract Dos {
    error Dos__Player_AlreadyExists();

    address[] entrants;

    function enter() public {
        //check for duplicate entrants
        address[] memory cachedEntrants = entrants;
        for (uint256 i; i < cachedEntrants.length; i++) {
            if (entrants[i] == msg.sender) {
                revert Dos__Player_AlreadyExists();
            }
        }

        entrants.push(msg.sender);
    }
}

// In the above code we have a entrants[] which will contain addresses.
// Before pusing an address we are checking wether that address already exists?
// If already exists it will revert
// If not new entrant will be added to entrants[]

// ---------

// The problem starts if the array gets bigger.
// If already 100 players entered, and for the 101th player the loop has to run 100 times.
// The main problem is since loop will run 100 times it will become gas intensive. 101th players has to pay for the gas.

// ---------

// If the players ented is 1000
// when 1001th player has to enter loop has to run 1000 times.
// Since `enter` will become more gas intensive. This contract will become unusable

// Denying the service of the contract.(DOS)

// ----------

// Let's benchmark some results

// 0 Players -> Execution Cost : 44851

// For 0 players Execution cost is more than 1 player because,
// since we are calling entrants[] for the first time. we have to warmup the storage variable.
// more explanation below

// 1 -> 30537

// 2 -> 33254

// 3 -> 35971

// 4 -> 38688

// 5 -> 41405

// 6 -> 44122

// 100 -> ?

// 1000 -> ?

// If we look at the pattern, the gas gets increasing for every player.
// As said for 1000 players this protocol will become more gas intensive and denying interation with the protocol.

// ----------

// Here are the reasons why pushing the first element onto an array costs more gas:

// Storage Allocation: When you create an array in Solidity, it doesn't immediately allocate space for any elements. Instead, it allocates space as needed when you add elements. The first time you push an element onto the array, Solidity needs to allocate storage for that element. This involves writing to the Ethereum state trie, which is a costly operation in terms of gas.

// Gas Cost for Writing Data: Every write operation to the Ethereum blockchain incurs a gas cost. When you push the first element onto an array, you're not only writing the new element but also updating the length of the array. This update requires additional gas because it involves changing the state of the contract.

// Optimization Opportunities: For subsequent operations, such as adding more elements to the array, Solidity can optimize the storage layout because it already knows the structure of the array. However, during the first operation, there are no optimizations available, so the cost is higher.

// EVM Execution Model: The Ethereum Virtual Machine (EVM) charges for every operation, including memory allocation and deallocation. When you push the first element, the EVM has to set up the necessary memory space, which contributes to the gas cost.

// To mitigate the high gas cost for the first operation, developers sometimes use patterns like initializing arrays with a known maximum size if possible, or using other data structures like mappings that might have lower overhead for certain operations.
