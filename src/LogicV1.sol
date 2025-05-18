// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// Initial Logic Contract (Version 1)
contract LogicV1 {
    // State variable stored in the proxy's storage
    uint256 public counter;
    bool private initialized;

    // Initializes the counter (can only be called once)
    function initialize(uint256 _initialValue) external {
        require(!initialized, "Already initialized");
        counter = _initialValue;
        initialized = true;
    }

    // Increments the counter
    function increment() external {
        counter += 1;
    }

    // Returns the counter value
    function getCounter() external view returns (uint256) {
        return counter;
    }
}