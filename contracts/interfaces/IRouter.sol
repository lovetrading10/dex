// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRouter {
  function quoteAsset(
    uint256 _amount1,
    uint256 _reserve1,
    uint256 _reserve2
  ) external returns (uint256 _amount2);

  function calculateLiquidity(
    address _poolAddress,
    uint256 _targetAmount1,
    uint256 _targetAmount2
  ) external returns (uint256 _amount1, uint256 _amount2);

  function deposit(
    address _token1,
    address _token2,
    uint256 _tokenAmount1,
    uint256 _tokenAmount2
  ) external payable;
}
