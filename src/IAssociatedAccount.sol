// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

interface AssociatedAccounts {
    /// @notice Represents an association between two accounts.
    struct AssociatedAccountRecord {
        /// @dev The CAIP-10 address of the initiating account.
        bytes initiator;
        /// @dev The CAIP-10 address of the approving account
        bytes approver;
        /// @dev Optional 4-byte selector for interfacing with the `data` field.
        bytes4 interfaceId;
        /// @dev Optional additional data.
        bytes data;
    }

    /// @notice Helper struct for sharing a signed association.
    struct SignedAssociationRecord {
        /// @dev The timestamp the association was originated.
        uint128 originatedAt;
        /// @dev The timestamp the association was revoked, `0` if active.
        uint128 revokedAt;
        /// @dev The signature of the initiator.
        bytes initiatorSignature;
        /// @dev The signature of the approver.
        bytes approverSignature;
        /// @dev The signed AssociatedAccountRecord.
        AssociatedAccountRecord record;
    }

    /// @notice Emitted when a SignedAssociationRecord completes its approval process.
    ///
    /// @param initiator The indexed address of the account that initiated the association.
    /// @param approver The indexed address of the account that accepted and completed the association.
    /// @param uuid The indexed uuid for the SignedAssociationRecord.
    /// @param sar The completed SignedAssociationRecord for the association between `initiator` and `approver`.
    event AssociationCreated(
        address indexed initiator, address indexed approver, bytes32 indexed uuid, SignedAssociationRecord sar
    );

    /// @notice Emitted when a previously active SignedAssociationRecord is revoked.
    ///
    /// @param revoker The indexed address of the account that revoked the association.
    /// @param uuid The indexed unique identifier for the association.
    event AssociationCreated(address indexed revoker, bytes32 indexed uuid);

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
    function storeAssociation(SignedAssociationRecord calldata sar) external;

    /// @notice Method for either parties in an association to revoke the association.
    ///
    /// @dev `uuid` == eip712Hash(`sar.record`)
    ///     The caller MUST be either `sar.record.initiator` or `sar.record.approver`.
    ///
    /// @param uuid The uuid signifying a unique SignedAssociationRecord.
    /// @param revokedAt The timestamp that the association should be revoked.
    function revokeAssociation(bytes32 uuid, uint256 revokedAt) external;
}
