// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// modifier, owner is the deployer
error Ballot__NotOwner();

contract Ballot {
    struct Voter {
        uint weight; // weight is accumulated by delegation
        bool voted; // if true, that person already voted
        address delegate; // person delegated to
        uint vote; // index of the voted proposal
    }

    struct Proposal {
        // If you can limit the length to a certain number of bytes,
        // always use one of bytes1 to bytes32 because they are much cheaper
        bytes32 name; // short name (up to 32 bytes)
        uint voteCount; // number of accumulated votes
    }

    // storage
    address private immutable chairperson;
    // always check voters[addr].weight if 0 to tell if the voter could vote
    mapping(address => Voter) public voters;
    Proposal[] public proposals;

    // Modifiers: Modifiers can also be chained together, meaning that you can have
    // multiple modifiers on a single function. However, modifiers can only modify
    // contract logic, and they cannot modify a contract’s storage
    modifier onlyOwner() {
        if (msg.sender != chairperson) revert Ballot__NotOwner();
        _;
    }

    function stringToBytes32(
        string memory source
    ) public pure returns (bytes32 result) {
        assembly {
            result := mload(add(source, 32))
        }
    }

    /**
     * @dev Create a new ballot to choose one of 'proposalNames'.
     * @param proposalNames names of proposals
     */
    //constructor(bytes32[] memory proposalNames) {
    constructor(string[] memory proposalNames) {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;

        for (uint i = 0; i < proposalNames.length; i++) {
            // 'Proposal({...})' creates a temporary
            // Proposal object and 'proposals.push(...)'
            // appends it to the end of 'proposals'.
            proposals.push(
                Proposal({
                    name: stringToBytes32(proposalNames[i]),
                    voteCount: 0
                })
            );
        }
    }

    /**
     * @dev Give 'voter' the right to vote on this ballot. May only be called by 'chairperson'.
     * @param voter address of voter
     */
    function giveRightToVote(address voter) public onlyOwner {
        require(voters[voter].weight == 0, "The voter could vote already.");
        voters[voter].weight = 1;
    }

    /**
     * @dev Delegate your vote to the voter 'to'.
     * @param to address to which vote is delegated
     */
    function delegate(address to) public {
        Voter storage sender = voters[msg.sender];
        require(sender.weight > 0, "has no right to vote/delegate.");
        require(!sender.voted, "You already voted.");
        require(to != msg.sender, "Self-delegation is disallowed.");

        // QUESTION: what if the person getting the delegated vote has no right to 
        // vote? does this need to be handled?
        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;

            // We found a loop in the delegation, not allowed.
            require(to != msg.sender, "Found loop in delegation.");
        }
        sender.voted = true;
        sender.delegate = to;
        Voter storage delegate_ = voters[to];
        if (delegate_.voted) {
            // If the delegate already voted,
            // directly add to the number of votes
            proposals[delegate_.vote].voteCount += sender.weight;
        } else {
            // If the delegate did not vote yet,
            // add to her weight.
            delegate_.weight += sender.weight;
        }
    }

    /**
     * @dev Give your vote (including votes delegated to you) to proposal 'proposals[proposal].name'.
     * @param proposal index of proposal in the proposals array
     */
    function vote(uint proposal) public {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote.");
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal;

        require(proposal < proposals.length, "Invalid proposal voted.");
        // If 'proposal' is out of the range of the array,
        // this will throw automatically and revert all
        // changes.
        proposals[proposal].voteCount += sender.weight;
    }

    /**
     * @dev Computes the winning proposal taking all previous votes into account.
     * @return winningProposal_ index of winning proposal in the proposals array
     */
    function winningProposal() public view returns (uint winningProposal_) {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    /**
     * @dev Calls winningProposal() function to get the index of the winner contained in the proposals array and then
     * @return winnerName_ the name of the winner
     */
    function winnerName() public view returns (bytes32 winnerName_) {
        winnerName_ = proposals[winningProposal()].name;
    }

    function getProposalName(
        uint256 index
    ) public view returns (bytes32 option_) {
        require(index < proposals.length, "Invalid proposal index.");
        option_ = proposals[index].name;
    }

    function getProposalVote(uint256 index) public view returns (uint count_) {
        require(index < proposals.length, "Invalid proposal index.");
        count_ = proposals[index].voteCount;
    }

    function ifVoted() public view returns (bool ifVote_) {
        ifVote_ = voters[msg.sender].voted;
    }

    function getWeight(
        address addr
    ) public view onlyOwner returns (uint weight_) {
        weight_ = voters[addr].weight;
    }

    function getVoterInfo(
        address addr
    ) public view onlyOwner returns (Voter memory voter_) {
        voter_ = voters[addr];
    }
}
