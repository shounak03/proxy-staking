// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import  "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { console } from "forge-std/console.sol";
contract StakingContract{

    mapping(address => uint) public  pendingBalance;
    mapping(address => uint256 ) unStakeTime; 
    uint public totalStake;
    bool private unstakeAllowed=false;
    
    function setStartTime() private { 
        unStakeTime[msg.sender] = block.timestamp; 
    } 
   
    function stakeV1(uint _amount) public payable {
        require(_amount > 0,"Not enough Etherium");
        require(_amount == msg.value);
        pendingBalance[msg.sender] += _amount;
        totalStake+=_amount;
    }
    function elapsedTime() private view returns (uint256 dd){
        dd = (block.timestamp - unStakeTime[msg.sender])/1 days; 
    }

    

    function unStakeV1(uint _amount) public returns (string memory) {
        if(unstakeAllowed==false){
            console.log(unstakeAllowed);
            unstakeAllowed = true;
            setStartTime();
            return "Unstaking started, wait for 11 days before you can unstake your ETH";
        }
        else if(unstakeAllowed==true && elapsedTime() <= 11){
            uint dd = elapsedTime();

            uint256 daysLeft = 11 - dd;
            return string(abi.encodePacked(
                daysLeft,
                " days left before you can unstake your tokens."
            ));
        }

        
        require(elapsedTime() >= 11, "You must wait 11 days before unstaking.");
        
        require(pendingBalance[msg.sender] >= _amount);
        payable(msg.sender).transfer(_amount);
        totalStake -= _amount;
        pendingBalance[msg.sender] -= _amount;

        return  "Unstaking Successful";
    }

}

contract storagrProxy{
   mapping(address => uint) pendingBalance; 
    uint public totalStake;
    address public implementation;

    constructor(address _implementation){
        implementation = _implementation;
    } 

    fallback() external {
        (bool success, ) = implementation.delegatecall(msg.data);

        if(!success){
            revert();
        }
    }
}

