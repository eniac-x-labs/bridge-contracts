// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import "src/core/L1/L1PoolManager.sol";
import "src/core/Proxy.sol";
import "src/core/ProxyTimeLockController.sol";
import "src/core/message/MessageManager.sol";
import "src/core/L1/AssetBalanceManager.sol";



contract l1PoolDeployer is Script {
    address admin;
    address ReLayer;
    Proxy proxyL1Pool;
    Proxy proxyMessageManager;
    Proxy proxyAssetBalanceManager;

    ProxyTimeLockController proxyTimeLockController;
    L1PoolManager l1PoolManage;
    MessageManager messageManager;
    AssetBalanceManager assetBalanceManager;
    function setUp() public {
        admin = 0x4089d9B3553b1faeF73526dae65737746f7a37c8;
        ReLayer = 0x4089d9B3553b1faeF73526dae65737746f7a37c8;
    }

    function run() external {
        vm.startBroadcast(0x4089d9B3553b1faeF73526dae65737746f7a37c8);
        uint256 minDelay = 7 days;
        address[] memory proposers = new address[](0);
        address[] memory executors = new address[](1);
        executors[0] = admin;

        l1PoolManage = new L1PoolManager();
        messageManager = new MessageManager();
        assetBalanceManager = new AssetBalanceManager();
//        bytes memory messageData = abi.encodeWithSignature("initialize()");
//
//        proxyMessageManager = new Proxy(address(messageManager), address(proxyTimeLockController), messageData);
//        bytes memory _data = abi.encodeWithSignature("initialize(address,address)", address(admin), address(proxyMessageManager));
//
//        proxyL1Pool = new Proxy(address(l1PoolManage), address(proxyTimeLockController), _data);
        proxyL1Pool = new Proxy(address(l1PoolManage), address(admin), "");
        proxyMessageManager = new Proxy(address(messageManager), address(admin), "");
        proxyAssetBalanceManager = new Proxy(address(assetBalanceManager), address(admin), "");
        MessageManager(address(proxyMessageManager)).initialize(address(proxyL1Pool));
        L1PoolManager(address(proxyL1Pool)).initialize(address(admin),address(proxyMessageManager), address(proxyAssetBalanceManager));
        AssetBalanceManager(address(proxyAssetBalanceManager)).initialize(address(proxyL1Pool));

        L1PoolManager(address(proxyL1Pool)).grantRole(l1PoolManage.ReLayer(), ReLayer);
        uint32 startTime = uint32(block.timestamp - block.timestamp % 86400 + 86400); // tomorrow
        L1PoolManager(address(proxyL1Pool)).setValidChainId(10, true);  //  Op Mainnet
        L1PoolManager(address(proxyL1Pool)).setValidChainId(534352, true);    // Scroll Mainnet
        L1PoolManager(address(proxyL1Pool)).setSupportToken(ContractsAddress.ETHAddress, true, startTime);
        L1PoolManager(address(proxyL1Pool)).setSupportToken(0xdAC17F958D2ee523a2206206994597C13D831ec7, true, startTime); //usdt
        L1PoolManager(address(proxyL1Pool)).setSupportToken(0x75231F58b43240C9718Dd58B4967c5114342a86c, true, startTime); //okb
        L1PoolManager(address(proxyL1Pool)).setSupportERC20Token(0xdAC17F958D2ee523a2206206994597C13D831ec7, true);
        L1PoolManager(address(proxyL1Pool)).setSupportERC20Token(0x75231F58b43240C9718Dd58B4967c5114342a86c, true);

        vm.stopBroadcast();
    }
}
