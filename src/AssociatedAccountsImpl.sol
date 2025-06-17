// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {AssociatedAccountsLib} from "./AssociatedAccountsLib.sol";
import {AssociatedAccounts} from "./AssociatedAccounts.sol";

contract AssociatedAccountsImpl is AssociatedAccounts {
    using AssociatedAccountsLib for SignedAssociationRecord;
    using AssociatedAccountsLib for AssociatedAccountRecord;

    mapping(bytes32 associationId => SignedAssociationRecord record) public associations;

    event AssociationInitiated(address indexed initiator, address indexed approver, SignedAssociationRecord sar);

    /// @notice Emitted when a SignedAssociationRecord completes its approval process.
    ///
    /// @param initiator The indexed address of the account that initiated the association.
    /// @param approver The indexed address of the account that accepted and completed the association.
    /// @param sar The completed SignedAssociationRecord for the association between `initiator` and `approver`.
    event AssociationApproved(address indexed initiator, address indexed approver, SignedAssociationRecord sar);

    error InvalidAssociation();
    error InvalidRevocation();

    modifier onlyValid(SignedAssociationRecord memory sar) {
        if (!sar.validateAssociatedAccount()) revert InvalidAssociation();
        _;
    }

    /// @notice Method for storing a completed SignedAssociationRecord.
    ///
    /// @dev The signed association record must meet the following validation criteria upon storage:
    ///     1. `sar.originatedAt` <= block.timestamp
    ///     2. `sar.revokedAt` == 0 || `sar.revokedAt` < block.timestamp
    ///     3. `sar.initiatorSignature` passes ECDSA or EIP-1271 signature validation.
    ///     4. `sar.approverSignature` passes ECDSA or EIP-1271 signature validation.
    ///
    ///     Upon successful validation, the method must emit the `AssociationCreated` event.
    ///
    /// @param sar The SignedAssociationRecord.
    function storeAssociation(SignedAssociationRecord calldata sar) external override {
        bytes32 uuid = sar.uuidFromSAR();
        associations[uuid] = sar;
    }

    /// @notice Method for either parties in an association to revoke the association.
    ///
    /// @dev `uuid` == eip712Hash(`sar.record`)
    ///     The caller MUST be either `sar.record.initiator` or `sar.record.approver`.
    ///
    /// @param uuid The uuid signifying a unique SignedAssociationRecord.
    /// @param revokedAt The timestamp that the association should be revoked.
    function revokeAssociation(bytes32 uuid, uint256 revokedAt) external {}


    /// @notice Method for fetching uuid(s) of associations between two addresses.
    ///
    /// @param addr1 CAIP10 address of the first account. 
    /// @param addr2 CAIP10 address of the second account.
    ///
    /// @return areAssociated `true` if the accounts have at least one valid and active association, else `false`.
    /// @return uuids Array of uuids for each association between the two accounts.
    function fetchAssociatedAccounts(string memory addr1, string memory addr2) external returns (bool areAssociated, bytes32[] memory uuids) {}

}
