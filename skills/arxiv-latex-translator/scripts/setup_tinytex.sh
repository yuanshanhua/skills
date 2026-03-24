#!/bin/bash
# Setup TinyTeX for LaTeX compilation
# This script installs TinyTeX if not already present

set -e

TINYTeX_DIR="$HOME/.TinyTeX"
BIN_DIR="$TINYTeX_DIR/bin/universal-darwin"

# Check if already installed
if [ -d "$TINYTeX_DIR/bin" ] && [ -x "$BIN_DIR/xelatex" ]; then
    echo "TinyTeX already installed at $TINYTeX_DIR"
    echo "BIN_DIR:$BIN_DIR"
    exit 0
fi

echo "Installing TinyTeX..."

# Create temp directory
TMPDIR=$(mktemp -d)
cd "$TMPDIR"

# Download TinyTeX
TINYTEX_URL="https://github.com/rstudio/tinytex-releases/releases/download/v2025.02/TinyTeX-v2025.02.tgz"
curl -sL "$TINYTEX_URL" | tar -xzf - -C "$HOME" --strip-components=1

# Verify installation
if [ -x "$BIN_DIR/xelatex" ]; then
    echo "TinyTeX installed successfully"
    echo "BIN_DIR:$BIN_DIR"
else
    echo "ERROR: TinyTeX installation failed" >&2
    exit 1
fi

# Cleanup
rm -rf "$TMPDIR"
