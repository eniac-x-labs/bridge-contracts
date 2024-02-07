// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

interface IPolygonZkEVML1Bridge {
    function bridgeAsset(
        uint32 destinationNetwork,
        address destinationAddress,
        uint256 amount,
        address token,
        bool forceUpdateGlobalExitRoot,
        bytes calldata permitData
    ) external payable;
}

//https://zkevm.polygonscan.com/address/0x2a3dd3eb832af982ec71669e178424b10dca2ede#writeProxyContract
//https://zkevm.polygonscan.com/address/0x5ac4182a1dd41aeef465e40b82fd326bf66ab82c#code#L1991
interface IPolygonZkEVML2Bridge {
    function bridgeAsset(
        uint32 destinationNetwork,
        address destinationAddress,
        uint256 amount,
        address token,
        bool forceUpdateGlobalExitRoot,
        bytes calldata permitData
    ) external payable;
}
