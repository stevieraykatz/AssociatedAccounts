// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title InteroperableAddressSort
/// @notice Library for deterministically sorting ERC-7930 Interoperable Addresses
/// @dev Implements lexicographic byte comparison to ensure deterministic ordering
library InteroperableAddressSort {
    /// @notice Sort two ERC-7930 addresses in lexicographic order
    /// @dev Performs lexicographic comparison of the binary representations
    /// @param addr1 First ERC-7930 address as bytes
    /// @param addr2 Second ERC-7930 address as bytes
    /// @return first The address that should come first in sorted order
    /// @return second The address that should come second in sorted order
    function sort(bytes calldata addr1, bytes calldata addr2)
        internal
        pure
        returns (bytes calldata first, bytes calldata second)
    {
        if (lessThanOrEqual(addr1, addr2)) {
            return (addr1, addr2);
        } else {
            return (addr2, addr1);
        }
    }

    /// @notice Check if addr1 is less than addr2 lexicographically
    /// @param addr1 First ERC-7930 address as bytes
    /// @param addr2 Second ERC-7930 address as bytes
    /// @return True if addr1 < addr2, false otherwise
    function lessThan(bytes calldata addr1, bytes calldata addr2) internal pure returns (bool) {
        uint256 len1 = addr1.length;
        uint256 len2 = addr2.length;
        uint256 minLen = len1 < len2 ? len1 : len2;

        // Compare byte by byte
        for (uint256 i = 0; i < minLen; i++) {
            if (addr1[i] < addr2[i]) {
                return true;
            } else if (addr1[i] > addr2[i]) {
                return false;
            }
        }

        // If all compared bytes are equal, the shorter address is "less than"
        return len1 < len2;
    }

    /// @notice Check if addr1 is less than or equal to addr2 lexicographically
    /// @param addr1 First ERC-7930 address as bytes
    /// @param addr2 Second ERC-7930 address as bytes
    /// @return True if addr1 <= addr2, false otherwise
    function lessThanOrEqual(bytes calldata addr1, bytes calldata addr2) internal pure returns (bool) {
        uint256 len1 = addr1.length;
        uint256 len2 = addr2.length;
        uint256 minLen = len1 < len2 ? len1 : len2;

        // Compare byte by byte
        for (uint256 i = 0; i < minLen; i++) {
            if (addr1[i] < addr2[i]) {
                return true;
            } else if (addr1[i] > addr2[i]) {
                return false;
            }
        }

        // If all compared bytes are equal, shorter or equal length satisfies <=
        return len1 <= len2;
    }

    /// @notice Check if two addresses are equal
    /// @param addr1 First ERC-7930 address as bytes
    /// @param addr2 Second ERC-7930 address as bytes
    /// @return True if addresses are equal, false otherwise
    function equal(bytes calldata addr1, bytes calldata addr2) internal pure returns (bool) {
        if (addr1.length != addr2.length) {
            return false;
        }

        for (uint256 i = 0; i < addr1.length; i++) {
            if (addr1[i] != addr2[i]) {
                return false;
            }
        }

        return true;
    }

    /// @notice Check if addr1 is greater than addr2 lexicographically
    /// @param addr1 First ERC-7930 address as bytes
    /// @param addr2 Second ERC-7930 address as bytes
    /// @return True if addr1 > addr2, false otherwise
    function greaterThan(bytes calldata addr1, bytes calldata addr2) internal pure returns (bool) {
        return lessThan(addr2, addr1);
    }

    /// @notice Sort two ERC-7930 addresses and return their keccak256 hashes in sorted order
    /// @param addr1 First ERC-7930 address as bytes
    /// @param addr2 Second ERC-7930 address as bytes
    /// @return hash1 Keccak256 hash of the first address in sorted order
    /// @return hash2 Keccak256 hash of the second address in sorted order
    function sortAndHash(bytes calldata addr1, bytes calldata addr2)
        internal
        pure
        returns (bytes32 hash1, bytes32 hash2)
    {
        (bytes calldata first, bytes calldata second) = sort(addr1, addr2);
        hash1 = keccak256(first);
        hash2 = keccak256(second);
    }
}
