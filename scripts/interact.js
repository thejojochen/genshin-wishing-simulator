const API_KEY = process.env.API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const CONTRACT_ADDRESS = process.env.CONTRACT_ADDRESS;

const { providers } = require("ethers");
const { ethers } = require("hardhat");
const contract = require("../artifacts/contracts/VRFv2Consumer.sol/VRFv2Consumer.json");

//console.log(JSON.stringify(contract.abi));

// Provider
const alchemyProvider = new ethers.providers.AlchemyProvider(
  (network = "goerli"),
  API_KEY
);

// Signer
const signer = new ethers.Wallet(PRIVATE_KEY, alchemyProvider);

// Contract
const vrfContract = new ethers.Contract(CONTRACT_ADDRESS, contract.abi, signer);
const maxRange = 100000;

const myWallet = new ethers.Wallet(PRIVATE_KEY, alchemyProvider);
console.log(myWallet.address);
//constContractConnected = vrfContract.connect(provider.getSigner[x]);

async function main() {
  console.log("starting process");

  const transactionResponse = await vrfContract.requestRandomWords();
  console.log(transactionResponse);
  const receipt = await transactionResponse.wait(8);
  console.log(receipt);

  console.log("successfully requested random words");
  const result = await vrfContract.s_randomWords(0);

  console.log("The result is: " + result);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

//other comments
//let result = await vrfContract.getCustomRandomWord(maxRange);
//   let result = await vrfContract.s_randomWords(1);

//   bigResult = ethers.BigNumber.from(result);
//   console.log((result % maxRange) + 1);
//console.log(bigResult);
//console.log(bigResult.toString());

//   console.log("requesting random words");
//   const msgsender = await vrfContract.getMsgSender();
//   console.log(msgsender);

//await vrfContract.requestRandomWords().wait();
//const unsignedtx = await vrfContract.populateTransaction.requestRandomWords();
//console.log(unsignedtx);
//const receipt = await myWallet.sendTransaction(unsignedtx).wait(3);
//

/*const receipt = await myWallet.alchemyProvider.waitForTransaction(
    unsignedtx.hash,
    3
  );*/
//console.log(receipt);

//bigResult = ethers.BigNumber.from(result);
//console.log((result % maxRange) + 1);
//let result = await alchemyProvider.getStorageAt(CONTRACT_ADDRESS, 15);
