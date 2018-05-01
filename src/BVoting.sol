pragma solidity ^0.4.21;

import "./Mortal.sol";
import "./Ballot.sol";

contract BVoting is Mortal {

    // Maps an address into somebody.
    mapping(address => User) public users;
    // List of elections
    mapping(address => Election) public elections; 
    // List of admins
    mapping(address => bool) admins;
    // New election created
    event electionCreated (address[] candidates, address electionContract, string title);
    // New user unlocked
    event userUnlocked(address user, address creator);
    // New admin created
    event adminCreated(address newAdmin, address creator);
    // New vote for an election
    event voted(address from, address electionTo, address votedFor);
    
    // First is blocked to default an user as blocked.
    enum Permission { BLOCKED, USER }

    // Basic user struct.
    struct User {
        Permission permission;
        uint expirationDate;
        string name;
        string surname;
        string electorCode;
    }
    
    struct Election{
        address winner;
        uint endingDate;
        string title;
    }
    
    // Ensures that only admins can run protected functions.
    modifier secured(){
        require(admins[msg.sender]);
        _;
    }
    
    // Only active users can make use of contract functions
    modifier activeUser(){
        require(users[msg.sender].permission == Permission.USER);
        require(users[msg.sender].expirationDate > now);
        _;
    }
    
    constructor() public{
        admins[msg.sender] = true;
    }
    
    function unlockUser(address id, string name, string surname, string electorCode) public secured{
        //users[id] = User(Permission.USER, now + 10 years, name, surname, electorCode);
        require(address(this).balance > 11 finney, "Smart contract out of ether");
        users[id] = User(Permission.USER, now + 10 years, name, surname, electorCode);
        id.transfer(10 finney);
        emit userUnlocked(id, msg.sender);
    }
    
    function makeAdmin(address id) public secured{
        admins[id] = true;
        emit adminCreated(id, msg.sender);
    }

    function isActive(address id) public constant returns(bool){
        return users[id].permission != Permission.BLOCKED;
    }

    //[0x405aA3a3F22B6C085efEA1e71fA482DFb719bE26, 0x4Fe7077c75B97473afF402c9A1e58DC96a628774]
    //["0x405aA3a3F22B6C085efEA1e71fA482DFb719bE26", "0x4Fe7077c75B97473afF402c9A1e58DC96a628774"]
    function createElection(address[] candidates, uint endDate, string title) public secured returns (address){
        require (endDate > now, "'endDate' parameter must be a future date.");
        address electionAddress = address (new Ballot(candidates));
        elections[electionAddress] = Election(0x0, endDate, title); 
        emit electionCreated(candidates, electionAddress, title);
        return electionAddress;
    }
    
    function voteFor(address electionAddress, address voteTo) public{
        require (users[msg.sender].permission != Permission.BLOCKED, "You must be an active an verified user");
        require (elections[electionAddress].endingDate > now, "Election is over");
        Ballot bb = Ballot(electionAddress);
        bb.vote(msg.sender, voteTo);
        emit voted(msg.sender, electionAddress, voteTo);
    }
    
    function () public payable { }
}