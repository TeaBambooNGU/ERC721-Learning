// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "forge-std/test.sol";
import "../src/TangNFT.sol";

contract TangNFTtest is Test {
    TangNFT private tangNFT ;
    
    function setUp() public {
        tangNFT = new TangNFT("TangNFT","TNFT");
    }

    function testSafeMint() public {
        address getNFTWallet = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
        uint tokenId = 19970710;
        tangNFT.safeMint(getNFTWallet,tokenId);
        console2.logUint(tangNFT.balanceOf(getNFTWallet));
        console2.logString(tangNFT.tokenURI(tokenId));
        assert  (1 == tangNFT.balanceOf(getNFTWallet));
    }

    function testTokenURI() public {
        string memory tokenURI = "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/19970710";
        uint tokenId = 19970710;
        address getNFTWallet = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
        tangNFT.safeMint(getNFTWallet,tokenId);
        string memory result = tangNFT.tokenURI(tokenId);
        assert (keccak256(abi.encodePacked(tokenURI)) == keccak256(abi.encodePacked(result)));
    }

    function testFailTokenURI() public view {
        string memory tokenURI = "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/19970710";
        uint tokenId = 19970710;
        
        string memory result = tangNFT.tokenURI(tokenId);
        assert (keccak256(abi.encodePacked(tokenURI)) == keccak256(abi.encodePacked(result)));
    }

}