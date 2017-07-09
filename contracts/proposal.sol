pragma solidity ^0.4.9;

import './GovernanceProxy.sol';
import './MinnieGovernance.sol';


contract Proposal{
    
    MinnieGovernance public governance;
    
    bytes32[] _requestedProxies;
    function requestedProxiesCount() constant returns(uint){
        return _requestedProxies.length;
    }
    function requestedProxies(uint i) returns(bytes32){
        return _requestedProxies[i];
    }
    
    function Proposal(MinnieGovernance gov){
        governance=gov;
    }
    
    function requestExecution() {
        governance.executeProposal(this);
    }
    
    function execute();
    
}
