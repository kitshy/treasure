// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;
import {Script, console} from "forge-std/Script.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {TreasureManager} from "../src/TreasureManager.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract TreasureManagerScript is Script {

    /** sepolia
        proxy address :  0xf469523a2D23E6A4B544d7468Cc4fD52d14e0934
        treasure address :  0xF9906696e0008CD3B0969226eaDE4da7Ee18721b
        proxyTreasureManager success :  0xDFC97b057eF039772F1bD7e8acf18949B660Cff1
    */

    /**
        proxy address :  0x5FbDB2315678afecb367f032d93F642f64180aa3
        treasure address :  0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
        proxyTreasureManager success :  0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
    */
    ProxyAdmin public proxyAdmin;
    TreasureManager public treasureManager;

    function setUp() public {}

    function run() public {

        uint256 depolyPrivateKey = vm.envUint("PRIVATE_KEY");
        address depolyAddress = vm.addr(depolyPrivateKey);
        vm.startBroadcast(depolyPrivateKey);

        proxyAdmin = new ProxyAdmin(depolyAddress);
        console.log("proxy address : ",address(proxyAdmin));

        treasureManager = new TreasureManager();
        console.log("treasure address : ",address(treasureManager));
        bytes memory data = abi.encodeWithSignature("initialize(address,address,address)",depolyAddress,depolyAddress,depolyAddress);
        TransparentUpgradeableProxy proxyTreasureManager = new TransparentUpgradeableProxy(address(treasureManager),address(proxyAdmin),data);
        console.log("proxyTreasureManager success : ",address (proxyTreasureManager));

        vm.stopBroadcast();
    }
}
