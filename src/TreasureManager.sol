// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interfaces/ITreasureManager.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract TreasureManager is Initializable,AccessControlUpgradeable,ReentrancyGuardUpgradeable,OwnableUpgradeable,ITreasureManager{

    using SafeERC20 for IERC20;

    address public constant ethAddress = 0xeEEeEeEeEEeEeEeceeEeEeEeEeCeEeeEeceEEeCe;

    address public treasureManager;
    address public withdrawManager;

    address[] public tokenWhiteList;

    mapping(address => uint256) public tokenBalances;

    mapping(address => mapping(address => uint256)) public granterRewardAmount;

    error IsZeroAddress();

    event DepositToken(address indexed tokenAddress,address indexed sender,uint256 amount);
    event WithdrawToken(address indexed tokenAddress,address indexed sender,address withdrawAddress, uint256 amount);
    event GrantRewardTokenAmount(address indexed tokenAddress,address granter,uint256 amount);
    event WithdrawManagerUpdate(address indexed withdrawManger);

    modifier onlyTreasureManager{
        require(msg.sender==address(treasureManager),"only treasureManager can call");
        _;
    }

    modifier onlyWithdrawManager{
        require(msg.sender==address(withdrawManager),"only withdrawManager can call");
        _;
    }

    function initialize(address initOwner,address _treasureManager,address _withdrawManager) public initializer {
        treasureManager =_treasureManager;
        withdrawManager = _withdrawManager;
        _transferOwnership(initOwner);
    }

    receive() external payable {
        this.depositETH();
    }

    function depositETH() external payable returns (bool){
        tokenBalances[ethAddress] += msg.value;
        emit DepositToken(ethAddress,msg.sender,msg.value);
        return true;
    }

    function depositERC20(IERC20 tokenAddress,uint256 amount) external{
        tokenAddress.transferFrom(msg.sender,address(this),amount);
        tokenBalances[address(tokenAddress)] += amount;
        emit DepositToken(address (tokenAddress),msg.sender,amount);
    }

    function withdrawETH(address payable withdrawAddress,uint256 amount) external payable onlyWithdrawManager override(ITreasureManager) returns(bool){
        require(tokenBalances[address(ethAddress)]>=amount,"eth not enough");
        (bool success,) = withdrawAddress.call{value:amount}("");
        if(!success){
            return false;
        }
        tokenBalances[ethAddress] -= amount;
        emit WithdrawToken(ethAddress,msg.sender,withdrawAddress,amount);
        return true;
    }

    function withdrawERC20(IERC20 tokenAddress,address withdrawAddress,uint256 amount) external onlyWithdrawManager override(ITreasureManager) returns(bool){

        require(tokenBalances[address(tokenAddress)] >=amount,"token not enough");
        tokenAddress.transfer(withdrawAddress,amount);
        tokenBalances[address(tokenAddress)] -= amount;

        emit WithdrawToken(address(tokenAddress),msg.sender,withdrawAddress,amount);
        return true;
    }

    function setTokenWhiteList(address tokenAddress) external{
        if(tokenAddress == address (0)){
            IsZeroAddress;
        }
        tokenWhiteList.push(tokenAddress);
    }

    function getTokenWhiteList() external view returns(address[] memory){
        return tokenWhiteList;
    }

    function setWithdrawManager(address _withdrawManager) external{
        withdrawManager = _withdrawManager;
        emit WithdrawManagerUpdate(_withdrawManager);
    }

    function grantReward(address tokenAddress , address granter,uint256 amount) external{
        require(address(tokenAddress) !=address(0) && granter!=address(0),"invalid address");
        granterRewardAmount[granter][tokenAddress] = amount;
        emit GrantRewardTokenAmount(tokenAddress,granter,amount);
    }

    function queryReward(address tokenAddress) external view returns(uint256){
        return granterRewardAmount[msg.sender][tokenAddress];
    }

    function claimToken(address tokenAddress) external nonReentrant{
        require(tokenAddress!=address(0),"invalid address");

        uint256 rewardAmount = granterRewardAmount[msg.sender][tokenAddress];
        require(rewardAmount >0 ,"no reward available");

        uint256 tokenAmount = tokenBalances[tokenAddress];
        require(tokenAmount >0 ,"token amount not enough");

        if(tokenAddress == ethAddress){
            (bool success,) = msg.sender.call{value:rewardAmount}("");
            require(success,"eth transfer failed");
        }else{
            IERC20(tokenAddress).transfer(msg.sender,rewardAmount);
        }
        granterRewardAmount[msg.sender][tokenAddress] = 0;
        tokenBalances[tokenAddress] -= rewardAmount;
    }

    function claimAllToken()  external nonReentrant{

        for(uint256 i;i<tokenWhiteList.length;i++){
            address tokenAddress = tokenWhiteList[i];

            require(tokenAddress!=address(0),"invalid address");
            uint256 rewardAmount = granterRewardAmount[msg.sender][tokenAddress];
            if(rewardAmount>0){
                if(tokenAddress == ethAddress){
                    (bool success,) = msg.sender.call{value:rewardAmount}("");
                    require(success,"eth transfer failed");
                }else{
                    IERC20(tokenAddress).transfer(msg.sender,rewardAmount);
                }
                granterRewardAmount[msg.sender][tokenAddress] = 0;
                tokenBalances[tokenAddress] -= rewardAmount;
            }
        }
    }

}
