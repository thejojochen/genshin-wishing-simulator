async function main() {
  const vrfFactory = await ethers.getContractFactory("VRFv2Consumer");

  // Start deployment, returning a promise that resolves to a contract object
  const vrfGenerator = await vrfFactory.deploy(1074);
  console.log("Contract deployed to address:", vrfGenerator.address);

  console.log(await vrfGenerator.getSubscriptionID());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
