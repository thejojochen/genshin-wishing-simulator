async function main() {
  const factoryFactory = await ethers.getContractFactory(
    "genshinCharacterFactory"
  );

  // Start deployment, returning a promise that resolves to a contract object
  const factoryContract = await factoryFactory.deploy("test", "TEST");
  console.log("Contract deployed to address:", factoryContract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
