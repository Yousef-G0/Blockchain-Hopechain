// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract HopeChainDonation {
    address public admin;
    uint public totalDonations;
    uint public cooldownTime = 1 minutes;   

    struct Donation {
        address donor;
        uint amount;
        uint timestamp;
    }

    Donation[] public donations;
    mapping(address => uint) public lastDonationTime;

    event DonationReceived(address indexed donor, uint amount, uint timestamp);
    event FundsWithdrawn(address indexed admin, uint amount);

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    // Accept donations
    function donate() public payable {
        require(msg.value > 0);
        require(
            block.timestamp >= lastDonationTime[msg.sender] + cooldownTime
        );

        donations.push(Donation(msg.sender, msg.value, block.timestamp));
        totalDonations += msg.value;
        lastDonationTime[msg.sender] = block.timestamp;

        emit DonationReceived(msg.sender, msg.value, block.timestamp);
    }

    // Return number of donations
    function getDonationCount() public view returns (uint) {
        return donations.length;
    }

    // Return donation record by index
    function getDonationByIndex(uint index) public view returns (address, uint, uint) {
        require(index < donations.length);
        Donation memory d = donations[index];
        return (d.donor, d.amount, d.timestamp);
    }

    // Admin withdraws all funds
    function withdrawFunds() public onlyAdmin {
        uint balance = address(this).balance;
        require(balance > 0);

        payable(admin).transfer(balance);
        emit FundsWithdrawn(admin, balance);
    }

    // View current contract balance
    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
}

