// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//import "./ERC721Tradable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

//import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title Creature
 * Creature - a contract for my non-fungible creatures.
 */
contract genshinCharacterFactory is ERC721 {
    address public verifiedAddress;

    string[] public URIs;
    uint256[] public standardFourStars;
    uint256[] public featuredFourStars;
    uint256[] public standardFiveStars;
    uint256 public featuredFiveStars;
    mapping(uint256 => string) public tokenIdToURI;
    uint256 public tokenIdCounter = 1;

    modifier onlyVerifiedAddress() {
        require(msg.sender == verifiedAddress);
        _;
    }

    constructor(string memory name_, string memory symbol_)
        ERC721(name_, symbol_)
    {}

    function addURI(string memory _newURI) public {
        URIs.push(_newURI);
    }

    function baseTokenURI() public pure returns (string memory) {
        return
            "https://ipfs.io/ipfs/QmbmR2xpe4NT7JPpiXZFLSL7dbJzDQDgK6BRiMDrr43Acb";
    }

    function mint(
        address to,
        uint256 tokenId,
        uint256 URIIndex
    ) public {
        _mint(to, tokenId);
        tokenIdToURI[tokenId] = URIs[URIIndex];
    }

    function mintRandomItem(
        uint256[] memory rarityArray,
        address _to,
        uint256 _randomNumber
    ) public {
        uint256 _URIIndex = getTheIndex(rarityArray, _randomNumber);
        uint256 _tokenId = tokenIdCounter;
        mint(_to, _tokenId, _URIIndex);
        tokenIdCounter = tokenIdCounter + 1;
    }

    //pseudocode for now
    function getTheIndex(uint256[] memory targetArr, uint256 _randomNumber)
        public
        pure
        returns (uint256)
    {
        uint256 randomNumber = _randomNumber; //requestRandomWords()
        uint256 moddedNumber = (randomNumber % targetArr.length) + 0;
        return moddedNumber;
    }

    // function condensedFunction(uint256 randomNumber, int[] targetArr, address _to) public {
    //   //uint256 randomNumber = requestRandomWords();
    //   //uint256 moddedNumber = randomNumber % targetArr.length + 0;
    //   uint256 _URIIndex =  randomNumber % targetArr.length + 0;

    //   uint256 _tokenId = tokenIdCounter;
    //   _mint(_to, tokenId);
    //   tokenIdToURI[tokenId] = URIs[URIIndex];
    //   tokenIdCounter = tokenIdCounter + 1;

    // }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        _requireMinted(tokenId);

        string memory requestedURI = tokenIdToURI[tokenId];
        return requestedURI;
    }

    ////////////overrride//////////////////

    function approve(address to, uint256 tokenId) public override {
        revert("not a valid operation");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        revert("not a valid operation");
    }

    function setApprovalForAll(address operator, bool approved)
        public
        override
    {
        revert("not a valid operation");
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        revert("not a valid operation");
    }
}
