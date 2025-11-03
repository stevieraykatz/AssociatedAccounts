// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @dev Enumeration described in Key Types table of eip-draft-aa-account-configuration
/// https://github.com/chunter-cb/EIPs/blob/enshrined-aa-validation/EIPS/eip-draft-aa-account-configuration.md

bytes1 constant K1 = 0x01;
bytes1 constant R1 = 0x02;
bytes1 constant EDDSA = 0x03;
bytes1 constant BLS = 0x04;
bytes1 constant WEBAUTHN = 0x05;
