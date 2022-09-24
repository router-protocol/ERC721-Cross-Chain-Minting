// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @dev This has to be inherited by the developer in his contract on every chain where the fee for NFT is desired to be taken.

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@routerprotocol/router-crosstalk/contracts/RouterCrossTalk.sol";

abstract contract OnFeeChain is RouterCrossTalk {
  using SafeERC20 for IERC20;
  uint8 public immutable mintingChainID;
  address private feeTokenForNFT;
  uint256 private feeInTokenForNFT;

  uint256 private _crossChainGasLimit;

  constructor(uint8 mintingChainID_, address genericHandler_)
    RouterCrossTalk(genericHandler_)
  {
    mintingChainID = mintingChainID_;
  }

  /**
   * @notice _setFeeTokenForNFT Used to set feeToken, this can only be set by Admin
   * @param _feeToken Address of the token to be set as fee
   */
  function _setFeeTokenForNFT(address _feeToken) internal {
    feeTokenForNFT = _feeToken;
  }

  /**
   * @notice fetchFeeTokenForNFT Used to fetch feeToken
   * @return feeToken address that is set
   */
  function fetchFeeTokenForNFT() external view returns (address) {
    return feeTokenForNFT;
  }

  /**
   * @notice _setFeeInTokenForNFT Used to set fees in Token, this can only be set by Admin
   * @param _price Amount of feeToken to be taken as price
   */
  function _setFeeInTokenForNFT(uint256 _price) internal {
    feeInTokenForNFT = _price;
  }

  /**
   * @notice fetchFeeInTokenForNFT Used to fetch fee in Token for NFT
   * @return Returns fee in Token
   */
  function fetchFeeInTokenForNFT() external view returns (uint256) {
    return feeInTokenForNFT;
  }

  /**
   * @notice setCrossChainGasLimit Used to set CrossChainGasLimit, this can only be set by CrossChain Admin or Admins
   * @param _gasLimit Amount of gasLimit that is to be set
   */
  function _setCrossChainGasLimit(uint256 _gasLimit) internal {
    _crossChainGasLimit = _gasLimit;
  }

  /**
   * @notice fetchCrossChainGasLimit Used to fetch CrossChainGasLimit
   * @return crossChainGasLimit that is set
   */
  function fetchCrossChainGasLimit() external view returns (uint256) {
    return _crossChainGasLimit;
  }

  function _mintCrossChain(
    address _recipient,
    address _refundAddress,
    uint256 _crossChainGasPrice
  ) internal returns (bool, bytes32) {
    require(_recipient != address(0), "FeeChain: Recipient cannot be 0");
    require(
      _refundAddress != address(0),
      "FeeChain: RefundAddress cannot be 0"
    );

    IERC20(feeTokenForNFT).safeTransferFrom(
      msg.sender,
      address(this),
      feeInTokenForNFT
    );

    bytes4 _selector = bytes4(keccak256("receiveCrossChain(address,address)"));
    bytes memory _data = abi.encode(_recipient, _refundAddress);
    (bool success, bytes32 hash) = routerSend(
      mintingChainID,
      _selector,
      _data,
      _crossChainGasLimit,
      _crossChainGasPrice
    );
    return (success, hash);
  }

  // The hash returned from RouterSend function should be used to replay a tx
  // These gas limit and gas price should be higher than one entered in the original tx.
  function replayTx(
    bytes32 hash,
    uint256 gasLimit,
    uint256 gasPrice
  ) internal {
    routerReplay(hash, gasLimit, gasPrice);
  }

  /**
   * @notice _routerSyncHandler This is an internal function to control the handling of various selectors and its corresponding
   * @param _selector Selector to interface.
   * @param _data Data to be handled.
   */
  function _routerSyncHandler(bytes4 _selector, bytes memory _data)
    internal
    virtual
    override
    returns (bool, bytes memory)
  {}

  function withdrawFeeTokenForNFT() external virtual;
}
