// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract SimpleProxy {
    // Address of the contract owner
    address public owner;


    // EIP-1967 storage slot for the implementation address
    bytes32 private constant IMPLEMENTATION_SLOT = bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1);

    

}