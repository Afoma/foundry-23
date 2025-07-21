// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from 'forge-std/Test.sol';
import {FundMe} from '../src/FundMe.sol';
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test{
    address user = makeAddr('user');
    uint256 SEND_VALUE= 0.1 ether;
    FundMe public fundMe;
    uint256 STARTING_BALANCE = 10 ether;

    function setUp() external{
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(user, STARTING_BALANCE);
    }
    function testMinimumDollarIsFive() public{
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }
    function testOwnerIsMsgSender() public{
        assertEq(fundMe.i_owner(), msg.sender);
    }
    function testPriceFeedVersionIsAccurate() public{
        uint256 version = fundMe.getVersion();
        console.log(version);
        assertEq(version, 4);
    }
    function testFundFailsWithoutEnoughETH() public{
        vm.expectRevert();
        fundMe.fund();
    }
    function testFundUpdatesFundDataStructure() public{
        vm.prank(user);
        fundMe.fund{value:SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(user);
        assertEq(amountFunded, SEND_VALUE);
    }
}