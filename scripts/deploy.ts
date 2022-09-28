import { ethers } from "hardhat";
const helpers = require("@nomicfoundation/hardhat-network-helpers");


async function main() {

  const USDC_ADDRESS = "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48";
  const BIG_MAN = "0xb60c61dbb7456f024f9338c739b02be68e3f545c";

  // Deploying the token 
  const Token = await ethers.getContractFactory("DETH");
  const token = await Token.deploy();
  await token.deployed();

  // Deploying the swapper 
  const Swap = await ethers.getContractFactory("OracleSwap");
  const swap = await Swap.deploy(token.address, USDC_ADDRESS);
  await swap.deployed();

  // sending token to the swpap contract
  const Send = await token.transfer(swap.address, 10000000);
  const send = Send.wait();

  // impersonating
  await helpers.impersonateAccount(BIG_MAN);
  const impersonatedSigner = await ethers.getSigner(BIG_MAN);

  // swapping
  // const SWAP = await ethers.getContractAt(
  //   "OracleSwap",
  //   swap.address,
  //   impersonatedSigner
  // );

  // approving 
  const USDC_CONTRACT = await ethers.getContractAt(
    "DETH",
    USDC_ADDRESS,
    impersonatedSigner
  );


  const approve = await USDC_CONTRACT.approve(swap.address, ethers.utils.parseEther("2000"));
  approve.wait();


  const swapping = await swap.swap(ethers.utils.parseEther("2000"));
  await swapping.wait();


  // comfrim swap occured (by chaking balances)
  const check_bal = token.balanceOf(BIG_MAN);
  console.log(check_bal)
}




main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
