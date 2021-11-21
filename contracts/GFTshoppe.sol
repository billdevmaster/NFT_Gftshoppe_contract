// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract GFTShoppe is ERC721, ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    using Strings for *;
    Counters.Counter public _tokenIDs;

    mapping(address => bool) public isAdmin;
    mapping(address => uint256) public tokenCounters;

    string public baseTokenURI;
    uint256 private mintAmount = 0.02 ether;
    uint256 private maxMintCount = 5;

    constructor() ERC721("Gft Shoppe", "GFTShoppe") {
    }

    modifier onlyMinter() {
        require(
            isAdmin[_msgSender()] ||
                owner() == _msgSender(),
            " caller has no minting right!!!"
        );
        _;
    }
    modifier onlyAdmin() {
        require(
            isAdmin[_msgSender()] || owner() == _msgSender(),
            " caller has no minting right!!!"
        );
        _;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        baseTokenURI = baseURI;
    }

    function createItem(uint256 amount) public payable {
        require(_tokenIDs.current() + amount <= 10000, "Max mint amount is reached");
        require(
            tokenCounters[msg.sender] + amount <= maxMintCount,
            "Exceed the Max Amount to mint."
        );
        require(amount * mintAmount == msg.value, "You sent the incorrect amount of tokens");
        for (uint256 i = 0; i < amount; i++) {
            _tokenIDs.increment();
            uint256 newItemID = _tokenIDs.current();
            _safeMint(msg.sender , newItemID);
        }
        tokenCounters[msg.sender] = tokenCounters[msg.sender] + amount;
    }

    function createTeamItem(uint256 amount) public onlyAdmin {
        require(_tokenIDs.current() + amount <= 10000, "Max mint amount is reached");
        
        for (uint256 i = 0; i < amount; i++) {
            _tokenIDs.increment();
            uint256 newItemID = _tokenIDs.current();
            _safeMint(msg.sender , newItemID);
        }
        tokenCounters[msg.sender] = tokenCounters[msg.sender] + amount;
    }

    function addAdmin(address adminAddress) public onlyOwner {
        require(
            adminAddress != address(0),
            " admin Address is the zero address"
        );
        isAdmin[adminAddress] = true;
    }

    function removeAdmin(address adminAddress) public onlyOwner {
        require(
            adminAddress != address(0),
            " admin Address is the zero address"
        );
        isAdmin[adminAddress] = false;
    }

    function setRevealOpenSea(string memory baseURI) public onlyAdmin {
        baseTokenURI = baseURI;
    }

    function withdraw() public onlyAdmin payable {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function setMintAmount(uint256 amount) public onlyOwner {
        mintAmount = amount;
    }

    function setMaxMintCount(uint256 count) public onlyOwner {
        maxMintCount = count;
    }

    function walletOfUser(address user) public view returns(uint256[] memory) {
        uint256 tokenCount = balanceOf(user);

        uint256[] memory tokensId = new uint256[](tokenCount);
        for(uint256 i; i < tokenCount; i++){
            tokensId[i] = tokenOfOwnerByIndex(user, i);
        }
        return tokensId;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}