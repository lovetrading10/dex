// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPoolFactory {
  function pools(address _token1, address _token2) external view returns (address pool);

  function createPool(address token1, address token2) external;

  function setFee(uint256 _fee) external;
}
