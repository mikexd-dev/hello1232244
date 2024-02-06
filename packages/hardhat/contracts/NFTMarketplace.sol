// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTMarketplace is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    struct NFT {
        uint256 id;
        string name;
        string metadata;
        address owner;
        uint256 price;
    }
    
    mapping(uint256 => NFT) private _nfts;
    mapping(uint256 => bool) private _tokenOnSale;
    
    constructor() ERC721("NFTMarketplace", "NFTM") {}
    
    function createNFT(string memory name, string memory metadata) external {
        _tokenIds.increment();
        uint256 newNFTId = _tokenIds.current();
        _safeMint(msg.sender, newNFTId);
        
        NFT memory newNFT = NFT(newNFTId, name, metadata, msg.sender, 0);
        _nfts[newNFTId] = newNFT;
    }
    
    function putNFTForSale(uint256 nftId, uint256 price) external {
        require(_exists(nftId), "NFT does not exist");
        require(ownerOf(nftId) == msg.sender, "Not the owner of NFT");
        
        _nfts[nftId].price = price;
        _tokenOnSale[nftId] = true;
    }
    
    function removeNFTFromSale(uint256 nftId) external {
        require(_exists(nftId), "NFT does not exist");
        require(ownerOf(nftId) == msg.sender, "Not the owner of NFT");
        
        _nfts[nftId].price = 0;
        _tokenOnSale[nftId] = false;
    }
    
    function buyNFT(uint256 nftId) external payable {
        require(_exists(nftId), "NFT does not exist");
        require(_tokenOnSale[nftId], "NFT is not for sale");
        require(msg.value >= _nfts[nftId].price, "Insufficient payment");
        
        address payable seller = payable(ownerOf(nftId));
        _transfer(seller, msg.sender, nftId);
        seller.transfer(msg.value);
        
        _nfts[nftId].price = 0;
        _tokenOnSale[nftId] = false;
    }
    
    function getNFT(uint256 nftId) external view returns (string memory name, string memory metadata, address owner, uint256 price) {
        require(_exists(nftId), "NFT does not exist");
        
        NFT memory nft = _nfts[nftId];
        return (nft.name, nft.metadata, nft.owner, nft.price);
    }
    
    function getNFTsOnSale() external view returns (uint256[] memory) {
        uint256[] memory nftsOnSale = new uint256[](tokenSupply());
        uint256 index = 0;
        
        for (uint256 i = 1; i <= tokenSupply(); i++) {
            if (_tokenOnSale[i]) {
                nftsOnSale[index] = i;
                index++;
            }
        }
        
        return nftsOnSale;
    }
    
    function tokenSupply() public view returns (uint256) {
        return _tokenIds.current();
    }
}