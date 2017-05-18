pragma solidity ^0.4.2;

import '../proposal.sol';
import '../minnie_bank.sol';
import "../periodic_contribution_reporter.sol";


contract DeployReporterProposal is Proposal{
    
    function DeployReporterProposal(MinnieGovernance gov) Proposal(gov)
    {
        _requestedProxies.push(gov.identifierHash("governance"));
        _requestedProxies.push(gov.identifierHash("bank"));
    }
    
    
    function execute() {
        GovernanceProxy gov_proxy=governance.proxyFor("governance");
        GovernanceProxy bank_proxy=governance.proxyFor("bank");
        
        MinnieGovernance proxyfiedGov=MinnieGovernance(gov_proxy);
        MinnieBank proxyfiedBank=MinnieBank(bank_proxy);
        
        MinnieBank bank=MinnieBank(bank_proxy.target());
        
        //deploy reporter
        PeriodicContributionRepository reporter= new PeriodicContributionRepository(bank);
        
        //Transfer ownership to governance
        reporter.changeOwner(address(governance));
        
        //register reporter in governance
        proxyfiedGov.setProxyFor("periodic_reporter", address(reporter));
        
        //allow reporter to acces bank
        proxyfiedBank.addTrustedAddress(address(reporter));
    }
    
}
