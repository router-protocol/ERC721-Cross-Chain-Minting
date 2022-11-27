// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@routerprotocol/router-crosstalk/contracts/RouterCrossTalk.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

/// @title Cross-Chain NFT Fee Chain contract.
/// @author Router Protocol.
/// @notice This contract is used for paying fees for minting cross-chain NFTs.
/// @dev This has to be inherited by the developer in his contract on every chain
/// where the fee for NFT is desired to be taken.
abstract contract OnFeeChain is ERC721, IERC721Receiver, RouterCrossTalk {
  using SafeERC20 for IERC20;
  /// chainId of the minting chain (where OnMintingChain is deployed)
  uint8 public immutable mintingChainID;

  /// fee token to be used for paying for the NFT
  address private feeTokenForNFT;

  /// fee amount in fee token for NFT to be paid per NFT
  uint256 private feeInTokenForNFT;

  /// gas limit to be used for execution of the cross-chain request on the other chain
  uint256 private crossChainGasLimit;

  constructor(
    string memory name_,
    string memory symbol_,
    uint8 mintingChainID_,
    address genericHandler_
  ) ERC721(name_, symbol_) RouterCrossTalk(genericHandler_) {
    mintingChainID = mintingChainID_;
  }

  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(IERC165, ERC721)
    returns (bool)
  {
    return
      interfaceId == type(IERC721).interfaceId ||
      interfaceId == type(IERC721Metadata).interfaceId ||
      super.supportsInterface(interfaceId);
  }

  /// @notice function to to set feeToken for minting NFT
  /// @param _feeToken Address of the token to be set as fee
  function _setFeeTokenForNFT(address _feeToken) internal {
    feeTokenForNFT = _feeToken;
  }

  /// @notice function to fetch the fee token
  /// @return feeToken address
  function fetchFeeTokenForNFT() external view returns (address) {
    return feeTokenForNFT;
  }

  /// @notice function to set fees to be paid for NFT
  /// @param _price Amount of feeToken to be taken as price per NFT
  function _setFeeInTokenForNFT(uint256 _price) internal {
    feeInTokenForNFT = _price;
  }

  /// @notice function to fetch fee amount for NFT
  /// @return Returns fee in Token
  function fetchFeeInTokenForNFT() external view returns (uint256) {
    return feeInTokenForNFT;
  }

  /// @notice function to set CrossChainGasLimit
  /// @param _gasLimit Amount of gasLimit that is to be set
  function _setCrossChainGasLimit(uint256 _gasLimit) internal {
    crossChainGasLimit = _gasLimit;
  }

  /// @notice function to fetch CrossChainGasLimit
  /// @return crossChainGasLimit
  function fetchCrossChainGasLimit() external view returns (uint256) {
    return crossChainGasLimit;
  }

  /// @notice function to create a cross-chain request to mint a cross-chain NFT
  /// @dev A fee will be charged (feeInTokenForNFT) for minting the NFT
  /// @param recipient address of the recipient of NFT on minting chain
  /// @param refundAddress address of the wallet to which refund is to be processed
  /// in case NFT is not available on destination chain
  /// @param crossChainGasPrice gas price that you are willing to pay to execute the
  /// transaction on the minting chain
  /// @dev If the _crossChainGasPrice is less than required, the transaction can get stuck
  /// on the bridge and you may need to replay the transaction.
  function _mintCrossChain(
    address recipient,
    address refundAddress,
    uint256 crossChainGasPrice
  ) internal returns (bool, bytes32) {
    require(recipient != address(0), "recipient != address(0)");
    require(refundAddress != address(0), "RefundAddress != address(0)");

    IERC20(feeTokenForNFT).safeTransferFrom(
      msg.sender,
      address(this),
      feeInTokenForNFT
    );

    // selector to the function to be called on the destination chain
    bytes4 _selector = bytes4(
      keccak256("receiveMintCrossChain(address,address)")
    );
    bytes memory _data = abi.encode(recipient, refundAddress);
    (bool success, bytes32 hash) = routerSend(
      mintingChainID,
      _selector,
      _data,
      crossChainGasLimit,
      crossChainGasPrice
    );
    return (success, hash);
  }

  /// @notice function to create a cross-chain request to transfer NFT cross-chain
  /// @dev The contract burns the NFT into the contract and creates a cross-chain request
  /// to mint (on fee chains) /unlock (on minting chain) the NFT on the destination chain
  /// @param destChainId chainId of the destination chain(router specs - https://dev.routerprotocol.com/important-parameters/supported-chains)
  /// @param recipient address of the recipient on the destination chain
  /// @param tokenId of the token user is willing to transfer cross-chain
  /// @param crossChainGasPrice gas price that you are willing to pay to execute the
  /// transaction on the minting chain
  /// @dev If the crossChainGasPrice is less than required, the transaction can get stuck
  /// on the bridge and you may need to replay the transaction.
  function _transferCrossChain(
    uint8 destChainId,
    address recipient,
    uint256 tokenId,
    uint256 crossChainGasPrice
  ) internal returns (bool, bytes32) {
    require(_exists(tokenId) && ownerOf(tokenId) == msg.sender, "not your NFT");
    require(recipient != address(0), "recipient != address(0)");

    _burn(tokenId);

    bytes4 selector = bytes4(keccak256("receiveCrossChain(address,uint256)"));
    bytes memory data = abi.encode(recipient, tokenId);
    (bool success, bytes32 hash) = routerSend(
      destChainId,
      selector,
      data,
      crossChainGasLimit,
      crossChainGasPrice
    );

    return (success, hash);
  }

  /// @notice function to replay a transaction stuck on the bridge due to insufficient
  /// cross-chain gas limit or gas price passed in _mintCrossChain function
  /// @dev gasLimit and gasPrice passed in this function should be greater than what was passed earlier
  /// @param hash hash returned from RouterSend function should be used to replay a tx
  /// @param gasLimit gas limit to be passed for executing the tx on destination chain
  /// @param gasPrice gas price to be passed for executing the tx on destination chain
  function replayTx(
    bytes32 hash,
    uint256 gasLimit,
    uint256 gasPrice
  ) internal {
    routerReplay(hash, gasLimit, gasPrice);
  }

  /// @notice _routerSyncHandler This is an internal function to control the handling of various selectors and its corresponding
  /// @param _selector Selector to interface.
  /// @param _data Data to be handled.
  function _routerSyncHandler(bytes4 _selector, bytes memory _data)
    internal
    override
    returns (bool, bytes memory)
  {
    if (_selector == bytes4(keccak256("receiveCrossChain(address,uint256)"))) {
      (address recipient, uint256 tokenId) = abi.decode(
        _data,
        (address, uint256)
      );

      (bool success, bytes memory returnData) = address(this).call(
        abi.encodeWithSelector(_selector, recipient, tokenId)
      );
      return (success, returnData);
    }

    return (false, "");
  }

  /// @notice function to handle cross-chain transfer of NFT for which request was made on another chain
  /// @dev isSelf modifier is placed as a security feature so that requests only from
  /// the bridge is able to trigger this function
  /// @param recipient address of recipient of NFT received from the fee chain
  /// @param tokenId tokenId of NFT to be unlocked to the recipient
  function receiveCrossChain(address recipient, uint256 tokenId)
    external
    isSelf
  {
    require(recipient != address(0), "recipient != address(0)");
    _safeMint(recipient, tokenId);
  }

  function onERC721Received(
    address operator,
    address from,
    uint256 tokenId,
    bytes calldata data
  ) external override returns (bytes4) {
    return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
  }

  /// @notice function to withdraw fee tokens received as payment for NFT
  /// @dev This needs to be implemented by the developers to get the fees paid by minters
  function withdrawFeeTokenForNFT() external virtual;
}
