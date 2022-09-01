// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../MintingChain.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SampleMintingChain is OnMintingChain {
  address public owner;

  constructor(
    string memory name_,
    string memory symbol_,
    uint256 MaxTokenId_,
    address genericHandler_
  ) OnMintingChain(name_, symbol_, MaxTokenId_, genericHandler_) {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "Only owner can call this function");
    _;
  }

  function setLinker(address _linker) external onlyOwner {
    setLink(_linker);
  }

  function setFeeTokenForNFT(address _feeToken) external onlyOwner {
    _setFeeTokenForNFT(_feeToken);
  }

  function setFeeInTokenForNFT(uint256 _price) external onlyOwner {
    _setFeeInTokenForNFT(_price);
  }

  // If fees is to be paid on minting chain
  function mintSameChain(address recipient) external {
    mint(recipient);
  }

  function withdrawFeeTokenForNFT() external override onlyOwner {
    address feeToken = this.fetchFeeTokenForNFT();
    uint256 amount = IERC20(feeToken).balanceOf(address(this));
    IERC20(feeToken).transfer(owner, amount);
  }
}
