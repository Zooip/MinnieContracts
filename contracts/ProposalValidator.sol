pragma solidity ^0.4.9;

import "./owned.sol";
import "./MinnieGovernance.sol";

contract ProposalValidator {
    
    MinnieGovernance public governance;
    address[] public voters;
    mapping(address=>ProposalVote) votesOn;
    
    bool constant TIE_OUTPUT=true;
    
    uint public quorum;
    
    struct ProposalVote {
        mapping(address=>bool) castedVoters;
        mapping(address=>bool) votes;
    }
    
    function ProposalValidator(MinnieGovernance g, address first_voter) {
        governance=g;
        voters.push(first_voter);
        quorum=1;
    }
    
    function isExecutableProposal(address proposal) returns(bool){
        if(countVotesFor(proposal)>=quorum){
            return voteOuputFor(proposal);
        }else{
            return false;
        }
    }
    
    function countVotesFor(address proposal) constant returns(uint){
        uint _c=0;
        for(uint i=0;i<voters.length;i++){
            if(votesOn[proposal].castedVoters[voters[i]]){_c++;}
        }
        return _c;
    }
    
    function voteOuputFor(address proposal) constant returns(bool){
        uint yes_count=0;
        uint no_count=0;
        for(uint i=0;i<voters.length;i++){
            if(votesOn[proposal].votes[voters[i]]){
                yes_count++;
            }else{
                no_count++;
            }
        }
        
        if(yes_count>no_count){
            return true;
        }else if (yes_count<no_count){
            return false;
        }else{
            return TIE_OUTPUT;
        }
        
    }
    
    function registerProposal(address proposal) {
        //Nothing to do for now
    }
    
    function vote(address proposal, bool vote){
        votesOn[proposal].castedVoters[msg.sender]=true;
        votesOn[proposal].votes[msg.sender]=vote;
    }
}
