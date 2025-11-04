// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface AssociatedAccounts {
    /// @notice Represents an association between two accounts.
    struct AssociatedAccountRecord {
        /// @dev The ERC-7930 binary representation of the iniating account's address.
        bytes initiator;
        /// @dev The ERC-7930 binary representation of the approving account's address.
        bytes approver;
        /// @dev Optional 4-byte selector for interfacing with the `data` field.
        bytes4 interfaceId;
        /// @dev Optional additional data.
        bytes data;
    }

    /// @notice Complete payload containing a finalized association.
    struct SignedAssociationRecord {
        /// @dev The timestamp from which the association is valid.
        uint120 validAt;
        /// @dev The timestamp the association was revoked.
        uint120 revokedAt;
        /// @dev The initiator curve specifier.
        bytes1 initiatorCurve;
        /// @dev The approver curve specifier.
        bytes1 approverCurve;
        /// @dev The signature of the initiator.
        bytes initiatorSignature;
        /// @dev The signature of the approver.
        bytes approverSignature;
        /// @dev The underlying AssociatedAccountRecord.
        AssociatedAccountRecord record;
    }

    /// @notice Emitted when a SignedAssociationRecord completes its approval process.
    ///
    /// @param uuid The indexed uuid for the SignedAssociationRecord matching the EIP-712 typed hash.
    /// @param initiator The keccak256 hash of the ERC-7930 address of the account that initiated the association.
    /// @param approver The keccak256 hash of ERC-7930 address of the account that accepted and completed the association.
    /// @param sar The completed SignedAssociationRecord for the association between `initiator` and `approver`.
    event AssociationCreated(
        bytes32 indexed uuid, bytes32 indexed initiator, bytes32 indexed approver, SignedAssociationRecord sar
    );

    /// @notice Emitted when a previously active SignedAssociationRecord is revoked.
    ///
    /// @param revoker The indexed unique identifier for the association.
    /// @param uuid The indexed keccak256 hash of the ERC-7930 address of the revoking account.
    event AssociationRevoked(bytes32 indexed uuid, bytes32 indexed revoker);

    /// @notice Store a new SignedAssociationRecord after validation.
    /// @param sar The SignedAssociationRecord to store.
    function storeAssociation(SignedAssociationRecord calldata sar) external;

    /// @notice Revoke an existing association.
    /// @param uuid The unique identifier of the association to revoke.
    /// @param revokedAt Optional timestamp for when the association should be considered revoked (0 for immediate).
    function revokeAssociation(bytes32 uuid, uint120 revokedAt) external;

    /// @notice Retrieve a stored association by uuid.
    /// @param uuid The unique identifier of the association.
    /// @return The SignedAssociationRecord corresponding to the uuid.
    function getAssociation(bytes32 uuid) external view returns (SignedAssociationRecord memory);
}
