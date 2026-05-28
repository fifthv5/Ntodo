#!/usr/bin/env bash
set -e

# Change directory directly to the script folder to guarantee file tracking works
cd "$(dirname "$0")"

printf "🚀 Initializing Todo CLI environment installation loop...\n"

# 1. Dependency Validation Checks
if ! command -v nim &>/dev/null; then
  printf "✗ Error: The Nim compiler was not found on your system.\n"
  printf "Please install it using: sudo pacman -S nim\n"
  exit 1
fi

# 2. Local Destination Verification
BIN_DIR="$HOME/.nimble/bin"
mkdir -p "$BIN_DIR"

# 3. Production Native Binary Compilation Run
printf "📦 Compiling optimized production executable from source...\n"
if nim c -d:release -o:"$BIN_DIR/todo" todo.nim; then
  printf "✔ Compilation successful! Binary placed inside: %s/todo\n" "$BIN_DIR"
else
  printf "✗ Error: Code compilation phase crashed unexpectedly.\n"
  exit 1
fi

# 4. Global PATH Verification Assistance Guide
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
  printf "\n⚠️  Notice: %s is missing from your system \$PATH variable.\n" "$BIN_DIR"
  printf "Add this instruction snippet into your active shell configuration profile:\n"
  printf "   Fish: fish_add_path \"\$HOME/.nimble/bin\"\n"
  printf "   Zsh/Bash: export PATH=\"\$HOME/.nimble/bin:\$PATH\"\n"
else
  printf "\n🎉 Installation completed! You can now use the 'todo' command instantly.\n"
fi
