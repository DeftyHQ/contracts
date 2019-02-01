const env = require('yenv')('../env.yaml', { raw: true });
const DeftyWrap = artifacts.require('DeftyWrap');

const makerCDPAddress = env.ETH_DAI_TUB;

module.exports = function(deployer) {
  deployer.deploy(DeftyWrap, makerCDPAddress);
};
