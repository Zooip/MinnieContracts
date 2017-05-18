pragma solidity ^0.4.9;

import 'minnie_governance.sol';

contract GovernanceProxy {
    
    MinnieGovernance public governanceContract;
    address public currentGrant;
    address public target;
    
    modifier onlygovernance {
        if(msg.sender != address(governanceContract)){throw;} //Consumes all gas
        _;
    }
    
    modifier onlygranted {
        /*log0("Only granted (sender, granted) :");
        log0(bytes32(msg.sender));
        log0(bytes32(currentGrant));*/
        if(currentGrant!=msg.sender && msg.sender != address(governanceContract)){throw;} //Consumes all gas
        _;
    }
    
    function GovernanceProxy(address _target){
        governanceContract=MinnieGovernance(msg.sender);
        target=_target;
    }
    
    function grantAccess(address proposal) onlygovernance{
        currentGrant=proposal;
    }
    
        
    function clearAccess() onlygovernance{
        currentGrant=0x0;
    }
    
    function() onlygranted {
      target.call(msg.data);
    }
}