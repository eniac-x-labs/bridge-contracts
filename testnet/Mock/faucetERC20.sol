// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract faucetToken is ERC20 {
    mapping(address => bool) public isClaimed;
    constructor(
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {
        _mint(_msgSender(), 1_000_000_000 * (10 ** decimals()));
    }

    function faucet() external {
        require(isClaimed[msg.sender] == false, "Already Claimed");
        isClaimed[msg.sender] = true;
        _mint(msg.sender, 1 * 10 ** decimals());
    }
}
