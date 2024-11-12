const fs = require("fs");
const path = require("path");

// Define directories
const outDir = "./out";
const targetDir = "./ityfuzz_build";

// Ensure the target directory exists
if (!fs.existsSync(targetDir)) {
  fs.mkdirSync(targetDir, { recursive: true });
}

// Function to extract ABI and BIN files
function extractAbiAndBin() {
  fs.readdirSync(outDir).forEach((file) => {
    const contractPath = path.join(outDir, file);

    // Check if it's a directory (e.g., "ContractName.sol")
    if (fs.statSync(contractPath).isDirectory()) {
      fs.readdirSync(contractPath).forEach((contractFile) => {
        if (contractFile.endsWith(".json")) {
          const contractDataPath = path.join(contractPath, contractFile);
          const contractData = JSON.parse(
            fs.readFileSync(contractDataPath, "utf-8")
          );

          const contractName = contractFile.split(".")[0];

          // Save ABI
          const abiPath = path.join(targetDir, `${contractName}.abi`);
          fs.writeFileSync(abiPath, JSON.stringify(contractData.abi, null, 2));

          // Save BIN (Bytecode) - ensure it's a string and remove "0x" prefix if present
          const bytecode = (
            typeof contractData.bytecode === "object"
              ? contractData.bytecode.object || ""
              : contractData.bytecode
          ).replace(/^0x/, "");

          const binPath = path.join(targetDir, `${contractName}.bin`);
          fs.writeFileSync(binPath, bytecode);

          console.log(`Extracted ${contractName}.abi and ${contractName}.bin`);
        }
      });
    }
  });
}

// Run the extraction
extractAbiAndBin();
