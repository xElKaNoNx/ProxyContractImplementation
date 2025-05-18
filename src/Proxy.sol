// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Simplified EIP-1967 Proxy Contract
contract Proxy {
    // EIP-1967 slot for logic contract address
    bytes32 private constant IMPLEMENTATION_SLOT = 
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    // EIP-1967 slot for admin address
    bytes32 private constant ADMIN_SLOT = 
        0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    // Constructor sets initial logic and admin addresses
    constructor(address _logic, address _admin) {
        require(_logic != address(0), "Invalid logic address");
        require(_admin != address(0), "Invalid admin address");
        assembly {
            sstore(IMPLEMENTATION_SLOT, _logic)
            sstore(ADMIN_SLOT, _admin)
        }
    }

    // Restricts function to admin only
    modifier onlyAdmin() {
        require(msg.sender == getAdmin(), "Not admin");
        _;
    }

    // Retrieves logic contract address
    function getImplementation() public view returns (address impl) {
        assembly {
            impl := sload(IMPLEMENTATION_SLOT)
        }
    }

    // Retrieves admin address
    function getAdmin() public view returns (address admin) {
        assembly {
            admin := sload(ADMIN_SLOT)
        }
    }

    // Upgrades to a new logic contract (admin only)
    function upgrade(address _newLogic) external onlyAdmin {
        require(_newLogic != address(0), "Invalid logic address");
        assembly {
            sstore(IMPLEMENTATION_SLOT, _newLogic)
        }
    }

    // Delegates calls to the logic contract
    fallback() external payable {
        address impl = getImplementation();
        require(impl != address(0), "Implementation not set");
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), impl, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }

    // Allows proxy to receive ETH
    receive() external payable {}
}