/* eslint-disable prettier/prettier */
import { Contract } from "ethers";
import { task, types } from "hardhat/config";
import { TASK_MAP_CONTRACT } from "./task-names";

// chainid = Destination Chain IDs defined by Router. Eg: Polygon, Fantom and BSC are assigned chain IDs 1, 2, 3.
// nchainid = Actual Destination Chain IDs
task(TASK_MAP_CONTRACT, "Map Contracts")
  .addParam<string>(
    "routerChainid",
    "Remote ChainID (Router Specs)",
    "",
    types.string
  )
  .addParam<string>("actualChainid", "Remote ChainID", "", types.string)

  .setAction(async (taskArgs, hre): Promise<null> => {
    const deployments = require("../deployments/deployments.json");
    const handlerABI = require("../build/contracts/genericHandler.json");
    const network = await hre.ethers.provider.getNetwork();
    const lchainID = network.chainId.toString();

    const handlerContract: Contract = await hre.ethers.getContractAt(
      handlerABI,
      deployments[lchainID].handler
    );

    await handlerContract.MapContract([
      deployments[lchainID].ContractAdd,
      taskArgs.routerChainid,
      deployments[taskArgs.actualChainid].ContractAdd,
    ]);
    console.log("Contract Mapping Done");
    return null;
  });
