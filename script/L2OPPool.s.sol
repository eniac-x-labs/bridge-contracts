// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import "src/core/L2/L2PoolManager.sol";
import "src/core/Proxy.sol";
import "src/core/ProxyTimeLockController.sol";
import "src/core/message/MessageManager.sol";


contract L2PoolDeployer is Script {
    address admin;
    address ReLayer;
    Proxy proxyL2Pool;
    Proxy proxyMessageManager;
    ProxyTimeLockController proxyTimeLockController;
    L2PoolManager l2PoolManager;
    MessageManager messageManager;
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

        l2PoolManager = new L2PoolManager();
        messageManager = new MessageManager();

        proxyL2Pool = new Proxy(address(l2PoolManager), address(admin), "");
        proxyMessageManager = new Proxy(address(messageManager), address(admin), "");
        MessageManager(address(proxyMessageManager)).initialize(address(proxyL2Pool));
        L2PoolManager(address(proxyL2Pool)).initialize(address(admin),address(proxyMessageManager));



        L2PoolManager(address(proxyL2Pool)).grantRole(l2PoolManager.ReLayer(), ReLayer);
        L2PoolManager(address(proxyL2Pool)).setValidChainId(1, true);  // eth mainnet
        L2PoolManager(address(proxyL2Pool)).setValidChainId(534352, true);    // Scroll mainnet

        L2PoolManager(address(proxyL2Pool)).setSupportERC20Token(0x94b008aA00579c1307B0EF2c499aD98a8ce58e58, true); //usdt
        

        vm.stopBroadcast();
    }
}
