// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.9;

import "hardhat/console.sol";

contract SuperCoin {

    enum Role {
        Admin,
        Buyer,
        Seller
    }

    enum TransactionType {
        Credit,
        Debit
    }

    enum Status {
        Active,
        Inactive,
        Deleted
    }

    struct HistoryEntry {
        string description;
        int256 balanceBefore;
        int256 balanceAfter;
        TransactionType creditOrDebit;
        string transactionId;
        int256 timestamp;
    }

    struct Participant {
        address wallet;
        string name;
        string id;
        HistoryEntry[] history;
        int256 balance;
        Role role;
        Status currentStatus;
    }

    string[] public sellerIds;
    string[] public buyerIds;
    mapping(string => Participant) public allParticipants;
    int256 public valueOfOneCoin = 10;
    int256 public totalSupply;

    constructor(int256 initialValue) {
        totalSupply = initialValue;
    }

    function getParticipantDetails(string calldata participantId) external view returns (Participant memory) {
        require(bytes(allParticipants[participantId].id).length > 0, "Invalid Participant Id");
        return allParticipants[participantId];
    }

    function registerParticipant(string calldata name, string calldata id, string calldata role, int256 timestamp) public returns (Participant memory) {
        require(bytes(name).length > 0, "Name cannot be empty");
        require(bytes(id).length > 0, "Id cannot be empty");
        require(bytes(role).length > 0, "Role cannot be empty");

        if (bytes(allParticipants[id].name).length > 0) {
            return allParticipants[id];
        }

        Role parsedRole = Role.Buyer;
        if (keccak256(abi.encodePacked(role)) == keccak256(abi.encodePacked("seller"))) {
            parsedRole = Role.Seller;
            sellerIds.push(id);
        } else {
            buyerIds.push(id);
        }

        Participant storage newParticipant = allParticipants[id];
        newParticipant.wallet = msg.sender;
        newParticipant.name = name;
        newParticipant.id = id;
        newParticipant.history.push(HistoryEntry("Account Created", 0, 0, TransactionType.Credit, "-1", timestamp));
        newParticipant.balance = 0;
        newParticipant.role = parsedRole;
        newParticipant.currentStatus = Status.Active;

        return newParticipant;
    }

    function _mint(int256 amount) internal {
        totalSupply += amount;
    }

    function subtractBalance(string calldata participantId, int256 amount, string memory description, int256 timestamp) public {
        require(bytes(allParticipants[participantId].name).length > 0, "Participant does not exist");
        Participant storage participant = allParticipants[participantId];
        participant.history.push(HistoryEntry(description, participant.balance, participant.balance - amount, TransactionType.Debit, "-1", timestamp));
        participant.balance -= amount;
    }

    function addBalance(string calldata participantId, int256 amount, string memory description, int256 timestamp) public {
        require(bytes(allParticipants[participantId].name).length > 0, "Participant does not exist");
        Participant storage participant = allParticipants[participantId];
        participant.history.push(HistoryEntry(description, participant.balance, participant.balance + amount, TransactionType.Credit, "-1", timestamp));
        participant.balance += amount;
    }

    function claimCoins(
        string calldata buyerId,
        string calldata orderId,
        int256 coinsFlipkart,
        int256 coinsSeller,
        string calldata sellerId,
        int256 timestamp
    ) public {
        require(bytes(allParticipants[buyerId].name).length > 0, "Buyer does not exist");
        require(bytes(allParticipants[sellerId].name).length > 0, "Seller does not exist");
        _mint(coinsFlipkart);
        subtractBalance(sellerId, coinsSeller, string(abi.encodePacked("Claim Coins transferred to Buyer:", ' ', buyerId)), timestamp);
        addBalance(buyerId, coinsFlipkart, string(abi.encodePacked("Claim Coins awarded for order:", ' ', orderId)), timestamp);
        addBalance(buyerId, coinsSeller, string(abi.encodePacked("Claim Coins awarded by seller for order:", ' ', orderId)), timestamp);
    }

    function toLoyalCustomers(
        string[] calldata customerIds,
        string calldata sellerId,
        int256 numberOfCoins,
        int256 timestamp
    ) public {
        require(bytes(allParticipants[sellerId].name).length > 0, "Seller does not exist");
        uint256 arrayLength = customerIds.length;
        for (uint256 i = 0; i < arrayLength; i++) {
            subtractBalance(sellerId, numberOfCoins, string(abi.encodePacked("Loyalty Coins transferred to Buyer:", ' ', customerIds[i])), timestamp);
            addBalance(customerIds[i], numberOfCoins, string(abi.encodePacked("Loyalty Coins awarded by seller:", ' ', sellerId)), timestamp);
        }
    }

    function buyCoupon(string calldata customerId, int256 amount, string calldata couponId, int256 timestamp) public {
        require(amount > 0, "Coupon cost must be greater than 0");
        subtractBalance(customerId, amount, string(abi.encodePacked("Coupon Paid for coupon:", ' ', couponId)), timestamp);
    }
}
