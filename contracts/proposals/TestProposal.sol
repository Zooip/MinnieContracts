pragma solidity ^0.4.9;

import '../Proposal.sol';
import '../MinnieBank.sol';


contract TestProposal is Proposal{
    
    function TestProposal(MinnieGovernance gov) Proposal(gov)
    {
        _requestedProxies.push(gov.identifierHash("bank"));
    }
    
    
    function execute() {
        GovernanceProxy proxy=governance.proxyFor("bank");
        MinnieBank realBank=MinnieBank(proxy.target());
        MinnieBank proxyBank=MinnieBank(address(proxy));
        log0(bytes32(realBank.test_value()));
        proxyBank.registerContributor(address(1));
        log0(bytes32(realBank.test_value()));
    }
    
}
