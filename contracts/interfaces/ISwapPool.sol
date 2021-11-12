// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISwapPool {
  function initialize(address _token1, address _token2) external;

  function update() external;

  function getReserve() external view returns (uint256 reserve1, uint256 reserve2);
}
