// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {AssociationsStore} from "../src/AssociationsStore.sol";

/// @title Deploy Script for AssociationsStore
/// @notice Deploys the AssociationsStore contract
contract Deploy is Script {
    function run() external returns (AssociationsStore) {
        uint256 deployerPrivateKey = vm.envUint("DEPLOY_PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        
        AssociationsStore store = new AssociationsStore();
        
        vm.stopBroadcast();
        
        console.log("AssociationsStore deployed at:", address(store));
        
        return store;
    }
}

