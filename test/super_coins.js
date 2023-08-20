const { expect } = require("chai");

describe("SuperCoin", function () {
  let SuperCoin;
  let superCoin;
  let owner;
  let buyer;
  let seller;

  beforeEach(async function () {
    [owner, buyer, seller] = await ethers.getSigners();
    SuperCoin = await ethers.getContractFactory("SuperCoin");
    superCoin = await SuperCoin.deploy(1000); // Initial totalSupply is 1000
    await superCoin.deployed();
  });

  it("should register a participant", async function () {
    const role = "buyer";
    const name = "John Doe";
    const id = "buyer1";
    const timestamp = Math.floor(Date.now() / 1000);
    const tx = await superCoin
      .connect(buyer)
      .registerParticipant(name, id, role, timestamp);
    await tx.wait();

    const participant = await superCoin.getParticipantDetails(id);
    expect(participant.name).to.equal(name);
    expect(participant.role).to.equal(1); // Buyer role
    expect(participant.balance).to.equal(0);
  });

  it("should add and subtract balance", async function () {
    const amount = 100;
    const description = "Test transaction";
    const timestamp = Math.floor(Date.now() / 1000);

    await superCoin
      .connect(buyer)
      .registerParticipant("John Doe", "buyer1", "buyer", timestamp);

    await superCoin
      .connect(buyer)
      .addBalance("buyer1", amount, description, timestamp);
    let participant = await superCoin.getParticipantDetails("buyer1");
    expect(participant.balance).to.equal(amount);

    await superCoin
      .connect(buyer)
      .subtractBalance("buyer1", amount, description, timestamp);
    participant = await superCoin.getParticipantDetails("buyer1");
    expect(participant.balance).to.equal(0);
  });

  it("should claim coins", async function () {
    const buyerId = "buyer1";
    const sellerId = "seller1";
    const coinsFlipkart = 50;
    const coinsSeller = 30;
    const orderId = "order123";
    const timestamp = Math.floor(Date.now() / 1000);

    await superCoin
      .connect(buyer)
      .registerParticipant("John Doe", buyerId, "buyer", timestamp);
    await superCoin
      .connect(seller)
      .registerParticipant("Jane Smith", sellerId, "seller", timestamp);

    await superCoin
      .connect(owner)
      .claimCoins(
        buyerId,
        orderId,
        coinsFlipkart,
        coinsSeller,
        sellerId,
        timestamp
      );

    const buyerParticipant = await superCoin.getParticipantDetails(buyerId);
    const sellerParticipant = await superCoin.getParticipantDetails(sellerId);

    expect(buyerParticipant.balance).to.equal(coinsFlipkart + coinsSeller);
    expect(sellerParticipant.balance).to.equal(0);
  });
});
