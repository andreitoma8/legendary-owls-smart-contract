// SPDX-License-Identifier: MIT
// Creator: Andrei Toma
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
    string internal uriPrefix;

    // Metadata file extension
    string internal constant uriSuffix = ".json";

    // The URI prefix for the hidden metadata
    string internal hiddenMetadataUri;

    // The URI prefix for the caged owls metadata
    string internal cagedMetadataUri;

    string internal cagedBackgroundMetadataUri;

    // The cost to mint 1 NFT
    uint256 public cost = 0.088 ether;

    // The roadmap level
    uint256 public level;

    // The maximum supply of Owls
    uint256 public constant maxSupply = 8888;

    // Time for the second level of uri change
    uint256 internal timeForSecondChange = 604800;

    // Mapping of Owls to level of uncaged evolution
    mapping(uint256 => uint256) internal uncaged;

    // Mapping of Token Id to time to uncage for level 2
    mapping(uint256 => uint256) internal uncageTimerTwo;

    // Mapping of address to bool that determins wether the address already claimed the whitelist mint
    mapping(address => bool) public whitelistClaimed;

    // The Merkle Root
    bytes32 internal merkleRoot;

    // Admin address
    address internal admin;

    // Presale state
    bool public presale = false;

    // Minting state
    bool public paused = true;

    // Revealed state
    bool public revealed = false;

    constructor() ERC721("Legendary Owls", "OWLS") {
        admin = msg.sender;
    }

    ///////////////
    // Modifiers //
    ///////////////

    // Keeps mint limit per tx to 7 and keeps max supply at 8888
    modifier mintCompliance(uint256 _mintAmount) {
        require(_mintAmount > 0 && _mintAmount <= 7, "Invalid mint amount!");
        require(
            supply.current() + _mintAmount <= maxSupply,
            "Max supply exceeded!"
        );
        _;
    }

    // Gives access to function only for Owner or Admin
    modifier onlyOwnerAndAdmin() {
        require(
            owner() == _msgSender() || admin == _msgSender(),
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

    ///////////////
    // Giveaways //
    ///////////////

    // To ensure a high level of fairness, Roadmap functions have no modifier
    // and can be called by everyone, but only after a specified amount of
    // tokens has been minted and only once. Who's gona be the fastest one
    // and get the tx that will start the giveaways? :)

    // Function used to giveaway 1 ETH to 5 NFT Owners
    // Will be called 5 times by Owner/Admin
    function roadMapOne() public {
        require(totalSupply() > 1777, "Not yet available");
        require(level < 1, "Roadmap step already done");
        level++;
        uint256 length = totalSupply();
        for (uint256 i = 1; i <= 5; i++) {
            uint256 tokenOfWinner = ((block.timestamp / i) % length) + 1;
            address winner = ownerOf(tokenOfWinner);
            (bool bl, ) = payable(winner).call{value: 1 ether}("");
            require(bl);
        }
    }

    // Function will send 8 ETH to DAO treasury
    // The DAO SC is not yet deployed so the address
    // will be passed as an arg
    function roadMapTwo(address _treasury) public onlyOwnerAndAdmin {
        require(totalSupply() > 3555, "Not yet available");
        (bool bl, ) = payable(_treasury).call{value: 8 ether}("");
        require(bl);
    }

    // Function used to mint 20 NFTs for 20 Holders
    function roadMapThree() public {
        require(totalSupply() > 5332, "Not yet available");
        require(level < 2, "Roadmap step already done");
        level++;
        uint256 length = totalSupply();
        for (uint256 i = 1; i <= 20; i++) {
            uint256 tokenOfWinner = ((block.timestamp / i) % length) + 1;
            address winner = ownerOf(tokenOfWinner);
            _mintLoop(winner, 1);
        }
    }

    // 10 ETH will be doanted to Ukraine
    // You can verify the address by searching
    // it on Etherscan.io or on any official
    // Ukrainian website/ news website
    function roadMapFour(address _charity) public onlyOwnerAndAdmin {
        require(totalSupply() > 7110, "Not yet available");
        require(level < 3, "Roadmap step already done");
        level++;
        (bool bl, ) = payable(_charity).call{value: 10 ether}("");
        require(bl);
    }

    // Function will send 12 ETH to DAO treasury
    // The DAO SC is not yet deployed so the address
    // will be passed as an arg
    function roadMapFive(address _treasury) public onlyOwnerAndAdmin {
        require(totalSupply() > 8800, "Not yet available");
        (bool bl, ) = payable(_treasury).call{value: 12 ether}("");
        require(bl);
    }

    // Final Giveaway is a surprise and will be anounced
    // after the collection is fully minted, stay tuned!

    ///////////////////
    // URI Functions //
    ///////////////////

    // Funtion to be called after uncage timer expires for each level.
    // Will make tokenURI return the uncaged metadata. Pass in the token ID
    function uncage(uint256 _tokenId) public {
        if (uncaged[_tokenId] < 1) {
            require(
                block.timestamp > uncageTimer[_tokenId],
                "You have to wait more to uncage your Owl!"
            );
            uncaged[_tokenId] = 1;
            uncageTimerTwo[_tokenId] == block.timestamp + timeForSecondChange;
        } else if (uncaged[_tokenId] == 1) {
            require(
                block.timestamp > uncageTimerTwo[_tokenId],
                "You have to wait more to uncage your Owl!"
            );
            uncaged[_tokenId] = 2;
        }
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
        string memory currentBaseURI = uri(_tokenId);
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
    }

    function uri(uint256 _tokenId) internal view returns (string memory) {
        if (uncaged[_tokenId] == 2) {
            return uriPrefix;
        } else if (uncaged[_tokenId] == 1) {
            return cagedMetadataUri;
        } else {
            return cagedBackgroundMetadataUri;
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

    // Administrative function
    function setCagedBackgroundMetadataUri(string memory _newUri)
        public
        onlyOwnerAndAdmin
    {
        cagedBackgroundMetadataUri = _newUri;
    }

    /////////////////////
    // Price functions //
    /////////////////////

    // Administrative function
    function setPrice(uint256 _price) public onlyOwnerAndAdmin {
        cost = _price;
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

    ///////////////////////
    // Withdraw function //
    ///////////////////////

    function withdraw() public onlyOwnerAndAdmin {
        (bool hs, ) = payable(admin).call{
            value: (address(this).balance * 6) / 100
        }("");
        require(hs);
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }

    ///////////
    // Utils //
    ///////////

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

    // If you got this far you are a hardcore geek! :)
}
