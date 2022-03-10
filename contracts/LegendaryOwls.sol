// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./OpenZeppelin/ERC721Votes.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract LegendaryOwls is ERC721, Ownable {
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private supply;

    string public uriPrefix = "";
    string public constant uriSuffix = ".json";
    string public hiddenMetadataUri;
    string public cagedMetadataUri;

    uint256 public cost = 0.065 ether;
    uint256 public constant maxSupply = 8888;

    mapping(uint256 => bool) uncaged;

    mapping(address => bool) public whitelistClaimed;
    bytes32 public merkleRoot;

    bool public presale = false;
    bool public paused = true;
    bool public revealed = false;

    constructor() ERC721("Legendary Owls", "OWLS") {
        setHiddenMetadataUri("ipfs://__CID__/hidden.json");
    }

    modifier mintCompliance(uint256 _mintAmount) {
        require(
            supply.current() + _mintAmount <= maxSupply,
            "Max supply exceeded!"
        );
        _;
    }

    function totalSupply() public view returns (uint256) {
        return supply.current();
    }

    // Mint functions

    function mint(uint256 _mintAmount)
        public
        payable
        mintCompliance(_mintAmount)
    {
        require(!paused, "The contract is paused!");
        require(msg.value >= cost * _mintAmount, "Insufficient funds!");

        _mintLoop(msg.sender, _mintAmount);
    }

    function whitelistMint(uint256 _mintAmount, bytes32[] calldata _merkleProof)
        public
        payable
        mintCompliance(_mintAmount)
    {
        require(presale, "Presale is not active.");
        require(!whitelistClaimed[msg.sender], "Address has already claimed.");
        require(_mintAmount < 3);
        bytes32 leaf = keccak256(abi.encodePacked((msg.sender)));
        require(
            MerkleProof.verify(_merkleProof, merkleRoot, leaf),
            "Invalid proof"
        );
        whitelistClaimed[msg.sender] = true;
        _mintLoop(msg.sender, _mintAmount);
    }

    function mintForAddress(uint256 _mintAmount, address _receiver)
        public
        mintCompliance(_mintAmount)
        onlyOwner
    {
        _mintLoop(_receiver, _mintAmount);
    }

    // URI functions

    function uncage(uint256 _tokenId) public {
        require(
            block.timestamp > uncageTimer[_tokenId],
            "You have to wait more to uncage your Owl!"
        );
        uncaged[_tokenId] = true;
    }

    function checkUncaged(uint256 _tokenId) public view returns (bool) {
        if (uncaged[_tokenId] == true) {
            return true;
        }
    }

    function tokensOfOwner(address _owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory ownedTokenIds = new uint256[](ownerTokenCount);
        uint256 currentTokenId = 1;
        uint256 ownedTokenIndex = 0;
        while (ownedTokenIndex < ownerTokenCount && currentTokenId <= 8888) {
            address currentTokenOwner = ownerOf(currentTokenId);

            if (currentTokenOwner == _owner) {
                ownedTokenIds[ownedTokenIndex] = currentTokenId;

                ownedTokenIndex++;
            }

            currentTokenId++;
        }
        return ownedTokenIds;
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        if (revealed == false) {
            return hiddenMetadataUri;
        }
        string memory currentBaseURI = _baseURI();
        if (checkUncaged(_tokenId) == true) {
            return
                bytes(currentBaseURI).length > 0
                    ? string(
                        abi.encodePacked(
                            currentBaseURI,
                            _tokenId.toString(),
                            uriSuffix
                        )
                    )
                    : "";
        } else {
            return
                bytes(cagedMetadataUri).length > 0
                    ? string(
                        abi.encodePacked(
                            cagedMetadataUri,
                            _tokenId.toString(),
                            uriSuffix
                        )
                    )
                    : "";
        }
    }

    function setHiddenMetadataUri(string memory _hiddenMetadataUri)
        public
        onlyOwner
    {
        hiddenMetadataUri = _hiddenMetadataUri;
    }

    function setCagedUri(string memory _cagedURI) public onlyOwner {
        cagedMetadataUri = _cagedURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return uriPrefix;
    }

    function setUriPrefix(string memory _uriPrefix) public onlyOwner {
        uriPrefix = _uriPrefix;
    }

    // Price functions

    function setPrice(uint256 _price) public onlyOwner {
        cost = _price;
    }

    function getPrice() public view returns (uint256) {
        return cost;
    }

    // State functions

    function setPresale(bool _bool) public onlyOwner {
        presale = _bool;
    }

    function setPaused(bool _state) public onlyOwner {
        paused = _state;
    }

    function setRevealed(bool _state) public onlyOwner {
        revealed = _state;
    }

    // Withdraw function

    function withdraw() public onlyOwner {
        // Pay dev
        (bool hs, ) = payable(0xA4Ad17ef801Fa4bD44b758E5Ae8B2169f59B666F).call{
            value: (address(this).balance * 6) / 100
        }("");
        require(hs);
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }

    // Utils

    function setMerkleRoot(bytes32 _newMerkleRoot) public onlyOwner {
        merkleRoot = _newMerkleRoot;
    }

    function _mintLoop(address _receiver, uint256 _mintAmount) internal {
        for (uint256 i = 0; i < _mintAmount; i++) {
            supply.increment();
            _safeMint(_receiver, supply.current());
        }
    }
}
