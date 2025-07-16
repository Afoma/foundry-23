// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;
    address[] public funders;
    mapping (address => uint256) public addressToAmountFunded;

    address public immutable i_owner;
    uint256 public constant MINIMUM_USD = 5e18;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable{
        require (msg.value.getConversionRate(s_priceFeed) > MINIMUM_USD, "didn't send enough eth");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }
    function getVersion() public view returns(uint256){
        return s_priceFeed.version();
    }
    modifier onlyOwner() {
        if(msg.sender != i_owner) {revert FundMe__NotOwner();}
        _;
    }
    function withdraw() public onlyOwner {
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
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