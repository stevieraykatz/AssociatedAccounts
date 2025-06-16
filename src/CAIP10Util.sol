// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {CAIP10} from "@openzeppelin/contracts/utils/CAIP10.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

library CAIP10Util {
    using Strings for string;

    function toAddress(string memory caip10) internal pure returns (address) {
        (, string memory account) = CAIP10.parse(caip10);
        return account.parseAddress();
    }

}