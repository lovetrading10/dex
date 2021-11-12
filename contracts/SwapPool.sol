// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/ISwapPool.sol";
import "./PoolFactory.sol";

contract SwapPool is ISwapPool {
  bool private paused;
  bool public hasInitialized;

  address public factory;
  address public token1; // 1st token
  address public token2; // 2nd token

  uint256 public tokenReserve1;
  uint256 public tokenReserve2;

  uint256 public exchangeRate; // store 4 decimal points. Divide by 10,000 to get real exchange rate

  constructor(address _factoryContract) {
    hasInitialized = true;
    factory = _factoryContract;
  }

  function initialize(address _token1, address _token2) public override {
    require(hasInitialized == false, "Pool initialized before");
    token1 = _token1;
    token2 = _token2;
  }

  function update() public override {
    tokenReserve1 = IERC20(token1).balanceOf(address(this));
    tokenReserve2 = IERC20(token2).balanceOf(address(this));
  }

  function getReserve() public view override returns (uint256 reserve1, uint256 reserve2) {
    (reserve1, reserve2) = (tokenReserve1, tokenReserve2);
  }

  // TODO: add multiplier to incentivize early liquidity providers

  modifier unpaused() {
    require(paused == false, "Pool is paused");
    _;
  }
}
