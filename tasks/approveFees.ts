/* eslint-disable prettier/prettier */
import { TASK_APPROVE_FEES } from "./task-names";
import { task, types } from "hardhat/config";

task(TASK_APPROVE_FEES, "Approves the fees")
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
    await C11._approveFees(taskArgs.feeToken, "1000000000000000000000000", {
      gasLimit: 2000000,
    });
    console.log(`Fee approved`);
    return null;
  });
