// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract ChainBattles is ERC721URIStorage {

    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenId;

    struct weapon {
        uint level;
        uint weight;
        uint strength;
    }

    mapping(uint256 => weapon) public tokenIdToData;

    constructor() ERC721 ("Chain Battles", "CBTLS") {}
    
    function generateCharacter(uint256 tokenId) public view returns(string memory){

        bytes memory svg = abi.encodePacked(
            '<svg width="512px" height="512px" viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg">',
            '<style>.base {fill: red; font-family: rockwell; font-size: 30px;}</style>',
            '<path fill="#000" d="M27.47 15.344c62.946 25.422 108.824 61.313 115.843 132.03v.188c52.31 30.132 92.605 72.538 104.28 119.938 1.792 7.272 2.84 14.637 3.126 22.03 31.737-3.283 64-20.935 87.843-46.624 26.42-28.467 42.056-65.91 36.843-103.03-15.205 1.917-30.855.922-46.5-2.314-50.282-10.398-101.7-42.974-148.562-77.875-4.79-4.21-9.93-8.084-15.406-11.656-34.787-22.69-82.864-32.686-137.47-32.686zM234.687 41.25l-15.72 23c19.23 13.107 38.792 25.095 58.126 34.72l13.437-19.25c-12.406-18.774-34.986-32.363-55.842-38.47zm239.375 21.375c-16.886 31.464-37.035 52.625-59.72 64.875-6.702 3.62-13.573 6.434-20.593 8.53 6.67 44.027-11.746 87.505-41.5 119.564-27.275 29.387-64.424 49.947-102.53 52.844-4.482 31.48-23.408 62.858-59.75 90.312 40.743 9.164 78.742 9.05 113.436 1.906l7.72-49.03 2.937-18.595 13.03 13.595L359 379.875c27.795-16.753 64.71-44.308 83.22-67.906L413.31 262l-11.468-19.78 22.03 6.093 47.938 13.25c13.232-23.865 21.327-60.527 21.47-98.875.13-34.855-6.22-70.88-19.22-100.063zM146.092 170.97L20.564 354.75l.812 110.625 175.53-251.5c-13.78-15.612-31.054-30.19-50.81-42.906z"/>',
            '<text x="25%" y="15%" class="base" dominant-baseline="middle" text-anchor="middle">Type: Weapon</text>',
            '<text x="75%" y="75%" class="base" dominant-baseline="middle" text-anchor="middle">', "Level: ",getWeaponLevel(tokenId),'</text>',
            '<text x="75%" y="85%" class="base" dominant-baseline="middle" text-anchor="middle">', "Strength: ",getWeaponStrength(tokenId),'</text>',
            '<text x="75%" y="95%" class="base" dominant-baseline="middle" text-anchor="middle">', "Weight: ",getWeaponWeight(tokenId),'</text>',
            '</svg>'
        );
        
        return string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(svg)
            )
        );
    }

    function getWeaponLevel(uint256 tokenId) public view returns(string memory) {
        uint256 levels = tokenIdToData[tokenId].level;
        return levels.toString();
    }

    function getWeaponWeight(uint256 tokenId) public view returns(string memory) {
        uint256 weight = tokenIdToData[tokenId].weight;
        return weight.toString();
    }

    function getWeaponStrength(uint256 tokenId) public view returns(string memory) {
        uint256 stregth = tokenIdToData[tokenId].strength;
        return stregth.toString();
    }

    // Weight and Strength are set with random values from 0 to 100.
    // Level is set from 0 to 10
    function setWeapon(uint256 tokenId) internal {
        tokenIdToData[tokenId].level    = tokenIdToData[tokenId].weight + uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,block.difficulty))) % 10;
        tokenIdToData[tokenId].weight   = tokenIdToData[tokenId].weight + uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,msg.sender))) % 100;
        tokenIdToData[tokenId].strength = tokenIdToData[tokenId].strength + uint(keccak256(abi.encodePacked(msg.sender,block.timestamp,block.difficulty))) % 100;
    }

    function getTokenURI(uint256 tokenId) public view returns (string memory){
        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "Chain Battles #', tokenId.toString(), '",',
                '"description": "Battles on chain",',
                '"image": "', generateCharacter(tokenId), '"',
            '}'
        );
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }

    function mint() public {
        _tokenId.increment();
        uint256 newItemId = _tokenId.current();
        _safeMint(msg.sender, newItemId);
        setWeapon(newItemId);
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }
 
    // Users can train their weapons to increase their level. A random level from 0 to 5 is increased
    // Level attribute makes their weapons more powerfull
    // Potential improve: They could train their weapon paying some game credits
    function train(uint256 tokenId) public {
        require(_exists(tokenId), "Please use an existing token");
        require(ownerOf(tokenId) == msg.sender, "You must own this token to train it");
        uint256 currentLevel = tokenIdToData[tokenId].level;
        tokenIdToData[tokenId].level = currentLevel + randomize(5);
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }

    // Users are allowed to burn their own weapons. 
    // Potential improve: They could burn weapons and get back game credits to mint new ones. This inspiration comes
    // from https://cometh.io
    function burn(uint256 tokenId) public {
        require(_exists(tokenId), "Please use an existing token");
        require(ownerOf(tokenId) == msg.sender, "You must own this token to burn it");
        _burn(tokenId);
    }

    function randomize(uint256 number) internal view returns(uint){
        return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,msg.sender))) % number;
    }

}
