// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "src/RewardContract.sol";

contract RewardContractTest is Test {
    RewardContract c;
    address test = 0xF40e1B6A63621Cb5F9b64cD766E3D465648B5C3d;

    function setUp() public {
        c = new RewardContract(address(this));
    }

    function testMint() public {
       c.mint(test, 10);
       assertEq(c.balanceOf(test),10);
    }

    function testUdate() public {
        c.updateStakingContract(test);
        vm.startPrank(test);
        c.mint(test,10);
        assertEq(c.balanceOf(test),10);

    }
}
