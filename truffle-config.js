const env = require('yenv')(null, { raw: true });
const HDWalletProvider = require('truffle-hdwallet-provider');

// Fetch env variables according to process.env.NODE_ENV configuraiton
const config = {
  networkURL: env.ETH_RPC_URL,
  privateKey: env.ETH_PRIVATE_KEY
}

module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!

  // contracts_build_directory: path.join(__dirname, "client/src/contracts"),
  // compilers: {
  //   solc: {
  //     version: "0.4.22"  // ex:  "0.4.20". (Default: Truffle's installed solc)
  //   }
  // },

  networks: {
    development: {
      host: "127.0.0.1",
      port: 2000,
      network_id: "*" // Match any network id
    },
    kovan: {
      provider: () => new HDWalletProvider(config.privateKey, config.networkURL),
      host: config.networkURL,
      port: 8545,
      network_id: 42,
      gas: 4700000
    },
  }

};
