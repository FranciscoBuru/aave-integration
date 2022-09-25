// SPDX-License-Identifier: MIT
// NFT contract where the tokenURI can be 1 of 3 different dogs
// Randomnly selected
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTContract is ERC721 {
    uint256 public tokenCounter;
    address public owner;

    constructor() ERC721("PaymentNFT", "PNFT") {
        tokenCounter = 0;
        owner = msg.sender;
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

        return string(abi.encodePacked(_baseURI()));
    }

    function _baseURI() internal view virtual override returns (string memory) {
        //Hardcodea el URI
        return "ipfs://QmY41tqW2qfmH4oMHjYF379De8yNeVGmU4LafFQhEgQcuu";
    }

    function createCollectible(address destination) public {
        require(msg.sender == owner);
        uint256 newTokenId = tokenCounter;
        _mint(destination, newTokenId);
        tokenCounter = tokenCounter + 1;
    }
}
