// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Test} from "forge-std/Test.sol";

import {console} from "forge-std/console.sol";

import {AssociatedAccountsLib} from "src/AssociatedAccountsLib.sol";

contract AssociatedAccountsFlow is Test {
    using AssociatedAccountsLib for *;

    uint256 pkeyApprover = 0x0A;
    address approver = vm.addr(pkeyApprover);
    uint256 pkeyInitiator = 0x0B;
    address initiator = vm.addr(pkeyInitiator);

    bytes4 VALID_SIGNATURE = 0x1626ba7e;
    bytes4 INVALID_SIGNATURE = 0xffffffff;

    function test_AllowsTwoAccountsToAssociate() public {
        /// ORIGINATION
        /// STEP 1: the Initiator builds and signs an AAR, associating the initiator and approver addresses
        // 1.A/B: Build the AAR
        AssociatedAccountsLib.AssociatedAccountRecord memory aar =
            AssociatedAccountsLib.AssociatedAccountRecord({initiator: initiator, approver: approver, data: ""});

        // 1.C: Sign the AAR
        bytes32 aarHash = aar.eip712Hash();
        (uint8 v1, bytes32 r1, bytes32 s1) = vm.sign(pkeyInitiator, aarHash);

        // 1.D: Return the partial SAR
        bytes memory initiatorSignature = abi.encodePacked(r1, s1, v1);
        AssociatedAccountsLib.SignedAssociationRecord memory step1_sar = AssociatedAccountsLib.SignedAssociationRecord({
            initiatorSignature: initiatorSignature,
            approverSignature: "",
            record: aar
        });

        /// STEP 2: The Approver signs the AAR.
        // 2.A: Approver signs the AAR.
        (uint8 v2, bytes32 r2, bytes32 s2) = vm.sign(pkeyApprover, aarHash);

        // 2.C: Return the finalized SAR
        bytes memory approverSignature = abi.encodePacked(r2, s2, v2);
        AssociatedAccountsLib.SignedAssociationRecord memory step2_sar = step1_sar;
        step2_sar.approverSignature = approverSignature;

        /// STEP 3: Emit the specified event with the final SAR and associated accounts.
        emit AssociatedAccountsLib.AssociationCreated(initiator, approver, step2_sar);

        /// CONSUMPTION
        // STEP 1: validate that the signature is valid for both the Initiator and the Approver
        assertTrue(step2_sar.validateAssociatedAccount());
    }
}
