// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ChainProof {

    address public admin;

    struct Credential {
        string title;
        uint level;
        uint issuedAt;
    }

    mapping(address => Credential[]) private credentials;
    mapping(address => mapping(string => bool)) private credentialExists;

    event CredentialIssued(address indexed member, string title, uint level, uint issuedAt);

    uint public constant ACCESS_THRESHOLD = 50;

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "ChainProof: caller is not the admin");
        _;
    }

    function issueCredential(address member, string calldata title, uint level) public onlyAdmin {
        require(level >= 1 && level <= 3, "ChainProof: level must be 1, 2, or 3");
        require(member != address(0), "ChainProof: cannot issue to the zero address");

        // DUPLICATE DECISION: Reject. A title represents a unique achievement.
        // Allowing repeats would let admins inflate scores fraudulently.
        require(!credentialExists[member][title], "ChainProof: credential already issued to this address");

        credentials[member].push(Credential({
            title: title,
            level: level,
            issuedAt: block.timestamp
        }));

        credentialExists[member][title] = true;

        emit CredentialIssued(member, title, level, block.timestamp);
    }

    function getCredentials(address member) public view returns (Credential[] memory) {
        return credentials[member];
    }

    // TRUST SCORE FORMULA: Σ(level² × 10) + (count × 5)
    // Quadratic level term strongly rewards depth.
    // Linear count bonus rewards sustained, distinct contributions.
    // Non-gameable via duplicates because issueCredential rejects them.
    function getTrustScore(address member) public view returns (uint) {
        Credential[] memory memberCreds = credentials[member];
        uint count = memberCreds.length;
        uint score = 0;

        for (uint i = 0; i < count; i++) {
            uint lvl = memberCreds[i].level;
            score += lvl * lvl * 10;
        }

        score += count * 5;
        return score;
    }

    // NON-TRANSFERABLE: Credentials are stored by address with no transfer
    // mechanism. A credential is permanently bound to the wallet it was issued to.
    function accessGranted() public view returns (bool) {
        uint score = getTrustScore(msg.sender);
        require(score >= ACCESS_THRESHOLD, "ChainProof: trust score below required threshold");
        return true;
    }
}
