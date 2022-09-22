async function main() {
  const wishContractFactory = await ethers.getContractFactory("Wish");

  // Start deployment, returning a promise that resolves to a contract object
  const wishContract = await wishContractFactory.deploy(
    "0x6FdcD2dF2C59873DebB80d9eABC10f07EB94d7cF"
  );
  console.log("Contract deployed to address:", wishContract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
