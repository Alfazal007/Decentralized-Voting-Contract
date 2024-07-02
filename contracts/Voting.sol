// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

error IsOwner_Or_AlreadyAnAdmin();
error AlreadyVoter_Or_IsAdmin_Or_IsOwner_Or_IsCandidate();
error Candidates_Cannot_Be_Added_Yet();
error Not_Admin();
error Already_A_Candidate();
error No_Candidate();
error Voting_Not_Started();
error Not_A_Candidate();
error Already_Voted_Or_Not_A_Voter();
error Not_Admin_Or_Candidates_Still_Adding();
error StillVoting_Or_Candidates_Still_Adding();
error Voting_Already_Started();
error Admin_Cannot_Be_Candidate();
error Candidates_Still_Adding();
error There_Are_Already_Some_Candidates();
error No_Voters();
error Only_Admin_Can_Add_Voters();
error No_Candidates_Or_No_Voters();

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
    bool public votingStarted;
    bool public candidatesAddingStarted;

    constructor() Ownable(msg.sender) {
        ownerAddress = msg.sender;
        votingStarted = false;
        candidatesAddingStarted = false;
    }

    // varibles
    Person[] public admins;
    mapping(address => bool) public adminMapping;

    Person[] public voters;
    mapping(address => bool) public voterMapping;

    mapping(address => uint256) public candidatesToVoters;
    address[] public candidatesArray;

    // test
    function addAdmin(address newAdmin) public onlyOwner {
        if (hasAdmin(newAdmin) == true || newAdmin == ownerAddress) {
            revert IsOwner_Or_AlreadyAnAdmin();
        }
        adminMapping[newAdmin] = true;
        admins.push(Person(PersonType.ADMIN, newAdmin));
    }

    // test
    function hasAdmin(address adminToBeFound) public view returns (bool) {
        return adminMapping[adminToBeFound] == true;
    }

    function addVoter(address newVoter) public {
        if (
            hasVoter(newVoter) ||
            hasAdmin(newVoter) ||
            newVoter == ownerAddress ||
            hasCandidates(newVoter)
        ) {
            revert AlreadyVoter_Or_IsAdmin_Or_IsOwner_Or_IsCandidate();
        }
        if (votingStarted == true) {
            revert Voting_Already_Started();
        }
        if (hasAdmin(msg.sender) == false) {
            revert Only_Admin_Can_Add_Voters();
        }
        if (candidatesAddingStarted == true) {
            revert Candidates_Still_Adding();
        }
        voterMapping[newVoter] = true;
        voters.push(Person(PersonType.VOTERS, newVoter));
    }

    function hasVoter(address voterToBeFound) public view returns (bool) {
        return voterMapping[voterToBeFound] == true;
    }

    function hasCandidates(
        address candidateToBeFound
    ) public view returns (bool) {
        return candidatesToVoters[candidateToBeFound] >= 1;
    }

    // start adding candidates -- admins
    function startAddingCandidates() public {
        if (candidatesArray.length > 0) {
            revert There_Are_Already_Some_Candidates();
        }
        if (hasAdmin(msg.sender) == false) {
            revert Not_Admin();
        }
        candidatesAddingStarted = true;
    }

    // add candidates -- admins
    function addCandidates(address newCandidate) public {
        if (candidatesAddingStarted == false) {
            revert Candidates_Cannot_Be_Added_Yet();
        }
        if (hasAdmin(msg.sender) != true) {
            revert Not_Admin();
        }
        if (hasCandidates(newCandidate) == true) {
            revert Already_A_Candidate();
        }
        if (hasAdmin(newCandidate) == true) {
            revert Admin_Cannot_Be_Candidate();
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
            revert Not_Admin();
        }
        if (candidatesAddingStarted == true) {
            revert Candidates_Still_Adding();
        }
        if (candidatesArray.length == 0) {
            revert No_Candidate();
        }
        if (voters.length <= 0) {
            revert No_Voters();
        }
        votingStarted = true;
    }

    // cast a vote -- voters
    function castVote(address candidate) public {
        if (votingStarted == false) {
            revert Voting_Not_Started();
        }
        if (hasCandidates(candidate) == false) {
            revert Not_A_Candidate();
        }
        // has already voted
        if (voterMapping[msg.sender] == false) {
            revert Already_Voted_Or_Not_A_Voter();
        }
        voterMapping[msg.sender] = false;
        candidatesToVoters[candidate]++;
    }

    // end voting -- admins
    function endVoting() public {
        if (hasAdmin(msg.sender) != true || candidatesAddingStarted == true) {
            revert Not_Admin_Or_Candidates_Still_Adding();
        }
        votingStarted = false;
    }

    // winner declaration

    // need to do many things here
    function declareWinner() public onlyOwner returns (address, uint256) {
        if (votingStarted == true || candidatesAddingStarted == true) {
            revert StillVoting_Or_Candidates_Still_Adding();
        }
        if (candidatesArray.length <= 0 || voters.length <= 0) {
            revert No_Candidates_Or_No_Voters();
        }
        address winner = address(0);
        uint256 votes = 0;

        for (uint256 i = 0; i < candidatesArray.length; i++) {
            address curCandidate = candidatesArray[i];
            if (candidatesToVoters[curCandidate] > votes) {
                votes = candidatesToVoters[curCandidate];
                winner = curCandidate;
            }
            delete candidatesToVoters[curCandidate];
        }
        for (uint256 i = 0; i < voters.length; i++) {
            delete voterMapping[voters[i].person];
        }
        delete voters;
        delete candidatesArray;
        // reset admins map and array
        for (uint256 i = 0; i < admins.length; i++) {
            delete adminMapping[admins[i].person];
        }
        delete admins;
        return (winner, votes - 1);
    }
}
