// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AssociatedAccountsLib} from "./AssociatedAccountsLib.sol";
import {AssociatedAccounts} from "./AssociatedAccounts.sol";
import {InteroperableAddress} from "./InteroperableAddresses.sol";

/// @title AssociationsStore
/// @notice Proof of concept storage contract for Associations compliant with the Associated Accounts specification.
contract AssociationsStore is AssociatedAccounts {
    using AssociatedAccountsLib for *;

    /// @dev Mapping from association uuid to SignedAssociationRecord
    mapping(bytes32 => SignedAssociationRecord) private associations;

    /// @dev Mapping from account hash to array of association uuids involving that account
    mapping(bytes32 => bytes32[]) private accountAssociations;

    /// @notice Error thrown when validation of a SignedAssociationRecord fails.
    error InvalidAssociation();

    /// @notice Error thrown when attempting to revoke an association that doesn't exist.
    error AssociationNotFound();

    /// @notice Error thrown when an association with the given uuid already exists.
    error AssociationAlreadyExists();

    /// @notice Error thrown when the caller is not authorized to revoke the association.
    error UnauthorizedRevocation();

    /// @notice Error thrown when attempting to revoke an already revoked association.
    error AssociationAlreadyRevoked();

    /// @notice Store a new SignedAssociationRecord after validation.
    /// @param sar The SignedAssociationRecord to store.
    function storeAssociation(SignedAssociationRecord calldata sar) external {
        bytes32 uuid = sar.uuidFromSAR();

        if (associations[uuid].validAt != 0) revert AssociationAlreadyExists();
        if (!sar.validateAssociatedAccount()) revert InvalidAssociation();

        bytes32 initiatorHash = keccak256(sar.record.initiator);
        bytes32 approverHash = keccak256(sar.record.approver);

        associations[uuid] = sar;
        accountAssociations[initiatorHash].push(uuid);
        accountAssociations[approverHash].push(uuid);

        emit AssociationCreated(uuid, initiatorHash, approverHash, sar);
    }

    /// @notice Revoke an existing association.
    /// @param uuid The unique identifier of the association to revoke.
    /// @param revokedAt Optional timestamp for when the association should be considered revoked (0 for immediate).
    function revokeAssociation(bytes32 uuid, uint120 revokedAt) external {
        SignedAssociationRecord storage sar = associations[uuid];

        if (sar.validAt == 0) revert AssociationNotFound();
        if (sar.revokedAt != 0) revert AssociationAlreadyRevoked();

        // Format the msg.sender as an ERC-7930 address for comparison
        // @TODO: this won't work if the account is not native to this chain. consider how we can use signatures
        // to relay revocations.
        bytes memory senderInteroperable = InteroperableAddress.formatEvmV1(block.chainid, msg.sender);
        bytes32 senderHash = keccak256(senderInteroperable);
        bytes32 initiatorHash = keccak256(sar.record.initiator);
        bytes32 approverHash = keccak256(sar.record.approver);

        if (senderHash != initiatorHash && senderHash != approverHash) {
            revert UnauthorizedRevocation();
        }

        uint120 effectiveRevokedAt = revokedAt > block.timestamp ? revokedAt : uint120(block.timestamp);
        sar.revokedAt = effectiveRevokedAt;

        emit AssociationRevoked(uuid, senderHash);
    }

    /// @notice Retrieve a stored association by uuid.
    /// @param uuid The unique identifier of the association.
    /// @return The SignedAssociationRecord corresponding to the uuid.
    function getAssociation(bytes32 uuid) external view returns (SignedAssociationRecord memory) {
        SignedAssociationRecord memory sar = associations[uuid];
        if (sar.validAt == 0) {
            revert AssociationNotFound();
        }
        return sar;
    }

    /// @notice Get all association uuids for a given account.
    /// @param account The ERC-7930 formatted account address.
    /// @return An array of association uuids involving the account.
    function getAssociationUuidsForAccount(bytes calldata account) external view returns (bytes32[] memory) {
        bytes32 accountHash = keccak256(account);
        return accountAssociations[accountHash];
    }

    /// @notice Get all associations for a given account.
    /// @param account The ERC-7930 formatted account address.
    /// @return An array of SignedAssociationRecords involving the account.
    function getAssociationsForAccount(bytes calldata account)
        external
        view
        returns (SignedAssociationRecord[] memory)
    {
        bytes32 accountHash = keccak256(account);
        bytes32[] memory uuids = accountAssociations[accountHash];
        SignedAssociationRecord[] memory sars = new SignedAssociationRecord[](uuids.length);

        for (uint256 i = 0; i < uuids.length; i++) {
            sars[i] = associations[uuids[i]];
        }

        return sars;
    }

    /// @notice Get all active (non-revoked and currently valid) associations for a given account.
    /// @param account The ERC-7930 formatted account address.
    /// @return An array of active SignedAssociationRecords involving the account.
    function getActiveAssociationsForAccount(bytes calldata account)
        external
        view
        returns (SignedAssociationRecord[] memory)
    {
        bytes32 accountHash = keccak256(account);
        bytes32[] memory uuids = accountAssociations[accountHash];

        uint256 activeCount = 0;
        for (uint256 i = 0; i < uuids.length; i++) {
            SignedAssociationRecord storage sar = associations[uuids[i]];
            if (_isActive(sar)) {
                activeCount++;
            }
        }

        SignedAssociationRecord[] memory activeSars = new SignedAssociationRecord[](activeCount);
        uint256 index = 0;
        for (uint256 i = 0; i < uuids.length; i++) {
            SignedAssociationRecord storage sar = associations[uuids[i]];
            if (_isActive(sar)) {
                activeSars[index] = sar;
                index++;
            }
        }

        return activeSars;
    }

    /// @notice Check if two accounts have an active association.
    /// @param account1 The first ERC-7930 formatted account address.
    /// @param account2 The second ERC-7930 formatted account address.
    /// @return True if there is an active association between the accounts, false otherwise.
    function areAccountsAssociated(bytes calldata account1, bytes calldata account2) external view returns (bool) {
        bytes32 account1Hash = keccak256(account1);
        bytes32 account2Hash = keccak256(account2);
        bytes32[] memory uuids = accountAssociations[account1Hash];

        for (uint256 i = 0; i < uuids.length; i++) {
            SignedAssociationRecord storage sar = associations[uuids[i]];

            // Check if this association involves account2
            bytes32 initiatorHash = keccak256(sar.record.initiator);
            bytes32 approverHash = keccak256(sar.record.approver);

            bool involvesAccount2 = (initiatorHash == account2Hash) || (approverHash == account2Hash);

            if (involvesAccount2 && _isActive(sar)) {
                return true;
            }
        }

        return false;
    }

    /// @notice Get the association between two specific accounts (if it exists).
    /// @param account1 The first ERC-7930 formatted account address.
    /// @param account2 The second ERC-7930 formatted account address.
    /// @return exists True if an association exists between the accounts.
    /// @return sar The SignedAssociationRecord between the accounts (empty if not found).
    function getAssociationBetweenAccounts(bytes calldata account1, bytes calldata account2)
        external
        view
        returns (bool exists, SignedAssociationRecord memory sar)
    {
        bytes32 account1Hash = keccak256(account1);
        bytes32 account2Hash = keccak256(account2);
        bytes32[] memory uuids = accountAssociations[account1Hash];

        for (uint256 i = 0; i < uuids.length; i++) {
            SignedAssociationRecord storage storedSar = associations[uuids[i]];

            // Check if this association involves account2
            bytes32 initiatorHash = keccak256(storedSar.record.initiator);
            bytes32 approverHash = keccak256(storedSar.record.approver);

            bool involvesAccount2 = (initiatorHash == account2Hash) || (approverHash == account2Hash);

            if (involvesAccount2) {
                return (true, storedSar);
            }
        }

        return (false, sar);
    }

    /// @notice Helper function to check if an association is currently active.
    /// @param sar The SignedAssociationRecord to check.
    /// @return True if the association is active, false otherwise.
    function _isActive(SignedAssociationRecord storage sar) private view returns (bool) {
        return
            sar.validAt > 0 && sar.validAt <= block.timestamp && (sar.revokedAt == 0 || sar.revokedAt > block.timestamp);
    }
}
