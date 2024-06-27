pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "src/core/L2/L2PoolManager.sol";
import "src/core/Proxy.sol";
import "src/core/ProxyTimeLockController.sol";
import "src/interfaces/IL1PoolManager.sol";
import "src/core/message/MessageManager.sol";
import "src/Mock/mockWETH.sol";
import "src/Mock/mockERC20.sol";

contract L1PoolTest is Test {
    address admin;
    address ReLayer;

    ProxyTimeLockController proxyTimeLockController;
    Proxy l2Poolproxy;
    Proxy l2Messageproxy;
    L2PoolManager l2Pool;
    MessageManager l2Message;
    address ETHAddress = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;


    fallback() external payable {}
    receive() external payable {}

    function setUp() public {

        admin = makeAddr("admin");
        ReLayer = makeAddr("ReLayer");
        vm.deal(address(this), 10 ether);
        vm.deal(ReLayer, 100 ether);
        uint256 minDelay = 7 days;
        address[] memory proposers = new address[](0);
        address[] memory executors = new address[](1);
        executors[0] = admin;


        l2Pool = new L2PoolManager();
        l2Message = new MessageManager();
        vm.startPrank(admin);
//        bytes memory l2Pooldata = abi.encodeWithSignature("initialize(address,address)", address(admin),address(l2Message));
//        bytes memory l2Messagedata = abi.encodeWithSignature("initialize(address)", address(l2Pool));
        l2Poolproxy = new Proxy(address(l2Pool), address(admin), "");
        l2Messageproxy = new Proxy(address(l2Message), address(admin), "");
        MessageManager(address(l2Messageproxy)).initialize(address(l2Poolproxy));
        L2PoolManager(address(l2Poolproxy)).initialize(address(admin),address(l2Messageproxy));



        L2PoolManager(address(l2Poolproxy)).grantRole(l2Pool.ReLayer(), ReLayer);
//        console.logBytes32(l2Pool.ReLayer());
        L2PoolManager(address(l2Poolproxy)).setValidChainId(0x1, true); // Mainnet
        L2PoolManager(address(l2Poolproxy)).setValidChainId(0x82750, true); // Scroll
        L2PoolManager(address(l2Poolproxy)).setValidChainId(0x44d, true); // Polygon zkevm
        L2PoolManager(address(l2Poolproxy)).setValidChainId(0xa, true); // OP

        vm.stopPrank();

        vm.startPrank(ReLayer);


    }

    function test_TransferETHToL1()  public {
        L2PoolManager(address(l2Poolproxy)).BridgeInitiateETH{value: 10 ether}(0xa, 0x1,address(this));
        vm.startPrank(ReLayer);
        L2PoolManager(address(l2Poolproxy)).WithdrawETHtoL1(address(this), 0.1 ether);
    }
}
