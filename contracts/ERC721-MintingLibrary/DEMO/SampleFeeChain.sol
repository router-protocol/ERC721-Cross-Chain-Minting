// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../FeeChain.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SampleFeeChain is OnFeeChain {
  address public owner;

  constructor(uint8 mintingChainID_, address genericHandler_)
    OnFeeChain(mintingChainID_, genericHandler_)
  {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "Only owner can call this function");
    _;
  }

  function setLinker(address _linker) external onlyOwner {
    setLink(_linker);
  }

  function setFeesToken(address _feeToken) external onlyOwner {
    setFeeToken(_feeToken);
  }

  function _approveFees(address _feeToken, uint256 amount) external onlyOwner {
    approveFees(_feeToken, amount);
  }

  function setCrossChainGasLimit(uint256 _gasLimit) external onlyOwner {
    _setCrossChainGasLimit(_gasLimit);
  }

  function setFeeTokenForNFT(address _feeToken) external onlyOwner {
    _setFeeTokenForNFT(_feeToken);
  }

  function setFeeInTokenForNFT(uint256 _price) external onlyOwner {
    _setFeeInTokenForNFT(_price);
  }

  function mintCrossChain(
    address _recipient,
    address _refundAddress,
    uint256 _crossChainGasPrice
  ) external returns (bytes32) {
    (bool sent, bytes32 hash) = _mintCrossChain(
      _recipient,
      _refundAddress,
      _crossChainGasPrice
    );
    require(sent == true, "Unsuccessful");
    return hash;
  }

  // The hash returned from mintCrossChain function should be used to replay a tx.
  // These gas limit and gas price should be higher than one entered in the original tx.
  function relpayTransaction(
    bytes32 hash,
    uint256 gasLimit,
    uint256 gasPrice
  ) external onlyOwner {
    replayTx(hash, gasLimit, gasPrice);
  }

  function recoverFeeTokens() external onlyOwner {
    address feeToken = this.fetchFeeToken();
    uint256 amount = IERC20(feeToken).balanceOf(address(this));
    IERC20(feeToken).transfer(owner, amount);
  }

  function withdrawFeeTokenForNFT() external override onlyOwner {
    address feeToken = this.fetchFeeTokenForNFT();
    uint256 amount = IERC20(feeToken).balanceOf(address(this));
    IERC20(feeToken).transfer(owner, amount);
  }
}
