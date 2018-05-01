pragma solidity ^0.4.21;

import "./Mortal.sol";

contract Ballot is Owned{
    mapping (address => Candidate) public candidates;
    mapping (address => bool) public voters;
    
    address[] public registeredCandidates;
    uint public candidatesQty;
    bool public created = true;
    
    struct Candidate{
        bool active;
        uint votes;
    }
    

    constructor(address[] memory candidateList) public {
        for (uint i = 0; i < candidateList.length; i++){
            Candidate storage candidate = candidates[candidateList[i]];
            
            // Avoid adding a candidate multiple times
            require(!candidate.active);
            candidate.active = true;
        }
        // Null vote
        candidates[0x0].active = true;
        // Save the list of candidates
        registeredCandidates = candidateList;
        candidatesQty = candidateList.length;
    }

    function vote(address from, address to) onlyowner public {
        // haven't voted yet
        require(!voters[from]);
        // Is an active candidate
        require(candidates[to].active);
        // Is not voting for himself
        require(from != to);
        candidates[to].votes++;
        voters[from] = true;
        
        // Order list of candidates
        for (uint i = 0; i < candidatesQty; i++){
            if(to == registeredCandidates[i]){
                if (i > 0){
                    if (candidates[to].votes > candidates[registeredCandidates[i-1]].votes){
                        registeredCandidates[i] = registeredCandidates[i-1];
                        registeredCandidates[i-1] = to;
                    }
                }
            }
        }
        
        
    }
}