// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import  "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { console } from "forge-std/console.sol";

contract RewardContract is ERC20,Ownable{
    address stakingContract;

    constructor(address _stakingContract) ERC20("LevCoin","LCO") Ownable(msg.sender){
        stakingContract = _stakingContract;
    }

    function mint(address account, uint tokens) public onlyOwner{
        _mint(account,tokens);
    }

    function updateStakingContract(address _stakingContract) public onlyOwner{
        stakingContract = _stakingContract;
    }

} 