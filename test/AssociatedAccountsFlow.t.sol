// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

import {AssociatedAccountsLib} from "src/AssociatedAccountsLib.sol";
import {AssociatedAccounts} from "src/AssociatedAccounts.sol";

import {InteroperableAddress} from "src/InteroperableAddresses.sol";
import {K1} from "src/Curves.sol";

contract AssociatedAccountsFlow is Test {
    using AssociatedAccountsLib for *;

    uint256 pkeyApprover = 0x0A;
    address approverAddr = vm.addr(pkeyApprover);
    uint256 pkeyInitiator = 0x0B;
    address initiatorAddr = vm.addr(pkeyInitiator);

    function test_AllowsTwoAccountsToAssociate() public {
        bytes memory initiator = InteroperableAddress.formatEvmV1(initiatorAddr);
        bytes memory approver = InteroperableAddress.formatEvmV1(approverAddr);

        /// ORIGINATION
        /// The Initiator builds and signs an AAR, associating the initiator and approver addresses
        // Message Creation
        AssociatedAccounts.AssociatedAccountRecord memory aar =
            AssociatedAccounts.AssociatedAccountRecord({initiator: initiator, approver: approver, interfaceId: bytes4(0), data: ""});

        // Signing
        bytes32 aarHash = aar.eip712Hash();
        (uint8 v1, bytes32 r1, bytes32 s1) = vm.sign(pkeyInitiator, aarHash);

        // Output
        bytes memory initiatorSignature = abi.encodePacked(r1, s1, v1);
        AssociatedAccounts.SignedAssociationRecord memory step1_sar = AssociatedAccounts.SignedAssociationRecord({
            validAt: 0,
            revokedAt: 0,
            initiatorCurve: K1,
            approverCurve: 0,
            initiatorSignature: initiatorSignature,
            approverSignature: "",
            record: aar
        });

        /// APPROVAL
        /// The Approver signs the AAR.
        // Signing
        (uint8 v2, bytes32 r2, bytes32 s2) = vm.sign(pkeyApprover, aarHash);

        // Output
        bytes memory approverSignature = abi.encodePacked(r2, s2, v2);
        AssociatedAccounts.SignedAssociationRecord memory step2_sar = step1_sar;
        step2_sar.approverSignature = approverSignature;
        step2_sar.approverCurve = K1;
        step2_sar.validAt = uint120(block.timestamp);

        /// CONSUMPTION
        // Validation
        assertTrue(AssociatedAccountsLib.validateAssociatedAccount(step2_sar));
    }
}
