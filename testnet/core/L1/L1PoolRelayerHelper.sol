// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../bridge/TokenBridgeBase.sol";
import "../../interfaces/IL1PoolManager.sol";
import "../../interfaces/WETH.sol";
import "../../interfaces/IScrollBridge.sol";
import "../../interfaces/IPolygonZkEVMBridge.sol";
import "../../interfaces/IOptimismBridge.sol";
import "../../interfaces/IArbitrumOneBridge.sol";
import "../../interfaces/IArbitrumNovaBridge.sol";
import "../../interfaces/IZksyncBridge.sol";
import "../../interfaces/IMantleBridge.sol";
import "../../interfaces/IMantaBridge.sol";
import "../../interfaces/IMessageManager.sol";
import "../libraries/ContractsAddress.sol";
import "../../interfaces/IL1MessageQueue.sol";

contract L1PoolRelayerHelper  {
    using SafeERC20 for IERC20;

    /***************************************
     ***** Relayer function *****
     ***************************************/
    function TransferAssertToBridgePrev(
        uint256 Blockchain,
        address _token,
        address _to,
        uint256 _amount
    ) internal {
        if (Blockchain == 0x8274f) {
            //https://chainlist.org/chain/534352
            //Scroll

            //
            TransferAssertToScrollBridge(_token, _to, _amount);
        } 
        // else if (Blockchain == 0x5a2) {
        //     //https://chainlist.org/chain/1101
        //     //Polygon zkEVM
        //     TransferAssertToPolygonZkevmBridge(_token, _to, _amount);
        // } 
        else if (Blockchain == 0xaa37dc) {
            //https://chainlist.org/chain/10
            //OP Mainnet
            TransferAssertToOptimismBridge(_token, _to, _amount);
        } else if (Blockchain == 0x66eee) {
            //https://chainlist.org/chain/42161
            //Arbitrum One

            TransferAssertToArbitrumOneBridge(_token, _to, _amount);
        } 
        //No Arbitrum Nova Testnet
        //  else if (Blockchain == 0x12c) {
        //     //https://chainlist.org/chain/324
        //     //ZkSync Mainnet
        //     TransferAssertToZkSyncBridge(_token, _to, _amount);
        // }  else if (Blockchain == 0x138b){
        //     //Mantle Mainnet https://chainlist.org/chain/5000
        //     TransferAssertToMantleBridge(_token, _to, _amount);
        // }
        // else if (Blockchain == 0x34816d){
        //     //Manta Pacific Mainnet https://chainlist.org/chain/169
        //     TransferAssertToMantaBridge(_token, _to, _amount);
        // }
        // else if (Blockchain == 0xab4b){
        //     //ZKFair Mainnet https://chainlist.org/chain/42766
        //     TransferAssertToZKFairBridge(_token, _to, _amount);
        // } 
        else {
            revert ErrorBlockChain();
        }
    }

    function TransferAssertToArbitrumOneBridge(
        address _token,
        address _to,
        uint256 _amount
    ) internal {
        if (_token == address(ContractsAddress.ETHAddress)) {
            IArbitrumOneL1Bridge(ContractsAddress.ArbitrumOneL1GatewayRouter)
                .outboundTransferCustomRefund{value: _amount}(
                ContractsAddress.ETHAddress,
                address(this),
                _to,
                _amount,
                0,
                0,
                ""
            );
        } else if (_token == address(ContractsAddress.WETH)) {
            IERC20(_token).approve(
                ContractsAddress.ArbitrumOneL1WETHGateway,
                _amount
            );
            IArbitrumOneL1Bridge(ContractsAddress.ArbitrumOneL1WETHGateway)
                .outboundTransferCustomRefund(
                    _token,
                    address(this),
                    _to,
                    _amount,
                    0,
                    0,
                    ""
                );
        } else {
            IERC20(_token).approve(
                ContractsAddress.ArbitrumOneL1ERC20Gateway,
                _amount
            );
            IArbitrumOneL1Bridge(ContractsAddress.ArbitrumOneL1ERC20Gateway)
                .outboundTransferCustomRefund(
                    _token,
                    address(this),
                    _to,
                    _amount,
                    0,
                    0,
                    ""
                );
        }
    }

    // function TransferAssertToArbitrumNovaBridge(
    //     address _token,
    //     address _to,
    //     uint256 _amount
    // ) internal {
    //     if (_token == address(ContractsAddress.ETHAddress)) {
    //         IArbitrumNovaL1Bridge(ContractsAddress.ArbitrumNovaL1GatewayRouter)
    //             .outboundTransferCustomRefund{value: _amount}(
    //             ContractsAddress.ETHAddress,
    //             address(this),
    //             _to,
    //             _amount,
    //             0,
    //             0,
    //             ""
    //         );
    //     } else if (_token == address(ContractsAddress.WETH)) {
    //         IERC20(_token).approve(
    //             ContractsAddress.ArbitrumNovaL1WETHGateway,
    //             _amount
    //         );
    //         IArbitrumNovaL1Bridge(ContractsAddress.ArbitrumNovaL1WETHGateway)
    //             .outboundTransferCustomRefund(
    //                 _token,
    //                 address(this),
    //                 _to,
    //                 _amount,
    //                 0,
    //                 0,
    //                 ""
    //             );
    //     } else {
    //         IERC20(_token).approve(
    //             ContractsAddress.ArbitrumNovaL1ERC20Gateway,
    //             _amount
    //         );
    //         IArbitrumNovaL1Bridge(ContractsAddress.ArbitrumNovaL1ERC20Gateway)
    //             .outboundTransferCustomRefund(
    //                 _token,
    //                 address(this),
    //                 _to,
    //                 _amount,
    //                 0,
    //                 0,
    //                 ""
    //             );
    //     }
    // }

    function TransferAssertToScrollBridge(
        address _token,
        address _to,
        uint256 _amount
    ) internal {
        if (_token == address(ContractsAddress.ETHAddress)) {
            uint fee = IL1MessageQueue(ContractsAddress.ScrollL1MessageQueue)
                .estimateCrossDomainMessageFee(170000);
            IScrollStandardL1ETHBridge(
                ContractsAddress.ScrollL1StandardETHBridge
            ).depositETH{value: _amount + fee}(_to, _amount, 170000);
        } else if (_token == address(ContractsAddress.WETH)) {
            uint fee = IL1MessageQueue(ContractsAddress.ScrollL1MessageQueue)
                .estimateCrossDomainMessageFee(20000);
            IERC20(_token).approve(
                ContractsAddress.ScrollL1StandardWETHBridge,
                _amount
            );
            IScrollStandardL1WETHBridge(
                ContractsAddress.ScrollL1StandardWETHBridge
            ).depositERC20(_token, _to, _amount, 20000);
        } else {
            uint fee = IL1MessageQueue(ContractsAddress.ScrollL1MessageQueue)
                .estimateCrossDomainMessageFee(20000);
            IERC20(_token).approve(
                ContractsAddress.ScrollL1StandardWETHBridge,
                _amount
            );
            IScrollStandardL1ERC20Bridge(
                ContractsAddress.ScrollL1StandardERC20Bridge
            ).depositERC20(_token, _to, _amount, 20000);
        }
    }

    // function TransferAssertToPolygonZkevmBridge(
    //     address _token,
    //     address _to,
    //     uint256 _amount
    // ) internal {
    //     if (_token == address(ContractsAddress.ETHAddress)) {
    //         IPolygonZkEVML1Bridge(ContractsAddress.PolygonZkEVML1Bridge)
    //             .bridgeAsset{value: _amount}(
    //             0x1,
    //             _to,
    //             _amount,
    //             address(0),
    //             false,
    //             ""
    //         );
    //     } else {
    //         IERC20(_token).approve(
    //             ContractsAddress.PolygonZkEVML1Bridge,
    //             _amount
    //         );
    //         IPolygonZkEVML1Bridge(ContractsAddress.PolygonZkEVML1Bridge)
    //             .bridgeAsset(0x1, _to, _amount, _token, false, "");
    //     }
    // }

    // function TransferAssertToZKFairBridge(
    //     address _token,
    //     address _to,
    //     uint256 _amount
    // ) internal {
    //     if (_token == address(ContractsAddress.ETHAddress)) {
    //         IPolygonZkEVML1Bridge(ContractsAddress.ZKFairL1Bridge)
    //             .bridgeAsset{value: _amount}(
    //             0x1,
    //             _to,
    //             _amount,
    //             address(0),
    //             false,
    //             ""
    //         );
    //     } else {
    //         IERC20(_token).approve(
    //             ContractsAddress.ZKFairL1Bridge,
    //             _amount
    //         );
    //         IPolygonZkEVML1Bridge(ContractsAddress.ZKFairL1Bridge)
    //             .bridgeAsset(0x1, _to, _amount, _token, false, "");
    //     }
    // }
    
    function TransferAssertToOptimismBridge(
        address _token,
        address _to,
        uint256 _amount
    ) internal {
        if (_token == address(ContractsAddress.ETHAddress)) {
            IOptimismL1Bridge(ContractsAddress.OptimismL1StandardBridge)
                .depositETHTo{value: _amount}(_to, 0, "");
        } else {
            address l2token = getOPL2TokenAddress(_token);
            IERC20(_token).approve(
                ContractsAddress.OptimismL1StandardBridge,
                _amount
            );
            IOptimismL1Bridge(ContractsAddress.OptimismL1StandardBridge)
                .depositERC20To(
                    _token,
                    l2token,
                    _to,
                    _amount,
                    uint32(gasleft()),
                    ""
                );
        }
    }

    // function TransferAssertToMantaBridge(
    //     address _token,
    //     address _to,
    //     uint256 _amount
    // ) internal {
    //     if (_token == address(ContractsAddress.ETHAddress)) {
    //         IMantaL1Bridge(ContractsAddress.MantaL1Bridge)
    //             .depositETHTo{value: _amount}(_to, 0, "");
    //     } else {
    //         address l2token = getMantaL2TokenAddress(_token);
    //         IERC20(_token).approve(
    //             ContractsAddress.MantaL1Bridge,
    //             _amount
    //         );
    //         IMantaL1Bridge(ContractsAddress.MantaL1Bridge)
    //             .depositERC20To(
    //                 _token,
    //                 l2token,
    //                 _to,
    //                 _amount,
    //                 uint32(gasleft()),
    //                 ""
    //             );
    //     }
    // }

    // function TransferAssertToZkSyncBridge(
    //     address _token,
    //     address _to,
    //     uint256 _amount
    // ) internal {
    //     if (_token == address(ContractsAddress.ETHAddress)) {
    //         IZkSyncBridge(ContractsAddress.ZkSyncL1Bridge).deposit{value: _amount}(
    //             _to,
    //             address(0),
    //             _amount,
    //             0,
    //             0,
    //             address(this)
    //         );
    //     } else {
    //         IERC20(_token).approve(ContractsAddress.ZkSyncL1Bridge, _amount);
    //         IZkSyncBridge(ContractsAddress.ZkSyncL1Bridge).deposit(
    //              _to,
    //             _token,
    //             _amount,
    //             0,
    //             0,
    //             address(this)
    //         );
    //     }

    // }

    // function TransferAssertToMantleBridge(
    //     address _token,
    //     address _to,
    //     uint256 _amount
    // ) internal {
    //     if (_token == address(ContractsAddress.ETHAddress)) {
    //         IMantleL1Bridge(ContractsAddress.MantleL1Bridge).depositETHTo(
    //             _to,
    //             0,
    //             ""
    //         );
    //     } else {
    //         IERC20(_token).approve(ContractsAddress.MantleL1Bridge, _amount);
    //         IMantleL1Bridge(ContractsAddress.MantleL1Bridge).depositERC20To(
    //             _token,
    //             getMantleL2TokenAddress(_token),
    //             _to,
    //             _amount,
    //             0,
    //             ""
    //         );
    //     }
    // }
    
    //https://github.com/ethereum-optimism/ethereum-optimism.github.io/blob/master/data
    function getOPL2TokenAddress(
        address _token
    ) internal pure returns (address) {
        if (_token == ContractsAddress.WETH) {
            return 0x4200000000000000000000000000000000000006;
        } else if (_token == ContractsAddress.USDT) {
            return 0x94b008aA00579c1307B0EF2c499aD98a8ce58e58;
        } else if (_token == ContractsAddress.USDC) {
            return 0x0b2C639c533813f4Aa9D7837CAf62653d097Ff85;
        } else if (_token == ContractsAddress.DAI) {
            return 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1;
        } else {
            revert TokenIsNotSupported(_token);
        }
    }
    //https://github.com/mantlenetworkio/mantle-token-lists/tree/main/data
    function getMantleL2TokenAddress(
        address _token
    ) internal pure returns (address) {
        if (_token == ContractsAddress.USDT) {
            return 0x201EBa5CC46D216Ce6DC03F6a759e8E766e956aE;
        } else if (_token == ContractsAddress.USDC) {
            return 0x201EBa5CC46D216Ce6DC03F6a759e8E766e956aE;
        }  else {
            revert TokenIsNotSupported(_token);
        }

}

    //https://github.com/Manta-Network/manta-pacific-token-list
    function getMantaL2TokenAddress(
        address _token
    ) internal pure returns (address) {
        if (_token == ContractsAddress.USDT) {
            return 0xf417F5A458eC102B90352F697D6e2Ac3A3d2851f;
        } else if (_token == ContractsAddress.USDC) {
            return 0xb73603C5d87fA094B7314C74ACE2e64D165016fb;
        }  else if (_token == ContractsAddress.DAI){
            return 0x1c466b9371f8aBA0D7c458bE10a62192Fcb8Aa71;
        }else {
            revert TokenIsNotSupported(_token);
        }
    }
}