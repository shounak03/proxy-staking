// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {console} from "forge-std/console.sol";

interface ILevToken {
    function mint(address to, uint256 amount) external;
}
contract StakingContract {
    mapping(address => uint) public pendingBalance;
    mapping(address => uint) unStakeTime;
    mapping(address => uint) unclaimedRewards;
    mapping(address => uint) lastUpdatesAt;
    uint public totalStake;
    bool private unstakeAllowed = false;
    ILevToken public levToken;

    constructor(ILevToken _levToken) {
        levToken = _levToken;
    }

    function setStartTime() private {
        unStakeTime[msg.sender] = block.timestamp;
    }

    function stakeV1(uint _amount) public payable {
        require(_amount > 0, "Not enough Etherium");
        require(_amount == msg.value);
        if(lastUpdatesAt[msg.sender] == 0){
            lastUpdatesAt[msg.sender] = block.timestamp;
        }
        else{
            uint lastTime = lastUpdatesAt[msg.sender];
            uint updatedReward = (block.timestamp - lastTime) * pendingBalance[msg.sender] * 1 / 1000;
            unclaimedRewards[msg.sender] += updatedReward;
            lastUpdatesAt[msg.sender] = block.timestamp;
        }
        pendingBalance[msg.sender] += _amount;
        totalStake += _amount;
    }

    function elapsedTime() private view returns (uint256 dd) {
        dd = (block.timestamp - unStakeTime[msg.sender]) / 1 days;
    }

    function unStakeV1(uint _amount) public returns (string memory) {
        if (unstakeAllowed == false) {
            unstakeAllowed = true;
            setStartTime();
            return
                "Unstaking started, wait for 11 days before you can unstake your ETH";
        } else if (unstakeAllowed == true && elapsedTime() <= 11) {
            uint dd = elapsedTime();

            uint256 daysLeft = 11 - dd;
            return 
                string(
                    abi.encodePacked(
                        daysLeft,
                        " days left before you can unstake your tokens."
                    )
                );
        }

        require(elapsedTime() >= 11, "You must wait 11 days before unstaking.");

        uint updatedReward = (block.timestamp - lastUpdatesAt[msg.sender]) * pendingBalance[msg.sender] * 1 / 1000;
        unclaimedRewards[msg.sender] += updatedReward;
        lastUpdatesAt[msg.sender] = block.timestamp;

        require(pendingBalance[msg.sender] >= _amount);
        payable(msg.sender).transfer(_amount);

        totalStake -= _amount;
        pendingBalance[msg.sender] -= _amount;

        return "Unstaking Successful";
    }

    function RedeemReward() public {
        address _address = msg.sender;
        uint currentReward = unclaimedRewards[_address];
        uint lastTime = lastUpdatesAt[_address];
        uint updatedReward = (block.timestamp - lastTime) * pendingBalance[_address] * 1 / 1000; 
        payable(_address).transfer(updatedReward+currentReward);
        unclaimedRewards[_address] = 0;
        lastUpdatesAt[_address] = block.timestamp;
    }
    function getReward(address _address) public view returns (uint) {
        uint currentReward = unclaimedRewards[_address];
        uint lastTime = lastUpdatesAt[_address];
        uint updatedReward = (block.timestamp - lastTime) * pendingBalance[_address] * 1 / 1000; // 0.01% = 1/10000
        return currentReward + updatedReward;
    }
}

contract storagrProxy {
    mapping(address => uint) pendingBalance;
    uint public totalStake;
    address public implementation;

    constructor(address _implementation) {
        implementation = _implementation;
    }

    fallback() external {
        (bool success, ) = implementation.delegatecall(msg.data);

        if (!success) {
            revert();
        }
    }
}
