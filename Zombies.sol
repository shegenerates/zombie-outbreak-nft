pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Zombies is Ownable, ERC721 { //ERC721URIStorage
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    
        // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    string public baseUri;
    string public zombieUri;
    
    uint public numHumansMinted = 0;
    uint public numZombiesMinted = 0;
    
    mapping(address => bool) isInfected;

    event Minted(address to, uint id, string uri);

    constructor() ERC721("Zombies", "BRAINS") {
      baseUri = "ipfs://Qmac3F4cVUQg6LZsgHnBeroVjz4UCZYcWHp68E6kHCYqjG";
      zombieUri = "ipfs://Qmad9Xft39371GzgNvaTPJEgWQR3rrpcFmVFCord64ZDRv"; 
    }
    
    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];

        if(isInfected[ownerOf(tokenId)]){
            return zombieUri;
        }
        else{
            return baseUri;
        }
    }
    
    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    
    /*
    * Mint Humans
    */
    function mintHuman(address player, uint numberOfMints)
        public 
        returns (uint256)
    {
        require(numHumansMinted + numberOfMints <= 10000, "Maximum amount of Humans already minted."); //10000 item cap (9900 public + 100 team mints)
        require(numberOfMints <= 20, "You cant mint more than 20 Humans at a time.");

        for(uint i = 0; i < numberOfMints; i++) {

            _tokenIds.increment();
            uint256 newItemId = _tokenIds.current();
            string memory tokenURI = baseUri;
            _mint(player, newItemId);
            _setTokenURI(newItemId, tokenURI);

            //removed Mint event here bc of gas intensity.
            numHumansMinted++;
        }
        
        return _tokenIds.current();
    }
    
    /*
    * Mint Zombies - one at a time, only 20 total
    */
        function mintZombie(address player)
        public 
        returns (uint256)
    {
        require(numZombiesMinted < 20, "Maximum amount of Zombies already minted."); //10000 item cap (9900 public + 100 team mints)
       

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        string memory tokenURI = zombieUri;
        _mint(player, newItemId);
        _setTokenURI(newItemId, tokenURI);
        
        isInfected[player] = true;

        numZombiesMinted++;
        return _tokenIds.current();
    }
    

    
    
    /*
    * override transfers, infect if sent a zombie.
    */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        if(isInfected[from]){
            isInfected[to] = true;
        }
        
    }

}
    
