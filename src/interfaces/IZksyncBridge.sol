// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;


interface IZkSyncBridge {
    function deposit(
        address _l2Receiver,
        address _l1Token,
        uint256 _amount,
        uint256 _l2TxGasLimit,
        uint256 _l2TxGasPerPubdataByte,
        address _refundRecipient
    ) external payable returns (bytes32 txHash);
    function withdraw(
        address _l1Receiver,
        address _l2Token,
        uint256 _amount
    ) external payable;

}
