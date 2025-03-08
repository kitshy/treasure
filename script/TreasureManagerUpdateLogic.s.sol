// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;
import {Script, console} from "forge-std/Script.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {TreasureManager} from "../src/TreasureManager.sol";
import {ITransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract TreasureManagerUpdateLogic is Script {

    function setUp() public {}

    function run() public {

        address proxyAdmin = 0x5FbDB2315678afecb367f032d93F642f64180aa3;
        address proxyTreasureManager = 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0;

        uint256 depolyPrivateKey = vm.envUint("PRIVATE_KEY");
        address depolyAddress = vm.addr(depolyPrivateKey);
        vm.startBroadcast(depolyPrivateKey);

        TreasureManager treasureManagerV2 = new TreasureManager();
        console.log("treasureV2 address : ",address(treasureManagerV2));

        ProxyAdmin(proxyAdmin).upgradeAndCall(ITransparentUpgradeableProxy(proxyTreasureManager),address(treasureManagerV2),bytes(""));

        console.log("proxyTreasureManager success : ",address (proxyTreasureManager));

        vm.stopBroadcast();
    }
}
