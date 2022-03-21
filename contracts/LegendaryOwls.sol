// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SmartContracts/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract LegendaryOwls is ERC721, Ownable {
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private supply;

    // The URI prefix for the main metadata
    string public uriPrefix = "";

    // Metadata file extension
    string public constant uriSuffix = ".json";

    // The URI prefix for the hidden metadata
    string public hiddenMetadataUri;

    // The URI prefix for the caged owls metadata
    string public cagedMetadataUri;

    // The cost to mint 1 NFT
    uint256 public cost = 0.08 ether;

    // The maximum supply of Owls
    uint256 public constant maxSupply = 8888;

    // Mapping of Owls to caged/uncaged state
    mapping(uint256 => bool) uncaged;

    // Mapping of address to bool that determins wether the address already claimed the whitelist mint
    mapping(address => bool) public whitelistClaimed;

    // The Merkle Root hex
    bytes32 public merkleRoot;

    // Admin address
    address admin;

    // Presale state
    bool public presale = false;

    // Minting state
    bool public paused = true;

    // Revealed state
    bool public revealed = false;

    constructor() ERC721("Legendary Owls", "OWLS") {}

    ///////////////
    // Modifiers //
    ///////////////

    // Keeps mint limit per tx to 15 and keeps max supply at 8888
    modifier mintCompliance(uint256 _mintAmount) {
        require(_mintAmount > 0 && _mintAmount <= 15, "Invalid mint amount!");
        require(
            supply.current() + _mintAmount <= maxSupply,
            "Max supply exceeded!"
        );
        _;
    }

    // Gives access to function only for Owner or Admin
    modifier onlyOwnerAndAdmin() {
        require(
            owner() == _msgSender() || admin == msg.sender,
            "Not owner or Admin"
        );
        _;
    }

    ////////////////////
    // Mint Functions //
    ////////////////////

    // The main mint function
    // _mintAmount = How many NFTs to mint in the tx
    function mint(uint256 _mintAmount)
        public
        payable
        mintCompliance(_mintAmount)
    {
        require(!paused, "The contract is paused!");
        require(msg.value >= cost * _mintAmount, "Insufficient funds!");

        _mintLoop(msg.sender, _mintAmount);
    }

    // The whitelist mint function
    // Can only be called once per address
    // _mintAmount = How many NFTs to mint in the tx
    // _merkleProof = Hex proof generated by Merkle Tree for whitelist verification
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

    // Function that allows the team to mint for other addresses for free
    // Will be used for giveaways
    function mintForAddress(uint256 _mintAmount, address _receiver)
        public
        mintCompliance(_mintAmount)
        onlyOwnerAndAdmin
    {
        _mintLoop(_receiver, _mintAmount);
    }

    ///////////////////
    // URI Functions //
    ///////////////////

    // Funtion to be called after uncage timer expires. Will make tokenURI return the uncaged metadata
    // Pass in the token ID
    function uncage(uint256 _tokenId) public {
        require(
            block.timestamp > uncageTimer[_tokenId],
            "You have to wait more to uncage your Owl!"
        );
        uncaged[_tokenId] = true;
    }

    // Returns bool true if token ID is uncaged and false if token ID is caged
    function checkUncaged(uint256 _tokenId) public view returns (bool _caged) {
        return uncaged[_tokenId];
    }

    // ERC721 standard tokenURI function.
    // Will return hidden, caged or uncaged URI based on reveal state and uncaged state
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

    // Administrative function
    function setHiddenMetadataUri(string memory _hiddenMetadataUri)
        public
        onlyOwnerAndAdmin
    {
        hiddenMetadataUri = _hiddenMetadataUri;
    }

    // Administrative function
    function setCagedUri(string memory _cagedURI) public onlyOwnerAndAdmin {
        cagedMetadataUri = _cagedURI;
    }

    // Override for ERC721 Smart Contract
    function _baseURI() internal view virtual override returns (string memory) {
        return uriPrefix;
    }

    // Administrative function
    function setUriPrefix(string memory _uriPrefix) public onlyOwnerAndAdmin {
        uriPrefix = _uriPrefix;
    }

    /////////////////////
    // Price functions //
    /////////////////////

    // Administrative function
    function setPrice(uint256 _price) public onlyOwnerAndAdmin {
        cost = _price;
    }

    // Returns price of mint per NFT
    function getPrice() public view returns (uint256) {
        return cost;
    }

    /////////////////////
    // State functions //
    /////////////////////

    // Administrative function
    function setPresale(bool _bool) public onlyOwnerAndAdmin {
        presale = _bool;
    }

    // Administrative function
    function setPaused(bool _state) public onlyOwnerAndAdmin {
        paused = _state;
    }

    // Administrative function
    function setRevealed(bool _state) public onlyOwnerAndAdmin {
        revealed = _state;
    }

    // Administrative function
    function setCanTransfer(bool _state) public onlyOwnerAndAdmin {
        canTransfer = _state;
    }

    ///////////////////////
    // Withdraw function //
    ///////////////////////

    function withdraw() public onlyOwner {
        (bool hs, ) = payable(0xA4Ad17ef801Fa4bD44b758E5Ae8B2169f59B666F).call{
            value: (address(this).balance * 6) / 100
        }("");
        require(hs);
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }

    ///////////
    // Utils //
    ///////////

    // Administrative function
    function setAdmin(address _admin) public onlyOwner {
        admin = _admin;
    }

    // Returns total supply
    function totalSupply() public view returns (uint256) {
        return supply.current();
    }

    // Administrative function
    function setMerkleRoot(bytes32 _newMerkleRoot) public onlyOwnerAndAdmin {
        merkleRoot = _newMerkleRoot;
    }

    // Loop for minting multiple NFTs in one transaction
    function _mintLoop(address _receiver, uint256 _mintAmount) internal {
        for (uint256 i = 0; i < _mintAmount; i++) {
            supply.increment();
            _safeMint(_receiver, supply.current());
        }
    }

    // Returns an array of tokens of _owner address
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

    receive() external payable {}
}
