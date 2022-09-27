// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract erc155test is ERC1155 {
    constructor(string memory uri_) ERC1155(uri_) {}

    function singleMint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public /*questionable visibility*/
    {
        _mint(to, id, amount, data);
    }

    //override all transfer/approve functions

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public pure override {
        revert("not a valid function call");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public pure override {
        revert("not a valid function call");
    }

    function setApprovalForAll(address operator, bool approved)
        public
        pure
        override
    {
        revert("not a valid function call");
    }
}
