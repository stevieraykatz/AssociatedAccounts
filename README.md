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
| **Proxy** | `0x6f4D643BD9332d9Aa3a828576e3a64ccc58D2684` | [View on Sepolia BaseScan](https://sepolia.basescan.org/address/0x6f4D643BD9332d9Aa3a828576e3a64ccc58D2684) |
| Implementation | `0x868C5e78c6bB86E3794d8c5beBf27941644722B7` | [View on Sepolia BaseScan](https://sepolia.basescan.org/address/0x868C5e78c6bB86E3794d8c5beBf27941644722B7) |
| ProxyAdmin | `0x5650Ccf0B216826B5bCeCc9033691Ad515B1f5ad` | [View on Sepolia BaseScan](https://sepolia.basescan.org/address/0x5650Ccf0B216826B5bCeCc9033691Ad515B1f5ad) |

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
