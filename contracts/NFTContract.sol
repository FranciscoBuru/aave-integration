// SPDX-License-Identifier: MIT
// NFT contract where the tokenURI can be 1 of 3 different dogs
// Randomnly selected
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTContract is ERC721, Ownable {
    uint256 public tokenCounter;
    uint256[] public year;
    uint256[] public month;
    uint256[] public unit;

    constructor() ERC721("PaymentNFT", "PNFT") {
        tokenCounter = 0;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI)) : "";
    }

    function _baseURI() internal view virtual override returns (string memory) {
        //Hardcodea el URI
        return "";
    }

    function createCollectible(
        address _destination,
        uint256 _year,
        uint256 _month,
        uint256 _unit
    ) public onlyOwner {
        uint256 newTokenId = tokenCounter;
        _safeMint(_destination, newTokenId);
        year[tokenCounter] = _year;
        month[tokenCounter] = _month;
        unit[tokenCounter] = _unit;
        tokenCounter = tokenCounter + 1;
    }
}
