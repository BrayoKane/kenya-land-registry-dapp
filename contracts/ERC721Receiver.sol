// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

/**
 * Simple default receiver you can inherit in contracts
 * that want to accept ERC721 tokens.
 */
abstract contract ERC721Receiver is IERC721Receiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure virtual override returns (bytes4) {
        // Return this function selector to confirm receipt
        return IERC721Receiver.onERC721Received.selector;
    }
}
