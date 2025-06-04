// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {ERC1271} from "./ERC1271.sol";

contract AssociatedAccounts is ERC1271 {
    struct AssociatedAccountRecord {
        address account;
        bytes data;
    }

    function validateAssociatedAccount(
        AssociatedAccountRecord memory record
    ) public view returns (bool) {}

    /// @notice Returns the domain name and version to use when creating EIP-712 signatures.
    ///
    /// @dev MUST be defined by the implementation.
    ///
    /// @return name    The user readable name of signing domain.
    /// @return version The current major version of the signing domain.
    function _domainNameAndVersion() internal view override returns (string memory name, string memory version) {
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
    function _isValidSignature(bytes32 hash, bytes calldata signature) internal view virtual returns (bool) {

    }
}
