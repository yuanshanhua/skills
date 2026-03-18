#!/bin/bash
# Setup TinyTeX for LaTeX compilation on Linux (x86_64)
set -e

TINYTEX_DIR="$HOME/.TinyTeX"
BIN_DIR="$TINYTEX_DIR/bin/x86_64-linux"

# Check if already installed
if [ -d "$TINYTEX_DIR/bin" ] && [ -x "$BIN_DIR/xelatex" ]; then
    echo "TinyTeX already installed at $TINYTEX_DIR"
    echo "BIN_DIR:$BIN_DIR"
    exit 0
fi

echo "Installing TinyTeX for Linux..."

TMPDIR=$(mktemp -d)
cd "$TMPDIR"

# Download TinyTeX for Linux
TINYTEX_URL="https://github.com/rstudio/tinytex-releases/releases/download/v2025.02/TinyTeX-v2025.02-x86_64-linux.tar.gz"
echo "Downloading TinyTeX from $TINYTEX_URL ..."
curl -L --retry 3 "$TINYTEX_URL" -o tinytex.tar.gz
tar -xzf tinytex.tar.gz -C "$HOME"

# Verify
if [ -x "$BIN_DIR/xelatex" ]; then
    echo "TinyTeX installed successfully"
    echo "BIN_DIR:$BIN_DIR"
else
    # Try locating xelatex
    FOUND=$(find "$TINYTEX_DIR/bin" -name xelatex 2>/dev/null | head -1)
    if [ -n "$FOUND" ]; then
        BIN_DIR=$(dirname "$FOUND")
        echo "TinyTeX installed at: $BIN_DIR"
        echo "BIN_DIR:$BIN_DIR"
    else
        echo "ERROR: xelatex not found after installation" >&2
        ls "$TINYTEX_DIR/bin/" 2>/dev/null
        exit 1
    fi
fi

rm -rf "$TMPDIR"
