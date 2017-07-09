pragma solidity ^0.4.9;

import '../Proposal.sol';
import '../MinnieBank.sol';
import "../PeriodicContributionRepository.sol";

// Deploy a new contract and add it to the bank's trustedAddresses
contract DeployReporterProposal is Proposal{
    
    function DeployReporterProposal(MinnieGovernance gov) Proposal(gov) {
        //Init proxies dependencies
        _requestedProxies.push(gov.identifierHash("governance"));
        _requestedProxies.push(gov.identifierHash("bank"));
    }
    
    
    function execute() {
        //Set proxies
        GovernanceProxy gov_proxy=governance.proxyFor("governance");
        GovernanceProxy bank_proxy=governance.proxyFor("bank");
        
        //Set proxified contracts
        // [XXX] - What does that mean?
        // [XXX] - No new => means no constructor call?
        MinnieGovernance proxyfiedGov=MinnieGovernance(gov_proxy);
        MinnieBank proxyfiedBank=MinnieBank(bank_proxy);
        
        //Set real contracts (governance is already known from Proposal)
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
