// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ERC721Receiver.sol";

abstract contract ERC721 {
    string public name;
    string public symbol;

    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "Zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "Nonexistent token");
        return owner;
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return _owners[tokenId] != address(0);
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "Zero address");
        require(!_exists(tokenId), "Already minted");

        _balances[to] += 1;
        _owners[tokenId] = to;
        emit Transfer(address(0), to, tokenId);

        _checkOnERC721Received(address(0), to, tokenId, "");
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        require(ownerOf(tokenId) == from, "Not owner");
        require(to != address(0), "Zero address");

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;
        emit Transfer(from, to, tokenId);

        _checkOnERC721Received(from, to, tokenId, data);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private {
        // If `to` is a contract, ensure it can handle ERC721
        if (to.code.length > 0) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data)
                returns (bytes4 retval)
            {
                require(
                    retval == IERC721Receiver.onERC721Received.selector,
                    "ERC721Receiver rejected tokens"
                );
            } catch {
                revert("Transfer to non ERC721Receiver");
            }
        }
    }
}
