const ethers = require('ethers');

/*
  Simple helper to create wallet used by Doppelganger to deploy.
*/
function createWallet(privateKey, providerURL) {

  // To generate key from mnemonic
  // usage: node.privateKey
  // const walletPath = { "standard": "m/44'/60'/0'/0/0" };
  // const mnemonic = "<your_mnemonic>";
  // const hdnode = ethers.utils.HDNode.fromMnemonic(mnemonic);
  // const node = hdnode.derivePath(walletPath.standard);
  // const privateKey = node.privateKey
  
  const provider = new ethers.providers.JsonRpcProvider(providerURL);
  const wallet = new ethers.Wallet(privateKey, provider);
  return wallet;
}

function intToBytes32(int, web3) {
  return web3.utils.padLeft(web3.utils.toHex(int), 64)
}


module.exports = {
  createWallet,
  intToBytes32
}
