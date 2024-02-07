// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

// https://optimistic.etherscan.io/address/0xc0d3c0d3c0d3c0d3c0d3c0d3c0d3c0d3c0d30010#code#F2#L179
// https://optimistic.etherscan.io/address/0x4200000000000000000000000000000000000010
interface IOptimismL2StandardBridge {
    function withdrawTo(
        address _l2Token,
        address _to,
        uint256 _amount,
        uint32 _minGasLimit,
        bytes calldata _extraData
    ) external payable;
}

interface IOptimismL1Bridge {
    function depositETHTo(
        address _to,
        uint32 _minGasLimit,
        bytes calldata _extraData
    ) external payable;

    function depositERC20To(
        address _l1Token,
        address _l2Token,
        address _to,
        uint256 _amount,
        uint32 _minGasLimit,
        bytes calldata _extraData
    ) external;
}
