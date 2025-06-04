// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Test} from "forge-std/Test.sol";

import {AssociatedAccountsLib} from "src/AssociatedAccountsLib.sol";

contract AssociatedAccountsBase is Test {

    uint256 pkeyA = 0x0A;
    address A = vm.addr(pkeyA);
    uint256 pkeyB = 0x0B;
    address B = vm.addr(pkeyB);

    bytes4 VALID_SIGNATURE = 0x1626ba7e;
    bytes4 INVALID_SIGNATURE = 0xffffffff;
    
    function setUp() public {}

    function test_AllowsAnAccountToCreateAnSAR() public view {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pkeyB, AssociatedAccountsLib.eip712Hash(_getDefaultRecord()));
        bytes memory signatureData = abi.encodePacked(v, r, s);

        AssociatedAccountsLib.SignedAssociationRecord memory sar = AssociatedAccountsLib.SignedAssociationRecord({
            signer: B, 
            record: _getDefaultRecord(),
            signature: signatureData
        });

        assertEq(AssociatedAccountsLib.validateAssociatedAccount(sar), VALID_SIGNATURE);
    }

    function _getDefaultRecord() internal view returns (AssociatedAccountsLib.AssociatedAccountRecord memory) {
        return AssociatedAccountsLib.AssociatedAccountRecord({
            account: A,
            data: ""
        });
    }
}