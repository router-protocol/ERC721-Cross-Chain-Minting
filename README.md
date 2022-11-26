# Cross-Chain ERC721 NFT Minting Library

The library consists of two contracts, the OnFeeChain and the OnMintingChain contract. This suggests that there are going to be two types of chains. One is the minting chain where the minting of any NFT happens for the first time. Then these can be transferred cross-chain where it will be locked inside the minting chain contract and will be minted on the destination chain but the initial minting takes place only on the minting chain and there can be only one minting chain.

If you have multiple minting chains, then the uniqueness property of NFTs will be affected, creating multiple instances of the same NFT token id on multiple chains. Thus it is necessary to have only one minting chain.

However, you can have multiple fee chains. Fee chains suggest that fee for minting NFTs can be paid on the fee chains and it can actually be minted on the minting chain. Also you can transfer your tokens from any chain to any chain be it fee chain or minting chain.

## How token transfers work across chains?

1. Fee chain to Fee chain - burnt on the source chain and minted on destination chain
2. Fee chain to Minting chain - burnt on the source chain and unlocked on the destination chain
3. Minting chain to Fee chain - locked on the source chain and minted on the destination chain

## To try out the project by deploying it on multiple chains:

1. Create the deployments.json file inside the deployments folder
2. Create your .env file
3. Run the following commands:

```bash
$ npx hardhat DEPLOY_FEECHAIN --network [network_name] --mintingchainid [chainId of minting chain(router spec)]
$ npx hardhat DEPLOY_MINTINGCHAIN --network [network_name]
```

4. Map these contracts using the MAP_CONTRACTS task
5. Send some fee tokens the contract.
6. Approve the fee chain contract to deduct fee tokens for NFT from your account to pay minting fees.

Now test out the cross chain mint and cross chain transfer functionality.

For official documentation, visit: https://dev.routerprotocol.com/crosstalk-library/using-crosstalk-to-mint-nfts-across-chains
