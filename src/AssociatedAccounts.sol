// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;


import {AssociatedAccountsLib, SignedAssociationRecord, AssociatedAccountRecord} from "./AssociatedAccountsLib.sol";

contract AssociatedAccounts {
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
        if(!sar.validateAssociatedAccount()) revert InvalidAssociation();
        _;
    }

    function storeAssociation(SignedAssociationRecord memory sar) onlyValid(sar) external returns (bytes32 uuid) {
        uuid = sar.uuidFromSAR();
        associations[uuid] = sar;
    }

}