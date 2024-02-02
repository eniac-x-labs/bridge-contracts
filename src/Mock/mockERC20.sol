// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract mockToken is ERC20 {
    constructor(
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {
        _mint(_msgSender(), 1_000_000_000 * (10 ** decimals()));
    }

    function mint(address to, uint256 value) external returns (bool) {
        require(value <= 10_000 * (10 ** decimals()), "Token: invalid amount");
        _mint(to, value);
        return true;
    }
}
