/*
  Helper scripts to interact with contract in console.
*/


// Setup
const dwp = await DeftyWrap.deployed()
const numberToBytes32 = int => web3.utils.padLeft(web3.utils.toHex(int), 64)

// Prove that sender owns cup
dwp.proveOwnership(numberToBytes32(1))
dwp.cupId()
dwp.cupLad()
