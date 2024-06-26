// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Voting is Ownable {
    // this is shared resource
    enum PersonType {
        ADMIN,
        VOTERS
    }

    // the type of person voter or admin
    struct Person {
        PersonType typeOfPerson;
        address person;
    }

    address immutable ownerAddress;
    bool votingStarted;
    bool candidatesAddingStarted;

    constructor() Ownable(msg.sender) {
        ownerAddress = msg.sender;
        votingStarted = false;
        candidatesAddingStarted = false;
    }

    // varibles
    Person[] admins;
    mapping(address => bool) adminMapping;

    Person[] voters;
    mapping(address => bool) voterMapping;

    mapping(address => uint256) candidatesToVoters;
    address[] public candidatesArray;

    function addAdmin(address newAdmin) public onlyOwner {
        if (hasAdmin(newAdmin) == true || newAdmin == ownerAddress) {
            return;
        }
        adminMapping[newAdmin] = true;
        admins.push(Person(PersonType.ADMIN, newAdmin));
    }

    function hasAdmin(address adminToBeFound) public view returns (bool) {
        return adminMapping[adminToBeFound] == true;
    }

    function addVoter(address newVoter) public onlyOwner {
        if (hasVoter(newVoter) || hasAdmin(newVoter) || newVoter == ownerAddress) {
            return;
        }
        voterMapping[newVoter] = true;
        voters.push(Person(PersonType.VOTERS, newVoter));
    }

    function hasVoter(address voterToBeFound) public view returns (bool) {
        return voterMapping[voterToBeFound] == true;
    }

    function hasCandidates(address candidateToBeFound) public view returns (bool) {
        return candidatesToVoters[candidateToBeFound] == 1;
    }

    // start adding candidates -- admins
    function startAddingCandidates() public {
        if (hasAdmin(msg.sender) == true) {
            candidatesAddingStarted = true;
        }
    }

    // add candidates -- admins
    function addCandidates(address newCandidate) public {
        if (candidatesAddingStarted == false) {
            return;
        }
        if (hasAdmin(msg.sender) != true) {
            return;
        }
        if (hasCandidates(newCandidate) == true) {
            return;
        }
        candidatesToVoters[newCandidate] = 1;
        candidatesArray.push(newCandidate);
    }

    // end adding candidates -- admins
    function endAddingCandidates() public {
        if (hasAdmin(msg.sender) == true) {
            candidatesAddingStarted = false;
        }
    }

    // start voting -- admins
    function startVoting() public {
        if (hasAdmin(msg.sender) != true) {
            return;
        }
        if (candidatesAddingStarted == true) {
            return;
        }
        if (candidatesArray.length == 0) {
            return;
        }
        votingStarted = true;
    }

    // cast a vote -- voters
    function castVote(address candidate) public {
        if (votingStarted == false) {
            return;
        }
        if (hasCandidates(candidate) == false) {
            return;
        }
        // has already voted
        if (voterMapping[msg.sender] == false) {
            return;
        }
        voterMapping[msg.sender] = true;
        candidatesToVoters[candidate]++;
    }

    // end voting -- admins
    function endVoting() public {
        if (hasAdmin(msg.sender) != true || candidatesAddingStarted == true) {
            return;
        }
        votingStarted = false;
    }

    // winner declaration

    // need to do many things here
    function declareWinner() public returns (address, uint256) {
        address winner = address(0);
        uint256 votes = 0;
        if (votingStarted == true || candidatesAddingStarted == true) {
            return (winner, votes);
        }

        for (uint256 i = 0; i < candidatesArray.length; i++) {
            address curCandidate = candidatesArray[i];
            if (candidatesToVoters[curCandidate] > votes) {
                votes = candidatesToVoters[curCandidate];
                winner = curCandidate;
            }
            delete candidatesToVoters[curCandidate];
        }
        for(uint256 i = 0; i < voters.length; i++) {
            delete voterMapping[voters[i].person];
        }
        delete voters;
        delete candidatesArray;
        // reset admins map and array
        for(uint256 i = 0; i < admins.length; i++) {
            delete adminMapping[admins[i].person];
        }
        delete admins;
        return (winner, votes);
    }
}
