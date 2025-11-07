// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @dev Enumeration described in Key Types table of eip-draft-aa-account-configuration
/// https://github.com/chunter-cb/EIPs/blob/enshrined-aa-validation/EIPS/eip-draft-aa-account-configuration.md

bytes2 constant K1 = 0x0001;
bytes2 constant R1 = 0x0002;
bytes2 constant EDDSA = 0x0003;
bytes2 constant BLS = 0x0004;
bytes2 constant WEBAUTHN = 0x8001;
bytes2 constant ERC1271 = 0x8002;
bytes2 constant ERC6492 = 0x8003;
