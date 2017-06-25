pragma solidity ^0.4.9;

import 'dapple/test.sol';

import 'std.sol';

contract ownedTest is Test {
  Tester proxy_tester;

  owned owned_contract;
  event OwnerChanged(
    address newOwner,
    address previousOwner
  );

  function setUp() {
    owned_contract = new owned();
    proxy_tester = new Tester();
    proxy_tester._target(owned_contract);
  }

  function testOwnerIsSetFromSender() {
    assertEq(address(this), owned_contract.owner());
  }

  function testOwnerIsSetFromChange() {
    owned_contract.changeOwner(address(1));
    assertEq(address(1), owned_contract.owner());
  }

  function testEventIsSentAtChange() {
    expectEventsExact(owned_contract);
    OwnerChanged(address(1), address(this));

    owned_contract.changeOwner(address(1));
  }
}
