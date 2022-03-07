// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "Merkleroot.sol";


contract zkuNFT is ERC721("NFT", "ZKU"), MerkleProof {

    //Here we define how will the tokens ID's will work. 
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    
    //We will mint an NFT to any adress, 
    //Store the name and description and return the ID of the newly created token.
    function mint(address to, string memory _NFTname, string memory _NFTdescription) public returns(uint256) {
        _tokenIds.increment();
        uint256 newId = _tokenIds.current();
        _safeMint(to, newId);
        Metadata memory _metadata = Metadata(
            _NFTname,
            _NFTdescription
        );
        
        bytes32 MintHash = keccak256(
            abi.encodePacked(msg.sender, to, newId, _NFTname, _NFTdescription)
        );
        addLeaf(MintHash);
        _tokenMetadata[newId] = _metadata;
        return newId;
    }
    
    // We define the metadata format for on-chain, we include the name and description of each NFT.
    struct Metadata {
        string NFTname;
        string NFTdescription;
    }
    mapping(uint256 => Metadata) private _tokenMetadata;
    
    
    // Merkle Tree
    // We need to pre-decide a size for the tree to create an empty tree.
    
    uint256 numberOfLeaves;
    bytes32[] private merkleTreeNodes;
    Counters.Counter private _currentLeaf;
    

    constructor(uint256 _nLeaves) payable{
        numberOfLeaves = _nLeaves;
       
        for (uint i = 0; i < _nLeaves; i++) {
            merkleTreeNodes.push(keccak256(abi.encodePacked("NewEmptyMerkleTree")));
        }

        uint n = _nLeaves;
        uint offset = 0;

        while (n > 0) {
            for (uint i = 0; i < n - 1; i += 2) {
                merkleTreeNodes.push(
                    keccak256(
                        abi.encodePacked(merkleTreeNodes[offset + i], merkleTreeNodes[offset + i + 1])
                    )
                );
            }
            offset += n;
            n = n / 2;
        }
    }

    function updateMerkleTree(uint256 _leafPosition) public {
        uint n = numberOfLeaves/2;
        uint offset = numberOfLeaves;
        uint nodePositionOnCurrentLevel = _leafPosition;
        uint tmpNodePosition = _leafPosition;
        uint currentTreeLevel = 1;
        while (n > 0) {
            uint treePosition = offset + nodePositionOnCurrentLevel/2;
            if (nodePositionOnCurrentLevel % 2 == 0) {
                merkleTreeNodes[treePosition] =
                    keccak256(
                        abi.encodePacked(merkleTreeNodes[tmpNodePosition], merkleTreeNodes[tmpNodePosition + 1])
                    );
            } else if (nodePositionOnCurrentLevel % 2 == 1) {
                merkleTreeNodes[treePosition] =
                    keccak256(
                        abi.encodePacked(merkleTreeNodes[tmpNodePosition - 1], merkleTreeNodes[tmpNodePosition])
                    );
            }
            offset += n;
            n = n / 2;
            currentTreeLevel += 1;
            nodePositionOnCurrentLevel = treePosition % (numberOfLeaves/currentTreeLevel);
            tmpNodePosition = treePosition;
        }
    }

    //We add a leaf to the merkle tree.
    function addLeaf(bytes32 _leaf) public {
        _currentLeaf.increment();
        uint256 currentLeaf = _currentLeaf.current() - 1;
        require(currentLeaf <= numberOfLeaves, "You have exceeded the number of base leaves in the tree");
        merkleTreeNodes[currentLeaf] = _leaf;
        updateMerkleTree(currentLeaf);
    }

    //Get the merkle root.
    function getmerkleRoot() public view returns(bytes32) {
        return merkleTreeNodes[numberOfLeaves*2 - 2];
    }

     //Return NFT metadata that corresponds to the tokenId provided.
    function tokenMetadata(uint256 tokenId) public view returns(Metadata memory) {
        return _tokenMetadata[tokenId];
    }
}