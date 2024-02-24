// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/TangNFT.sol";

contract TangNFTScript is Script {

    function setUp() public {
        
    }

    function run() public {
        vm.startBroadcast();
        TangNFT tangNFT = new TangNFT("BSET WISH TO TW","Tang");
        vm.stopBroadcast();
    }
}