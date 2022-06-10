// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "hardhat/console.sol";

// ReentrancyGuard contract is use for protect our marketplace from Reentrancy Attacks
contract Marketplace is ReentrancyGuard {
    // Variables
    // Our marketplace will charge fee for each nft purchased
    address payable public immutable feeAccount; // the account that receives fees
    // immutable ---> they can assigned a value by only once
    uint256 public immutable feePercent; // the fee percentage on sales
    uint256 public itemCount;

    // struct is help us to write complex datatype with multiple fields
    struct Item {
        uint256 itemId;
        IERC721 nft;
        uint256 tokenId;
        uint256 price;
        address payable seller;
        bool sold;
    }

    // itemId(key) -> Item(value)
    mapping(uint256 => Item) public items;

    event Offered(
        uint256 itemId,
        address indexed nft,
        uint256 tokenId,
        uint256 price,
        address indexed seller
    );
    event Bought(
        uint256 itemId,
        address indexed nft,
        uint256 tokenId,
        uint256 price,
        address indexed seller,
        address indexed buyer
    );

    constructor(uint256 _feePercent) {
        ////constructor is a special function which is run only one time after deploye the smart contract
        feeAccount = payable(msg.sender);
        feePercent = _feePercent;
    }

    // Make item to offer on the marketplace-------------------------------------------
    function makeItem(
        IERC721 _nft,
        uint256 _tokenId,
        uint256 _price
    ) external nonReentrant {
        //nonReentrant--> Prevent bad guys from calling makeItem function
        require(_price > 0, "Price must be greater than zero");
        // increment itemCount
        itemCount++;
        // transfer nft (if user want to list the Item)
        _nft.transferFrom(msg.sender, address(this), _tokenId);

        // add new item to items mapping
        items[itemCount] = Item(
            itemCount,
            _nft,
            _tokenId,
            _price,
            payable(msg.sender),
            false //false for Sold Item
        );
        // emit Offered event
        emit Offered(itemCount, address(_nft), _tokenId, _price, msg.sender);
    }

    // Purchase Item --------------------------------------------------------------
    function purchaseItem(uint256 _itemId) external payable nonReentrant {
        uint256 _totalPrice = getTotalPrice(_itemId);
        Item storage item = items[_itemId];
        require(_itemId > 0 && _itemId <= itemCount, "item doesn't exist");
        require(
            msg.value >= _totalPrice,
            "not enough ether to cover item price and market fee"
        );
        require(!item.sold, "item already sold");
        // pay seller and feeAccount
        item.seller.transfer(item.price);
        feeAccount.transfer(_totalPrice - item.price);
        // update item to sold
        item.sold = true;
        // transfer nft to buyer
        item.nft.transferFrom(address(this), msg.sender, item.tokenId);
        // emit Bought event
        emit Bought(
            _itemId,
            address(item.nft),
            item.tokenId,
            item.price,
            item.seller,
            msg.sender
        );
    }

    function getTotalPrice(uint256 _itemId) public view returns (uint256) {
        return ((items[_itemId].price * (100 + feePercent)) / 100); //the item price set by the seller + market fees --->so this function returns the total price
    }
}

// Few helpful links

// ReentrancyGuard--> https://docs.openzeppelin.com/contracts/4.x/api/security#ReentrancyGuard

// Event & Emit --->  want makeItem function to emit an event. Event allows us to log data to the ethereum blockchain.
