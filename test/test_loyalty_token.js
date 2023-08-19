const { expect } = require("chai");

describe("LoyaltyToken", function () {
  let LoyaltyToken, loyaltyToken, owner, addr1, addr2;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();
    LoyaltyToken = await ethers.getContractFactory("LoyaltyToken");
    loyaltyToken = await LoyaltyToken.deploy("Loyalty Token", "LOYAL");
  });

  it("should initialize wallet and get wallet balance", async function () {
    await loyaltyToken.initializeWallet();
    const walletAddress = await loyaltyToken.getWalletBalance(owner.address);
    expect(walletAddress).to.equal(0); // You need to provide the expected balance here
  });

  it("should distribute tokens to a wallet", async function () {
    await loyaltyToken.initializeWallet();
    await loyaltyToken.distributeTokens(owner.address, 100);
    const balance = await loyaltyToken.getWalletBalance(owner.address);
    expect(balance).to.equal(100);
  });

  it("should claim tokens from a wallet", async function () {
    await loyaltyToken.initializeWallet();
    await loyaltyToken.distributeTokens(owner.address, 100);
    await loyaltyToken.claimTokens(50);
    const balance = await loyaltyToken.getWalletBalance(owner.address);
    expect(balance).to.equal(50);
  });
});
