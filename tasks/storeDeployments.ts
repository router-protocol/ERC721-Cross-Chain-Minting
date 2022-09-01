/* eslint-disable prettier/prettier */
import { task, types } from "hardhat/config";
import { TASK_STORE_DEPLOYMENTS } from "./task-names";
import fs from "fs";

task(TASK_STORE_DEPLOYMENTS, "store deployments")
  .addParam<string>("contractName", "Contract Name", "", types.string)
  .addParam<string>("contractAddress", "Contract Address", "", types.string)
  .setAction(async (taskArgs, { ethers }): Promise<null> => {
    const networkID = await ethers.provider.network.chainId;

    const deployedContracts = require("../deployments/deployments.json");

    if (typeof deployedContracts[networkID] === "undefined") {
      deployedContracts[networkID] = {};
    }

    deployedContracts[networkID][taskArgs.contractName] =
      taskArgs.contractAddress;

    fs.writeSync(
      fs.openSync("./deployments/deployments.json", "w"),
      JSON.stringify(deployedContracts, null, 2)
    );
    return null;
  });
