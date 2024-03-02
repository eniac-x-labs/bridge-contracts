// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import "testnet/core/L1/L1PoolManager.sol";
import "testnet/core/Proxy.sol";
import "testnet/core/ProxyTimeLockController.sol";
import "testnet/core/message/MessageManager.sol";


contract l1PoolDeployer is Script {
    address admin;
    address ReLayer;
    Proxy proxyL1Pool;
    Proxy proxyMessageManager;
    ProxyTimeLockController proxyTimeLockController;
    L1PoolManager l1PoolManage;
    MessageManager messageManager;
    address USDT = 0x523C8591Fbe215B5aF0bEad65e65dF783A37BCBC;
    function setUp() public {
        admin = 0x8061C28b479B846872132F593bC7cbC6b6C9D628;
        ReLayer = 0x8061C28b479B846872132F593bC7cbC6b6C9D628;
    }

    function run() external {
        vm.startBroadcast(0x8061C28b479B846872132F593bC7cbC6b6C9D628);
        uint256 minDelay = 7 days;
        address[] memory proposers = new address[](0);
        address[] memory executors = new address[](1);
        executors[0] = admin;

        l1PoolManage = new L1PoolManager();
        messageManager = new MessageManager();
//        bytes memory messageData = abi.encodeWithSignature("initialize()");
//
//        proxyMessageManager = new Proxy(address(messageManager), address(proxyTimeLockController), messageData);
//        bytes memory _data = abi.encodeWithSignature("initialize(address,address)", address(admin), address(proxyMessageManager));
//
//        proxyL1Pool = new Proxy(address(l1PoolManage), address(proxyTimeLockController), _data);
        proxyL1Pool = new Proxy(address(l1PoolManage), address(admin), "");
        proxyMessageManager = new Proxy(address(messageManager), address(admin), "");
        MessageManager(address(proxyMessageManager)).initialize(address(proxyL1Pool));
        L1PoolManager(address(proxyL1Pool)).initialize(address(admin),address(proxyMessageManager));

        L1PoolManager(address(proxyL1Pool)).grantRole(l1PoolManage.ReLayer(), ReLayer);
        uint32 startTime = uint32(block.timestamp - block.timestamp % 86400 + 86400); // tomorrow
        L1PoolManager(address(proxyL1Pool)).setValidChainId(1442, true);  // Polygon zkevm Testnet
        L1PoolManager(address(proxyL1Pool)).setValidChainId(11155420, true);  // OP Sepolia
        L1PoolManager(address(proxyL1Pool)).setValidChainId(534351, true);    // Scroll Sepolia
        L1PoolManager(address(proxyL1Pool)).setValidChainId(421614, true);    // ARB Sepolia
        L1PoolManager(address(proxyL1Pool)).setValidChainId(84532, true);    // Base Sepolia
        L1PoolManager(address(proxyL1Pool)).setValidChainId(300, true);    // Zksync Sepolia
        L1PoolManager(address(proxyL1Pool)).setSupportToken(ContractsAddress.ETHAddress, true, startTime);
        L1PoolManager(address(proxyL1Pool)).setSupportToken(ContractsAddress.WETH, true, startTime);
        L1PoolManager(address(proxyL1Pool)).setSupportToken(0xEB0684E79Ac35D64cDef3cCFB09f899ddACb5a54, true, startTime);
        L1PoolManager(address(proxyL1Pool)).setSupportERC20Token(0xEB0684E79Ac35D64cDef3cCFB09f899ddACb5a54, true);

        vm.stopBroadcast();
    }
}
