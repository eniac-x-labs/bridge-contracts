// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

library ContractsAddress {
    /******************
     **** Mainnet sepolia ****
     *****************/
    address public constant ETHAddress =
        address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    // @notice TestWETH
//    //https://sepolia.etherscan.io/token/0x7b79995e5f793a07bc00c21412e50ecae098e7f9
    address public constant WETH = 0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9;
//
   //https://etherscan.io/token/0xdac17f958d2ee523a2206206994597c13d831ec7
   address public constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

   //https://etherscan.io/token/0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48
   address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

   //https://etherscan.io/token/0x6b175474e89094c44da98b954eedeac495271d0f
   address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    //TODO
    /******************
     **** Arbitrum ****
     *****************/

    address public constant ArbitrumCustomerBridge =
        0x0000000000000000000000000000000000000001; //TODO
    address public constant ArbitrumOneL1GatewayRouter =
        0xcE18836b233C83325Cc8848CA4487e94C6288264;
    // https://sepolia.etherscan.io/address/0xA8aD8d7e13cbf556eE75CB0324c13535d8100e1E
    address public constant ArbitrumOneL1WETHGateway =
        0xA8aD8d7e13cbf556eE75CB0324c13535d8100e1E;
    //https://etherscan.io/address/0xa3A7B6F88361F48403514059F1F16C8E78d60EeC
    address public constant ArbitrumOneL1ERC20Gateway =
        0x902b3E5f8F19571859F4AB1003B960a5dF693aFF;
    //https://arbiscan.io/address/0x5288c571Fd7aD117beA99bF60FE0846C4E84F933
    address public constant ArbitrumOneL2GatewayRouter =
        0x9fDD1C4E4AA24EEc1d913FABea925594a20d43C7;
    //https://arbiscan.io/address/0x6c411aD3E74De3E7Bd422b94A27770f5B86C623B
    address public constant ArbitrumOneL2WETHGateway =
        0xCFB1f08A4852699a979909e22c30263ca249556D;
    //https://arbiscan.io/address/0x09e9222E96E7B4AE2a407B98d48e330053351EEe
    address public constant ArbitrumOneL2ERC20Gateway =
        0x6e244cD02BBB8a6dbd7F626f05B2ef82151Ab502;

    //https://arbiscan.io/address/0x82aF49447D8a07e3bd95BD0d56f35241523fBab1
    address public constant ArbitrumOneWETH =
        0x980B62Da83eFf3D4576C647993b0c1D7faf17c73;
    //TODO
    /******************
     ***** Linea ******
     *****************/

    address public constant LineaCustomerBridge =
        0x0000000000000000000000000000000000000001; //TODO
    //https://lineascan.build/token/0xe5d7c2a44ffddf6b295a15c148167daaaf5cf34f
    address public constant LineaWETH =
        0xe5D7C2a44FfDDf6b295A15c148167daaAf5Cf34f;
// @notice Polygon zkEVM is not supported Sepolia as L1
//    /*******************
//     ** Polygon ZkEVM **
//     *******************/
//    //https://docs.polygon.technology/zkEVM/architecture/protocol/zkevm-bridge/smart-contracts/
//
//    //https://etherscan.io/address/0x2a3DD3EB832aF982ec71669E178424b10Dca2EDe#readProxyContract
//    address public constant PolygonZkEVML1Bridge =
//        0x2a3DD3EB832aF982ec71669E178424b10Dca2EDe;
//    //https://zkevm.polygonscan.com/address/0x2a3DD3EB832aF982ec71669E178424b10Dca2EDe
//    address public constant PolygonZkEVML2Bridge =
//        0x2a3DD3EB832aF982ec71669E178424b10Dca2EDe;
//    //https://zkevm.polygonscan.com/token/0x4F9A0e7FD2Bf6067db6994CF12E4495Df938E6e9
//    address public constant PolygonZkEVMWETH =
//        0x4F9A0e7FD2Bf6067db6994CF12E4495Df938E6e9;
//    //https://zkevm.polygonscan.com/token/0x1e4a5963abfd975d8c9021ce480b42188849d41d
//    address public constant PolygonZkEVMUSDT =
//        0x1E4a5963aBFD975d8c9021ce480b42188849D41d;
//    //https://zkevm.polygonscan.com/token/0xa8ce8aee21bc2a48a5ef670afcc9274c7bbbc035
//    address public constant PolygonZkEVMUSDC =
//        0xA8CE8aee21bC2A48a5EF670afCc9274C7bbbC035;
//    //https://zkevm.polygonscan.com/token/0xc5015b9d9161dca7e18e32f6f25c4ad850731fd4
//    address public constant PolygonZkEVMDAI =
//        0xC5015b9d9161Dca7e18e32f6f25C4aD850731Fd4;

    /**************************
     ***** Scroll Testnet*****
     *************************/
    // https://docs.scroll.io/en/developers/scroll-contracts/#scroll-sepolia-testnet

    //https://sepolia.etherscan.io/address/0x65D123d6389b900d954677c26327bfc1C3e88A13
    address public constant ScrollL1StandardERC20Bridge =
        0x65D123d6389b900d954677c26327bfc1C3e88A13;
    //https://sepolia.etherscan.io/address/0x8A54A2347Da2562917304141ab67324615e9866d
    address public constant ScrollL1StandardWETHBridge =
        0x8A54A2347Da2562917304141ab67324615e9866d;
    //https://sepolia.scrollscan.com/address/0xaDcA915971A336EA2f5b567e662F5bd74AEf9582
    address public constant ScrollL2StandardERC20Bridge =
        0xaDcA915971A336EA2f5b567e662F5bd74AEf9582;
    //https://sepolia.scrollscan.com/address/0x481B20A927206aF7A754dB8b904B052e2781ea27
    address public constant ScrollL2StandardWETHBridge =
     0x481B20A927206aF7A754dB8b904B052e2781ea27;
    //https://sepolia.etherscan.io/address/0x8A54A2347Da2562917304141ab67324615e9866d
    address public constant ScrollL1StandardETHBridge =
        0x8A54A2347Da2562917304141ab67324615e9866d;
    //https://sepolia.etherscan.io/address/0xF0B2293F5D834eAe920c6974D50957A1732de763
    address public constant ScrollL1MessageQueue =
        0xF0B2293F5D834eAe920c6974D50957A1732de763;

//    //https://scrollscan.com/token/0xf55bec9cafdbe8730f096aa55dad6d22d44099df
//    address public constant ScrollUSDT =
//        0xf55BEC9cafDbE8730f096Aa55dad6D22d44099Df;
//    //https://scrollscan.com/token/0x06efdbff2a14a7c8e15944d1f4a48f9f95f663a4
//    address public constant ScrollUSDC =
//        0x06eFdBFf2a14a7c8E15944D1F4A48F9F95F663A4;
//    //https://scrollscan.com/token/0xca77eb3fefe3725dc33bccb54edefc3d9f764f97
//    address public constant ScrollDAI =
//        0xcA77eB3fEFe3725Dc33bccB54eDEFc3D9f764f97;
//    //https://scrollscan.com/token/0x5300000000000000000000000000000000000004
   address public constant ScrollWETH =
       0x5300000000000000000000000000000000000004;

    /***************************
     ***** Optimism Testnet *****
     **************************/

    //https://sepolia.etherscan.io/address/0xFBb0621E0B23b5478B630BD55a5f21f67730B0F1
    address public constant OptimismL1StandardBridge =
        0xFBb0621E0B23b5478B630BD55a5f21f67730B0F1;
    // https://sepolia-optimism.etherscan.io/address/0x4200000000000000000000000000000000000010
    address public constant OptimismL2StandardBridge =
        0x4200000000000000000000000000000000000010;
    // https://docs.optimism.io/chain/tokenlist#op-sepolia
//    address public constant OP_LEGACY_ERC20_ETH =
//        0xDeadDeAddeAddEAddeadDEaDDEAdDeaDDeAD0000;
//
//    //https://optimistic.etherscan.io/token/0x4200000000000000000000000000000000000006
//    address public constant OptimismWETH =
//        0x4200000000000000000000000000000000000006;
//
//    //https://optimistic.etherscan.io/token/0x94b008aa00579c1307b0ef2c499ad98a8ce58e58
//    address public constant OptimismUSDT =
//        0x94b008aA00579c1307B0EF2c499aD98a8ce58e58;
//    //https://optimistic.etherscan.io/token/0x0b2c639c533813f4aa9d7837caf62653d097ff85
//    address public constant OptimismUSDC =
//        0x0b2C639c533813f4Aa9D7837CAf62653d097Ff85;
//    //https://optimistic.etherscan.io/token/0xda10009cbd5d07dd0cecc66161fc93d7c9000da1
//    address public constant OptimismDAI =
//        0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1;


}
