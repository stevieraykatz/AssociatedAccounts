// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IERC1271 {
        /// @notice Validates the `signature` against the given `hash`.
    ///
    /// @dev MUST be defined by the implementation.
    ///
    /// @param hash      The hash whose signature has been performed on.
    /// @param signature The signature associated with `hash`.
    ///
    /// @return `true` is the signature is valid, else `false`.
    function isValidSignature(bytes32 hash, bytes calldata signature) external view virtual returns (bool);
}
