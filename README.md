#DeftyHQ

### Installation

This project requires yarn and truffle.

1. Clone the project
2. Run `yarn` to install dependencies
3. Create a file named `.env.<NODE_ENV>`
4. Run `yarn build`

To run on a local network you also need to deploy makerDAO/testchain.
You can then create and configure CDP's with Dai-cli

### Getting Started
Each environment uses a different `.env.<NODE_ENV>` file to configure the
connection to the chain.

#### Development
- `yarn build` will compile and deploy the contracts on local testchain.
- `yarn console` will launch a truffle console on the testchain.
- `yarn test` will launch truffle tests

#### Staging
- `yarn build:kovan` will compile and deploy the contracts on Kovan.
- `yarn console:kovan` will launch a truffle console on Kovan.


#### TODO

- [ ] Check Zeppelin ERC721 are all imports necessary?
- [ ] Do I need truffle Migration in staging?
- [ ] Downsides of a Proxy contract for upgrades?
- [ ] How to test a function which includes a inter-contract call?
      What are the options to intercept and mock response?
- [ ]
