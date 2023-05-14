// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

//INTERNAL IMPORT FOR NFT  OPENZIPLINE
import "@openzeppelin/contracts/utils/Counters.sol";/*Bo dem cho phep ta co the biet dc co bn mat hang ,
bao nhieu mat hang da ban ....*/
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "hardhat/console.sol";

contract NFTMarketplace is ERC721URIStorage {
    //su dung Counters
    using Counters for Counters.Counter;

    //dem xem co bao nhieu token id dc tao ra
    Counters.Counter private _tokenIds;
    //dem xem bao nhieu ma token dc ban di
    Counters.Counter private _itemsSold;

    uint256 listingPrice = 0.0015 ether;

    //lay dia chi cua chu so huu va su dung method payable de nhan tien
    address payable owner;

    mapping(uint256 => MarketItem) private idMarketItem;

    //tao khung xuong cho pj se co 5 truong chinh
    struct MarketItem {
        uint256 tokenId,
        address payable seller,
        address payable owner,
        uint256 price,
        bool sold
    }
    
    //kich hoat su kien khi co thong bao mua ban nft ta se nhan dc 5 field nay
    event idMarketItemCreated {
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    };

    modifier onlyOwner{
        require(msg.sender == owner, "only owner of the marketplace contract");
        _;
    }
    
    constructor() ERC721("NFT Metavarse Token", "MYNFT"){
        owner == payable(msg.sender);
    }

    //cap nhat bang gia
    function updateListingPrice(uint256 _listingPrice) public payable onlyOwner
    {
        listingPrice = _listingPrice;
    }
    //cho nguoi dung co the xem dc gia ma ho phai tra
    function getListingPrice() public view return (uint256) {
        return listtingPrice;
    }
    //let create "create nft token function"
    function createToken(string memory tokenURI, uint256 price) public payable returns(uint256){
        _tokenIds.increment();

        uint256 newTokenId = _tokenIds.current();
        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);

        createMarketItem(newTokenId, price);

        return newTokenId;
    }

    //create merket items
    function createMarketItem(uint256 tokenId, uint256 price) private{


        //check xem gia co ton tai hay k neu k ton tai vut err ra
        require(price > 0 , "Price must be al lest 1");
        //gia tri nguoi gui phai bang gia tri niem yet
        require(msg.value == listingPrice, "Price must be equal to listing price");

        idMarketItem[tokenId] = MarketItem(
            tokenId,
            payable(msg.sender),
            payable(address(this)),
            price,
            false,
        );

        _transfer(msg.sender, address(this), tokenId);

        emit idMarketItemCreated(tokenId, msg.sender, address(this), price, false);
    }

    //FUNCTION FOR RESALE TOKEN
    function reSellToken(uint256 tokenID, uint256 price) public payable{
        require(idMarketItem[tokenId].owner == msg.sender, "Only item owner can perform this operation");

        require(msg.value == listingPrice, "Price must be equal to listingPrice");

        idMarketItem[tokenId].sold = false;
        idMarketItem[tokenId].price = price;
        idMarketItem[tokenId].seller = payable(msg.sender);
        idMarketItem[tokenId].owner = payable(address(this));

        _itemsSold.decrement();

        _transfer(msg.sender, address(this), tokenId);
    }

    //FUNCTION CREATEMARKETSALE

    function createMarketSale(uint256 tokenId) public payable{
        uint256 price = idMarketItem[tokenId].price;
        
        require(msg.value == price, "Please submit the asking price in order to complete the purchase");

        idMarketItem[tokenId].owner = payable(msg.sender);
        idMarketItem[tokenId].sold = true;
        idMarketItem[tokenId].owner = payable(address(0));

        _itmesSold.increment();

        _transfer(address(this), msg.sender, tokenId);

        payable(owner).transfer(listingPrice);
        payable(idMarketItem[tokenId].seller).transfer(msg.value);
    }

    //GETTING UNSOLD NFT DATA
    function fetchMarketItem() public view returns(MarketItem[] memory){
        uint256 itemCount = _tokenIds.current() - _itemsSold.current();
        uint256 unSoldItemCount = _tokenIds.current() - _itemsSold.current();
        uint256 currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        for (uint256 i = 0;i< itemCount; i++) {
            if (idMarketItem[i + 1].owner == address(this)) {
                uint256 currentId = i + 1;

                MarketItem storage currentItem = idMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    //PURCHASE ITEM 
    function fetchMyNFT() public view returns(MarketItem[] memory){
        uint256 totalCount = _tokenIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for(uint256 i =0;i <totalCount; i++){
            if(idMarketItem[i + 1].owner == msg.sender){
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount); 
        for (uint256 i = 0;i < totalCount; i++){
            if (idMarketItem[i + 1].owner == msg.sender) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

}