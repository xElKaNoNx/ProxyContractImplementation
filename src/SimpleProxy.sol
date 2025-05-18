// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract SimpleProxy {
    // Address of the contract owner
    address public owner;


    // EIP-1967 storage slot for the implementation address
    bytes32 private constant IMPLEMENTATION_SLOT = bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1);

    // Modifier to restrict access to the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    // Constructor sets the deployer as the owner
    constructor() {
        owner = msg.sender;
    }

    // Function to set the implementation address
    function setImplementation(address newImplementation) external onlyOwner {
        assembly {
            sstore(IMPLEMENTATION_SLOT, newImplementation)
        }
    }

    // Function to get the current implementation address
    function getImplementation() public view returns (address impl) {
        assembly {
            impl := sload(IMPLEMENTATION_SLOT)
        }
    }

    // Fallback function to delegate calls to the implementation
    fallback() external payable {
        address impl = getImplementation();
        require(impl != address(0), "Implementation not set");
        assembly {
            // Copy calldata to memory
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())

            // Delegatecall to the implementation
            let result := delegatecall(gas(), impl, ptr, calldatasize(), 0, 0)

            // Copy returndata to memory
            let size := returndatasize()
            returndatacopy(ptr, 0, size)
            
            // Revert or return based on the result
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }

}