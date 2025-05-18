// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Upgraded Logic Contract (Version 2)
contract LogicV2 {
    uint256 public counter;

    // Initializes the counter, compatible with V1
    function initialize(uint256 _initialValue) external {
        require(counter == 0, "Already initialized");
        counter = _initialValue;
    }

    // Increments the counter
    function increment() external {
        counter += 1;
    }

    // Decrements the counter (new feature)
    function decrement() external {
        require(counter > 0, "Counter underflow");
        counter -= 1;
    }

    // Returns the counter value
    function getCounter() external view returns (uint256) {
        return counter;
    }
}