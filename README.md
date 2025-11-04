## Associated Accounts

This specification defines a standard for establishing and verifying associations between accounts. This allows addresses to publicly declare and prove a relationship with other addresses, enabling use cases like sub-account identity inheritance, authorization delegation, and reputation collation. 

## Documentation

https://hackmd.io/@RBb7iKFvTf2nLSFcIpFp6A/B1HFQNYCge

## Installation

### As a Foundry dependency

```shell
forge install AssociatedAccounts=YourOrg/AssociatedAccounts
```

### As an npm package

```shell
npm install associated-accounts
# or
yarn add associated-accounts
# or
pnpm add associated-accounts
```

## Usage

### Solidity

```solidity
import {AssociatedAccounts} from "associated-accounts/src/AssociatedAccounts.sol";
import {AssociationsStore} from "associated-accounts/src/AssociationsStore.sol";
```

### TypeScript

Import ABIs directly from the compiled artifacts:

```typescript
import { getContract } from 'viem';
import AssociationsStoreArtifact from 'associated-accounts/out/AssociationsStore.sol/AssociationsStore.json' assert { type: 'json' };

const contract = getContract({
  address: '0x...',
  abi: AssociationsStoreArtifact.abi,
  client: publicClient,
});
```

Or use the pre-exported ABIs:

```typescript
import { associationsStoreAbi } from 'associated-accounts/abis';
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
