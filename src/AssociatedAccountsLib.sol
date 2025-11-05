// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {AssociatedAccounts} from "./AssociatedAccounts.sol";
import {K1, R1, EDDSA, BLS, WEBAUTHN} from "./Curves.sol";
import {InteroperableAddress} from "./InteroperableAddresses.sol";
import {InteroperableAddressSort} from "./InteroperableAddressSort.sol";
import {SignatureChecker} from "lib/openzeppelin-contracts/contracts/utils/cryptography/SignatureChecker.sol";

import {console} from "forge-std/console.sol";

/// @notice Helper Lib for creating, signing and validating AssociatedAccount records and the resulting
///     SignedAssociationRecords.
library AssociatedAccountsLib {
    error UnsupportedCurve(bytes1 curve);
    error UnsupportedChainType(bytes2 chainType);

    /// @dev Precomputed `typeHash` used to produce EIP-712 compliant hash.
    ///      The original hash must be:
    ///         - An EIP-712 hash: keccak256("\x19\x01" || someDomainSeparator || hashStruct(someStruct))
    bytes32 private constant _MESSAGE_TYPEHASH =
        keccak256("AssociatedAccountRecord(bytes initiator, bytes approver, bytes4 interfaceId, bytes data)");

    /// @notice Helper for validating the contents of a SignedAssociationRecord.
    function validateAssociatedAccount(AssociatedAccounts.SignedAssociationRecord calldata sar)
        external
        view
        returns (bool)
    {
        bytes32 hash = eip712Hash(sar.record);
        // console.logBytes32(hash);
        // console.log("validAt", sar.validAt);
        // console.log("revokedAt", sar.revokedAt);
        // console.logBytes1(sar.initiatorCurve);
        // console.logBytes(sar.initiatorSignature);
        // console.logBytes1(sar.approverCurve);
        // console.logBytes(sar.approverSignature);
        // console.logBytes(abi.encode(sar.record));
        return sar.validAt <= block.timestamp && (sar.revokedAt == 0 || (sar.revokedAt > block.timestamp))
            && _validateSignature(sar.record.initiator, sar.initiatorCurve, sar.initiatorSignature, hash)
            && _validateSignature(sar.record.approver, sar.approverCurve, sar.approverSignature, hash);
    }

    /// @notice Returns the `domainSeparator` used to create EIP-712 compliant hashes.
    ///
    /// @dev Implements domainSeparator = hashStruct(eip712Domain).
    ///      See https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator.
    ///
    /// @return The 32 bytes domain separator result.
    function domainSeparator() public view returns (bytes32) {
        (string memory name, string memory version) = _domainNameAndVersion();
        return keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version)"),
                keccak256(bytes(name)),
                keccak256(bytes(version)),
                block.chainid
            )
        );
    }

    /// @notice Helper for generating the association uuid for a given `aar`.
    ///
    /// @dev The keccak256 hash of the encoding of the two addresses `initiator` and `approver`,
    ///     with the eip-712 domainSeparator.
    function uuidFromAAR(AssociatedAccounts.AssociatedAccountRecord calldata aar) public view returns (bytes32) {
        return _eip712Hash(aar.initiator, aar.approver, aar.interfaceId, aar.data);
    }

    /// @notice Helper for generating the association uuid for a given `sar`.
    ///
    /// @dev The keccak256 hash of the encoding of the two addresses `initiator` and `approver`,
    ///     with the eip-712 domainSeparator.
    function uuidFromSAR(AssociatedAccounts.SignedAssociationRecord calldata sar) public view returns (bytes32) {
        return uuidFromAAR(sar.record);
    }

    /// @notice Helper for fetching the EIP-712 signature hash for a provided AssociatedAccountRecord.
    function eip712Hash(AssociatedAccounts.AssociatedAccountRecord calldata aar) public view returns (bytes32) {
        return _eip712Hash(aar.initiator, aar.approver, aar.interfaceId, aar.data);
    }

    function _validateSignature(bytes calldata account, bytes1 curve, bytes calldata signature, bytes32 hash)
        internal
        view
        returns (bool)
    {
        // recover account address, accept only EVM addresses for now
        (bytes2 chainType, bytes memory chainReference, bytes memory addr) = InteroperableAddress.parseV1(account);
        if (chainType != InteroperableAddress.EIP155_CHAIN_TYPE) {
            revert UnsupportedChainType(chainType);
        }
        address accountAddr = address(bytes20(addr));
        // switch on curve
        if (curve == K1) {
            return _validateSepc256k1(hash, accountAddr, signature);
        } else if (curve == R1) {
            return _validateSepc256r1(hash, accountAddr, signature);
        } else if (curve == EDDSA) {
            return _validateEddsa(hash, accountAddr, signature);
        } else if (curve == BLS) {
            return _validateBls(hash, accountAddr, signature);
        } else if (curve == WEBAUTHN) {
            return _validateWebauthN(hash, accountAddr, signature);
        }
    }

    function _validateSepc256k1(bytes32 hash, address account, bytes calldata signature) internal view returns (bool) {
        return SignatureChecker.isValidSignatureNow(account, hash, signature);
    }

    function _validateSepc256r1(bytes32 hash, address account, bytes calldata signature) internal view returns (bool) {
        revert UnsupportedCurve(R1);
    }

    function _validateEddsa(bytes32 hash, address account, bytes calldata signature) internal view returns (bool) {
        revert UnsupportedCurve(EDDSA);
    }

    function _validateBls(bytes32 hash, address account, bytes calldata signature) internal view returns (bool) {
        revert UnsupportedCurve(BLS);
    }

    function _validateWebauthN(bytes32 hash, address account, bytes calldata signature) internal view returns (bool) {
        revert UnsupportedCurve(WEBAUTHN);
    }

    /// @notice Returns the domain name and version to use when creating EIP-712 signatures.
    ///
    /// @dev MUST be defined by the implementation.
    ///
    /// @return name    The user readable name of signing domain.
    /// @return version The current major version of the signing domain.
    function _domainNameAndVersion() internal pure returns (string memory name, string memory version) {
        return ("AssociatedAccount", "1");
    }

    /// @notice Returns the EIP-712 typed hash of the `AssociatedAccountRecord(address account, bytes data)` data structure.
    ///
    /// @dev Implements encode(domainSeparator : 𝔹²⁵⁶, message : 𝕊) = "\x19\x01" || domainSeparator ||
    ///      hashStruct(message).
    /// @dev See https://eips.ethereum.org/EIPS/eip-712#specification.
    ////
    /// @return The resulting EIP-712 hash.
    function _eip712Hash(bytes calldata initiator, bytes calldata approver, bytes4 interfaceId, bytes calldata data)
        internal
        view
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked("\x19\x01", domainSeparator(), _hashStruct(initiator, approver, interfaceId, data))
            );
    }

    /// @notice Returns the EIP-712 `hashStruct` result of the `AssociatedAccountRecord` data structure.
    ///
    /// @dev Implements hashStruct(s : 𝕊) = keccak256(typeHash || encodeData(s)).
    /// @dev Addresses are sorted lexicographically to ensure deterministic hashing regardless of initiator/approver order.
    /// See https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct.
    ///
    /// @return The EIP-712 `hashStruct` result.
    function _hashStruct(bytes calldata initiator, bytes calldata approver, bytes4 interfaceId, bytes calldata data)
        internal
        pure
        returns (bytes32)
    {
        // Sort addresses to ensure deterministic hash
        (bytes32 hash1, bytes32 hash2) = InteroperableAddressSort.sortAndHash(initiator, approver);
        
        return keccak256(
            abi.encode(_MESSAGE_TYPEHASH, hash1, hash2, interfaceId, keccak256(data))
        );
    }
}
