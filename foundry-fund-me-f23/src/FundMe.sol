// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    // allow users to send $
    // have a minimum $ spent $5
    uint256 public minimumUsd = 5e18;
    address[] public funders;
    // this is an array of the people/addresses 
    // that are paying into this contract
    mapping (address => uint256) public addressToAmountFunded;
    // here we map the paying people/ addresses to the amount
    // they are paying into the contract
    function fund() public payable{
        // it will receive funds so i make it payable
        require (getConversionRate(msg.value) > minimumUsd, "didn't send enough eth") ;
        // getConverrsionRate wraps the msg.value
        // to make it in terms of usd
        // msg.value is the amount of eth paid into a contract
        funders.push(msg.sender);
        // here we push those who have paid into 
        // an array or list called funders 
        // that has their addresses
        addressToAmountFunded[msg.sender] = addressToAmountFunded[msg.sender] + msg.value;
    }
    function getData() public view returns (uint256) {
        // this function will return the price of eth
        // in terms of usd
        // we will use the chainlink data feed
        AggregatorV3Interface dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (
            ,
            int256 answer,// price of eth in terms of usd
            ,
            ,           
        ) = dataFeed.latestRoundData();
        return uint256(answer * 1e10); 
        // the uin256 that wraps the answer is to convert
        // int256 to uin256. this method is called type casting
        // 1e10 is used to convert the price to 18 decimals
    }
    function getConversionRate(uint256 ethAmount) public view returns(uint256){
        // this function will convert the eth amount we got 
        // in the getData function to usd
        uint256 ethPrice = getData();
        uint256 ethAmountInUsd = (ethPrice*ethAmount) / 1e18;
        // in solidity, we multiply before dividing
        // to avoid precision loss
        // we divide their result by 1e18 since each of them-
        // ethPrice and ethAmount are in 18 decimals
        // and their result will be in 36 decimal places
        // and this will be too much for our readability
        return ethAmountInUsd;

    }
    function getVersion() public view returns(uint256){
        return AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306).version();
    }
}