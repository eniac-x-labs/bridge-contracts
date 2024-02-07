// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

interface IL1PoolManager {
    //    enum status {Active, Pending, };
    struct Pool {
        uint32 startTimestamp;
        uint32 endTimestamp;
        address token;
        uint256 TotalAmount;
        uint256 TotalFee;
        uint256 TotalFeeClaimed;
        bool IsCompleted;
    }

    struct User {
        bool isWithdrawed;
        address token;
        uint256 StartPoolId;
        uint256 EndPoolId;
        uint256 Amount;
    }

    function DepositAndStaking(
        address _token,
        uint256 _amount
    ) external payable;
    function DepositAndStakingERC20(address _token, uint256 _amount) external;
    function DepositAndStakingETH() external payable;
    function DepositAndStakingWETH(uint256 amount) external;
    function ClaimAllReward() external;
    function CompletePoolAndNew(Pool[] memory CompletePools) external payable;
    function setMinStakeAmount(address _token, uint256 _amount) external;
    function SetSupportToken(
        address _token,
        bool _isSupport,
        uint32 startTimes
    ) external;
    function TransferAssertToBridge(
        uint256 Blockchain,
        address _token,
        address _to,
        uint256 _amount
    ) external;

    // 定义事件
    event StarkingERC20Event(
        address indexed user,
        address indexed token,
        uint256 amount
    );
    event StakingETHEvent(address indexed user, uint256 amount);
    event StakingWETHEvent(address indexed user, uint256 amount);
    event ClaimEvent(
        address indexed user,
        uint256 startPoolId,
        uint256 endPoolId,
        address indexed token,
        uint256 amount,
        uint256 fee
    );
    event TransferAssertTo(
        uint256 Blockchain,
        address indexed token,
        address indexed to,
        uint256 amount
    );

    event ClaimReward(
        address _user,
        uint256 startPoolId,
        uint256 EndPoolId,
        address _token,
        uint Reward
    );
    event Withdraw(
        address _user,
        uint256 startPoolId,
        uint256 EndPoolId,
        address _token,
        uint Amount,
        uint Reward
    );

    event CompletePoolEvent(address indexed token, uint256 poolIndex);
    event SetMinStakeAmountEvent(address indexed token, uint256 amount);
    event SetSupportTokenEvent(address indexed token, bool isSupport);

    error NoReward();
    error TokenIsNotSupported(address token);
    error NewPoolIsNotCreate(uint256 PoolIndex);
    error LessThanMinStakeAmount(uint256 minAmount, uint256 providedAmount);
    error PoolIsCompleted(uint256 poolIndex);
    error AlreadyClaimed();
    error LessThanZero(uint256 amount);
    error TokenIsAlreadySupported(address token, bool isSupported);

    error OutOfRange(uint256 PoolId, uint256 PoolLength);
}
