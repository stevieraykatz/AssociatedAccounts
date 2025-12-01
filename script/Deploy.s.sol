// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {AssociationsStore} from "../src/AssociationsStore.sol";
import {TransparentUpgradeableProxy} from "lib/openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ProxyAdmin} from "lib/openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";

/// @title Deploy Script for AssociationsStore
/// @notice Deploys the AssociationsStore contract behind a Transparent Upgradeable Proxy
contract Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOY_PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy the implementation contract
        AssociationsStore implementation = new AssociationsStore();
        console.log("AssociationsStore implementation deployed at:", address(implementation));
        
        // Deploy ProxyAdmin
        ProxyAdmin proxyAdmin = new ProxyAdmin(deployer);
        console.log("ProxyAdmin deployed at:", address(proxyAdmin));
        
        // Deploy the TransparentUpgradeableProxy
        bytes memory initData = "";
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(implementation),
            address(proxyAdmin),
            initData
        );
        console.log("TransparentUpgradeableProxy deployed at:", address(proxy));
        
        vm.stopBroadcast();
        
        console.log("\n=== Deployment Summary ===");
        console.log("Implementation Address:", address(implementation));
        console.log("ProxyAdmin:", address(proxyAdmin));
        console.log("Proxy Address:", address(proxy));
        console.log("ProxyAdmin owner:", deployer);
    }
}

