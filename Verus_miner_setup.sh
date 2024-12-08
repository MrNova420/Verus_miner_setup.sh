#!/data/data/com.termux/files/usr/bin/bash
# Verus Miner Setup Script for Termux
# This script automates the installation and setup of a VerusCoin miner on Termux.
# Created for use in a GitHub repository.

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Step 1: Update and install dependencies
echo -e "${CYAN}[1/5] Updating and upgrading Termux packages...${NC}"
pkg update -y && pkg upgrade -y

echo -e "${CYAN}[2/5] Installing required packages...${NC}"
pkg install -y git build-essential cmake wget

# Step 2: Clone and build the VerusCoin miner
MINER_REPO="https://github.com/veruscoin/veruscoin"
echo -e "${CYAN}[3/5] Cloning VerusCoin miner repository...${NC}"
if [ -d "veruscoin" ]; then
  echo -e "${RED}Repository already exists. Pulling latest changes...${NC}"
  cd veruscoin && git pull && cd ..
else
  git clone $MINER_REPO
fi

echo -e "${CYAN}[4/5] Building the miner...${NC}"
cd veruscoin
mkdir -p build && cd build
cmake .. -DARCH=arm64
make -j$(nproc)

# Step 3: Configure and run the miner
MINER_EXEC="./ccminer"
if [ ! -f "$MINER_EXEC" ]; then
  echo -e "${RED}Miner executable not found. Build might have failed.${NC}"
  exit 1
fi

# Get pool and wallet information
read -p "Enter your mining pool address: " POOL_ADDRESS
read -p "Enter your wallet address: " WALLET_ADDRESS
read -p "Enter your worker name (optional): " WORKER_NAME
WORKER_NAME=${WORKER_NAME:-TermuxWorker}

echo -e "${CYAN}[5/5] Starting the miner...${NC}"
$MINER_EXEC -a verushash -o $POOL_ADDRESS -u $WALLET_ADDRESS.$WORKER_NAME -t $(nproc)

# End message
echo -e "${GREEN}VerusCoin miner setup complete! Happy mining.${NC}"
