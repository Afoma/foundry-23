// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from 'forge-std/Test.sol';
import {FundMe} from '../../src/FundMe.sol';
import {DeployFundMe} from '../../script/DeployFundMe.s.sol';
import {FundFundMe} from '../../script/Interactions.s.sol';

contract InteractionsTest is Test{
    FundMe public fundMe;
    
    address user = makeAddr('user');
    uint256 constant SEND_VALUE= 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external{
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(user, STARTING_BALANCE);
    }
    function testUserCanFUnd() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));
    }
}