// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BarberShopContract {
    address public owner;

    // Struct to represent a staff member
    struct Staff {
        string fullName;
        uint workingDaysPerWeek;
        bool available;
        mapping(string => bool) servicesOffered;
        mapping(string => uint) servicePrices;
        uint totalEarnings;
    }
   
   // Mapping to store staff members
    mapping(address => Staff) public staffRegistry;

    // Struct to represent a client
    struct Client {
        string name;
        string service;
        int phone;
            }

    // Mapping to store clients
    mapping(address => Client) public clients;

      // Constructor to set the contract owner
    constructor() {
        owner = msg.sender;
    }

    // Modifier to restrict functions to the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    // Function to add a new staff member (onlyOwner can call this)
    function addStaffMember(address staffAddress, string memory fullName, uint workingDaysPerWeek) public onlyOwner {
    Staff storage newStaff = staffRegistry[staffAddress];
    newStaff.fullName = fullName;
    newStaff.workingDaysPerWeek = workingDaysPerWeek;
    newStaff.available = true;}

    // Function to remove a staff member (onlyOwner can call this)
    function removeStaffMember(address staffAddress) public onlyOwner {
        delete staffRegistry[staffAddress];
    }


    

}