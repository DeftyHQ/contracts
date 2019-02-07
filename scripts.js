/*
  Helper scripts to interact with contract in console.
*/

const settings = {
  chain: {
    kovan: {
      cup: 4836
    }
  }
}

// Setup
const dwp = await DeftyWrap.deployed()
const numberToBytes32 = int => web3.utils.padLeft(web3.utils.toHex(int), 64)

// Prove that sender owns cup
// fail on kovan
dwp.proveOwnership(numberToBytes32(1))

// suceed
dwp.proveOwnership(numberToBytes32(4832))
dwp.wrap(numberToBytes32(4832))
dwp.getTokenId(numberToBytes32(4832))
dwp.getCupId(1)
// 1. a way to know the cdps owned by an address
// 2. a way to show the state of a cdp (proof list)
// 3. a way to display the associated NFT
dwp.unwrap(1)
