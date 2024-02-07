// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

interface IL1MessageQueue {
    function estimateCrossDomainMessageFee(
        uint256 _gasLimit
    ) external view returns (uint256);
}
