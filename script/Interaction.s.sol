// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract Funding is Script {
    uint256 constant SEND_VALUE = 1 ether;

    function fundFundMe(address contractAddress) public {
        FundMe(payable(contractAddress)).fund{value: SEND_VALUE}();
        console.log("sent %s", SEND_VALUE);
    }

    function run() external {
        address contractAddress = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        vm.startBroadcast();
        fundFundMe(contractAddress);
        vm.stopBroadcast();
    }
}

contract Withdrawing is Script {
     uint256 constant SEND_VALUE = 0.001 ether;

    function withdrawFundMe(address contractAddress) public {
        vm.startBroadcast();
        FundMe(payable(contractAddress)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address contractAddress = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        withdrawFundMe(contractAddress);
    }
}
