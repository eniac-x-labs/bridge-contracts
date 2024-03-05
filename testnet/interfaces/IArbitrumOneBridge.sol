// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

interface IArbitrumOneL1Bridge {
    function outboundTransferCustomRefund(
        address _token,
        address _refundTo,
        address _to,
        uint256 _amount,
        uint256 _maxGas,
        uint256 _gasPriceBid,
        bytes calldata _data
    ) external payable returns (bytes memory);
}

interface IArbitrumOneL1WETHBridge {
       function outboundTransfer(
        address _token,
        address _to,
        uint256 _amount,
        uint256 _maxGas,
        uint256 _gasPriceBid,
        bytes calldata _data
    ) public payable  returns (bytes memory); 
}

interface IArbitrumOneL2Bridge {
    function outboundTransfer(
        address _l1Token,
        address _to,
        uint256 _amount,
        bytes calldata _data
    ) external payable returns (bytes memory);
}

interface IArbitrumOneL2ETHBridge {
    function withdrawEth(
        address destination
    ) external payable returns (uint256);
}
