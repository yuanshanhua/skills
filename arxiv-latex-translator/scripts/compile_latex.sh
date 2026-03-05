#!/bin/bash
# Compile LaTeX document using XeLaTeX
# Usage: compile_latex.sh <main_tex_file> [output_name]

set -e

TEX_FILE="$1"
OUTPUT_NAME="${2:-output}"

if [ -z "$TEX_FILE" ]; then
    echo "Usage: compile_latex.sh <main_tex_file> [output_name]"
    exit 1
fi

# Setup PATH for TinyTeX
export PATH="$HOME/.TinyTeX/bin/universal-darwin:$PATH"

# Verify xelatex exists
if ! command -v xelatex &> /dev/null; then
    echo "ERROR: xelatex not found. Please run setup_tinytex.sh first."
    exit 1
fi

# Get directory of tex file
WORKDIR=$(dirname "$TEX_FILE")
cd "$WORKDIR"

BASENAME=$(basename "$TEX_FILE" .tex)

echo "Compiling $TEX_FILE..."

# First run
xelatex -interaction=nonstopmode "$BASENAME" 2>&1 | tail -20

# Run biber if needed
if [ -f "${BASENAME}.bcf" ]; then
    if command -v biber &> /dev/null; then
        echo "Running biber..."
        biber "$BASENAME" 2>&1 || echo "Biber warning (non-fatal)"
    fi
fi

# Second run for references
xelatex -interaction=nonstopmode "$BASENAME" 2>&1 | tail -10

# Third run to finalize
xelatex -interaction=nonstopmode "$BASENAME" 2>&1 | tail -10

# Check output
if [ -f "${BASENAME}.pdf" ]; then
    OUTPUT_PDF="${OUTPUT_NAME}.pdf"
    mv "${BASENAME}.pdf" "$OUTPUT_PDF"
    echo "PDF generated: $(realpath "$OUTPUT_PDF")"
    echo "SIZE:$(stat -f%z "$OUTPUT_PDF" 2>/dev/null || stat -c%s "$OUTPUT_PDF" 2>/dev/null || echo "unknown")"
else
    echo "ERROR: PDF generation failed"
    exit 1
fi
