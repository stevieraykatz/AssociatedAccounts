// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface AssociatedAccounts {
    /// @notice Represents an association between two accounts.
    struct AssociatedAccountRecord {
        /// @dev The ERC-7930 binary representation of the initiating account's address.
        bytes initiator;
        /// @dev The ERC-7930 binary representation of the approving account's address.
        bytes approver;
        /// @dev The timestamp from which the association is valid.
        uint40 validAt;
        /// @dev The timestamp when the association expires.
        uint40 validUntil;
        /// @dev Optional 4-byte selector for interfacing with the `data` field.
        bytes4 interfaceId;
        /// @dev Optional additional data.
        bytes data;
    }

    /// @notice Complete payload containing a finalized association.
    struct SignedAssociationRecord {
        /// @dev The timestamp the association was revoked.
        uint40 revokedAt;
        /// @dev The initiator key type specifier.
        bytes2 initiatorKeyType;
        /// @dev The approver key type specifier.
        bytes2 approverKeyType;
        /// @dev The signature of the initiator.
        bytes initiatorSignature;
        /// @dev The signature of the approver.
        bytes approverSignature;
        /// @dev The underlying AssociatedAccountRecord.
        AssociatedAccountRecord record;
    }

    /// @notice Emitted when a SignedAssociationRecord completes its approval process.
    ///
    /// @param hash The indexed hash for the SignedAssociationRecord matching the EIP-712 typed hash.
    /// @param initiator The keccak256 hash of the ERC-7930 address of the account that initiated the association.
    /// @param approver The keccak256 hash of ERC-7930 address of the account that accepted and completed the association.
    /// @param sar The completed SignedAssociationRecord for the association between `initiator` and `approver`.
    event AssociationCreated(
        bytes32 indexed hash, bytes32 indexed initiator, bytes32 indexed approver, SignedAssociationRecord sar
    );

    /// @notice Emitted when a previously active SignedAssociationRecord is revoked.
    ///
    /// @param hash The indexed unique identifier for the association.
    /// @param revokedBy The indexed keccak256 hash of the ERC-7930 address of the revoking account.
    /// @param revokedAt The timestamp at which the association is revoked.
    event AssociationRevoked(bytes32 indexed hash, bytes32 indexed revokedBy, uint256 revokedAt);

    /// @notice Store a new SignedAssociationRecord after validation.
    /// @param sar The SignedAssociationRecord to store.
    function storeAssociation(SignedAssociationRecord calldata sar) external;

    /// @notice Revoke an existing association.
    /// @param associationId The unique identifier of the association to revoke.
    /// @param revokedAt Optional timestamp for when the association should be considered revoked (0 for immediate).
    function revokeAssociation(bytes32 associationId, uint40 revokedAt) external;

    /// @notice Retrieve a stored association by its identifier.
    /// @param associationId The unique identifier of the association.
    /// @return The SignedAssociationRecord corresponding to the associationId.
    function getAssociation(bytes32 associationId) external view returns (SignedAssociationRecord memory);
}
