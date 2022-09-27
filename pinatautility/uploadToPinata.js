const pinataApiKey = process.env.PINATA_API_KEY;
const pinataSecret = process.env.PINATA_API_SECRET;

const fs = require("fs");
const path = require("path");

const { Jsons } = require("../URIs.js");

const pinataSDK = require("@pinata/sdk");
const pinata = pinataSDK(pinataApiKey, pinataSecret);

pinata
  .testAuthentication()
  .then((result) => {
    //handle successful authentication here
    console.log(result);
  })
  .catch((err) => {
    //handle error here
    console.log(err);
  });

const imagesFilePath = "./images/";
async function storeImages() {
  const fullImagesPath = path.resolve(imagesFilePath);
  const files = fs.readdirSync(fullImagesPath);
  let responses = [];
  for (fileIndex in files) {
    const readableStreamForFile = fs.createReadStream(
      `${fullImagesPath}/${files[fileIndex]}`
    );

    pinata
      .pinFileToIPFS(readableStreamForFile)
      .then((result) => {
        //handle results here
        console.log(result.IpfsHash);
      })
      .catch((err) => {
        //handle error here
        console.log(err);
      });
  }
}

// const options = {
//   pinataMetadata: {
//     name: "mycustomname",
//   },
// };
let count = 0;

for (let i = 0; i < Jsons.length; i++) {
  pinata
    .pinJSONToIPFS(Jsons[i])
    .then((result) => {
      //handle results here
      console.log(result);
      count++;
    })
    .catch((err) => {
      //handle error here
      console.log(err);
    });
}

// console.log("number uploaded:" + count);
