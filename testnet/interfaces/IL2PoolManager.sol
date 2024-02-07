// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

interface IL2PoolManager {
    event WithdrawETHtoL1Success(
        uint256 chainId,
        uint256 timestamp,
        address to,
        uint256 value
    );

    event WithdrawWETHtoL1Success(
        uint256 chainId,
        uint256 timestamp,
        address to,
        uint256 value
    );

    event WithdrawERC20toL1Success(
        uint256 chainId,
        uint256 timestamp,
        address token,
        address to,
        uint256 value
    );
}
