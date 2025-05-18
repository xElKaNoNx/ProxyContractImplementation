// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Proxy} from "../src/Proxy.sol";
import {LogicV1} from "../src/LogicV1.sol";
import {LogicV2} from "../src/LogicV2.sol";

contract DeployProxyScript is Script {
    function run() public {
        // Get private key from environment variable
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address admin = vm.addr(deployerPrivateKey);

        console.log("Deploying contracts with admin:", admin);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy LogicV1 implementation
        LogicV1 logicV1 = new LogicV1();
        console.log("LogicV1 deployed at:", address(logicV1));

        // Deploy Proxy pointing to LogicV1
        Proxy proxy = new Proxy(address(logicV1), admin);
        console.log("Proxy deployed at:", address(proxy));

        // Initialize the logic through the proxy
        LogicV1(address(proxy)).initialize(0);
        console.log("Proxy initialized with counter value: 0");

        vm.stopBroadcast();

        console.log("Deployment completed successfully");
    }
}

contract UpgradeProxyScript is Script {
    function run() public {
        // Get private key and addresses from environment variables
        uint256 adminPrivateKey = vm.envUint("PRIVATE_KEY");
        address payable proxyAddress = payable(vm.envAddress("PROXY_ADDRESS"));

        console.log("Upgrading proxy at:", proxyAddress);

        vm.startBroadcast(adminPrivateKey);

        // Deploy LogicV2 implementation
        LogicV2 logicV2 = new LogicV2();
        console.log("LogicV2 deployed at:", address(logicV2));

        // Upgrade the proxy to point to LogicV2
        Proxy proxy = Proxy(proxyAddress);
        proxy.upgrade(address(logicV2));
        console.log("Proxy upgraded to LogicV2");

        vm.stopBroadcast();

        console.log("Upgrade completed successfully");
    }
}
