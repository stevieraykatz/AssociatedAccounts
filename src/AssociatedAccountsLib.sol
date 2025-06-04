// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {SignatureChecker} from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

/// @notice Helper Lib for creating and validating AssociatedAccount records and the resulting
///     SignedAssociationRecords.
library AssociatedAccountsLib {
    /// @dev Precomputed `typeHash` used to produce EIP-712 compliant hash when applying the anti
    ///      cross-account-replay layer.
    ///
    ///      The original hash must either be:
    ///         - An EIP-191 hash: keccak256("\x19Ethereum Signed Message:\n" || len(someMessage) || someMessage)
    ///         - An EIP-712 hash: keccak256("\x19\x01" || someDomainSeparator || hashStruct(someStruct))
    bytes32 private constant _MESSAGE_TYPEHASH = keccak256("AssociatedAccountRecord(address account, bytes data)");

    /// @notice Represents an association between the signer of this payload and the included `account`.
    struct AssociatedAccountRecord {
        /// @dev The address of the associated account.
        address account;
        /// @dev Optional additional data.
        bytes data;
    }

    /// @notice Helper struct for pairing signatures with the associated signer.
    struct SignedAssociationRecord {
        /// @dev The address of the account that signed the payload.
        address signer;
        /// @dev The signed AssociatedAccountRecord
        AssociatedAccountRecord record;
        /// @dev The signature data.
        bytes signature;
    }

    /// @notice Validates the `signature` against the given `hash`.
    ///
    /// @dev This implementation follows ERC-1271. See https://eips.ethereum.org/EIPS/eip-1271.
    /// @dev IMPORTANT: Signature verification is performed on the hash produced AFTER applying the anti
    ///      cross-account-replay layer on the given `hash` (i.e., verification is run on the replay-safe
    ///      hash version).
    ///
    /// @param signature The signature of the replay-safe hash to validate.
    ///
    /// @return result `0x1626ba7e` if validation succeeded, else `0xffffffff`.
    function isValidSignature(address account, bytes memory data, bytes calldata signature) public view returns (bytes4 result) {
        if (_isValidSignature({hash: replaySafeHash(account, data), signature: signature})) {
            // bytes4(keccak256("isValidSignature(bytes32,bytes)"))
            return 0x1626ba7e;
        }

        return 0xffffffff;
    }

    /// @notice Wrapper around `_eip712Hash()` to produce a replay-safe hash fron the given `hash`.
    ///
    /// @dev The returned EIP-712 compliant replay-safe hash is the result of:
    ///      keccak256(
    ///         \x19\x01 ||
    ///         this.domainSeparator ||
    ///         hashStruct(AssociatedAccountRecord({ account: `account`, data: `data`}))
    ///      )
    ///
    /// @return The corresponding replay-safe hash.
    function replaySafeHash(address account, bytes memory data) public view returns (bytes32) {
        return _eip712Hash(account, data);
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
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name)),
                keccak256(bytes(version)),
                block.chainid,
                address(this)
            )
        );
    }

    /// @notice Helper for validating the contents of a SignedAssociationRecord.
    function validateAssociatedAccount(SignedAssociationRecord calldata signedAssociation)
        public
        view
        returns (bytes4)
    {
        return isValidSignature(signedAssociation.record.account, signedAssociation.record.data, signedAssociation.signature);
    }

    /// @notice Helper for fetching the EIP-712 signature hash for a provided AssociatedAccountRecord.  
    function eip712Hash(AssociatedAccountRecord calldata record) external view returns (bytes32) {
        return _eip712Hash(record.account, record.data);
    }

    /// @notice Returns the domain name and version to use when creating EIP-712 signatures.
    ///
    /// @dev MUST be defined by the implementation.
    ///
    /// @return name    The user readable name of signing domain.
    /// @return version The current major version of the signing domain.
    function _domainNameAndVersion() internal pure returns (string memory name, string memory version) {
        return ("AsoociatedAccount", "1");
    }

    /// @notice Validates the `signature` against the given `hash`.
    ///
    /// @dev MUST be defined by the implementation.
    ///
    /// @param hash      The hash whose signature has been performed on.
    /// @param signature The signature associated with `hash`.
    ///
    /// @return `true` is the signature is valid, else `false`.
    function _isValidSignature(bytes32 hash, bytes calldata signature) internal view returns (bool) {
        SignedAssociationRecord memory signedAssociation = abi.decode(signature, (SignedAssociationRecord));
        return SignatureChecker.isValidSignatureNow(signedAssociation.signer, hash, signedAssociation.signature);
    }

    /// @notice Returns the EIP-712 typed hash of the `AssociatedAccountRecord(address account, bytes data)` data structure.
    ///
    /// @dev Implements encode(domainSeparator : 𝔹²⁵⁶, message : 𝕊) = "\x19\x01" || domainSeparator ||
    ///      hashStruct(message).
    /// @dev See https://eips.ethereum.org/EIPS/eip-712#specification.
    ////
    /// @return The resulting EIP-712 hash.
    function _eip712Hash(address account, bytes memory data) internal view returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator(), _hashStruct(account, data)));
    }

    /// @notice Returns the EIP-712 `hashStruct` result of the `AssociatedAccountRecord(address account, bytes data)` data
    ///         structure.
    ///
    /// @dev Implements hashStruct(s : 𝕊) = keccak256(typeHash || encodeData(s)).
    /// @dev See https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct.
    ///
    /// @return The EIP-712 `hashStruct` result.
    function _hashStruct(address account, bytes memory data) internal view returns (bytes32) {
        return keccak256(abi.encode(_MESSAGE_TYPEHASH, account, data));
    }

}
