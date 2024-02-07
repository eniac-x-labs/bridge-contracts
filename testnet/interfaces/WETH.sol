// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

interface IWETH {
    function approve(address guy, uint256 wad) external returns (bool);
    function deposit() external payable;
    function transfer(address to, uint256 value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    function withdraw(uint256 wad) external;
}
