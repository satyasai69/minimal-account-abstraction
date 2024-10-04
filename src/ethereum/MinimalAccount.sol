// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {IAccount} from "lib/account-abstraction/contracts/interfaces/IAccount.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract MinimalAccount is IAccount, Ownable {
    constructor() Ownable(msg.sender) {}

    function validateUserOp(PackedUserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
        external
        returns (uint256 validationData)
    {
        validationData = _validateUserOp(userOp, userOpHash, missingAccountFunds);
    }

    function _validateUserOp(PackedUserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
        internal
        returns (uint256 validationData)
    {}
}
