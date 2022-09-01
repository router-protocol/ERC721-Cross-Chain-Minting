/* eslint-disable prettier/prettier */
import { TASK_SET_NFT_FEES } from "./task-names";
import { task, types } from "hardhat/config";

task(TASK_SET_NFT_FEES, "Sets the nft fee")
  .addParam(
    "contractAdd",
    "address of the cross-chain contract",
    "",
    types.string
  )
  .addParam("feeForNFT", "fee for NFT", "", types.string)
  .setAction(async (taskArgs, hre): Promise<null> => {
    const contract = await hre.ethers.getContractFactory("SampleFeeChain");
    const C11 = await contract.attach(taskArgs.contractAdd);
    await C11.setFeeInTokenForNFT(taskArgs.feeForNFT, { gasLimit: 2000000 });
    console.log(`NFT Fee set`);
    return null;
  });
