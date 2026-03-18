#!/bin/bash
# Compile LaTeX document using XeLaTeX (Linux version)
set -e

TEX_FILE="$1"
OUTPUT_NAME="${2:-output}"

if [ -z "$TEX_FILE" ]; then
    echo "Usage: compile_latex_linux.sh <main_tex_file> [output_name]"
    exit 1
fi

export PATH="$HOME/.TinyTeX/bin/x86_64-linux:$PATH"

if ! command -v xelatex &> /dev/null; then
    echo "ERROR: xelatex not found."
    exit 1
fi

WORKDIR=$(dirname "$(realpath "$TEX_FILE")")
cd "$WORKDIR"
BASENAME=$(basename "$TEX_FILE" .tex)

echo "Compiling $TEX_FILE in $WORKDIR ..."

xelatex -interaction=nonstopmode "$BASENAME" 2>&1 | tail -5

# bibtex or biber
if grep -q '\\bibliography{' "${BASENAME}.tex" 2>/dev/null; then
    echo "Running bibtex..."
    bibtex "$BASENAME" 2>&1 | tail -5 || true
elif [ -f "${BASENAME}.bcf" ]; then
    echo "Running biber..."
    biber "$BASENAME" 2>&1 | tail -5 || true
fi

xelatex -interaction=nonstopmode "$BASENAME" 2>&1 | tail -5
xelatex -interaction=nonstopmode "$BASENAME" 2>&1 | tail -5

if [ -f "${BASENAME}.pdf" ]; then
    mv "${BASENAME}.pdf" "${OUTPUT_NAME}.pdf"
    echo "PDF generated: $(realpath "${OUTPUT_NAME}.pdf")"
    echo "SIZE:$(stat -c%s "${OUTPUT_NAME}.pdf" 2>/dev/null || echo unknown)"
else
    echo "ERROR: PDF generation failed"
    exit 1
fi
