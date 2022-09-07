async function main() {
  const wishContractFactory = await ethers.getContractFactory("Wish");

  // Start deployment, returning a promise that resolves to a contract object
  const wishContract = await wishContractFactory.deploy(
    "0x03301a7bf777a8f5c46329ae315f63cfe09f4ec0"
  );
  console.log("Contract deployed to address:", wishContract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
