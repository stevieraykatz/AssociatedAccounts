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
        uint128 validAt;
        /// @dev The timestamp the association was revoked.
        uint128 revokedAt;
        /// @dev The signature of the initiator.
        bytes initiatorSignature;
        /// @dev The initiator curve specifier.
        Curve initiatorCurve;
        /// @dev The signature of the approver.
        bytes approverSignature;
        /// @dev The approver curve specifier.
        Curve approverCurve;
        /// @dev The underlying AssociatedAccountRecord.
        AssociatedAccountRecord record;
    }

    /// @notice Emitted when a SignedAssociationRecord completes its approval process.
    ///
    /// @param uuid The indexed uuid for the SignedAssociationRecord.
    /// @param initiator The ERC-7930 address of the account that initiated the association.
    /// @param approver The ERC-7930 address of the account that accepted and completed the association.
    /// @param sar The completed SignedAssociationRecord for the association between `initiator` and `approver`.
    event AssociationCreated(
        bytes32 indexed uuid, bytes initiator, bytes approver, SignedAssociationRecord sar
    );

    /// @notice Emitted when a previously active SignedAssociationRecord is revoked.
    ///
    /// @param revoker The indexed unique identifier for the association.
    /// @param uuid The ERC-7930 address of the revoking account.
    event AssociatedRevoked(bytes32 indexed uuid, bytes revoker);


    /// @notice Method for storing a completed SignedAssociationRecord.
    ///
    /// @dev The signed association record must meet the following validation criteria upon storage:
    ///     1. `sar.originatedAt` <= block.timestamp
    ///     2. `sar.revokedAt` == 0 || `sar.revokedAt` < block.timestamp
    ///     3. `sar.initiatorSignature` passes signature validation using `sar.initiatorCurve` recovery.
    ///     4. `sar.approverSignature` passes signature validation using `sar.approverCurve` recovery.
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
    /// @dev Addresses must be sorted according to {EIP-XXXX: Address Sorting}
    /// 
    /// @param addr1 ERC-7930 address of the first account. 
    /// @param addr2 ERC-7930 address of the second account.
    ///
    /// @return areAssociated `true` if the accounts have at least one valid and active association, else `false`.
    /// @return uuids Array of uuids for each association between the two accounts.
    function fetchAssociatedAccounts(string memory addr1, string memory addr2) external returns (bool areAssociated, bytes32[] memory uuids);
}
