// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ERC721.sol";
import "./AccessControl.sol";
import "./Counters.sol";

contract LandRegistryNFT is ERC721, AccessControl {
    using Counters for Counters.Counter;

    bytes32 public constant REGISTRAR_ROLE = keccak256("REGISTRAR_ROLE");
    Counters.Counter private _tokenIdCounter;

    enum ParcelStatus { Active, Disputed, Frozen, Revoked }

    struct Parcel {
        string lrNumber;
        string county;
        string coordinatesHash;
        string ownerIdHash;
        ParcelStatus status;
        uint256 registeredAt;
    }

    mapping(uint256 => Parcel) public parcels;
    mapping(uint256 => string[]) public parcelDocuments;

    event ParcelRegistered(uint256 indexed tokenId, string lrNumber, string county, address indexed owner);
    event ParcelTransferred(uint256 indexed tokenId, address indexed from, address indexed to);
    event ParcelStatusChanged(uint256 indexed tokenId, ParcelStatus newStatus, string reason);
    event ParcelDocumentAdded(uint256 indexed tokenId, string docHash);

    constructor(address ministryAdmin)
        ERC721("KenyaLandRegistry", "KLR")
    {
        _grantRole(DEFAULT_ADMIN_ROLE, ministryAdmin);
        _grantRole(REGISTRAR_ROLE, ministryAdmin);
    }

    modifier onlyRegistrar() {
        require(hasRole(REGISTRAR_ROLE, msg.sender), "Not registrar");
        _;
    }

    modifier onlyActive(uint256 tokenId) {
        require(_exists(tokenId), "Parcel does not exist");
        require(parcels[tokenId].status == ParcelStatus.Active, "Parcel not active");
        _;
    }

    function registerParcel(
        address owner,
        string calldata lrNumber,
        string calldata county,
        string calldata coordinatesHash,
        string calldata ownerIdHash
    ) external onlyRegistrar returns (uint256) {
        require(owner != address(0), "Invalid owner");
        require(bytes(lrNumber).length > 0, "LR number required");

        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();

        _safeMint(owner, tokenId);

        parcels[tokenId] = Parcel({
            lrNumber: lrNumber,
            county: county,
            coordinatesHash: coordinatesHash,
            ownerIdHash: ownerIdHash,
            status: ParcelStatus.Active,
            registeredAt: block.timestamp
        });

        emit ParcelRegistered(tokenId, lrNumber, county, owner);
        return tokenId;
    }

    function safeTransferParcel(uint256 tokenId, address to) external onlyActive(tokenId) {
        require(to != address(0), "Invalid recipient");
        require(ownerOf(tokenId) == msg.sender, "Not parcel owner");
        _safeTransfer(msg.sender, to, tokenId, "");
        emit ParcelTransferred(tokenId, msg.sender, to);
    }

    function setParcelStatus(uint256 tokenId, ParcelStatus newStatus, string calldata reason)
        external onlyRegistrar
    {
        require(_exists(tokenId), "Parcel does not exist");
        parcels[tokenId].status = newStatus;
        emit ParcelStatusChanged(tokenId, newStatus, reason);
    }

    function addParcelDocument(uint256 tokenId, string calldata docHash) external onlyRegistrar {
        require(_exists(tokenId), "Parcel does not exist");
        parcelDocuments[tokenId].push(docHash);
        emit ParcelDocumentAdded(tokenId, docHash);
    }

    function updateParcelMetadata(uint256 tokenId, string calldata newCoordinatesHash, string calldata newOwnerIdHash)
        external onlyRegistrar
    {
        require(_exists(tokenId), "Parcel does not exist");
        Parcel storage p = parcels[tokenId];
        if (bytes(newCoordinatesHash).length > 0) p.coordinatesHash = newCoordinatesHash;
        if (bytes(newOwnerIdHash).length > 0) p.ownerIdHash = newOwnerIdHash;
    }

    function getParcel(uint256 tokenId)
        external view returns (
            string memory, string memory, string memory, ParcelStatus, uint256, address
        )
    {
        require(_exists(tokenId), "Parcel does not exist");
        Parcel memory p = parcels[tokenId];
        return (p.lrNumber, p.county, p.coordinatesHash, p.status, p.registeredAt, ownerOf(tokenId));
    }

    function getParcelDocuments(uint256 tokenId) external view returns (string[] memory) {
        require(_exists(tokenId), "Parcel does not exist");
        return parcelDocuments[tokenId];
    }

    function addRegistrar(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(REGISTRAR_ROLE, account);
    }

    function removeRegistrar(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _revokeRole(REGISTRAR_ROLE, account);
    }
}
