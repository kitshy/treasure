// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ITreasureManager {

    function depositETH() external payable returns (bool);

    function depositERC20(IERC20 tokenAddress,uint256 amount) external;

    function withdrawETH(address payable withdrawAddress,uint256 amount) external payable returns(bool);

    function withdrawERC20(IERC20 tokenAddress,address withdrawAddress,uint256 amount) external returns(bool);

    function setTokenWhiteList(address tokenAddress) external;

    function getTokenWhiteList() external view returns(address[] memory);
    
    function setWithdrawManager(address _withdrawManager) external;

    function grantReward(address tokenAddress , address granter,uint256 amount) external ;

    function queryReward(address tokenAddress) external view returns(uint256);

    function claimToken(address tokenAddress) external;

    function claimAllToken()  external;

}
