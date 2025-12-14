cat > hardhat.config.js << 'EOF'
require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-verify");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000
      }
    }
  },
  
  networks: {
    hardhat: {
      chainId: 31337,
      allowUnlimitedContractSize: true
    },
    
    bscTestnet: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
      chainId: 97,
      gasPrice: 20000000000,
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : []
    },
    
    bsc: {
      url: "https://bsc-dataseed.binance.org/",
      chainId: 56,
      gasPrice: 5000000000,
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : []
    }
  },
  
  etherscan: {
    apiKey: {
      bsc: process.env.BSCSCAN_API_KEY || "",
      bscTestnet: process.env.BSCSCAN_API_KEY || ""
    }
  },
  
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./hardhat-cache",
    artifacts: "./artifacts"
  },
  
  mocha: {
    timeout: 40000
  }
};
EOF
