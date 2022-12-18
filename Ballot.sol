// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract Ballot{

    struct Voter{
        uint weight;
        bool voted;
        address delegate;
        uint vote;
    }

    struct Proposal{
        bytes32 name;
        uint voteCount;
    }

    address public chairperson;
    mapping(address => Voter) public voters;
    Proposal[] public proposals;

    constructor(bytes32[] memory ProposalNames) {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;

        for(uint i = 0; i < ProposalNames.length; i++) {
            proposals.push(Proposal({name: ProposalNames[i], voteCount: 0}));
        
        }
    }

    function giveRightToVote(address voter) external {
        require(msg.sender == chairperson, "Only chairperson can give right to vote");
        require(voters[voter].voted == false, "The voter already voted");
        require(voters[voter].weight == 0);
        voters[voter].weight = 1;
    }

    function delegate(address to) external {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "You have no right to vote");
        require(!sender.voted, "You already voted.");
        require(to != msg.sender, "Self-delegation is disallowed.");

        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;
            require(to != msg.sender, "Found loop in delegation.");
        }

        Voter storage delegate_ = voters[to];

        require(delegate_.weight >= 1);
        require(!delegate_.voted, "The person you are trying to delegate is already voted");
        sender.voted = true;
        sender.delegate = to;
        
    }

    function vote(uint proposal) external {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        require(sender.voted == false, "Already voted");
        sender.voted = true;
        sender.vote = proposal;

        proposals[proposal].voteCount += sender.weight; 
    }

    function winningProposal() public view returns(bytes32 winnerName_){
        bytes32 nota;
        uint winningVoteCount = 0;
        for(uint p = 0; p < proposals.length; p++){
            if(proposals[p].voteCount > winningVoteCount){
                winningVoteCount = proposals[p].voteCount;
                winnerName_ = proposals[p].name;
            }else{
                winnerName_ = nota;
            }
        }
    }

