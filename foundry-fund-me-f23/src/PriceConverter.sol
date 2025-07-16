// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
        function getData(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        // this function will return the price of eth
        // in terms of usd
        // we will use the chainlink data feed
        (
            ,
            int256 answer,// price of eth in terms of usd
            ,
            ,           
        ) = priceFeed.latestRoundData();
        return uint256(answer * 1e10); 
        // the uin256 that wraps the answer is to convert
        // int256 to uin256. this method is called type casting
        // 1e10 is used to convert the price to 18 decimals
    }
    function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns(uint256){
        // this function will convert the eth amount we got 
        // in the getData function to usd
        uint256 ethPrice = getData(priceFeed);
        uint256 ethAmountInUsd = (ethPrice*ethAmount) / 1e18;
        // in solidity, we multiply before dividing
        // to avoid precision loss
        // we divide their result by 1e18 since each of them-
        // ethPrice and ethAmount are in 18 decimals
        // and their result will be in 36 decimal places
        // and this will be too much for our readability
        return ethAmountInUsd;

    }
}