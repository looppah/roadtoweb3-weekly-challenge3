//Scripts to test contract functions in localhost
// scripts/test_contract.js

const hre = require("hardhat");
const abi = require("../artifacts/contracts/ChainBattles.sol/ChainBattles.json");
require("dotenv").config();

async function main() {

  const ChainBattles = await hre.ethers.getContractFactory("ChainBattles");
  const chainBattles = await ChainBattles.deploy();
  const mockTokenId = 1;
  await chainBattles.deployed();
  console.log("ChainBattles deployed to:", chainBattles.address);

  const mockUser = await hre.ethers.getSigner();

  console.log ("Minting NFT... ");
  await chainBattles.connect(mockUser).mint();
  console.log("NFT minted...")
 
  console.log("Training... ");
  await chainBattles.train(1);
  await chainBattles.train(1);
  console.log("After two trainings, level is set to: ", await chainBattles.getWeaponLevel(mockTokenId));
  
  console.log ("Weapon weight: ", await chainBattles.getWeaponWeight(mockTokenId));
  console.log("Weapon strength: ", await chainBattles.getWeaponStrength(mockTokenId));
}


// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });