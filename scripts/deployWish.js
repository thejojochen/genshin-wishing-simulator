async function main() {
  const wishContractFactory = await ethers.getContractFactory("Wish");

  // Start deployment, returning a promise that resolves to a contract object
  const wishContract = await wishContractFactory.deploy(
    "0x650A8AD676dD847c9966B48064627fc9D70a5D76"
  );
  console.log("Contract deployed to address:", wishContract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
