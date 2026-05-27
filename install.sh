#/usr/bin/env bash

set -env

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0;0m' # No Color

echo -e "${CYAN}🚀 Initializing Todo CLI environment installation loop...${NC}"

# 1. Dependency Validation Checks
if ! command -v nim &>/dev/null; then
  echo -e "${RED}✗ Error: The Nim compiler was not found on your system.${NC}"
  echo -e "Please install it using your system package manager (e.g., sudo pacman -S nim)."
  exit 1
fi

# 2. Local Destination Verification
BIN_DIR="$HOME/.nimble/bin"
mkdir -p "$BIN_DIR"

# 3. Production Native Binary Compilation Run
echo -e "${CYAN}📦 Compiling optimized production executable from source...${NC}"
if nim c -d:release -o:"$BIN_DIR/todo" todo.nim; then
  echo -e "${GREEN}✔ Compilation successful! Binary placed inside: $BIN_DIR/todo${NC}"
else
  echo -e "${RED}✗ Error: Code compilation phase crashed unexpectedly.${NC}"
  exit 1
fi

# 4. Global PATH Verification Assistance Guide
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
  echo -e "\n${RED}⚠️  Notice: $BIN_DIR is missing from your system \$PATH variable.${NC}"
  echo -e "Add this instruction snippet into your active shell configuration profile:"
  echo -e "${CYAN}   Fish: fish_add_path \"\$HOME/.nimble/bin\"${NC}"
  echo -e "${CYAN}   Zsh/Bash: export PATH=\"\$HOME/.nimble/bin:\$PATH\"${NC}"
else
  echo -e "\n${GREEN}🎉 Installation completed! You can now use the 'todo' command instantly.${NC}"
fi
