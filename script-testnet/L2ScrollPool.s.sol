// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import "testnet/core/L2/L2PoolManager.sol";
import "testnet/core/Proxy.sol";
import "testnet/core/ProxyTimeLockController.sol";
import "testnet/core/message/MessageManager.sol";


contract L2PoolDeployer is Script {
    address admin;
    address ReLayer;
    Proxy proxyL2Pool;
    Proxy proxyMessageManager;
    ProxyTimeLockController proxyTimeLockController;
    L2PoolManager l2PoolManager;
    MessageManager messageManager;
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

        l2PoolManager = new L2PoolManager();
        messageManager = new MessageManager();


//        proxyTimeLockController = new ProxyTimeLockController(minDelay, proposers, executors, admin);
//
//        bytes memory messageData = abi.encodeWithSignature("initialize()");
//        proxyMessageManager = new Proxy(address(messageManager), address(proxyTimeLockController), messageData);
//
//        bytes memory poolManagerData = abi.encodeWithSignature("initialize(address,address)", address(admin), address(proxyMessageManager));
//        proxyL2Pool = new Proxy(address(l2PoolManager), address(proxyTimeLockController), poolManagerData);

        proxyL2Pool = new Proxy(address(l2PoolManager), address(admin), "");
        proxyMessageManager = new Proxy(address(messageManager), address(admin), "");
        MessageManager(address(proxyMessageManager)).initialize(address(proxyL2Pool));
        L2PoolManager(address(proxyL2Pool)).initialize(address(admin),address(proxyMessageManager));



    L2PoolManager(address(proxyL2Pool)).grantRole(l2PoolManager.ReLayer(), ReLayer);
        L2PoolManager(address(proxyL2Pool)).setValidChainId(11155111, true);  // sepolia
        L2PoolManager(address(proxyL2Pool)).setValidChainId(1442, true);  // Polygon zkevm Testnet
        L2PoolManager(address(proxyL2Pool)).setValidChainId(11155420, true);  // OP Sepolia
        L2PoolManager(address(proxyL2Pool)).setValidChainId(300, true);  // Zksync Sepolia
        L2PoolManager(address(proxyL2Pool)).setValidChainId(84532, true);  // Base Sepolia
        L2PoolManager(address(proxyL2Pool)).setValidChainId(421614, true);  // ARB Sepolia
        L2PoolManager(address(proxyL2Pool)).setSupportERC20Token(0xa15165F0923D3BFab6E532b2177Df64BDa5A6533, true);
        
        vm.stopBroadcast();
    }
}
