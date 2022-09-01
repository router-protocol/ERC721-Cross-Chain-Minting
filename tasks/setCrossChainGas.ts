/* eslint-disable prettier/prettier */
import { TASK_SET_CROSSCHAIN_GAS } from "./task-names";
import { task, types } from "hardhat/config";

task(TASK_SET_CROSSCHAIN_GAS, "Sets the cross chain gas limit")
  .addParam(
    "contractAdd",
    "address of the cross-chain contract",
    "",
    types.string
  )
  .addParam("gasLimit", "address of the fee token", "", types.string)
  .setAction(async (taskArgs, hre): Promise<null> => {
    const contract = await hre.ethers.getContractFactory("SampleFeeChain");
    const C11 = await contract.attach(taskArgs.contractAdd);
    await C11.setCrossChainGasLimit(taskArgs.gasLimit, {
      gasLimit: 2000000,
    });
    console.log(`Cross chain gas limit set`);
    return null;
  });
