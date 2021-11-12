// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IPoolFactory.sol";
import "./InitializedProxy.sol";
import "./SwapPool.sol";

contract PoolFactory is Ownable, IPoolFactory {
  mapping(address => mapping(address => address)) public override pools; // track token pairs both ways
  uint256 public poolCount; // count of all swap pool

  address public pool; // address of base pool contract
  uint256 public fee; // transaction fee for all pools

  event PoolCreated(address token1, address token2, address pool);

  constructor() {
    transferOwnership(msg.sender);
    pool = address(new SwapPool(address(this)));
  }

  // create a swap pool betweeb any token and
  function createPool(address token1, address token2) external override {
    require(token1 != token2, "Same tokens");
    require(token1 != address(0) || token1 != address(0), "Cannot initialize pool with null address");
    require(pools[token1][token2] == address(0), "Pool with token pair already created");
    bytes memory _initializationCalldata = abi.encodeWithSignature("initialize(address,address)", msg.sender, token1, token2);
    address newPoolAddress = address(new InitializedProxy(pool, _initializationCalldata));
    pools[token1][token2] = newPoolAddress;
    pools[token2][token1] = newPoolAddress; // populate in both ways to ensure reachability
    poolCount++; // is a better alternative to create a list of all pairs? (See Sushi)

    emit PoolCreated(token1, token2, newPoolAddress);
  }

  function setFee(uint256 _fee) public override onlyOwner {
    fee = _fee;
  }
}
