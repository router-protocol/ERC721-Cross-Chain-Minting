/* eslint-disable prettier/prettier */
import { TASK_SET_FEES_TOKEN } from "./task-names";
import { task, types } from "hardhat/config";

task(TASK_SET_FEES_TOKEN, "Sets the fee token address")
  .addParam(
    "contractAdd",
    "address of the cross-chain contract",
    "",
    types.string
  )
  .addParam("feeToken", "address of the fee token", "", types.string)
  .setAction(async (taskArgs, hre): Promise<null> => {
    const contract = await hre.ethers.getContractFactory("SampleFeeChain");
    const C11 = await contract.attach(taskArgs.contractAdd);
    await C11.setFeesToken(taskArgs.feeToken, { gasLimit: 2000000 });
    console.log(`Fee token address set`);
    return null;
  });
