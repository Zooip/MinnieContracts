pragma solidity ^0.4.9;

import 'truffle/Assert.sol';
import "truffle/DeployedAddresses.sol";


import '../contracts/owned.sol';


contract TestOwned {

  owned owned_contract;

  function beforeEach() {
    owned_contract = new owned();
  }

  function testOwnerIsSetFromSender() {
    Assert.equal(address(this), owned_contract.owner(),
                'owner should be current contract');
  }

  function testOwnerIsSetFromChange() {
    owned_contract.changeOwner(address(1));
    Assert.equal(address(1), owned_contract.owner(),
                'owner should be changed to 1');
  }
}
