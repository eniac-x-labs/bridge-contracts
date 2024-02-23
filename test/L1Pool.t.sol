pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "src/core/L1/L1PoolManager.sol";
import "src/core/L1/L1PoolRelayerHelper.sol";
import "src/core/Proxy.sol";
import "src/core/ProxyTimeLockController.sol";
import "src/core/message/MessageManager.sol";
import "src/interfaces/IL1PoolManager.sol";
import "src/Mock/mockWETH.sol";
import "src/Mock/mockERC20.sol";



contract L1PoolTest is Test {

    address admin;
    address ReLayer;

    ProxyTimeLockController proxyTimeLockController;
    Proxy l1Poolproxy;
    Proxy l1Messageproxy;
    L1PoolManager l1Pool;
    L1PoolRelayerHelper l1Helper;
    MessageManager l1Message;
    address ETHAddress = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
//    mockWETH WETH = new mockWETH();
    mockToken USDT = new mockToken("USDT", "USDT");

    mockWETH WETH = mockWETH(payable(ContractsAddress.WETH));
//    mockToken USDT = mockToken(payable(ContractsAddress.USDT));
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


        l1Pool = new L1PoolManager();
        l1Message = new MessageManager();
        vm.startPrank(admin);
        l1Poolproxy = new Proxy(address(l1Pool), address(admin), "");
        l1Messageproxy = new Proxy(address(l1Message), address(admin), "");



        MessageManager(address(l1Messageproxy)).initialize(address(l1Poolproxy));
        L1PoolManager(address(l1Poolproxy)).initialize(address(admin),address(l1Messageproxy));

        l1Helper = new L1PoolRelayerHelper(address(l1Pool));
        L1PoolManager(address(l1Poolproxy)).setHelper(address(l1Helper));

        uint32 startTimes = uint32(block.timestamp - block.timestamp % 86400 + 86400); // tomorrow
        L1PoolManager(address(l1Poolproxy)).setMinStakeAmount(address(ETHAddress), 0.1 ether);
        L1PoolManager(address(l1Poolproxy)).grantRole(l1Pool.ReLayer(), ReLayer);

        L1PoolManager(address(l1Poolproxy)).setSupportToken(address(ETHAddress), true, startTimes);
        assert(L1PoolManager(address(l1Poolproxy)).getPoolLength(ETHAddress) == 2);
        assert(L1PoolManager(address(l1Poolproxy)).getPool(ETHAddress,1).startTimestamp == startTimes);
        assert(L1PoolManager(address(l1Poolproxy)).getPool(ETHAddress,1).endTimestamp == startTimes + 21 * 86400);
        L1PoolManager(address(l1Poolproxy)).setSupportToken(address(WETH), true, startTimes);
        L1PoolManager(address(l1Poolproxy)).setSupportToken(address(USDT), true, startTimes);
        vm.stopPrank();



        vm.startPrank(ReLayer);
        WETH.deposit{value: 10 ether}();
        USDT.mint(ReLayer, 100000000);
        vm.stopPrank();

    }


    function test_StakingETH() public {

        L1PoolManager(address(l1Poolproxy)).DepositAndStakingETH{value: 1 ether}();
        assert(L1PoolManager(address(l1Poolproxy)).getUserLength(address(this)) == 1);
        IL1PoolManager.User memory _user = L1PoolManager(address(l1Poolproxy)).getUser(address(this), 0);
        assert(_user.Amount == 1 ether);
        assert(_user.token == address(ETHAddress));
        assert(_user.StartPoolId == 1);
        assert(_user.EndPoolId == 0);
        assert(_user.isWithdrawed == false);

    }

    function test_StakingWETH() public {
        WETH.deposit{value: 1 ether}();
        WETH.approve(address(l1Poolproxy), 1 ether);
        L1PoolManager(address(l1Poolproxy)).DepositAndStakingWETH(1 ether);

        assert(L1PoolManager(address(l1Poolproxy)).getUserLength(address(this)) == 1);
        IL1PoolManager.User memory _user = L1PoolManager(address(l1Poolproxy)).getUser(address(this), 0);
        assert(_user.Amount == 1 ether);
        assert(_user.token == address(WETH));
        assert(_user.StartPoolId == 1);
        assert(_user.EndPoolId == 0);
        assert(_user.isWithdrawed == false);
    }

    function test_StakingUSDT() public {

        USDT.approve(address(l1Poolproxy), 100000);
        L1PoolManager(address(l1Poolproxy)).DepositAndStakingERC20(address(USDT), 100000);

        assert(L1PoolManager(address(l1Poolproxy)).getUserLength(address(this)) == 1);
        IL1PoolManager.User memory _user = L1PoolManager(address(l1Poolproxy)).getUser(address(this), 0);
        assert(_user.Amount == 100000);
        assert(_user.token == address(USDT));
        assert(_user.StartPoolId == 1);
        assert(_user.EndPoolId == 0);
        assert(_user.isWithdrawed == false);
    }


    function test_ClaimETH() public {
        uint balanceBefore = address(this).balance;
        L1PoolManager(address(l1Poolproxy)).DepositAndStakingETH{value: 1 ether}();
        CompleteETHPoolAndNew(address(ETHAddress), 0);

        CompleteETHPoolAndNew(address(ETHAddress), 0.1 ether);
//        L1PoolManager(address(l1Poolproxy)).ClaimSimpleAsset(ETHAddress);
        uint balanceAfter = address(this).balance;

        console.log("balanceBefore", balanceBefore);
        console.log("balanceAfter", balanceAfter);

    }

    function test_ClaimETH_Staking_twice() public {

        uint balanceBefore = address(this).balance;
        L1PoolManager(address(l1Poolproxy)).DepositAndStakingETH{value: 1 ether}();


        CompleteETHPoolAndNew(address(ETHAddress), 0);
        L1PoolManager(address(l1Poolproxy)).DepositAndStakingETH{value: 1 ether}();
        CompleteETHPoolAndNew(address(ETHAddress), 0.1 ether);
        CompleteETHPoolAndNew(address(ETHAddress), 0.2 ether);
//        L1PoolManager(address(l1Poolproxy)).ClaimSimpleAsset(ETHAddress);


        uint balanceAfter = address(this).balance;

        console.log("balanceBefore", balanceBefore);
        console.log("balanceAfter", balanceAfter);

    }

    function test_ClaimWETH() public{
        WETH.deposit{value: 1 ether}();
        uint balanceBefore = WETH.balanceOf(address(this));
        WETH.approve(address(l1Poolproxy), 0.1 ether);
        L1PoolManager(address(l1Poolproxy)).DepositAndStakingWETH(0.1 ether);
        CompleteWETHPoolAndNew(address(WETH), 0);

        CompleteWETHPoolAndNew(address(WETH), 0.1 ether);

//        L1PoolManager(address(l1Poolproxy)).ClaimSimpleAsset(address(WETH));
        uint balanceAfter =  WETH.balanceOf(address(this));

        console.log("balanceBefore", balanceBefore);
        console.log("balanceAfter", balanceAfter);

    }


    function test_ClaimUSDT() public{

        uint balanceBefore = USDT.balanceOf(address(this));
        USDT.approve(address(l1Poolproxy), 10000);
        L1PoolManager(address(l1Poolproxy)).DepositAndStakingERC20(address(USDT), 10000);
        CompleteUSDTPoolAndNew(address(USDT), 0);

        CompleteUSDTPoolAndNew(address(USDT), 100);

//        L1PoolManager(address(l1Poolproxy)).ClaimSimpleAsset(address(USDT));
        uint balanceAfter =  USDT.balanceOf(address(this));

        console.log("balanceBefore", balanceBefore);
        console.log("balanceAfter", balanceAfter);

    }


    function CompleteETHPoolAndNew(address _token, uint totalFee) internal {
        uint latest  = L1PoolManager(address(l1Poolproxy)).getPoolLength(_token) - 2;
        vm.warp(L1PoolManager(address(l1Poolproxy)).getPool(ETHAddress, latest).endTimestamp);
        vm.startPrank(ReLayer);

        IL1PoolManager.Pool[] memory CompletePools_period = new IL1PoolManager.Pool[](1);
        CompletePools_period[0] = IL1PoolManager.Pool(0, 0, address(ETHAddress), 0, totalFee, 0, false);
        L1PoolManager(address(l1Poolproxy)).CompletePoolAndNew{value: totalFee}(CompletePools_period);
        vm.stopPrank();

    }

    function CompleteWETHPoolAndNew(address _token, uint totalFee) internal {
        uint latest  = L1PoolManager(address(l1Poolproxy)).getPoolLength(_token) - 2;
        vm.warp(L1PoolManager(address(l1Poolproxy)).getPool(address(WETH), latest).endTimestamp);
        vm.startPrank(ReLayer);

        IL1PoolManager.Pool[] memory CompletePools_period = new IL1PoolManager.Pool[](1);
        CompletePools_period[0] = IL1PoolManager.Pool(0, 0, address(WETH), 0, totalFee, 0, false);
        L1PoolManager(address(l1Poolproxy)).CompletePoolAndNew(CompletePools_period);
        WETH.transfer(address(l1Poolproxy), totalFee);

        vm.stopPrank();

    }


    function CompleteUSDTPoolAndNew(address _token, uint totalFee) internal {
        uint latest  = L1PoolManager(address(l1Poolproxy)).getPoolLength(_token) - 2;
        vm.warp(L1PoolManager(address(l1Poolproxy)).getPool(address(USDT), latest).endTimestamp);
        vm.startPrank(ReLayer);

        IL1PoolManager.Pool[] memory CompletePools_period = new IL1PoolManager.Pool[](1);
        CompletePools_period[0] = IL1PoolManager.Pool(0, 0, address(USDT), 0, totalFee, 0, false);
        L1PoolManager(address(l1Poolproxy)).CompletePoolAndNew(CompletePools_period);
        USDT.transfer(address(l1Poolproxy), totalFee);

        vm.stopPrank();

    }

    function test_TransferAssertToScrollBridge() public {

        L1PoolManager(address(l1Poolproxy)).DepositAndStakingETH{value: 1 ether}();
        vm.startPrank(ReLayer);
        L1PoolManager(address(l1Poolproxy)).TransferAssertToBridge(0x82750, address(ETHAddress), admin, 0.1 ether);
    }

    function test_TransferAssertToPolygonZkEvm() public {
        L1PoolManager(address(l1Poolproxy)).DepositAndStakingETH{value: 1 ether}();
        vm.startPrank(ReLayer);
        L1PoolManager(address(l1Poolproxy)).TransferAssertToBridge(0x44d, address(ETHAddress), admin, 0.1 ether);
    }

    function test_TransferAssertToOP() public {
        L1PoolManager(address(l1Poolproxy)).DepositAndStakingETH{value: 1 ether}();
        vm.startPrank(ReLayer);
        L1PoolManager(address(l1Poolproxy)).TransferAssertToBridge(0xa, address(ETHAddress), admin, 1 ether);
    }



}
