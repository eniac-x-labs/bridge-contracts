// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IAssetBalanceManager {
    function TransferAssertToBridge(
        uint256 Blockchain,
        address _token,
        address _to,
        uint256 _amount
    ) external;
}
