// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

interface AssociatedAccounts {
    /// @notice Represents an association between two accounts.
    struct AssociatedAccountRecord {
        /// @dev The CAIP-10 address of the initiating account.
        string initiator;
        /// @dev The CAIP-10 address of the approving account
        string approver;
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
    /// @param initiator The indexed CAIP10 address of the account that initiated the association.
    /// @param approver The indexed CAIP10 address of the account that accepted and completed the association.
    /// @param uuid The indexed uuid for the SignedAssociationRecord.
    /// @param sar The completed SignedAssociationRecord for the association between `initiator` and `approver`.
    event AssociationCreated(
        string indexed initiator, string indexed approver, bytes32 indexed uuid, SignedAssociationRecord sar
    );

    /// @notice Emitted when a previously active SignedAssociationRecord is revoked.
    ///
    /// @param revoker The indexed address of the account that revoked the association.
    /// @param uuid The indexed unique identifier for the association.
    event AssociatedRevoked(address indexed revoker, bytes32 indexed uuid);


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

    /// @notice Method for fetching uuid(s) of associations between two addresses.
    ///
    /// @param addr1 CAIP10 address of the first account. 
    /// @param addr2 CAIP10 address of the second account.
    ///
    /// @return areAssociated `true` if the accounts have at least one valid and active association, else `false`.
    /// @return uuids Array of uuids for each association between the two accounts.
    function fetchAssociatedAccounts(string memory addr1, string memory addr2) external returns (bool areAssociated, bytes32[] memory uuids);
}
