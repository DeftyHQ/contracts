const DeftyWrap = artifacts.require('./DeftyWrap');
const config = {
  name: 'DeftyToken',
  symbol: 'DTY',
  cdpAddress: process.env.DAI_TUB
}


contract('DeftyWrap', (accounts) => {
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

  // Can prove Ownership of a cup
  // Can wrap an CDP into an NFT
  // Can unwrap an NFT and give CDP to msg.sender

  // Can list all proofs
  // Can list proofs by address
});
