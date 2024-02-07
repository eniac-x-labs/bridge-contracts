// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../../interfaces/IMessageManager.sol";
import "../libraries/ContractsAddress.sol";
import "../../interfaces/WETH.sol";

abstract contract TokenBridgeBase is
    Initializable,
    AccessControlUpgradeable,
    ReentrancyGuardUpgradeable
{
    bytes32 public constant ReLayer =
        keccak256(abi.encode(uint256(keccak256("ReLayer")) - 1)) &
            ~bytes32(uint256(0xff));

    using SafeERC20 for IERC20;
    IMessageManager public messageManager;

    uint256 public MinTransferAmount;
    uint256 public PerFee; // 0.1%

    mapping(uint256 => bool) private IsSupportedChainId;
    mapping(address => bool) private IsSupportedStableCoin;

    mapping(address => uint256) private FundingPoolBalance;
    mapping(address => uint256) public FeePoolValue;

    event InitiateETH(
        uint256 sourceChainId,
        uint256 destChainId,
        address indexed from,
        address indexed to,
        uint256 value
    );

    event InitiateWETH(
        uint256 sourceChainId,
        uint256 destChainId,
        address indexed from,
        address indexed to,
        uint256 value
    );

    event InitiateERC20(
        uint256 sourceChainId,
        uint256 destChainId,
        address indexed ERC20Address,
        address indexed from,
        address indexed to,
        uint256 value
    );

    event FinalizeETH(
        uint256 sourceChainId,
        uint256 destChainId,
        address indexed from,
        address indexed to,
        uint256 value
    );

    event FinalizeWETH(
        uint256 sourceChainId,
        uint256 destChainId,
        address indexed from,
        address indexed to,
        uint256 value
    );

    event FinalizeERC20(
        uint256 sourceChainId,
        uint256 destChainId,
        address indexed ERC20Address,
        address indexed from,
        address indexed to,
        uint256 value
    );

    error ChainIdIsNotSupported(uint256 id);

    error ChainIdNotSupported(uint256 chainId);

    error StableCoinNotSupported(address ERC20Address);

    error NotEnoughToken(address ERC20Address);

    error NotEnoughETH();

    error ErrorBlockChain();

    error LessThanMinTransferAmount(uint256 MinTransferAmount, uint256 value);

    error sourceChainIdError();

    function __TokenBridge_init(
        address _MultisigWallet,
        address _messageManager
    ) internal onlyInitializing {
        MinTransferAmount = 0.1 ether;
        PerFee = 10000; // 1%
        _grantRole(DEFAULT_ADMIN_ROLE, _MultisigWallet);
        messageManager = IMessageManager(_messageManager);
    }

    function BridgeInitiateETH(
        uint256 sourceChainId,
        uint256 destChainId,
        address to
    ) external payable returns (bool) {
        if (sourceChainId != block.chainid) {
            revert sourceChainIdError();
        }
        if (!IsSupportChainId(destChainId)) {
            revert ChainIdIsNotSupported(destChainId);
        }
        if (msg.value < MinTransferAmount) {
            revert LessThanMinTransferAmount(MinTransferAmount, msg.value);
        }
        FundingPoolBalance[ContractsAddress.ETHAddress] += msg.value;

        uint256 fee = (msg.value * PerFee) / 1_000_000;
        uint256 amount = msg.value - fee;
        FeePoolValue[ContractsAddress.ETHAddress] += fee;

        messageManager.sendMessage(
            block.chainid,
            destChainId,
            to,
            msg.value,
            fee
        );

        emit InitiateETH(sourceChainId, destChainId, msg.sender, to, amount);
        return true;
    }

    function BridgeInitiateWETH(
        uint256 sourceChainId,
        uint256 destChainId,
        address to,
        uint256 value
    ) external returns (bool) {
        if (sourceChainId != block.chainid) {
            revert sourceChainIdError();
        }
        if (!IsSupportChainId(destChainId)) {
            revert ChainIdNotSupported(destChainId);
        }

        IWETH WETH = IWETH(L2WETH());

        uint256 BalanceBefore = WETH.balanceOf(address(this));
        WETH.transferFrom(msg.sender, address(this), value);
        uint256 BalanceAfter = WETH.balanceOf(address(this));
        uint256 amount = BalanceAfter - BalanceBefore;
        if (amount < MinTransferAmount) {
            revert LessThanMinTransferAmount(MinTransferAmount, amount);
        }
        FundingPoolBalance[ContractsAddress.WETH] += amount;

        uint256 fee = (amount * PerFee) / 1_000_000;
        amount -= fee;
        FeePoolValue[ContractsAddress.WETH] += fee;

        messageManager.sendMessage(sourceChainId, destChainId, to, value, fee);

        emit InitiateWETH(sourceChainId, destChainId, msg.sender, to, amount);

        return true;
    }

    function BridgeInitiateERC20(
        uint256 sourceChainId,
        uint256 destChainId,
        address to,
        address ERC20Address,
        uint256 value
    ) external returns (bool) {
        if (sourceChainId != block.chainid) {
            revert sourceChainIdError();
        }
        if (!IsSupportChainId(destChainId)) {
            revert ChainIdIsNotSupported(destChainId);
        }
        if (!IsSupportStableCoin(ERC20Address)) {
            revert StableCoinNotSupported(ERC20Address);
        }

        uint256 BalanceBefore = IERC20(ERC20Address).balanceOf(address(this));
        IERC20(ERC20Address).safeTransferFrom(msg.sender, address(this), value);
        uint256 BalanceAfter = IERC20(ERC20Address).balanceOf(address(this));
        uint256 amount = BalanceAfter - BalanceBefore;
        FundingPoolBalance[ContractsAddress.ETHAddress] += value;
        uint256 fee = (amount * PerFee) / 1_000_000;
        amount -= fee;
        FeePoolValue[ERC20Address] += fee;

        messageManager.sendMessage(sourceChainId, destChainId, to, value, fee);

        emit InitiateERC20(
            sourceChainId,
            destChainId,
            ERC20Address,
            msg.sender,
            to,
            amount
        );

        return true;
    }

    function BridgeFinalizeETH(
        uint256 sourceChainId,
        uint256 destChainId,
        address to,
        uint256 amount,
        uint256 _fee,
        uint256 _nonce
    ) external payable onlyRole(ReLayer) returns (bool) {
        if (destChainId != block.chainid) {
            revert sourceChainIdError();
        }
        if (!IsSupportChainId(sourceChainId)) {
            revert ChainIdIsNotSupported(sourceChainId);
        }
        payable(to).transfer(amount);
        FundingPoolBalance[ContractsAddress.ETHAddress] -= amount;

        messageManager.claimMessage(
            sourceChainId,
            destChainId,
            to,
            amount,
            _fee,
            _nonce
        );

        emit FinalizeETH(sourceChainId, destChainId, address(this), to, amount);
        return true;
    }

    function BridgeFinalizeWETH(
        uint256 sourceChainId,
        uint256 destChainId,
        address to,
        uint256 amount,
        uint256 _fee,
        uint256 _nonce
    ) external onlyRole(ReLayer) returns (bool) {
        if (destChainId != block.chainid) {
            revert sourceChainIdError();
        }
        if (!IsSupportChainId(sourceChainId)) {
            revert ChainIdIsNotSupported(sourceChainId);
        }

        IWETH WETH = IWETH(L2WETH());
        WETH.transferFrom(address(this), to, amount);
        FundingPoolBalance[ContractsAddress.WETH] -= amount;

        messageManager.claimMessage(
            sourceChainId,
            destChainId,
            to,
            amount,
            _fee,
            _nonce
        );

        emit FinalizeWETH(
            sourceChainId,
            destChainId,
            address(this),
            to,
            amount
        );
        return true;
    }

    function BridgeFinalizeERC20(
        uint256 sourceChainId,
        uint256 destChainId,
        address to,
        address ERC20Address,
        uint256 amount,
        uint256 _fee,
        uint256 _nonce
    ) external onlyRole(ReLayer) returns (bool) {
        if (destChainId != block.chainid) {
            revert sourceChainIdError();
        }
        if (!IsSupportChainId(sourceChainId)) {
            revert ChainIdIsNotSupported(sourceChainId);
        }
        if (!IsSupportStableCoin(ERC20Address)) {
            revert StableCoinNotSupported(ERC20Address);
        }
        IERC20(ERC20Address).safeTransferFrom(address(this), to, amount);
        FundingPoolBalance[ContractsAddress.ETHAddress] -= amount;

        messageManager.claimMessage(
            sourceChainId,
            destChainId,
            to,
            amount,
            _fee,
            _nonce
        );

        emit FinalizeERC20(
            sourceChainId,
            destChainId,
            ERC20Address,
            address(this),
            to,
            amount
        );
        return true;
    }

    function IsSupportChainId(uint256 chainId) public view returns (bool) {
        return IsSupportedChainId[chainId];
    }

    function IsSupportStableCoin(
        address ERC20Address
    ) public view returns (bool) {
        return IsSupportedStableCoin[ERC20Address];
    }

    function L2WETH() public view returns (address) {
        uint256 Blockchain = block.chainid;
        if (Blockchain == 0x82750) {
            // Scroll: https://chainlist.org/chain/534352
            return (ContractsAddress.ScrollWETH);
        } else if (Blockchain == 0x44d) {
            // Polygon zkEVM https://chainlist.org/chain/1101
            return (ContractsAddress.PolygonZkEVMWETH);
        } else if (Blockchain == 0xa) {
            // OP Mainnet https://chainlist.org/chain/10
            return (ContractsAddress.OptimismWETH);
        } else {
            revert ErrorBlockChain();
        }
    }

    function QuickSendAssertToUser(
        address _token,
        address to,
        uint256 _amount
    ) external onlyRole(ReLayer) {
        SendAssertToUser(_token, to, _amount);
    }

    function SendAssertToUser(
        address _token,
        address to,
        uint256 _amount
    ) internal returns (bool) {
        if (!IsSupportStableCoin(_token)) {
            revert StableCoinNotSupported(_token);
        }
        if (_token == address(ContractsAddress.ETHAddress)) {
            if (address(this).balance < _amount) {
                revert NotEnoughETH();
            }
            payable(to).transfer(_amount);
        } else {
            if (IERC20(_token).balanceOf(address(this)) < _amount) {
                revert NotEnoughToken(_token);
            }
            IERC20(_token).safeTransfer(to, _amount);
        }
        return true;
    }

    function setMinTransferAmount(
        uint256 _MinTransferAmount
    ) external onlyRole(ReLayer) {
        MinTransferAmount = _MinTransferAmount;
    }

    function setValidChainId(
        uint256 chainId,
        bool isValid
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        IsSupportedChainId[chainId] = isValid;
    }

    function setSupportStableCoin(
        address ERC20Address,
        bool isValid
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        IsSupportedStableCoin[ERC20Address] = isValid;
    }

    function setPerFee(uint256 _PerFee) external onlyRole(DEFAULT_ADMIN_ROLE) {
        PerFee = _PerFee;
    }
}
