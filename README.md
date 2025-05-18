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

### How EIP-1967 Prevents Storage Collisions

In Solidity, storage slots are assigned sequentially starting from slot 0 for state variables. This creates a risk of collision between proxy and implementation contracts if they use the same slots for different purposes.

EIP-1967 solves this by:

1. Using cryptographically secure, random-looking slots derived from a namespaced hash
2. Subtracting 1 from the hash to further reduce collision probability
3. Ensuring these slots are extremely unlikely to be used by normal contract variables

For example, the implementation address is stored at a slot derived from `keccak256('eip1967.proxy.implementation')` minus 1, which produces a value that's practically impossible to collide with normal variable storage.

### Visual Representation of Proxy Pattern

```
User ──► Proxy Contract ─┬─► Implementation V1
                         │    (can be upgraded)
                         │
                         └─► Storage
                              (remains unchanged)
```

After upgrade:

```
User ──► Proxy Contract ─┬─X Implementation V1
                         │    (no longer used)
                         │
                         ├─► Implementation V2
                         │    (new logic)
                         │
                         └─► Storage
                              (preserved)
```

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

## Comparison with Other Proxy Patterns

There are several proxy patterns in Ethereum, each with its own advantages and trade-offs:

### 1. Transparent Proxy Pattern

**Key Differences from EIP-1967:**
- Uses a different approach to avoid function selector clashes
- Admin-specific logic is in the proxy itself, not in a separate contract
- Less gas efficient for regular users due to additional checks

### 2. UUPS (Universal Upgradeable Proxy Standard - EIP-1822)

**Key Differences from EIP-1967:**
- Upgrade logic is in the implementation contract, not the proxy
- More gas efficient for users
- Requires each implementation to include upgrade logic
- Cannot be "bricked" by deploying an implementation without upgrade code

### 3. Diamond Pattern (EIP-2535)

**Key Differences from EIP-1967:**
- Allows multiple implementation contracts (facets) simultaneously
- More complex but more flexible
- Better suited for large contracts that need to be split up

### Why Choose EIP-1967?

EIP-1967 is often preferred because:
- It's simpler to understand and implement than Diamond
- It's more standardized and widely adopted than custom proxy patterns
- It's more gas efficient than Transparent Proxies
- It separates admin logic from implementation logic, unlike UUPS

## Security Considerations

When using proxy patterns, be aware of these security concerns:

1. **Storage Collisions**: Implementation contracts must be careful not to use the same storage slots as the proxy
   - EIP-1967 mitigates this by using specific storage slots derived from hashes
   - Always maintain the same storage layout in upgraded implementations

2. **Function Selector Clashes**: Proxy and implementation functions can clash if they have the same selector
   - This happens when a function in the implementation has the same 4-byte signature as a proxy function
   - Can lead to proxy admin functions being inaccessible

3. **Initialization**: Implementation contracts should use initializer functions instead of constructors
   - Constructors are executed only when the implementation is deployed, not when used through a proxy
   - Always use a one-time initialization pattern with a guard against re-initialization

4. **Access Control**: Only authorized addresses should be able to upgrade the implementation
   - A compromised admin key can lead to malicious upgrades
   - Consider using multi-signature wallets or timelocks for admin functions

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
$ forge script script/DeployProxy.s.sol:DeployProxyScript --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
```

#### Deployment Example

```
LogicV1 deployed at: 0x350AECDbcaA3557bda602786b0D831655A53ec1D
Proxy deployed at: 0x844d5b937883bae08cA7CaA99Bc66258cBD2fC56
```

### Upgrade

```shell
$ forge script script/DeployProxy.s.sol:UpgradeProxyScript --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
```

## References

- [EIP-1967: Standard Proxy Storage Slots](https://eips.ethereum.org/EIPS/eip-1967)
- [OpenZeppelin Upgrades Documentation](https://docs.openzeppelin.com/upgrades/2.3/)
- [Solidity Documentation](https://docs.soliditylang.org/en/v0.8.19/)
- [ConsenSys Best Practices for Smart Contract Systems](https://consensys.github.io/smart-contract-best-practices/)
