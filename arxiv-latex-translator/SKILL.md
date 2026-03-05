---
name: arxiv-latex-translator
description: |
  Translate arXiv LaTeX papers to Chinese (or other languages) while preserving 
  formatting, and compile to PDF. Handles arXiv URL conversion, TinyTeX setup, 
  and maintains clean workspace separation.
  
  Use when user wants to:
  - Download and translate arXiv paper LaTeX source
  - Convert arXiv papers to Chinese PDF
  - Translate academic papers with LaTeX formatting preserved
  - Process arXiv abstract/PDF URLs to get source
  
  IMPORTANT: Only works with papers that have public LaTeX source. 
  Does NOT parse/translate PDF files directly.
---

# arXiv LaTeX Paper Translator

Translate arXiv LaTeX papers to Chinese while preserving all formatting, citations, and structure.

## Overview

This skill provides a complete workflow for:
1. Converting various arXiv URLs to LaTeX source download links
2. Downloading and extracting source files
3. Translating content while preserving LaTeX commands
4. Compiling translated document to PDF using TinyTeX

## Prerequisites

- Internet connection for downloading arXiv source
- Sufficient disk space (~100MB for TinyTeX + paper files)

## Workflow

### Step 1: Parse arXiv URL

Convert user-provided URL to LaTeX source URL:

**Supported URL formats (auto-convert to source):**
- Abstract page: `https://arxiv.org/abs/XXXX.XXXXX`
- PDF direct link: `https://arxiv.org/pdf/XXXX.XXXXX.pdf`
- Source listing: `https://arxiv.org/src/XXXX.XXXXX`
- Already source: `https://arxiv.org/e-print/XXXX.XXXXX`

**Extract arXiv ID pattern:** `\d{4}\.\d{4,}` (4 digits, dot, 4+ digits)

**Conversion rule:**
```
Input URL  →  Extract ID  →  Source URL
https://arxiv.org/abs/2602.02276  →  2602.02276  →  https://arxiv.org/e-print/2602.02276
https://arxiv.org/pdf/2602.02276.pdf  →  2602.02276  →  https://arxiv.org/e-print/2602.02276
```

Use `scripts/arxiv_download.py` to handle URL conversion and download:
```bash
python3 scripts/arxiv_download.py <arxiv_url> <workspace_dir>
```

**Error handling:**
- If download returns 404 → Paper has NO public LaTeX source
- STOP and report: "This paper does not have public LaTeX source available. Cannot proceed with translation."
- DO NOT attempt to download PDF and parse it

### Step 2: Setup TinyTeX

Install TinyTeX if not present:
```bash
bash scripts/setup_tinytex.sh
```

Verify: `xelatex --version` should work after setup.

### Step 3: Create Translation Workspace

Create clean workspace structure:
```
workspace/
├── source/           # Original arXiv source (READ-ONLY)
├── translated/       # Translated LaTeX files
└── output/           # Compiled PDF
```

**Important:** Never modify files in `source/`. Always copy to `translated/` before editing.

### Step 4: Translate Content

For each `.tex` file in source:

1. Copy file to `translated/`
2. Translate natural language content only
3. **Preserve ALL LaTeX commands:**
   - `\section`, `\subsection`, `\paragraph`
   - `\citep`, `\citet`, `\ref`, `\label`
   - `\begin{environment}` / `\end{environment}`
   - Math formulas `$...$`, `$$...$$`, `\[...\]`
   - `\textbf`, `\textit`, `\emph`
   - Tables, figures, algorithms (translate captions only)

**Translation guidelines:**
- Keep academic/professional tone
- Translate figure/table captions
- Keep citations and references in original form
- Do not translate code listings, file paths, URLs

### Step 5: Update Main Document

Modify main `.tex` file for Chinese support:

Replace:
```latex
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{CJKutf8}
```

With:
```latex
\usepackage{fontspec}
\usepackage{xeCJK}
\setCJKmainfont{Songti SC}      % Or other available Chinese font
\setCJKsansfont{Heiti SC}
\setCJKmonofont{Hiragino Sans GB W3}
```

