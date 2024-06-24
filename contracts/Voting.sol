// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Voting is Ownable {
    // this is shared resource
    enum FreshJuiceSize {
        ADMIN,
        VOTERS
    }

    // the type of person voter or admin
    struct Person {
        FreshJuiceSize typeOfPerson;
        address person;
    }

    address immutable ownerAddress;
    bool voingStarted;
    bool candidatesAddingStarted;

    constructor() Ownable(msg.sender) {
        ownerAddress = msg.sender;
        voingStarted = false;
        candidatesAddingStarted = false;
    }

    // varibles
    Person[] admins;
    mapping(address => bool) adminMapping;

    Person[] voters;
    mapping(address => bool) voterMapping;

    mapping(address => uint256) candidatesToVoters;

    function addAdmin(address newAdmin) public onlyOwner {
        if (hasAdmin(newAdmin) == true || newAdmin == ownerAddress) {
            return;
        }
        adminMapping[newAdmin] = true;
        admins.push(Person(FreshJuiceSize.ADMIN, newAdmin));
    }

    function hasAdmin(address adminToBeFound) public view returns (bool) {
        return adminMapping[adminToBeFound] == true;
    }

    function addVoter(address newVoter) public onlyOwner {
        if (hasVoter(newVoter) || hasAdmin(newVoter)) {
            return;
        }
        voterMapping[newVoter] = true;
        voters.push(Person(FreshJuiceSize.VOTERS, newVoter));
    }

    function hasVoter(address voterToBeFound) public view returns (bool) {
        return voterMapping[voterToBeFound] == true;
    }

    // start adding candidates -- admins
    function startAddingCandidates() public {
        if (hasAdmin(msg.sender) == true) {
            candidatesAddingStarted = true;
        }
    }

    // add candidates -- admins
    function addCandidates(address newCandidate) public {
        if (hasAdmin(msg.sender) != true) {
            return;
        }
    }

    // end adding candidates -- admins
    function endAddingCandidates() public {
        if (hasAdmin(msg.sender) == true) {
            candidatesAddingStarted = false;
        }
    }
    // start voting -- admins
    // cast a vote -- voters
    // end voting -- admins
    // winner declaration
}
