const hre = require("hardhat");

async function main() {

  const name = "SuperCoins";
  const symbol = "SP";
  const LoyaltyToken = await hre.ethers.getContractFactory("LoyaltyToken");

  // Start deployment, returning a promise that resolves to a contract object
  const loyalty_token = await LoyaltyToken.deploy(name, symbol);

  await loyalty_token.deployed();
  console.log("Contract deployed to address:", loyalty_token.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
