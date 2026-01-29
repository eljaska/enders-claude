#!/bin/bash
set -e

# Flag file to track if dependencies are installed
FLAG_FILE="$HOME/.claude/enders-claude-deps-installed"

# Only run on first launch (idempotent check)
if [ -f "$FLAG_FILE" ]; then
  exit 0
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REQUIREMENTS_FILE="$SCRIPT_DIR/plugin-requirements.txt"

# Check if requirements file exists
if [ ! -f "$REQUIREMENTS_FILE" ]; then
  echo "⚠️  Warning: plugin-requirements.txt not found at $REQUIREMENTS_FILE"
  exit 0
fi

echo "🔧 Installing required plugins for Ender's Claude configuration..."

# Read and install plugins from requirements file
while IFS= read -r line || [ -n "$line" ]; do
  # Skip empty lines and comments
  if [[ -z "$line" ]] || [[ "$line" =~ ^[[:space:]]*# ]]; then
    continue
  fi

  # Trim whitespace
  plugin=$(echo "$line" | xargs)

  # Install plugin (idempotent - won't fail if already installed)
  echo "  📦 Installing $plugin..."
  claude plugin install "$plugin" --scope user 2>&1 | grep -v "Already installed" || true
done < "$REQUIREMENTS_FILE"

# Mark as installed
mkdir -p "$HOME/.claude"
touch "$FLAG_FILE"

echo ""
echo "✅ All plugin dependencies installed successfully!"
echo ""
echo "⚠️  IMPORTANT: Please restart Claude Code to activate new plugins."
echo "   Exit this session and run 'claude' again."
echo ""

exit 0
