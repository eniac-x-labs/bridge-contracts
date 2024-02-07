// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../bridge/TokenBridgeBase.sol";
import "../../interfaces/IL1PoolManager.sol";
import "../../interfaces/WETH.sol";
import "../../interfaces/IScrollBridge.sol";
import "../../interfaces/IPolygonZkEVMBridge.sol";
import "../../interfaces/IOptimismBridge.sol";
import "../../interfaces/IMessageManager.sol";
import "../libraries/ContractsAddress.sol";
import "../../interfaces/IL1MessageQueue.sol";

contract L1PoolManager is IL1PoolManager, PausableUpgradeable, TokenBridgeBase {
    using SafeERC20 for IERC20;

    uint32 public periodTime;

    mapping(address => bool) public IsSupportToken;
    mapping(address => uint256) public balances;
    mapping(address => Pool[]) public Pools;
    mapping(address => User[]) public Users;
    mapping(address => uint256) public MinStakeAmount;
    address[] public SupportTokens;

    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _MultisigWallet,
        address _messageManager
    ) public initializer {
        __AccessControl_init();
        __ReentrancyGuard_init();
        __Pausable_init();

        TokenBridgeBase.__TokenBridge_init(_MultisigWallet, _messageManager);
        periodTime = 21 days;
    }

    /*************************
     ***** User function *****
     *************************/

    function DepositAndStaking(
        address _token,
        uint256 _amount
    ) public payable override whenNotPaused {
        if (msg.value > 0) {
            DepositAndStakingETH();
        } else if (_token == ContractsAddress.WETH) {
            DepositAndStakingWETH(_amount);
        } else if (IsSupportToken[_token]) {
            DepositAndStakingERC20(_token, _amount);
        }
    }

    function DepositAndStakingERC20(
        address _token,
        uint256 _amount
    ) public override nonReentrant whenNotPaused {
        if (!IsSupportToken[_token]) {
            revert TokenIsNotSupported(_token);
        }
        if (_amount < MinStakeAmount[_token]) {
            revert LessThanMinStakeAmount(MinStakeAmount[_token], _amount);
        }

        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
        uint256 PoolIndex = Pools[_token].length - 1;
        if (Pools[_token][PoolIndex].startTimestamp > block.timestamp) {
            Users[msg.sender].push(
                User({
                    isWithdrawed: false,
                    StartPoolId: PoolIndex,
                    EndPoolId: 0,
                    token: _token,
                    Amount: _amount
                })
            );
            Pools[_token][PoolIndex].TotalAmount += _amount;
        } else {
            revert NewPoolIsNotCreate(PoolIndex);
        }

        emit StarkingERC20Event(msg.sender, _token, _amount);
    }

    function DepositAndStakingETH()
        public
        payable
        override
        nonReentrant
        whenNotPaused
    {
        if (msg.value < MinStakeAmount[address(ContractsAddress.ETHAddress)]) {
            revert LessThanMinStakeAmount(
                MinStakeAmount[address(ContractsAddress.ETHAddress)],
                msg.value
            );
        }
        uint256 PoolIndex = Pools[address(ContractsAddress.ETHAddress)].length -
            1;
        if (Pools[address(ContractsAddress.ETHAddress)].length == 0) {
            revert NewPoolIsNotCreate(1);
        }
        if (
            Pools[address(ContractsAddress.ETHAddress)][PoolIndex]
                .startTimestamp > block.timestamp
        ) {
            Users[msg.sender].push(
                User({
                    isWithdrawed: false,
                    StartPoolId: PoolIndex,
                    EndPoolId: 0,
                    token: ContractsAddress.ETHAddress,
                    Amount: msg.value
                })
            );
            Pools[address(ContractsAddress.ETHAddress)][PoolIndex]
                .TotalAmount += msg.value;
        } else {
            revert NewPoolIsNotCreate(PoolIndex + 1);
        }

        emit StakingETHEvent(msg.sender, msg.value);
    }

    function DepositAndStakingWETH(
        uint256 amount
    ) public override nonReentrant whenNotPaused {
        if (amount < MinStakeAmount[address(ContractsAddress.WETH)]) {
            revert LessThanMinStakeAmount(MinStakeAmount[address(0)], amount);
        }

        IWETH(ContractsAddress.WETH).transferFrom(
            msg.sender,
            address(this),
            amount
        );

        uint256 PoolIndex = Pools[address(ContractsAddress.WETH)].length - 1;
        if (Pools[address(ContractsAddress.WETH)][PoolIndex].IsCompleted) {
            revert PoolIsCompleted(PoolIndex);
        }
        if (
            Pools[address(ContractsAddress.WETH)][PoolIndex].startTimestamp >
            block.timestamp
        ) {
            Users[msg.sender].push(
                User({
                    isWithdrawed: false,
                    StartPoolId: PoolIndex,
                    EndPoolId: 0,
                    token: ContractsAddress.WETH,
                    Amount: amount
                })
            );
            Pools[address(ContractsAddress.WETH)][PoolIndex]
                .TotalAmount += amount;
        }

        emit StakingWETHEvent(msg.sender, amount);
    }

    function WithdrawAll() external nonReentrant whenNotPaused {
        for (uint256 i = 0; i < SupportTokens.length; i++) {
            WithdrawOrClaimBySimpleAsset(msg.sender, SupportTokens[i], true);
        }
    }

    function ClaimAllReward() external nonReentrant whenNotPaused {
        for (uint256 i = 0; i < SupportTokens.length; i++) {
            WithdrawOrClaimBySimpleAsset(msg.sender, SupportTokens[i], false);
        }
    }

    function WithdrawByID(uint i) external nonReentrant whenNotPaused {
        if (i >= Users[msg.sender].length) {
            revert OutOfRange(i, Users[msg.sender].length);
        }
        WithdrawOrClaimBySimpleID(msg.sender, i, true);
    }

    function ClaimbyID(uint i) external nonReentrant whenNotPaused {
        if (i >= Users[msg.sender].length) {
            revert OutOfRange(i, Users[msg.sender].length);
        }
        WithdrawOrClaimBySimpleID(msg.sender, i, false);
    }

    function WithdrawOrClaimBySimpleID(
        address _user,
        uint index,
        bool IsWithdraw
    ) internal {
        address _token = Users[_user][index].token;
        uint256 EndPoolId = Pools[_token].length - 1;
        Pools[_token][EndPoolId].TotalAmount -= Users[_user][index].Amount;

        uint256 Reward = 0;
        uint256 Amount = Users[_user][index].Amount;
        uint256 startPoolId = Users[_user][index].StartPoolId;
        if (startPoolId > EndPoolId) {
            revert NoReward();
        }

        for (uint256 j = startPoolId; j < EndPoolId; j++) {
            if (j > Pools[_token].length - 1) {
                revert NewPoolIsNotCreate(j);
            }
            uint256 _Reward = (Amount * Pools[_token][j].TotalFee) /
                Pools[_token][j].TotalAmount;
            Reward += _Reward;
            Pools[_token][j].TotalFeeClaimed += _Reward;
        }
        require(Reward > 0, "No Reward");
        Amount += Reward;
        Users[_user][index].isWithdrawed = true;
        if (IsWithdraw) {
            Users[_user][index].isWithdrawed = true;
            SendAssertToUser(_token, _user, Reward);
            if (Users[_user].length > 1) {
                Users[_user][index] = Users[_user][Users[_user].length - 1];
                Users[_user].pop();

                emit Withdraw(
                    _user,
                    startPoolId,
                    EndPoolId,
                    _token,
                    Amount - Reward,
                    Reward
                );
            } else {
                Users[_user][index].StartPoolId = EndPoolId;
                SendAssertToUser(_token, _user, Amount);
                emit ClaimReward(_user, startPoolId, EndPoolId, _token, Reward);
            }
        }
    }

    function WithdrawOrClaimBySimpleAsset(
        address _user,
        address _token,
        bool IsWithdraw
    ) internal {
        if (Pools[_token].length == 0) {
            revert NewPoolIsNotCreate(0);
        }
        for (int256 i = 0; uint256(i) < Users[_user].length; i++) {
            uint256 index = uint256(i);
            if (Users[_user][index].token == _token) {
                if (Users[_user][index].isWithdrawed) {
                    continue;
                }

                uint256 EndPoolId = Pools[_token].length - 1;
                Pools[_token][EndPoolId].TotalAmount -= Users[_user][index]
                    .Amount;

                uint256 Reward = 0;
                uint256 Amount = Users[_user][index].Amount;
                uint256 startPoolId = Users[_user][index].StartPoolId;
                if (startPoolId > EndPoolId) {
                    revert NoReward();
                }

                for (uint256 j = startPoolId; j < EndPoolId; j++) {
                    if (j > Pools[_token].length - 1) {
                        revert NewPoolIsNotCreate(j);
                    }
                    uint256 _Reward = (Amount * Pools[_token][j].TotalFee) /
                        Pools[_token][j].TotalAmount;
                    Reward += _Reward;
                    Pools[_token][j].TotalFeeClaimed += _Reward;
                }
                require(Reward > 0, "No Reward");
                Amount += Reward;

                if (IsWithdraw) {
                    Users[_user][index].isWithdrawed = true;
                    SendAssertToUser(_token, _user, Reward);
                    if (Users[_user].length > 1) {
                        Users[_user][index] = Users[_user][
                            Users[_user].length - 1
                        ];
                        Users[_user].pop();
                        i--;
                        emit Withdraw(
                            _user,
                            startPoolId,
                            EndPoolId,
                            _token,
                            Amount - Reward,
                            Reward
                        );
                    } else {
                        Users[_user][index].StartPoolId = EndPoolId;
                        SendAssertToUser(_token, _user, Amount);
                        emit ClaimReward(
                            _user,
                            startPoolId,
                            EndPoolId,
                            _token,
                            Reward
                        );
                    }
                }
            }
        }
    }

    /***************************************
     ***** Relayer function *****
     ***************************************/

    function CompletePoolAndNew(
        Pool[] memory CompletePools
    ) external payable onlyRole(ReLayer) {
        for (uint256 i = 0; i < CompletePools.length; i++) {
            address _token = CompletePools[i].token;
            uint PoolIndex = Pools[_token].length - 1;
            Pools[_token][PoolIndex].IsCompleted = true;
            Pools[_token][PoolIndex].TotalFee = CompletePools[i].TotalFee;
            uint32 startTimes = Pools[_token][PoolIndex].endTimestamp;
            Pools[_token].push(
                Pool({
                    startTimestamp: startTimes,
                    endTimestamp: startTimes + periodTime,
                    token: _token,
                    TotalAmount: Pools[_token][PoolIndex].TotalAmount,
                    TotalFee: 0,
                    TotalFeeClaimed: 0,
                    IsCompleted: false
                })
            );
            emit CompletePoolEvent(_token, PoolIndex);
        }
    }

    function TransferAssertToBridge(
        uint256 Blockchain,
        address _token,
        address _to,
        uint256 _amount
    ) external onlyRole(ReLayer) {
        if (!IsSupportToken[_token]) {
            revert TokenIsNotSupported(_token);
        }
        if (Blockchain == 0x82750) {
            //https://chainlist.org/chain/534352
            //Scroll

            //
            TransferAssertToScrollBridge(_token, _to, _amount);
        } else if (Blockchain == 0x44d) {
            //https://chainlist.org/chain/1101
            //Polygon zkEVM
            TransferAssertToPolygonZkevmBridge(_token, _to, _amount);
        } else if (Blockchain == 0xa) {
            //https://chainlist.org/chain/10
            //OP Mainnet
            TransferAssertToOptimismBridge(_token, _to, _amount);
        } else {
            revert ErrorBlockChain();
        }
        emit TransferAssertTo(Blockchain, _token, _to, _amount);
    }

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

    function TransferAssertToPolygonZkevmBridge(
        address _token,
        address _to,
        uint256 _amount
    ) internal {
        if (_token == address(ContractsAddress.ETHAddress)) {
            IPolygonZkEVML1Bridge(ContractsAddress.PolygonZkEVML1Bridge)
                .bridgeAsset{value: _amount}(
                0x1,
                _to,
                _amount,
                address(0),
                false,
                ""
            );
        } else {
            IERC20(_token).approve(
                ContractsAddress.PolygonZkEVML1Bridge,
                _amount
            );
            IPolygonZkEVML1Bridge(ContractsAddress.PolygonZkEVML1Bridge)
                .bridgeAsset(0x1, _to, _amount, _token, false, "");
        }
    }

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
                ContractsAddress.OptimismL2StandardBridge,
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

    function setMinStakeAmount(
        address _token,
        uint256 _amount
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_amount < 0) {
            revert LessThanZero(_amount);
        }
        MinStakeAmount[_token] = _amount;
        emit SetMinStakeAmountEvent(_token, _amount);
    }

    function SetSupportToken(
        address _token,
        bool _isSupport,
        uint32 startTimes
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        if (IsSupportToken[_token]) {
            revert TokenIsAlreadySupported(_token, _isSupport);
        }
        IsSupportToken[_token] = _isSupport;
        //genesis pool
        Pools[_token].push(
            Pool({
                startTimestamp: uint32(startTimes) - periodTime,
                endTimestamp: startTimes,
                token: _token,
                TotalAmount: 0,
                TotalFee: 0,
                TotalFeeClaimed: 0,
                IsCompleted: false
            })
        );
        //genesis bridge
        Pools[_token].push(
            Pool({
                startTimestamp: uint32(startTimes),
                endTimestamp: startTimes + periodTime,
                token: _token,
                TotalAmount: 0,
                TotalFee: 0,
                TotalFeeClaimed: 0,
                IsCompleted: false
            })
        );
        //Next bridge
        SupportTokens.push(_token);
        emit SetSupportTokenEvent(_token, _isSupport);
    }

    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    function getPoolLength(address _token) external view returns (uint256) {
        return Pools[_token].length;
    }

    function getUserLength(address _user) external view returns (uint256) {
        return Users[_user].length;
    }

    function getPool(
        address _token,
        uint256 _index
    ) external view returns (Pool memory) {
        return Pools[_token][_index];
    }

    function getUser(address _user) external view returns (User[] memory) {
        return Users[_user];
    }

    function getUser(
        address _user,
        uint256 _index
    ) external view returns (User memory) {
        return Users[_user][_index];
    }

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
}
