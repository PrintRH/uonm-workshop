// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./UoNMToken.sol";

contract UoNMBroker is Ownable {
    UoNMToken public uonmToken;
    uint256 public uonmTokenBalance;
    uint256 public constant UONM_TOKENS_PER_ETH = 1000;

    event BuyUonmTokens(address indexed buyer, uint256 amountOfEth, uint256 amountOfUonmTokens);
    event SellUonmTokens(address indexed seller, uint256 amountOfUonmTokens, uint256 amountOfEth);

    constructor(address tokenAddress) Ownable(address(this)) {
        uonmToken = UoNMToken(tokenAddress);
        uonmTokenBalance = uonmToken.balanceOf(address(this));
    }

    function buyUonmTokens() public payable {
        address buyer = msg.sender;
        uint256 amountOfUonmTokens = msg.value * UONM_TOKENS_PER_ETH;
        require(msg.value > 0, "Insufficient ETH to buy UoNM tokens");
        uonmTokenBalance -= amountOfUonmTokens;
        uonmToken.transfer(buyer, amountOfUonmTokens);
        emit BuyUonmTokens(buyer, msg.value, amountOfUonmTokens);
    }

    function sellUonmTokens(uint256 amountOfUonmTokensToSell) public {
        uint256 amountOfEthToSeller = amountOfUonmTokensToSell / UONM_TOKENS_PER_ETH;
        // Check that seller (me) has more than zero tokens to sell
        require(amountOfUonmTokensToSell > 0, "Insufficient UoNM tokens to sell");
        // Check if seller(me) has enough tokens to sell
        require(uonmToken.balanceOf(msg.sender) >= amountOfUonmTokensToSell, "Insufficient UoNM tokens to sell");
        // Check if vendor has enough tokens to sell
        require(address(this).balance >= amountOfEthToSeller, "Insufficient liquidity in Vendor to perform sale");

        bool success = uonmToken.transfer(address(this), amountOfUonmTokensToSell);
        require(success, "Failed to transfer token to vendor");
        uonmTokenBalance += amountOfUonmTokensToSell;
        payable(msg.sender).transfer(amountOfEthToSeller);
        emit SellUonmTokens(msg.sender, amountOfUonmTokensToSell, amountOfEthToSeller);
    }

    function getUonmTokenBalance() public view returns (uint256) {
        return uonmTokenBalance;
    }

    // Function used to update deployment
    function updateUonmTokenBalance() public {
        uonmTokenBalance = uonmToken.balanceOf(address(this));
    }
}
