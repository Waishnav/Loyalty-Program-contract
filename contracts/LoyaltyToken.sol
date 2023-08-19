// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LoyaltyToken is ERC20, Ownable {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    // Mapping to store wallet balances
    mapping(address => uint256) private _walletBalances;

    // Initialize wallet account
    function initializeWallet(address walletAddress) external onlyOwner {
        require(!_isWalletInitialized(walletAddress), "Wallet already initialized");
        _walletBalances[walletAddress] = 0; // Initialize balance to 0
    }

    // Get wallet balance
    function getWalletBalance(address walletAddress) external view returns (uint256) {
        return _walletBalances[walletAddress];
    }

    // Distribute tokens to a wallet
    function distributeTokens(address walletAddress, uint256 amount) external onlyOwner {
        require(_isWalletInitialized(walletAddress), "Wallet not initialized");
        _mint(walletAddress, amount);
        _walletBalances[walletAddress] += amount;
    }

    // Claim tokens from a wallet
    function claimTokens(uint256 amount) external {
        require(_isWalletInitialized(msg.sender), "Wallet not initialized");
        require(_walletBalances[msg.sender] >= amount, "Insufficient balance");
        _walletBalances[msg.sender] -= amount;
        _burn(msg.sender, amount);
    }

    // Internal function to check if wallet is initialized
    function _isWalletInitialized(address walletAddress) internal view returns (bool) {
        return _walletBalances[walletAddress] > 0;
    }
}
