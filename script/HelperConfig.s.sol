// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INTIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEth();
        } else {
            activeNetworkConfig = getOrCreateAnvilEth();
        }
    }

    function getSepoliaEth() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaAdd = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaAdd;
    }

    function getOrCreateAnvilEth() public returns (NetworkConfig memory) {
        if(activeNetworkConfig.priceFeed != address(0)){
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INTIAL_PRICE
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilAdd = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilAdd;
    }
}
