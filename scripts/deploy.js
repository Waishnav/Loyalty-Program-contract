async function main() {
  const LoyaltyProgram = await ethers.getContractFactory("LoyaltyProgram");

  // Start deployment, returning a promise that resolves to a contract object
  const loyalty_program = await LoyaltyProgram.deploy("Loyalty Program!");
  console.log("Contract deployed to address:", loyalty_program.address);
}

main()
 .then(() => process.exit(0))
 .catch(error => {
   console.error(error);
   process.exit(1);
 });