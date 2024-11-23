## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

# Minimal Account Abstraction

A minimal implementation of ERC-4337 Account Abstraction for Ethereum and zkSync, built with Foundry. This project demonstrates how to create smart contract wallets with advanced features like batched transactions and custom validation logic.

## Features

- 🔐 Minimal smart contract wallet implementation
- ⚡ Support for both Ethereum and zkSync networks
- 🔄 Bundled transactions support
- ✅ Custom signature validation
- 🛠️ Built with Foundry for robust testing and deployment

## Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Solidity ^0.8.25
- Git

## Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/minimal-account-abstraction.git
cd minimal-account-abstraction

# Install dependencies
forge install

# Build the project
forge build
```

## Project Structure

```
minimal-account-abstraction/
├── src/
│   ├── ethereum/         # Ethereum-specific implementations
│   └── zksync/          # zkSync-specific implementations
├── script/              # Deployment and interaction scripts
├── test/               # Test files
└── foundry.toml        # Foundry configuration
```

## Core Components

### MinimalAccount Contract

The main smart contract wallet implementation:

```solidity
// src/ethereum/MinimalAccount.sol
contract MinimalAccount is IAccount, Ownable {
    IEntryPoint private immutable entryPoint;
    
    constructor(address _entryPoint) Ownable(msg.sender) {
        entryPoint = IEntryPoint(_entryPoint);
    }
    
    // Execute a transaction
    function execute(
        address dest,
        uint256 value,
        bytes calldata func
    ) external requireFromEntryPointOrOwner {
        (bool success, bytes memory result) = dest.call{value: value}(func);
        if (!success) {
            revert MinimalAccount__CallFailed(result);
        }
    }
    
    // Validate user operation
    function validateUserOp(
        PackedUserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 missingAccountFunds
    ) external requireFromEntryPoint returns (uint256 validationData) {
        validationData = _validateUserOp(userOp, userOpHash);
        _payPreFunds(missingAccountFunds);
    }
}
```

## Usage

### Deployment

Deploy your smart contract wallet using the provided script:

```bash
forge script script/DeployMinimal.s.sol --rpc-url <your-rpc-url> --broadcast
```

### Running Tests

```bash
# Run all tests
forge test

# Run specific test file
forge test --match-path test/MinimalAccount.t.sol -vvv

# Run with gas reporting
forge test --gas-report
```

### Example: Creating and Using a Wallet

1. Deploy the EntryPoint contract (if not already deployed on your network)
2. Deploy your MinimalAccount contract
3. Fund your account with ETH for gas
4. Create and send a UserOperation:

```solidity
// Example UserOperation creation
PackedUserOperation memory userOp = PackedUserOperation({
    sender: address(account),
    nonce: 0,
    initCode: "",
    callData: abi.encodeCall(
        MinimalAccount.execute,
        (recipient, value, "")
    ),
    callGasLimit: 100000,
    verificationGasLimit: 100000,
    preVerificationGas: 21000,
    maxFeePerGas: block.basefee,
    maxPriorityFeePerGas: 1 gwei,
    paymasterAndData: "",
    signature: ""
});

// Sign the UserOperation
bytes32 userOpHash = entryPoint.getUserOpHash(userOp);
bytes memory signature = signUserOp(userOpHash, privateKey);
userOp.signature = signature;

// Send the UserOperation
entryPoint.handleOps([userOp], beneficiary);
```

## Gas Optimization

The contract is designed to be gas-efficient:
- Uses packed user operations
- Minimal storage usage
- Optimized validation logic

## Security Considerations

- The contract implements access control through the `requireFromEntryPoint` and `requireFromEntryPointOrOwner` modifiers
- Signature validation is performed using OpenZeppelin's ECDSA library
- All external calls are checked for success

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [ERC-4337: Account Abstraction](https://eips.ethereum.org/EIPS/eip-4337)
- [Foundry](https://book.getfoundry.sh/)
- [OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts)
