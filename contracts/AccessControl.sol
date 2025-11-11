// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract AccessControl {
    struct RoleData {
        mapping(address => bool) members;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleGranted(bytes32 indexed role, address indexed account);
    event RoleRevoked(bytes32 indexed role, address indexed account);

    modifier onlyRole(bytes32 role) {
        require(hasRole(role, msg.sender), "Access denied");
        _;
    }

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members[account];
    }

    function _grantRole(bytes32 role, address account) internal {
        _roles[role].members[account] = true;
        emit RoleGranted(role, account);
    }

    function _revokeRole(bytes32 role, address account) internal {
        _roles[role].members[account] = false;
        emit RoleRevoked(role, account);
    }
}
