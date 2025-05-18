# Proxy Contract Implementation

## Overview

This repository contains a simplified implementation of the **EIP-1967** proxy standard for upgradeable smart contracts in Solidity. The goal is to demonstrate how proxy patterns enable contract upgradability while maintaining a consistent contract address and state.

## What is a Proxy Pattern?

A proxy pattern in Ethereum smart contracts separates the contract's logic from its storage:

- **Proxy Contract**: Stores the state and forwards calls to the implementation contract
- **Implementation Contract**: Contains the business logic that can be upgraded

This separation allows developers to upgrade a contract's functionality (fix bugs or add features) without changing the contract's address or losing its state.

## EIP-1967: Standard Proxy Storage Slots

[EIP-1967](https://eips.ethereum.org/EIPS/eip-1967) defines a standard for proxy contracts that focuses on:

1. **Standardized Storage Slots**: Uses specific storage slots for implementation addresses to avoid storage collisions
2. **Transparency**: Makes proxy patterns more transparent and interoperable
3. **Security**: Reduces the risk of storage conflicts between proxy and implementation contracts

### Key Storage Slots in EIP-1967

EIP-1967 defines specific storage slots for critical proxy information:

- **Implementation Address**: `0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc`
  - Calculated as `bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1)`

- **Admin Address**: `0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103`
  - Calculated as `bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1)`

- **Beacon Address** (for beacon proxies): `0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50`
  - Calculated as `bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)`

These slots are chosen to minimize the risk of collisions with the implementation contract's storage.

## How Proxy Patterns Work

### Delegation Mechanism

The proxy uses Solidity's `delegatecall` opcode to execute the implementation contract's code in the context of the proxy's storage:

1. User sends a transaction to the proxy contract
2. The proxy's fallback function uses `delegatecall` to forward the call to the implementation
3. The implementation's code executes using the proxy's storage
4. Results are returned to the user

### Upgrading the Implementation

To upgrade the contract:

1. Deploy a new implementation contract
2. Call the proxy's upgrade function to update the implementation address
3. All future calls to the proxy will use the new implementation's logic

## Implementation Details

This repository includes:

1. **Proxy.sol**: A simplified EIP-1967 proxy contract that:
   - Stores the implementation address in the EIP-1967 standard slot
   - Forwards calls to the implementation using `delegatecall`
   - Includes an upgrade mechanism controlled by an admin

2. **LogicV1.sol**: A basic implementation contract with:
   - A counter state variable
   - An initialize function to set the initial counter value
   - Functions to increment and get the counter value

3. **LogicV2.sol**: An upgraded implementation with:
   - All functionality from V1
   - Additional feature to decrement the counter

## Security Considerations

When using proxy patterns, be aware of these security concerns:

1. **Storage Collisions**: Implementation contracts must be careful not to use the same storage slots as the proxy
2. **Function Selector Clashes**: Proxy and implementation functions can clash if they have the same selector
3. **Initialization**: Implementation contracts should use initializer functions instead of constructors
4. **Access Control**: Only authorized addresses should be able to upgrade the implementation

## Usage

### Deployment

1. Deploy the implementation contract (LogicV1.sol)
2. Deploy the proxy contract (Proxy.sol), passing the implementation address and admin address
3. Interact with the proxy as if it were the implementation

### Upgrading

1. Deploy the new implementation (LogicV2.sol)
2. Call the proxy's upgrade function with the new implementation address
3. The proxy now uses the new implementation while preserving its state

## Development with Foundry

This project uses [Foundry](https://book.getfoundry.sh/) for development, testing, and deployment.

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Deploy

```shell
$ forge script script/DeployProxy.s.sol:DeployProxyScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

## References

- [EIP-1967: Standard Proxy Storage Slots](https://eips.ethereum.org/EIPS/eip-1967)
- [OpenZeppelin Upgrades Documentation](https://docs.openzeppelin.com/upgrades/2.3/)
- [Solidity Documentation](https://docs.soliditylang.org/en/v0.8.19/)
