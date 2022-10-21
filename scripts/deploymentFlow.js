const { ethers } = require("hardhat");
const { providers } = require("ethers");
const { URIs } = require("../URIs.js");
//const { uploadImagesToPinata } = require("../pinatautility/uploadToPinata");
const API_KEY = process.env.API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
//const FACTORY_CONTRACT_ADDRESS = process.env.FACTORY_CONTRACT_ADDRESS;
//const WISH_CONTRACT_ADDRESS = process.env.WISH_CONTRACT_ADDRESS;

//const factoryABI = require("../artifacts/contracts/genshinCharacterFactory.sol/genshinCharacterFactory.json");
//const wishABI = require("../artifacts/contracts/Wish.sol/Wish.json");

const alchemyProvider = new ethers.providers.AlchemyProvider(
  (network = "maticmum"),
  API_KEY
);

const signer = new ethers.Wallet(PRIVATE_KEY, alchemyProvider);

//const { URIs } = require("../URIs.js");
//import URIs from "../URIs.js";
//const wishABI = require("bignumber.js");

async function main() {
  const factoryFactory = await ethers.getContractFactory("GenshinGachaFactory");

  const factoryContract = await factoryFactory.deploy("test", "TEST");
  console.log("Factory Contract deployed to address:", factoryContract.address);

  const wishContractFactory = await ethers.getContractFactory("Wish");

  const wishContract = await wishContractFactory.deploy(
    1774,
    factoryContract.address
  );
  console.log("Wish Contract deployed to address:", wishContract.address);

  await factoryContract.initialize(wishContract.address);
  console.log("initialization complete ");

  /*const genshinCharacterFactoryFactory = await ethers.getContractFactory(
    "genshinCharacterFactory"
  );
  const factoryContract = await genshinCharacterFactoryFactory.deploy(
    "test",
    "TEST"
  );
  console.log(
    "Factory Contract deployed to address:" + factoryContract.address
  );*/

  // const factoryContract = new ethers.Contract(
  //   FACTORY_CONTRACT_ADDRESS,
  //   factoryABI.abi,
  //   signer
  // );

  // console.log("factory contract at: " + factoryContract.address);
  // const wishContract = new ethers.Contract(
  //   WISH_CONTRACT_ADDRESS,
  //   wishABI.abi,
  //   signer
  // );
  //console.log("wish contract at:" + wishContract.address);

  console.log("about to add " + URIs.length + " strings to URI array");

  //console.log("adding one to array");
  //await factoryContract.addURI(URIs[0]);

  for (let i = 0; i < URIs.length; i++) {
    await factoryContract.addURI(URIs[i]);
  }

  const arraylength = await factoryContract.getURIsLength();

  for (let i = 0; i < arraylength; i++) {
    console.log(i + ": " + (await factoryContract.URIs(i)));
  }

  // await wishContract.setFeaturedFiveStars(1, 2);
  // await wishContract.setStandardFiveStars([3, 4, 5, 6]);
  // console.log(await wishContract.standardFiveStarsLength());

  ///////////upload to pinata////////////
  // uploadImagesToPinata();
  ///////////////////////////////////////

  ///////set URIS //////////////////////////////
  /// possible idea use something similar to hardconfig from patrick collins tutorial/////////////
  //await factoryContract.addURI(URIstorage[0].name);
  //await console.log("jsonURI length" + URIstorage.length);
  // URIStoragelength = URIs.length;
  // console.log(URIStoragelength);
  // for (let i = 0; i < URIs.length; i++) {
  //   //await factoryContract.addURI(URIs[i]);
  //   //const transactionResponse = await factoryContract.addURI(URIs[i]);
  //   //await transactionResponse.wait();
  //   //console.log("added URI number " + i);
  // }
  // console.log("added URIs");
  ///////////// print URIs /////////////////////next to work on //////////////////////

  //  const transactionResponse = await fundMe.withdraw()
  //await transactionResponse.wait()

  // const uriArrLength = await factoryContract.getURIsLength();
  // console.log("URI array length is " + uriArrLength);
  // console.log("Here are the metadata URIs");
  // for (let i = 0; i < URIs.length; i++) {
  //   console.log(i + ": " + (await factoryContract.URIs(i)));
  // }

  ///////////// deploy wish.sol ////////////

  // const wishContractFactory = await ethers.getContractFactory("Wish");
  // const wishContract = await wishContractFactory.deploy(
  //   factoryContract.address
  // );
  // console.log("Wish Contract deployed to address:", wishContract.address);

  //////////  specify featured five and four stars ////////////////

  //const convertedparams = ethers.BigNumber.from([42]);

  //console.log("done");
  //console.log(convertedparams);
  //   console.log([ethers.BigNumber.from("42"), ethers.BigNumber.from("43")]);
  // let myParams = [122, 44];
  // let convertedParams = myParams.map((item) => {
  //   return new wishABI.BigNumber(item);
  // });

  // console.log(convertedParams);
  // wishContract.setStandardFiveStars(convertedParams);

  //wishContract.setStandardFourStars([1, 2]);
  //   wishContract.setFeaturedFourStars([1, 2]);
  //   wishContract.setFeaturedFourStars([1, 2]);

  // const standardFiveStarsLength = await wishContract.standardFiveStarsLength();
  // console.log(standardFiveStarsLength);
  // console.log("Here are the indexes of the standard Five Stars:");
  // for (let i = 0; i < standardFiveStarsLength; i++) {
  //   console.log(await wishContract.standardFiveStars(i));
  // }

  /////////////////////// test wishing /////////////////////////////////
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
