// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract TangNFT is ERC721, Ownable {
    // 最大NFT发行量
    uint256 public constant MAX_TANGS = 10000;
    uint256 public total_mint = 0;
    using Strings for uint;
    constructor(string memory _name, string memory _symbol) 
        ERC721(_name, _symbol) Ownable(msg.sender) {
        
    }
    // 暂时用无聊猿的ipfs 
    function _baseURI() internal override pure returns (string memory) {
        return "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/";
    }
    
    function _safeMint(address to, uint256 tokenId, bytes memory data) internal override  {
        require(total_mint < MAX_TANGS, "out of max mint");
        total_mint +=1;
        _mint(to, tokenId);
    }

    function safeMint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to,tokenId,"");
    }

    function tokenURI(uint tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string.concat(baseURI, tokenId.toString()) : "";
    }

    function balanceOf(address owner) public view override returns (uint256) {
        return super.balanceOf(owner);
    }
}