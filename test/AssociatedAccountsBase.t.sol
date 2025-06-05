// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Test} from "forge-std/Test.sol";

import {console} from "forge-std/console.sol";

import {AssociatedAccountsLib} from "src/AssociatedAccountsLib.sol";

contract AssociatedAccountsBase is Test {
    using AssociatedAccountsLib for *;

    uint256 pkeyApprover = 0x0A;
    address approver = vm.addr(pkeyApprover);
    uint256 pkeyInitiator = 0x0B;
    address initiator = vm.addr(pkeyInitiator);

    bytes4 VALID_SIGNATURE = 0x1626ba7e;
    bytes4 INVALID_SIGNATURE = 0xffffffff;
    
    function setUp() public {}

    function test_AllowsTwoAccountsToAssociate() public view {
        /// STEP 1: the Initiator builds and signs an AAR, associating the initiator and approver addresses
        
        // 1.A/B: Build the AAR 
        AssociatedAccountsLib.AssociatedAccountRecord memory step1_aar = AssociatedAccountsLib.AssociatedAccountRecord({
            account: approver,
            data: ""
        });

        // 1.C: Sign the AAR
        bytes32 step1_hash = AssociatedAccountsLib.eip712Hash(step1_aar);
        (uint8 v1, bytes32 r1, bytes32 s1) = vm.sign(pkeyInitiator, step1_hash);

        // 1.D: Return an SAR
        bytes memory step1_signatureData = abi.encodePacked(r1, s1, v1);
        AssociatedAccountsLib.SignedAssociationRecord memory step1_sar = AssociatedAccountsLib.SignedAssociationRecord({
            signer: initiator, 
            record: step1_aar,
            signature: step1_signatureData
        });

        assertTrue(step1_sar.validateAssociatedAccount());

        /// STEP 2: The Approver builds and signs an AAR, accepting the signed payload from Step 1 as `data`.
        // 2.A: Build the AAR including the SAR from step 1 as the data payload. 
        AssociatedAccountsLib.AssociatedAccountRecord memory step2_aar = AssociatedAccountsLib.AssociatedAccountRecord({
            account: initiator,
            data: abi.encode(step1_sar)
        });

        // 2.B: Sign the AAR
        bytes32 step2_hash = AssociatedAccountsLib.eip712Hash(step2_aar);
        (uint8 v2, bytes32 r2, bytes32 s2) = vm.sign(pkeyApprover, step2_hash);

        // 2.C: Return the final SAR
        bytes memory step2_signatureData = abi.encodePacked(r2, s2, v2);
        AssociatedAccountsLib.SignedAssociationRecord memory step2_sar = AssociatedAccountsLib.SignedAssociationRecord({
            signer: approver,
            record: step2_aar,
            signature: step2_signatureData
        });

        assertTrue(step2_sar.validateAssociatedAccount());
    }

}