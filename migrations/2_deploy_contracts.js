const DeftyWrap = artifacts.require('DeftyWrap');

// Set by dotenv-flow in truffle-config.js
const makerCDPAddress = process.env.DAI_TUB;

module.exports = function(deployer) {
  deployer.deploy(DeftyWrap, makerCDPAddress);
};
