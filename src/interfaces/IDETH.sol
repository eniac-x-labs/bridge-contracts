// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;



interface IDETH{

     struct BatchMint {
        address staker;
        uint256 amount;
    }
    function batchMint(BatchMint[] calldata batcher) external;
}