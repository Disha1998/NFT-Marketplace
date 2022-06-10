// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NFT is ERC721URIStorage {
    uint256 public tokenCount; //because we want to use "tokenCount" variable outside of the contract as well that's whay used "public" keyword

    constructor() ERC721("DApp NFT", "DAPP") {} //constructor is a special function which is run only one time after deploye the smart contract

    // Mint function for allow us to mint New nfts
    function mint(string memory _tokenURI) external returns (uint256) {
        tokenCount++; //tokanCount --initial value is zero so it will be implemented by 1( tokenCount++)
        _safeMint(msg.sender, tokenCount); // _safeMint is came from ERC721 token address --inbuild function ///// msg.sender is the global function so we can use it globally
        _setTokenURI(tokenCount, _tokenURI); //_setTokenURI is came from ERC721 token address -inbuild function
        return (tokenCount);
    }
}

// For deploye this smart contract following commands
// 1) npx hardhat node
// 2) npx hardhat run --network localhost  "<---)network)"  src/backend/scripts/deploy.js