Update title/author if needed.

### Step 6: Compile PDF

Use XeLaTeX (required for Chinese):
```bash
export PATH="$HOME/.TinyTeX/bin/universal-darwin:$PATH"

cd translated

# FIRST run: Generate aux files
xelatex -interaction=nonstopmode main.tex

# SECOND: Run bibtex to resolve citations (CRITICAL for papers using \bibliography{})
bibtex main

# THIRD and FOURTH: Re-run xelatex to resolve cross-references
xelatex -interaction=nonstopmode main.tex
xelatex -interaction=nonstopmode main.tex
```

**IMPORTANT**: Papers using `\bibliography{ref}` + `\bibliographystyle{tmlr}` require **bibtex**, not biber. If main.bcf exists, use biber instead:
```bash
biber main
```

Use `scripts/compile_latex.sh` helper:
```bash
bash scripts/compile_latex.sh translated/main.tex output_name
```

## File Organization

**Working directory structure:**
```
arxiv_<id>/
├── source/              # Original arXiv files (extracted tar.gz)
│   ├── main.tex
│   ├── sections/
│   └── figures/
├── translated/          # Your translation work
│   ├── main.tex        # Modified for Chinese
│   ├── sections/       # Translated sections
│   └── ...             # Other translated files
└── output/             # Final PDF
    └── paper_chinese.pdf
```

## Common Issues

### Missing Chinese Fonts

If compilation fails with font errors, check available fonts:
```bash
fc-list :lang=zh
```

Common macOS Chinese fonts:
- `Songti SC` (宋体)
- `Heiti SC` (黑体)
- `Hiragino Sans GB` (冬青黑体)

### Missing LaTeX Packages

Install with tlmgr:
```bash
tlmgr install <package-name>
```

Common packages needed:
- `ctex` (Chinese support - if not using xeCJK directly)
- `xecjk` (XeLaTeX Chinese)
- `fontspec` (font handling)

### Bibliography Issues (Citations showing as ???)

**Symptoms**: Citations appear as `[???]` or `[1, 2]` instead of proper citation numbers.

**Root Cause**: Missing bibtex/biber compilation step. Most arXiv papers use `\bibliography{}` which requires the complete compilation chain.

**Solution**:
1. Check if paper uses `\bibliography{}` (bibtex) or biblatex (biber):
   ```bash
   grep -n "bibliography\|biblatex" main.tex
   ```

2. For traditional `\bibliography{ref}` (most common):
   ```bash
   xelatex main.tex
   bibtex main          # <-- CRITICAL STEP
   xelatex main.tex
   xelatex main.tex
   ```

3. For biblatex (rare):
   ```bash
   tlmgr install biber
   xelatex main.tex
   biber main
   xelatex main.tex
   xelatex main.tex
   ```

### Page Count Mismatch

**Symptoms**: Translated PDF has significantly fewer pages than original (e.g., 29 vs 67 pages).

**Root Cause**: References section not generated due to missing bibtex step.

**Verification**:
- Check if references section exists at end of PDF
- Check if citations display as numbers `[1]` vs question marks `[???]`

**Solution**: Run complete compilation chain including bibtex (see Bibliography Issues above).

## Resources

- `scripts/arxiv_download.py` - URL conversion and download
- `scripts/setup_tinytex.sh` - TinyTeX installation
- `scripts/compile_latex.sh` - LaTeX compilation helper
- `references/latex-translation-guide.md` - Detailed translation patterns

## Output

Final deliverable:
- Translated PDF file (verify page count roughly matches original)
- Summary of translated sections
- Note if any sections were skipped (e.g., references)

**Quality Checklist**:
- [ ] Citations display as numbers `[1], [2]` not `[???]`
- [ ] References section generated at end
- [ ] Page count reasonable (±10% of original, accounting for Chinese density)
- [ ] No "undefined reference" warnings in compilation log
