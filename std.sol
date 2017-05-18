pragma solidity ^0.4.2;

//Abstract contracts for inheritence
contract owned {
    address public owner;
// Contract owner. It can be an ethereum account (a real people) or a
// contract setting governance rules

    event OwnerChanged(
    address newOwner,
    address previousOwner
    );

//functions using onlyowner can only be used from the owner address
    modifier onlyowner {
        //log0("Only owner (sender, granted) :");
        //log0(bytes32(msg.sender));
        //log0(bytes32(owner));
        if (msg.sender != owner){throw;} //Consumes all gas
        _;
    }
    
    
// Allow to change owner to allow change in governance
    function changeOwner(address newOwner) onlyowner {
        OwnerChanged(newOwner,owner); //Trigger event OwnerChanged
        owner=newOwner;
    }

    function owned() {
        owner=msg.sender;
    }
}