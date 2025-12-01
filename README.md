## Associated Accounts

This specification defines a standard for establishing and verifying associations between accounts. This allows addresses to publicly declare and prove a relationship with other addresses, enabling use cases like sub-account identity inheritance, authorization delegation, and reputation collation. 

This repo implements:

- **`AssociatedAccounts`** - The core interface defining the structs (`AssociatedAccountRecord` and `SignedAssociationRecord`), events, and storage functions for the ERC-8092 standard
- **`AssociatedAccountsLib`** - A helper library providing validation, EIP-712 hashing, and signature verification utilities for Associated Account records
- **`AssociationsStore`** - A reference implementation of an onchain storage contract for managing associations with features like account lookup, active association filtering, and revocation 

## Deployments

The Associations Store has been deployed to Base Sepolia behind a Transparent Upgradeable Proxy. This instance of the store has been deployed behind a proxy so that small changes in the spec can be reflected in the implementation without needing to redeploy.

| Contract | Address | Link |
|----------|---------|------|
| **Proxy** | `0xF7d1961962F22236fC30e6295Fa1AD0Df9Fa300D` | [View on BaseScan](https://sepolia.basescan.org/address/0xF7d1961962F22236fC30e6295Fa1AD0Df9Fa300D) |
| Implementation | `0x90C156F48BE396416A7F3B044B366Cf612f129c6` | [View on BaseScan](https://sepolia.basescan.org/address/0x90C156F48BE396416A7F3B044B366Cf612f129c6) |
| ProxyAdmin | `0x447c92D63aA37687D01addcf23C33Fc8d3FaD114` | [View on BaseScan](https://sepolia.basescan.org/address/0x447c92D63aA37687D01addcf23C33Fc8d3FaD114) |

> **Note:** Always interact with the Proxy address. The implementation contract contains the logic, but the proxy maintains the state and is upgradeable. 


## Documentation

The ERC draft can be found in this PR (will update to canonical link once merged):
https://github.com/ethereum/ERCs/pull/1377/files

## Installation

### As a Foundry dependency

```shell
forge install stevieraykatz/AssociatedAccounts
```

## Development

### Build

```shell
forge build
```

### Test

```shell
forge test
```

### Format

```shell
forge fmt
```
