// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test} from "forge-std/test.sol";
import {ZkMinimalAccount} from "../../src/zksycn/ZkMinimalAccount.sol";
import {Transaction} from
    "lib/foundry-era-contracts/src/system-contracts/contracts/libraries/MemoryTransactionHelper.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract ZkMinimalAccountTest is Test {
    ZkMinimalAccount zkMinimalAccount;
    ERC20Mock usdc;

    uint256 public AMOUNT = 1;
    bytes32 public constant EMPTY_BYTES32 = bytes32(0);

    function setUp() public {
        zkMinimalAccount = new ZkMinimalAccount();
        usdc = new ERC20Mock();
    }

    function testZkOwnerCanExecuteCommands() public {
        //Arrange
        address dec = address(usdc);
        uint256 val = 0;
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(zkMinimalAccount), AMOUNT);
        Transaction memory transaction =
            _createUnsignedTransaction(address(zkMinimalAccount), 133, dec, val, functionData);
        //Act
        vm.prank(zkMinimalAccount.owner());
        ZkMinimalAccount(zkMinimalAccount).executeTransaction(EMPTY_BYTES32, EMPTY_BYTES32, transaction);
        //Assert
        assertEq(usdc.balanceOf(address(zkMinimalAccount)), AMOUNT);
    }

    /*//////////////////////////////////////////////////////////////
                                HELPERS
    //////////////////////////////////////////////////////////////*/

    function _createUnsignedTransaction(
        address from,
        uint8 transactionType,
        address to,
        uint256 value,
        bytes memory data
    ) internal view returns (Transaction memory) {
        uint256 nonce = vm.getNonce(address(zkMinimalAccount));
        bytes32[] memory factoryDeps = new bytes32[](0);
        return Transaction({
            txType: transactionType, // type 113 (0x71).
            from: uint256(uint160(from)),
            to: uint256(uint160(to)),
            gasLimit: 16777216,
            gasPerPubdataByteLimit: 16777216,
            maxFeePerGas: 16777216,
            maxPriorityFeePerGas: 16777216,
            paymaster: 0,
            nonce: nonce,
            value: value,
            reserved: [uint256(0), uint256(0), uint256(0), uint256(0)],
            data: data,
            signature: hex"",
            factoryDeps: factoryDeps,
            paymasterInput: hex"",
            reservedDynamic: hex""
        });
    }
}
