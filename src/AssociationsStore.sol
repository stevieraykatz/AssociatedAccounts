// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AssociatedAccountsLib} from "./AssociatedAccountsLib.sol";
import {AssociatedAccounts} from "./AssociatedAccounts.sol";
import {InteroperableAddress} from "./InteroperableAddresses.sol";

/// @title AssociationsStore
/// @notice Proof of concept storage contract for Associations compliant with ERC-8092: Associated Accounts.
/// https://github.com/ethereum/ERCs/pull/1377/files
contract AssociationsStore is AssociatedAccounts {
    using AssociatedAccountsLib for *;

    /// @dev Mapping from association ID to SignedAssociationRecord
    mapping(bytes32 => SignedAssociationRecord) private associations;

    /// @dev Mapping from account hash to array of association IDs involving that account
    mapping(bytes32 => bytes32[]) private accountAssociations;

    /// @notice Error thrown when validation of a SignedAssociationRecord fails.
    error InvalidAssociation();

    /// @notice Error thrown when attempting to revoke an association that doesn't exist.
    error AssociationNotFound();

    /// @notice Error thrown when an association with the given identifier already exists.
    error AssociationAlreadyExists();

    /// @notice Error thrown when the caller is not authorized to revoke the association.
    error UnauthorizedRevocation();

    /// @notice Error thrown when attempting to revoke an already revoked association.
    error AssociationAlreadyRevoked();

    /// @notice Store a new SignedAssociationRecord after validation.
    /// @param sar The SignedAssociationRecord to store.
    function storeAssociation(SignedAssociationRecord calldata sar) external {
        bytes32 associationId = sar.associationIdFromSAR();

        if (associations[associationId].record.validAt != 0) revert AssociationAlreadyExists();
        if (!sar.validateAssociatedAccount()) revert InvalidAssociation();

        bytes32 initiatorHash = keccak256(sar.record.initiator);
        bytes32 approverHash = keccak256(sar.record.approver);

        associations[associationId] = sar;
        accountAssociations[initiatorHash].push(associationId);
        accountAssociations[approverHash].push(associationId);

        emit AssociationCreated(associationId, initiatorHash, approverHash, sar);
    }

    /// @notice Revoke an existing association.
    /// @param associationId The unique identifier of the association to revoke.
    /// @param revokedAt Optional timestamp for when the association should be considered revoked (0 for immediate).
    function revokeAssociation(bytes32 associationId, uint40 revokedAt) external {
        SignedAssociationRecord storage sar = associations[associationId];

        if (sar.record.validAt == 0) revert AssociationNotFound();
        if (sar.revokedAt != 0) revert AssociationAlreadyRevoked();

        // Format the msg.sender as an ERC-7930 address for comparison
        // @TODO: this won't work if the account is not native to this chain. Add support for other chains via relayed signed payloads.
        bytes memory senderInteroperable = InteroperableAddress.formatEvmV1(block.chainid, msg.sender);
        bytes32 senderHash = keccak256(senderInteroperable);
        bytes32 initiatorHash = keccak256(sar.record.initiator);
        bytes32 approverHash = keccak256(sar.record.approver);

        if (senderHash != initiatorHash && senderHash != approverHash) {
            revert UnauthorizedRevocation();
        }

        uint40 effectiveRevokedAt = revokedAt > block.timestamp ? revokedAt : uint40(block.timestamp);
        sar.revokedAt = effectiveRevokedAt;

        emit AssociationRevoked(associationId, senderHash, effectiveRevokedAt);
    }

    /// @notice Retrieve a stored association by its identifier.
    /// @param associationId The unique identifier of the association.
    /// @return The SignedAssociationRecord corresponding to the associationId.
    function getAssociation(bytes32 associationId) external view returns (SignedAssociationRecord memory) {
        SignedAssociationRecord memory sar = associations[associationId];
        if (sar.record.validAt == 0) {
            revert AssociationNotFound();
        }
        return sar;
    }

    /// @notice Get all association IDs for a given account.
    /// @param account The ERC-7930 formatted account address.
    /// @return An array of association IDs involving the account.
    function getAssociationIdsForAccount(bytes calldata account) external view returns (bytes32[] memory) {
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
        bytes32[] memory associationIds = accountAssociations[accountHash];
        SignedAssociationRecord[] memory sars = new SignedAssociationRecord[](associationIds.length);

        for (uint256 i = 0; i < associationIds.length; i++) {
            sars[i] = associations[associationIds[i]];
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
        bytes32[] memory associationIds = accountAssociations[accountHash];

        uint256 activeCount = 0;
        for (uint256 i = 0; i < associationIds.length; i++) {
            SignedAssociationRecord storage sar = associations[associationIds[i]];
            if (_isActive(sar)) {
                activeCount++;
            }
        }

        SignedAssociationRecord[] memory activeSars = new SignedAssociationRecord[](activeCount);
        uint256 index = 0;
        for (uint256 i = 0; i < associationIds.length; i++) {
            SignedAssociationRecord storage sar = associations[associationIds[i]];
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
        bytes32[] memory associationIds = accountAssociations[account1Hash];

        for (uint256 i = 0; i < associationIds.length; i++) {
            SignedAssociationRecord storage sar = associations[associationIds[i]];

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
        bytes32[] memory associationIds = accountAssociations[account1Hash];

        for (uint256 i = 0; i < associationIds.length; i++) {
            SignedAssociationRecord storage storedSar = associations[associationIds[i]];

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
        return sar.record.validAt > 0 && sar.record.validAt <= block.timestamp
            && (sar.record.validUntil == 0 || sar.record.validUntil > block.timestamp)
            && (sar.revokedAt == 0 || sar.revokedAt > block.timestamp);
    }
}
