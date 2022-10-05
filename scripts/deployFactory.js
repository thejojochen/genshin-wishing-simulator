async function main() {
  const factoryFactory = await ethers.getContractFactory(
    "genshinCharacterFactory"
  );

  // Start deployment, returning a promise that resolves to a contract object
  const factoryContract = await factoryFactory.deploy("test", "TEST");
  console.log("Factory Contract deployed to address:", factoryContract.address);

  const wishContractFactory = await ethers.getContractFactory("Wish");

  // Start deployment, returning a promise that resolves to a contract object
  const wishContract = await wishContractFactory.deploy(
    1774,
    factoryContract.address
  );
  console.log("Wish Contract deployed to address:", wishContract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
