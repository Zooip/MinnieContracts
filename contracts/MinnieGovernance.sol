pragma solidity ^0.4.9;

import "./owned.sol";
import "./MinnieBank.sol";
import './GovernanceProxy.sol';
import './Proposal.sol';
import './ProposalValidator.sol';

contract MinnieGovernance is owned {
    
    mapping(bytes32 => GovernanceProxy) public proxies;
    ProposalValidator public proposalValidator;
    
    // [XXX] - Shounldn't it be onlyowner?
    function setProxyFor(string identifier, address target) onlyowner returns(GovernanceProxy) {
        bytes32 h=identifierHash(identifier);
        // [XXX] - Why create a new GProxy contract and not change the existing proxy's target?
        // Because nobody owns the proxy, probably?
        // Then, shouldn't we somehow "delete" the old proxy?
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
