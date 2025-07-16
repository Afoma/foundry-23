// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error FundMe__NotOwner();

contract FundMe {
    // allow users to send $
    // have a minimum $ spent $5
    using PriceConverter for uint256;
    // this will import the library and attach it to
    // the desired type (functions here) in our contract
    // PriceConverter to all the uint256 types here
    // with the `using` and `for`keyword
    address[] public funders;
    // this is an array of the people/addresses 
    // that are paying into this contract
    mapping (address => uint256) public addressToAmountFunded;
    // here we map the paying people/ addresses to the amount
    // they are paying into the contract

    address public immutable i_owner;
    uint256 public constant MINIMUM_USD = 5e18;
    AggregatorV3Interface private s_priceFeed;
    // 

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable{
        // it will receive funds so i make it payable
        require (msg.value.getConversionRate(s_priceFeed) > MINIMUM_USD, "didn't send enough eth");
        // getConversionRate wraps the msg.value
        // to make it in terms of usd
        // msg.value is the amount of eth paid into a contract
        funders.push(msg.sender);
        // here we push those who have paid into 
        // an array or list called funders 
        // that has their addresses
        addressToAmountFunded[msg.sender] += msg.value;
    }
    function getVersion() public view returns(uint256){
        return s_priceFeed.version();
    }
    modifier onlyOwner() {
        // require(msg.sender == owner, "Must be owner");
        if(msg.sender != i_owner) {revert FundMe__NotOwner();}
        _;
    }
    function withdraw() public onlyOwner {
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        // this will reset the funders array to an empty array
        // new array that starts at index 0
        
        /* 
        ** transfer **
        payable(msg.sender).transfer(amount);
        ** send **
        bool success = payable(msg.sender).send(this).balance;
        require (success, "No send");
        */

        // call
        (bool success,) = payable(msg.sender).call{value:address(this).balance}("");
        require(success, "No call");
    }
    receive() external payable{
        fund();
    }
    fallback() external payable{
        fund();
    }
}