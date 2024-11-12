// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {EntryPoint} from "account-abstraction/core/EntryPoint.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address entryPoint;
        address usdc;
        address account;
    }

    uint256 constant ETH_SEPOLIA_CHAINID = 11155111;
    uint256 constant ZKSYNC_MAINNET_CHAINID = 324;
    uint256 constant ZKSYNC_SEPOLIA_CHAINID = 300;
    uint256 constant LOCAL_CHAINID = 31337;
    address constant BURNER_WALLET = 0x643315C9Be056cDEA171F4e7b2222a4ddaB9F88D;
    address constant ANVIL_DEFAULT_ACCOUNT = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    NetworkConfig public localnetworkConfig;

    mapping(uint256 chainId => NetworkConfig) public networkConfig;

    constructor() {
        networkConfig[ETH_SEPOLIA_CHAINID] = getSepoliaConfig();
        networkConfig[LOCAL_CHAINID] = getOrCreateAnvilConfig();
        networkConfig[ZKSYNC_MAINNET_CHAINID] = getZksyncMainnetConfig();
        networkConfig[ZKSYNC_SEPOLIA_CHAINID] = getZksyncSepoliaConfig();
    }

    function getConfig() public view returns (NetworkConfig memory) {
        return getConfigByChainId(block.chainid);
    }

    function getConfigByChainId(uint256 chainId) public view returns (NetworkConfig memory) {
        return networkConfig[chainId];
    }

    function getZksyncMainnetConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            entryPoint: address(0), // supports native AA, so no entry point needed
            usdc: 0x1d17CBcF0D6D143135aE902365D2E5e2A16538D4,
            account: BURNER_WALLET
        });
    }

    function getZksyncSepoliaConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            entryPoint: address(0), // There is no entrypoint in zkSync!
            usdc: 0x5A7d6b2F92C77FAD6CCaBd7EE0624E64907Eaf3E, // not the real USDC on zksync sepolia
            account: BURNER_WALLET
        });
    }

    function getSepoliaConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            entryPoint: 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789,
            usdc: 0x53844F9577C2334e541Aec7Df7174ECe5dF1fCf0, // Update with your own mock token
            account: BURNER_WALLET
        });
    }

    function getOrCreateAnvilConfig() public returns (NetworkConfig memory) {
        if (localnetworkConfig.entryPoint != address(0)) {
            return localnetworkConfig;
        }

        // deploy a  mork entryPoint contract
        vm.startBroadcast(ANVIL_DEFAULT_ACCOUNT);
        EntryPoint entryPoint = new EntryPoint();
        ERC20Mock usdc = new ERC20Mock();
        vm.stopBroadcast();

        localnetworkConfig =
            NetworkConfig({entryPoint: address(entryPoint), usdc: address(usdc), account: ANVIL_DEFAULT_ACCOUNT});

        return localnetworkConfig;
    }
}
