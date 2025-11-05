// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {InteroperableAddressSort} from "src/InteroperableAddressSort.sol";
import {InteroperableAddress} from "src/InteroperableAddresses.sol";

// Wrapper contract to test library functions
contract SortWrapper {
    function sort(bytes calldata addr1, bytes calldata addr2)
        external
        pure
        returns (bytes memory first, bytes memory second)
    {
        (bytes calldata f, bytes calldata s) = InteroperableAddressSort.sort(addr1, addr2);
        return (f, s);
    }

    function lessThan(bytes calldata addr1, bytes calldata addr2) external pure returns (bool) {
        return InteroperableAddressSort.lessThan(addr1, addr2);
    }

    function lessThanOrEqual(bytes calldata addr1, bytes calldata addr2) external pure returns (bool) {
        return InteroperableAddressSort.lessThanOrEqual(addr1, addr2);
    }

    function equal(bytes calldata addr1, bytes calldata addr2) external pure returns (bool) {
        return InteroperableAddressSort.equal(addr1, addr2);
    }

    function greaterThan(bytes calldata addr1, bytes calldata addr2) external pure returns (bool) {
        return InteroperableAddressSort.greaterThan(addr1, addr2);
    }

    function sortAndHash(bytes calldata addr1, bytes calldata addr2)
        external
        pure
        returns (bytes32 hash1, bytes32 hash2)
    {
        return InteroperableAddressSort.sortAndHash(addr1, addr2);
    }
}

contract InteroperableAddressSortTest is Test {
    SortWrapper wrapper;

    function setUp() public {
        wrapper = new SortWrapper();
    }

    function test_SortTwoAddresses_SameChainDifferentAddress() public view {
        // Create two EVM addresses on the same chain
        bytes memory addr1 = InteroperableAddress.formatEvmV1(1, address(0x1234));
        bytes memory addr2 = InteroperableAddress.formatEvmV1(1, address(0x5678));

        (bytes memory first, bytes memory second) = wrapper.sort(addr1, addr2);

        // addr1 should come before addr2 (0x1234 < 0x5678)
        assertEq(keccak256(first), keccak256(addr1));
        assertEq(keccak256(second), keccak256(addr2));
    }

    function test_SortTwoAddresses_ReversedOrder() public view {
        bytes memory addr1 = InteroperableAddress.formatEvmV1(1, address(0x5678));
        bytes memory addr2 = InteroperableAddress.formatEvmV1(1, address(0x1234));

        (bytes memory first, bytes memory second) = wrapper.sort(addr1, addr2);

        // addr2 should come before addr1 (0x1234 < 0x5678)
        assertEq(keccak256(first), keccak256(addr2));
        assertEq(keccak256(second), keccak256(addr1));
    }

    function test_SortTwoAddresses_DifferentChains() public view {
        // Chain 1 vs Chain 2
        bytes memory addr1 = InteroperableAddress.formatEvmV1(1, address(0x1234));
        bytes memory addr2 = InteroperableAddress.formatEvmV1(2, address(0x1234));

        (bytes memory first, bytes memory second) = wrapper.sort(addr1, addr2);

        // Chain 1 should come before Chain 2
        assertEq(keccak256(first), keccak256(addr1));
        assertEq(keccak256(second), keccak256(addr2));
    }

    function test_SortTwoAddresses_DifferentLengths() public view {
        // Different chain reference lengths
        bytes memory addr1 = InteroperableAddress.formatEvmV1(1, address(0x1234)); // Small chain ID
        bytes memory addr2 = InteroperableAddress.formatEvmV1(256, address(0x1234)); // Larger chain ID (needs more bytes)

        (bytes memory first, bytes memory second) = wrapper.sort(addr1, addr2);

        // Shorter address should come first when all compared bytes are equal
        assertTrue(addr1.length < addr2.length);
        assertEq(keccak256(first), keccak256(addr1));
        assertEq(keccak256(second), keccak256(addr2));
    }

    function test_LessThanOrEqual_Equal() public view {
        bytes memory addr1 = InteroperableAddress.formatEvmV1(1, address(0x1234));
        bytes memory addr2 = InteroperableAddress.formatEvmV1(1, address(0x1234));

        assertTrue(wrapper.lessThanOrEqual(addr1, addr2));
        assertTrue(wrapper.lessThanOrEqual(addr2, addr1));
    }

    function test_LessThanOrEqual_LessThan() public view {
        bytes memory addr1 = InteroperableAddress.formatEvmV1(1, address(0x1234));
        bytes memory addr2 = InteroperableAddress.formatEvmV1(1, address(0x5678));

        assertTrue(wrapper.lessThanOrEqual(addr1, addr2));
        assertFalse(wrapper.lessThanOrEqual(addr2, addr1));
    }

    function test_LessThanOrEqual_GreaterThan() public view {
        bytes memory addr1 = InteroperableAddress.formatEvmV1(1, address(0x5678));
        bytes memory addr2 = InteroperableAddress.formatEvmV1(1, address(0x1234));

        assertFalse(wrapper.lessThanOrEqual(addr1, addr2));
        assertTrue(wrapper.lessThanOrEqual(addr2, addr1));
    }

    function test_SortAndHash_Deterministic() public view {
        bytes memory addr1 = InteroperableAddress.formatEvmV1(1, address(0x1234));
        bytes memory addr2 = InteroperableAddress.formatEvmV1(1, address(0x5678));

        // Sort in both orders
        (bytes32 hash1a, bytes32 hash2a) = wrapper.sortAndHash(addr1, addr2);
        (bytes32 hash1b, bytes32 hash2b) = wrapper.sortAndHash(addr2, addr1);

        // Should produce the same result regardless of input order
        assertEq(hash1a, hash1b);
        assertEq(hash2a, hash2b);
    }

    function test_Equal() public view {
        bytes memory addr1 = InteroperableAddress.formatEvmV1(1, address(0x1234));
        bytes memory addr2 = InteroperableAddress.formatEvmV1(1, address(0x1234));
        bytes memory addr3 = InteroperableAddress.formatEvmV1(1, address(0x5678));

        assertTrue(wrapper.equal(addr1, addr2));
        assertFalse(wrapper.equal(addr1, addr3));
    }

    function test_LessThan() public view {
        bytes memory addr1 = InteroperableAddress.formatEvmV1(1, address(0x1234));
        bytes memory addr2 = InteroperableAddress.formatEvmV1(1, address(0x5678));

        assertTrue(wrapper.lessThan(addr1, addr2));
        assertFalse(wrapper.lessThan(addr2, addr1));
        assertFalse(wrapper.lessThan(addr1, addr1));
    }

    function test_GreaterThan() public view {
        bytes memory addr1 = InteroperableAddress.formatEvmV1(1, address(0x5678));
        bytes memory addr2 = InteroperableAddress.formatEvmV1(1, address(0x1234));

        assertTrue(wrapper.greaterThan(addr1, addr2));
        assertFalse(wrapper.greaterThan(addr2, addr1));
        assertFalse(wrapper.greaterThan(addr1, addr1));
    }

    function test_SortingIsLexicographic() public view {
        // Test that sorting is truly lexicographic by comparing bytes
        bytes memory addr1 = hex"000100000101AA"; // Version 1, Chain 0, Chain Ref [0x01], Address [0xAA]
        bytes memory addr2 = hex"000100000101BB"; // Version 1, Chain 0, Chain Ref [0x01], Address [0xBB]

        (bytes memory first, bytes memory second) = wrapper.sort(addr1, addr2);

        assertEq(keccak256(first), keccak256(addr1));
        assertEq(keccak256(second), keccak256(addr2));
    }
}
