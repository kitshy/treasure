// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import {Test, console} from "forge-std/Test.sol";
import {TreasureManager} from "../src/TreasureManager.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TreasureManagerTest is Test {
    TreasureManager public treasure;
    MockERC20 token;

    address owner = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    address treasureManager = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    address withdrawManager = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    address user1 = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);
    address user2 = address(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC);

    function setUp() public {

        vm.startPrank(owner);
        treasure = new TreasureManager();
        treasure.initialize(owner,treasureManager,withdrawManager);

        token = new MockERC20("TestToken", "TTK");
        token.mint(user1, 1000 ether);
        token.mint(owner,1000 ether);
        vm.stopPrank();

    }

    function test_depositETH() public{
        vm.deal(user1, 10 ether);
        vm.prank(user1);
        treasure.depositETH{value: 5 ether}();
        assertEq(treasure.tokenBalances(treasure.ethAddress()), 5 ether);
    }

    function test_depositERC20() public{

        vm.startPrank(user1);
        token.approve(address(treasure),100 ether);
        treasure.depositERC20(token,100 ether);
        assertEq(treasure.tokenBalances(address(token)),100 ether);
        vm.stopPrank();

    }

    function test_withdrawETH() public{

        vm.deal(withdrawManager, 100 ether);
        vm.startPrank(withdrawManager);
        treasure.depositETH{value: 10 ether}();
        bool success = treasure.withdrawETH(payable(user1),5 ether);
        assertTrue(success);
        assertEq(user1.balance,5 ether);
        vm.stopPrank();
    }

    function test_withdrawERC20() public{

        vm.startPrank(user1);
        token.approve(address (treasure),100 ether);
        treasure.depositERC20(token,100 ether);
        vm.stopPrank();

        vm.prank(withdrawManager);
        bool success = treasure.withdrawERC20(token,user1,50 ether);
        assertTrue(success);
        assertEq(token.balanceOf(user1),950 ether);
        vm.stopPrank();

    }

    function test_setTokenWhiteList() public{

        vm.startPrank(owner);
        treasure.setTokenWhiteList(address (token));

        address[] memory data = treasure.getTokenWhiteList();

        assertEq(data.length,1);
        assertEq(data[0],address(token));
        vm.stopPrank();

    }

    function test_getTokenWhiteList() public{

        vm.startPrank(owner);
        treasure.setTokenWhiteList(address (token));

        address[] memory data = treasure.getTokenWhiteList();
        assertEq(data.length,1);
        vm.stopPrank();
    }

    function test_setWithdrawManager() public{

        vm.startPrank(owner);
        treasure.setWithdrawManager(address(withdrawManager));

        assertEq(treasure.withdrawManager(),address (withdrawManager));
        vm.stopPrank();
    }

    function test_grantReward() public{

        vm.startPrank(owner);
        treasure.grantReward(address (token),owner,100 ether);
        assertEq(treasure.queryReward(address (token)),100 ether);
        vm.stopPrank();
    }

    function test_claimToken() public{

        vm.startPrank(owner);
        token.approve(address(treasure),100 ether);
        treasure.depositERC20(token,50 ether);

        treasure.grantReward(address (token),user1,20 ether);
        vm.stopPrank();

        vm.startPrank(user1);
        treasure.claimToken(address (token));
        assertEq(token.balanceOf(user1),1020 ether);
        vm.stopPrank();
    }

    function test_claimAllToken()  public{

        vm.startPrank(owner);
        token.approve(address(treasure),100 ether);
        treasure.depositERC20(token,50 ether);
        treasure.setTokenWhiteList(address (token));

        treasure.grantReward(address (token),user1,20 ether);
        vm.stopPrank();

        vm.startPrank(user1);
        treasure.claimAllToken();
        assertEq(token.balanceOf(user1),1020 ether);
        vm.stopPrank();
    }

}

// Mock ERC20 代币
contract MockERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
