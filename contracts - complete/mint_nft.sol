pragma solidity ^0.8.1;

    import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
    import "@openzeppelin/contracts/access/Ownable.sol";
    import "@openzeppelin/contracts/utils/math/SafeMath.sol";

    contract REALM is ERC721, Ownable {
        using SafeMath for uint256;
        using Strings for uint256;
        uint256 private _currentTokenId = 0;
        uint256 private _limitTokenCount = 999;
        
        // Optional mapping for token URIs
        mapping (uint256 => string) private _tokenURIs;

        // Base URI
        string public baseURI;

        address [] public whiteList;

        constructor()
            ERC721("REALM", "REALM")
        {
            
        }

        /**
         * @dev calculates the next token ID based on value of _currentTokenId
         * @return uint256 for the next token ID
         */
        function _getNextTokenId() private view returns (uint256) {
            return _currentTokenId.add(1);
        }

        /**
         * @dev increments the value of _currentTokenId
         */
        function _incrementTokenId() private {
            _currentTokenId++;
        }
        
        function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
            require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
            _tokenURIs[tokenId] = _tokenURI;
        }
        
        function setTokenURI(uint256 tokenId, string memory _tokenURI) public virtual {
            require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
            _tokenURIs[tokenId] = _tokenURI;
        }

        function _baseURI() internal view override(ERC721) returns(string memory) {
            return baseURI;
        }

        function setBaseURI(string memory _URI) external onlyOwner {
            baseURI = _URI;
        }
        
        function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
            require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

            string memory _tokenURI = _tokenURIs[tokenId];
            string memory base = _baseURI();
            return _tokenURI;
            
            // If there is no base URI, return the token URI.
            if (bytes(base).length == 0) {
                return _tokenURI;
            }
            // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
            if (bytes(_tokenURI).length > 0) {
                return string(abi.encodePacked(base, _tokenURI));
            }
            // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
            return string(abi.encodePacked(base, tokenId.toString()));
        }
        
        function mint(
            address _to,
            string memory tokenURI_
        ) public {
            // check address in whiteList
            bool is_exist = false;
            for(uint i = 0; i < whiteList.length; i++) {
                if (whiteList[i] == _to) {
                    is_exist = true;
                }
            }

            require(is_exist == true, "You must be in whitelist of our company");
            uint256 newTokenId = _getNextTokenId();
            _mint(_to, newTokenId);
            _setTokenURI(newTokenId, tokenURI_);
            _incrementTokenId();
        }

        function addWhiteList(address _member) external onlyOwner {
            whiteList.push(_member);
        }

        function getWhiteList()public view returns( address  [] memory){
            return whiteList;
        }

        function removeAddressInList(uint _id) public {
            delete whiteList[_id];
        }
}