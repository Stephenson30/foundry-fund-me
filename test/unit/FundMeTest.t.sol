// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";


contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant amountToBeSent = 0.1 ether;
    uint256 constant startBalance = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, startBalance);
    }

    function testMin5() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwner() public view {
        // console.log(fundMe.i_owner());
        // console.log(msg.sender);

        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeed() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailWithoutEth() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdateEth() public funded {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, amountToBeSent);
    }

    function testFundAddFunderToArrayOfFunders() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawbyOwner() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Action
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFromMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunder = 10;
        uint160 startingFunderIndex = 1;

        for (
            uint160 i = startingFunderIndex;
            startingFunderIndex < numberOfFunder;
            startingFunderIndex++
        ) {
            hoax(address(i), amountToBeSent);
            fundMe.fund{value: amountToBeSent}();
        }

        // Action
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // uint256 startGas = gasleft();
        // vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        // uint256 gasEnd = gasleft();

        // uint256 gasUsed = (startGas - gasEnd)* tx.gasprice;

        // console.log(gasUsed);

        // Assert
        assertEq(address(fundMe).balance, 0);
        assert(startingOwnerBalance + startingFundMeBalance == fundMe.getOwner().balance);
    }

      function testCheapWithdrawFromMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunder = 10;
        uint160 startingFunderIndex = 1;

        for (
            uint160 i = startingFunderIndex;
            startingFunderIndex < numberOfFunder;
            startingFunderIndex++
        ) {
            hoax(address(i), amountToBeSent);
            fundMe.fund{value: amountToBeSent}();
        }

        // Action
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // uint256 startGas = gasleft();
        // vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.cheapWithdraw();
        // uint256 gasEnd = gasleft();

        // uint256 gasUsed = (startGas - gasEnd)* tx.gasprice;

        // console.log(gasUsed);

        // Assert
        assertEq(address(fundMe).balance, 0);
        assert(startingOwnerBalance + startingFundMeBalance == fundMe.getOwner().balance);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: amountToBeSent}();
        _;
    }
}
