// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./helpers/SafeMath.sol";
import "./interfaces/IPoolFactory.sol";
import "./interfaces/ISwapPool.sol";
import "./interfaces/IRouter.sol";

contract Router is IRouter {
    using SafeMath for uint256;
    address public factory;

    constructor(address _factory) {
        factory = _factory;
    }

    event Deposit(
        address sender,
        address _token1,
        address _token2,
        uint256 tokenAmount1,
        uint256 tokenAmount2
    );

    function quoteAsset(
        uint256 _amount1,
        uint256 _reserve1,
        uint256 _reserve2
    ) public pure override returns (uint256 _amount2) {
        _amount2 = _amount1.mul(_reserve2) / _reserve1; // add safe math
    }

    function calculateLiquidity(
        address _poolAddress,
        uint256 _targetAmount1,
        uint256 _targetAmount2
    ) public view override returns (uint256 _amount1, uint256 _amount2) {
        (uint256 _reserve1, uint256 _reserve2) = ISwapPool(_poolAddress).getReserve(); // fetch how much pool has stored as reserve from pool contracts
        uint256 _bAmount = quoteAsset(_amount1, _reserve1, _reserve2);

        // TODO: Check math here lmao
        if (_bAmount > _targetAmount2) {
            // if the calculated amount for asset B exceeds what you have
            uint256 _aAmount = quoteAsset(_amount2, _reserve2, _reserve1);
            require(_aAmount < _targetAmount1, "Inssuficient liquidity");
            (_amount1, _amount2) = (_aAmount, _targetAmount2);
        } else {
            (_amount1, _amount2) = (_targetAmount1, _bAmount);
        }
    }

    // Deposit liquidity: user sends equal amount of each token
    function deposit(
        address _token1,
        address _token2,
        uint256 _tokenAmount1,
        uint256 _tokenAmount2
    ) public payable override {
        require(IPoolFactory(factory).pools(_token1, _token2) != address(0), "Pool doesn't exist");
        address poolAddress = IPoolFactory(factory).pools(_token1, _token2);
        (uint256 _amount1, uint256 _amount2) = calculateLiquidity(
            poolAddress,
            _tokenAmount1,
            _tokenAmount2
        );
        IERC20(_token1).transferFrom(msg.sender, poolAddress, _amount1); // why does Uni use a specia abi.encode function for safe transfer of assets?
        IERC20(_token2).transferFrom(msg.sender, poolAddress, _amount2);
        // add LP reward
        emit Deposit(msg.sender, _token1, _token2, _tokenAmount1, _tokenAmount2);
    }
}
