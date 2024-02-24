// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/test.sol";
import {TangNFT} from "../src/TangNFT.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {Base64} from "openzeppelin-contracts/contracts/utils/Base64.sol";

contract TangNFTtest is Test {
    TangNFT private tangNFT ;
    using Strings for uint256;

    
    function setUp() public {
        tangNFT = new TangNFT("TangNFT","TNFT");
    }

    function testSafeMint() public {
        address getNFTWallet = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
        uint tokenId = 0;
        tangNFT.safeMint(getNFTWallet);
        console2.logUint(tangNFT.balanceOf(getNFTWallet));
        console2.logString(tangNFT.tokenURI(tokenId));
        assert  (1 == tangNFT.balanceOf(getNFTWallet));
    }

    function testTokenURI() public {
        string memory _tokenURI = makeNFTURI("Tang",0);
        string memory tokenURI = string(abi.encodePacked("data:application/json;base64,",Base64.encode(bytes(_tokenURI))));
        uint tokenId = 0;
        address getNFTWallet = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
        tangNFT.safeMint(getNFTWallet);
        string memory result = tangNFT.tokenURI(tokenId);
        assert (keccak256(abi.encodePacked(tokenURI)) == keccak256(abi.encodePacked(result)));
    }

    function testMintNFT() public {
        string memory tokenURI = makeNFTURI("Tang",1);
        assertEq(tokenURI,vm.readFile("./test/tokenURI.json"));
    }

    
    function testURI() public {
        address getNFTWallet = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
        tangNFT.safeMint(getNFTWallet);
        string memory result = tangNFT.tokenURI(0);
        console2.log(result);
    }




    function makeNFTURI(string memory _name,uint256 id) private view returns (string memory json) {
        string memory tangSvg = vm.readFile("./src/resources/tang.svg");

        string memory name = string.concat(' "name": "',_name,'"');
        string memory description = string.concat(' "description": "', 'the ',id.toString(),'th NFT, BEST WISH TO YOU! "');
        string memory image = string.concat(' "image": ', '"data:image/svg+xml;base64,',Base64.encode(bytes(tangSvg)), '"');

        json = string.concat('{',name,',',description,',',image,'}');

        console2.logString(json);
    }

}