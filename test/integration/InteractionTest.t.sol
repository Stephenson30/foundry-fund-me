// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {Funding, Withdrawing} from "../../script/Interaction.s.sol";

contract InteractionTest is Test{
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant amountToBeSent = 0.1 ether;
    uint256 constant startBalance = 20 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, startBalance);
    }

    function testUserCanFund() public {
        Funding funding = new Funding();
        vm.deal(address(funding), startBalance);
        funding.fundFundMe(address(fundMe));

        Withdrawing withdrawing = new Withdrawing();
        withdrawing.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
}
