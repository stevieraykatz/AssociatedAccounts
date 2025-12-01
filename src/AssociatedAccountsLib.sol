// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {AssociatedAccounts} from "./AssociatedAccounts.sol";
import "./Curves.sol";
import {InteroperableAddress} from "./InteroperableAddresses.sol";

import {IERC1271} from "./interface/IERC1271.sol";
import {SignatureChecker} from "lib/openzeppelin-contracts/contracts/utils/cryptography/SignatureChecker.sol";

import {console} from "forge-std/console.sol";

/// @notice Helper Lib for creating, signing and validating AssociatedAccount records and the resulting
///     SignedAssociationRecords.
library AssociatedAccountsLib {
    error UnsupportedKeyType(bytes2 keyType);
    error UnsupportedChainType(bytes2 chainType);

    /// @dev Precomputed `typeHash` used to produce EIP-712 compliant hash.
    ///      The original hash must be:
    ///         - An EIP-712 hash: keccak256("\x19\x01" || someDomainSeparator || hashStruct(someStruct))
    bytes32 private constant _MESSAGE_TYPEHASH = keccak256(
        "AssociatedAccountRecord(bytes initiator,bytes approver,uint40 validAt,uint40 validUntil,bytes4 interfaceId,bytes data)"
    );

    /// @notice Helper for validating the contents of a SignedAssociationRecord.
    function validateAssociatedAccount(AssociatedAccounts.SignedAssociationRecord calldata sar)
        internal
        view
        returns (bool)
    {
        bytes32 hash = eip712Hash(sar.record);
        // Check timestamp validity
        if (block.timestamp < sar.record.validAt) return false;
        if (sar.record.validUntil != 0 && block.timestamp >= sar.record.validUntil) return false;
        if (sar.revokedAt != 0 && block.timestamp >= sar.revokedAt) return false;

        // Validate signatures if provided
        if (
            sar.initiatorSignature.length > 0
                && !_validateSignature(sar.record.initiator, sar.initiatorKeyType, sar.initiatorSignature, hash)
        ) {
            return false;
        }
        if (
            sar.approverSignature.length > 0
                && !_validateSignature(sar.record.approver, sar.approverKeyType, sar.approverSignature, hash)
        ) {
            return false;
        }

        return true;
    }

    /// @notice Returns the `domainSeparator` used to create EIP-712 compliant hashes.
    ///
    /// @dev Implements domainSeparator = hashStruct(eip712Domain).
    ///      See https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator.
    ///
    /// @return The 32 bytes domain separator result.
    function domainSeparator() internal pure returns (bytes32) {
        (string memory name, string memory version) = _domainNameAndVersion();
        return keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version)"), keccak256(bytes(name)), keccak256(bytes(version))
            )
        );
    }

    /// @notice Helper for generating the association uuid for a given `aar`.
    ///
    /// @dev The keccak256 hash of the encoding of the two addresses `initiator` and `approver`,
    ///     with the eip-712 domainSeparator.
    function uuidFromAAR(AssociatedAccounts.AssociatedAccountRecord calldata aar) internal pure returns (bytes32) {
        return _eip712Hash(aar.initiator, aar.approver, aar.validAt, aar.validUntil, aar.interfaceId, aar.data);
    }

    /// @notice Helper for generating the association uuid for a given `sar`.
    ///
    /// @dev The keccak256 hash of the encoding of the two addresses `initiator` and `approver`,
    ///     with the eip-712 domainSeparator.
    function uuidFromSAR(AssociatedAccounts.SignedAssociationRecord calldata sar) internal pure returns (bytes32) {
        return uuidFromAAR(sar.record);
    }

    /// @notice Helper for fetching the EIP-712 signature hash for a provided AssociatedAccountRecord.
    function eip712Hash(AssociatedAccounts.AssociatedAccountRecord calldata aar) internal pure returns (bytes32) {
        return _eip712Hash(aar.initiator, aar.approver, aar.validAt, aar.validUntil, aar.interfaceId, aar.data);
    }

    function _validateSignature(bytes calldata account, bytes2 keyType, bytes calldata signature, bytes32 hash)
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
        // switch on key type
        if (keyType == K1) {
            return _validateSepc256k1(hash, accountAddr, signature);
        } else if (keyType == R1) {
            return _validateSepc256r1(hash, accountAddr, signature);
        } else if (keyType == EDDSA) {
            return _validateEddsa(hash, accountAddr, signature);
        } else if (keyType == BLS) {
            return _validateBls(hash, accountAddr, signature);
        } else if (keyType == WEBAUTHN) {
            return _validateWebAuthn(hash, accountAddr, signature);
        } else if (keyType == ERC1271) {
            return _validateErc1271(hash, accountAddr, signature);
        } else if (keyType == ERC6492) {
            return _validateErc6492(hash, accountAddr, signature);
        } else {
            revert UnsupportedKeyType(keyType);
        }
    }

    function _validateSepc256k1(bytes32 hash, address account, bytes calldata signature) internal view returns (bool) {
        return SignatureChecker.isValidSignatureNow(account, hash, signature);
    }

    function _validateSepc256r1(bytes32 hash, address account, bytes calldata signature) internal view returns (bool) {
        revert UnsupportedKeyType(R1);
    }

    function _validateEddsa(bytes32 hash, address account, bytes calldata signature) internal view returns (bool) {
        revert UnsupportedKeyType(EDDSA);
    }

    function _validateBls(bytes32 hash, address account, bytes calldata signature) internal view returns (bool) {
        revert UnsupportedKeyType(BLS);
    }

    function _validateWebAuthn(bytes32 hash, address account, bytes calldata signature) internal view returns (bool) {
        revert UnsupportedKeyType(WEBAUTHN);
    }

    function _validateErc1271(bytes32 hash, address account, bytes calldata signature) internal view returns (bool) {
        return IERC1271(account).isValidSignature(hash, signature);
    }

    function _validateErc6492(bytes32 hash, address account, bytes calldata signature) internal view returns (bool) {
        revert UnsupportedKeyType(ERC6492);
    }

    /// @notice Returns the domain name and version to use when creating EIP-712 signatures.
    ///
    /// @dev MUST be defined by the implementation.
    ///
    /// @return name    The user readable name of signing domain.
    /// @return version The current major version of the signing domain.
    function _domainNameAndVersion() internal pure returns (string memory name, string memory version) {
        return ("AssociatedAccounts", "1");
    }

    /// @notice Returns the EIP-712 typed hash of the `AssociatedAccountRecord` data structure.
    ///
    /// @dev Implements encode(domainSeparator : 𝔹²⁵⁶, message : 𝕊) = "\x19\x01" || domainSeparator ||
    ///      hashStruct(message).
    /// @dev See https://eips.ethereum.org/EIPS/eip-712#specification.
    ///
    /// @return The resulting EIP-712 hash.
    function _eip712Hash(
        bytes calldata initiator,
        bytes calldata approver,
        uint40 validAt,
        uint40 validUntil,
        bytes4 interfaceId,
        bytes calldata data
    ) internal pure returns (bytes32) {
        return keccak256(
            abi.encodePacked(
                "\x19\x01", domainSeparator(), _hashStruct(initiator, approver, validAt, validUntil, interfaceId, data)
            )
        );
    }

    /// @notice Returns the EIP-712 `hashStruct` result of the `AssociatedAccountRecord` data structure.
    ///
    /// @dev Implements hashStruct(s : 𝕊) = keccak256(typeHash || encodeData(s)).
    /// See https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct.
    ///
    /// @return The EIP-712 `hashStruct` result.
    function _hashStruct(
        bytes calldata initiator,
        bytes calldata approver,
        uint40 validAt,
        uint40 validUntil,
        bytes4 interfaceId,
        bytes calldata data
    ) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                _MESSAGE_TYPEHASH,
                keccak256(initiator),
                keccak256(approver),
                validAt,
                validUntil,
                interfaceId,
                keccak256(data)
            )
        );
    }
}
