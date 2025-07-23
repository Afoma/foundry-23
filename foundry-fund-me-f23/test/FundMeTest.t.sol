// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from 'forge-std/Test.sol';
import {FundMe} from '../src/FundMe.sol';
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test{
    uint256 constant GAS_PRICE = 1;
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
        assertEq(fundMe.getOwner(), msg.sender);
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
    function testAddsFunderToArrayOfFunders() public{
        vm.startPrank(user);
        fundMe.fund{value: SEND_VALUE}();
        vm.stopPrank();
        address funder = fundMe.getFunder(0);
        assertEq(funder,user);
    }
    modifier funded(){
        vm.prank(user);
        fundMe.fund{value: SEND_VALUE}();
        assert(address(fundMe).balance > 0);
        _;
    }
    function testOnlyOwnerCanWithdraw() public{
        vm.expectRevert();
        fundMe.withdraw();
    }
    function testWithdrawFromASingleFunder() public{
        // Arrange
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        // Act
        uint256 gasStart = gasleft(); // example: 1000
        console.log(gasStart);
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());  // example: 200
        fundMe.withdraw();
        uint256 gasEnd = gasleft();   // 800
        console.log(gasEnd);
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log("Withdraw consumed: %d gas", gasUsed);
        // Assert
        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }
function testWithdrawFromMultipleFunders() public funded {
    // Arrange
    uint160 numberOfFunders = 10;
    uint160 startingFunderIndex = 1;
    for (uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++) {
        hoax(address(i), SEND_VALUE);
        fundMe.fund{value: SEND_VALUE}();
    }
    uint256 startingFundMeBalance = address(fundMe).balance;
    uint256 startingOwnerBalance = fundMe.getOwner().balance;
    // Act
    vm.startPrank(fundMe.getOwner());
    fundMe.withdraw();
    vm.stopPrank();
    // Assert
    assert(address(fundMe).balance == 0);
    assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    assert((numberOfFunders + 1) * SEND_VALUE == fundMe.getOwner().balance - startingOwnerBalance);
}
}