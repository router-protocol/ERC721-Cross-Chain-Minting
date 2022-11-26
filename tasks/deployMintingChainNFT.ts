/* eslint-disable prettier/prettier */
import { task, types } from "hardhat/config";
import {
  TASK_APPROVE_FEES,
  TASK_DEPLOY_MINTINGCHAIN_NFT,
  TASK_SET_CROSSCHAIN_GAS,
  TASK_SET_FEES_TOKEN,
  TASK_SET_LINKER,
  TASK_SET_NFT_FEES,
  TASK_SET_NFT_FEES_TOKEN,
  TASK_STORE_DEPLOYMENTS,
} from "./task-names";

task(
  TASK_DEPLOY_MINTINGCHAIN_NFT,
  "Deploys the minting chain nft project"
).setAction(async (taskArgs, hre): Promise<null> => {
  const deployment = require("../deployments/deployments.json");
  const network = await hre.ethers.provider.getNetwork();
  const chainId = network.chainId;
  const contractName = "SampleMintingChain";

  const handler = deployment[chainId].handler;
  const linker = deployment[chainId].linker;
  const feeToken = deployment[chainId].feeToken;
  const feeTokenForNFT = deployment[chainId].feeTokenForNFT;
  const feeForNFT = deployment[chainId].feeForNFT;
  const crossChainGas = deployment[chainId].crossChainGas;

  const contract = await hre.ethers.getContractFactory("SampleMintingChain");
  const C11 = await contract.deploy("Router", "ROUTE", "3", handler);
  await C11.deployed();
  console.log(`C11 deployed to: `, C11.address);

  await hre.run(TASK_STORE_DEPLOYMENTS, {
    contractName: "ContractAdd",
    contractAddress: C11.address,
  });

  await hre.run(TASK_SET_LINKER, {
    contractAdd: C11.address,
    linkerAdd: linker,
  });

  await hre.run(TASK_SET_FEES_TOKEN, {
    contractAdd: C11.address,
    feeToken: feeToken,
  });

  await hre.run(TASK_APPROVE_FEES, {
    contractAdd: C11.address,
    feeToken: feeToken,
  });

  await hre.run(TASK_SET_CROSSCHAIN_GAS, {
    contractAdd: C11.address,
    gasLimit: crossChainGas,
  });

  await hre.run(TASK_SET_NFT_FEES_TOKEN, {
    contractAdd: C11.address,
    feeToken: feeTokenForNFT,
  });

  await hre.run(TASK_SET_NFT_FEES, {
    contractAdd: C11.address,
    feeForNFT: feeForNFT,
  });

  return null;
});
