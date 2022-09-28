// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import {IERC20} from "./interface/IERC20.sol";


interface AggregatorV3Interface {
  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int answer,
      uint startedAt,
      uint updatedAt,
      uint80 answeredInRound
    );
}


// Price oracle interface 
/// @title Oracle Swap
/// @notice this contract take in USDC and send DETH to the user 
contract OracleSwap {
  AggregatorV3Interface internal priceFeed;
  address private deth_token;
  address private usdc_address;

  constructor(address _deth_token, address _usdc_address) {
    priceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
    deth_token = _deth_token;
    usdc_address = _usdc_address;
  }

  event Swapped(address swapper, uint256 amount);


  error NotTransfered();




  function getLatestPrice() public view returns (int) {
    (
      uint80 roundID,
      int price,
      uint startedAt,
      uint timeStamp,
      uint80 answeredInRound
    ) = priceFeed.latestRoundData();
    return price / 1e8;
  }

  function swap(uint256 _amount) public returns(bool swapped_) {

    // transfer usdc token to contract 
    (bool transfered) = IERC20(usdc_address).transferFrom(msg.sender, address(this), _amount);

    if(!transfered) {
        revert NotTransfered();
    }

    // convert
    uint256 oneEther = uint256(getLatestPrice()) * 1 ether;

    uint256 toSent = _amount / oneEther;


    // sending deth
    (bool sent ) = IERC20(deth_token).transfer(msg.sender, toSent);


    if(!sent) {
        revert NotTransfered();
    }


    // emit
    emit Swapped(msg.sender, _amount);
  }
}

