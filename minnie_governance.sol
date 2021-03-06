pragma solidity ^0.4.9;

import "std.sol";
import "minnie_bank.sol";
import 'governance_proxy.sol';
import 'proposal.sol';
import 'proposal_validator.sol';

contract MinnieGovernance is owned {
    
    mapping(bytes32 => GovernanceProxy) public proxies;
    ProposalValidator public proposalValidator;
    
    function setProxyFor(string identifier, address target) returns(GovernanceProxy){
        bytes32 h=identifierHash(identifier);
        GovernanceProxy proxy=new GovernanceProxy(target);
        owned(target).changeOwner(address(proxy));
        return proxies[h]=proxy;
    }
    
    function identifierHash(string identifier) constant returns(bytes32) {
        return sha3(identifier);
    }
    
    function proxyFor(string identifier) constant returns(GovernanceProxy){
        bytes32 h=identifierHash(identifier);
        GovernanceProxy proxy=proxies[h];
        return proxy;
    }
    
    function MinnieGovernance() {
        log0("Initializing Governance ...");
        log0(bytes32(address(this)));
        
        proposalValidator = new ProposalValidator(this,msg.sender);
        //proposalValidator = ProposalValidator(0x06b179aabf198ced0f98c8ceca905a920a137ef4);
        GovernanceProxy proxy=new GovernanceProxy(this);
        proxies[identifierHash("governance")]=proxy;
        owner=address(proxy);
        
        MinnieBank bank=new MinnieBank();
        setProxyFor("bank", address(bank));
    }
    
    function executeProposal(Proposal proposal) {
        
        if(!proposalValidator.isExecutableProposal(proposal)){throw;}
        
        uint proxy_count=proposal.requestedProxiesCount();
        
        GovernanceProxy[] memory proxies_cache = new GovernanceProxy[](proxy_count);
        uint i;
        for(i = 0; i < proxy_count; i++) {
            proxies_cache[i]=proxies[proposal.requestedProxies(i)];
        }
        
        for(i = 0; i < proxies_cache.length; i++) {
            proxies_cache[i].grantAccess(address(proposal));
        }

        proposal.execute();
        
        for(i = 0; i < proxies_cache.length; i++) {
            proxies_cache[i].clearAccess();
        }
    }
}