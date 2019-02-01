
const tAssert = require('truffle-assertions');
const Doppelganger = require('ethereum-doppelganger').default;
const Maker = artifacts.require('ISaiTub');
const DeftyWrap = artifacts.require('DeftyWrap');
const { createWallet, intToBytes32 } = require('./utils');

const config = {
  name: 'DeftyToken',
  symbol: 'DTY',
  cdpAddress: process.env.ETH_DAI_TUB,
  wallet: createWallet(process.env.ETH_PRIVATE_KEY, process.env.ETH_RPC_URL)
}

contract('DeftyWrap', (accounts) => {
  describe('setup', ()=> {
    let instance;

    beforeEach('setup contract for each test', async() => {
      instance = await DeftyWrap.new(config.cdpAddress);
    });

    it('has the correct name', async () => {
      const name = await instance.name();
      assert.equal(name, config.name, 'Name constant is different from expected');
    });

    it('has the correct symbol', async () => {
      const symbol = await instance.symbol();
      assert.equal(symbol, config.symbol, 'Symbol constant is different from expected');
    });

    it('is initilized with a cdpAddress', async () => {
      const addrr = await instance.cdpAddress()
      assert.equal(addrr.toLowerCase(), config.cdpAddress.toLowerCase(), 'Address is different from constructor argument');
    });

    it('setCdpAddress() can change the address', async () => {
      await instance.setCdpAddress(accounts[1])
      const addrr = await instance.cdpAddress()
      assert.equal(addrr, accounts[1], 'Address change not taken into account')
    })

    it('setCdpAddress() can only be called by contract owner', async () => {
      // The contract owner is accounts[0] so we try to send from another account.
      await tAssert.reverts(
        instance.setCdpAddress(accounts[1], { from: accounts[2] }),
      )
    });
  });

  describe('proveOwnership()', () => {
    let instance, doppelganger;

    before(null, async () => {
      doppelganger = new Doppelganger(Maker.abi);
      await doppelganger.deploy(config.wallet); // Fails here and doesn't want to deploy. Missing a
    });

    beforeEach(null, async () => {
      instance = await DeftyWrap.new(doppelganger.address);
      await doppelganger.lad.returns(accounts[0]);
    });

    it('fails if called by another address then owner', async () => {
      const cupId = intToBytes32(2234, web3)
      await tAssert.reverts(
        instance.proveOwnership(cupId, { from: accounts[1] }),
        'The msg.sender is not the owner of the CDP'
      )
    });

    it('suceeds when called by owner', async () => {
      const cupId = intToBytes32(2234, web3)
      await tAssert.passes(instance.proveOwnership(cupId))
    });

    it('emits a Proved event on success', async () => {
      const cupId = intToBytes32(2234, web3)
      const result = await instance.proveOwnership(cupId)
      await tAssert.eventEmitted(result, 'Proved', null)
    });
  })

  describe('wrap()', () => {
    let instance, user, notUser, doppelganger;

    // Relies on web3 and tAssert
    function wrapCup(contract, stub, user) {
      const cupId = intToBytes32(149, web3)
      await stub.lad.returns(user);
      await contract.proveOwnership(cupId, { from: user })

      await stub.lad.returns(instance.address);
      return tAssert.passes(
        instance.wrap(cupId, { from: user }),
        'You must give() the CDP to this contract before calling wrap()'
      )
    }

    before(null, async () => {
      user = accounts[5]
      notUser = accounts[4]
      doppelganger = new Doppelganger(Maker.abi);
      await doppelganger.deploy(config.wallet); // Fails here and doesn't want to deploy. Missing a
    });

    beforeEach(null, async () => {
      instance = await DeftyWrap.new(doppelganger.address);
    });

    it('fails if there is no pre-existant proof', async () => {
      const cupId = intToBytes32(149, web3)
      await tAssert.reverts(
        instance.wrap(cupId, { from: user }),
        'You must proveOwnership() of CDP before wrapping'
      )
    });

    it('fails if the sender is different from previousOwner', async () => {
      const cupId = intToBytes32(149, web3)
      await doppelganger.lad.returns(user);
      await instance.proveOwnership(cupId, { from: user })
      await tAssert.reverts(
        instance.wrap(cupId, { from: notUser }),
        'You must be the previousOwner in order to wrap a CDP'
      )
    });

    it('fails if the Contract is not the owner of the CDP', async () => {
      const cupId = intToBytes32(149, web3)
      await doppelganger.lad.returns(user);
      await instance.proveOwnership(cupId, { from: user })
      await tAssert.reverts(
        instance.wrap(cupId, { from: user }),
        'You must give() the CDP to this contract before calling wrap()'
      )
    });

    it('succeeds when all 3 conditions are meet', async () => {
      // Sender must be previousOwner and contract must have the cdp.
      const cupId = intToBytes32(149, web3)
      await doppelganger.lad.returns(user);
      await instance.proveOwnership(cupId, { from: user })

      await doppelganger.lad.returns(instance.address);
      await tAssert.passes(
        instance.wrap(cupId, { from: user }),
        'You must give() the CDP to this contract before calling wrap()'
      )
      await tAssert.eventEmitted(result, 'Wrapped', null)
    });

    it('creates a proof', async () => {
      const success = wrapCup(instance, doppelganger, user);
      await success()
      const proofs = await instance.proofRegistery()
      console.log(proofs)
    });
  })
});

// @TODO
// - [x] Can prove Ownership of a cup
// - [x] Can wrap an CDP into an NFT
// - [ ] Can unwrap an NFT and give CDP to msg.sender
// - [ ] Can list all proofs
// - [ ] Can list proofs by address
