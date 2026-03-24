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

#### macOS

Install TinyTeX if not present:
```bash
bash scripts/setup_tinytex.sh
```

Verify: `xelatex --version` should work after setup.

**macOS binary path:** `$HOME/.TinyTeX/bin/universal-darwin`

#### Linux (TencentOS / CentOS / RHEL)

Install TinyTeX manually (download from GitHub releases to avoid network issues):

```bash
# Download TinyTeX-1 tarball
wget https://github.com/rstudio/tinytex-releases/releases/download/v2026.03/TinyTeX-1-v2026.03.02.tar.gz

# Extract to home directory
tar -xzf TinyTeX-1-v2026.03.02.tar.gz -C ~

# Add to PATH
export PATH="$HOME/.TinyTeX/bin/x86_64-linux:$PATH"

# Switch to a fast CTAN mirror (Tsinghua recommended for China)
tlmgr option repository https://mirrors.tuna.tsinghua.edu.cn/CTAN/systems/texlive/tlnet

# Install required packages
tlmgr install xecjk fontspec ctex

# Install Chinese fonts (Noto CJK)
yum install -y google-noto-cjk-fonts    # RHEL/CentOS/TencentOS
# OR: apt install -y fonts-noto-cjk      # Debian/Ubuntu
```

**Linux binary path:** `$HOME/.TinyTeX/bin/x86_64-linux`

Use `scripts/compile_latex_linux.sh` for Linux compilation.

### Step 3: Create Translation Workspace

Create clean workspace structure:
```
workspace/
├── source/           # Original arXiv source (READ-ONLY)
├── translated/       # Translated LaTeX files
└── output/           # Compiled PDF
```

**Important:** Never modify files in `source/`. Always copy to `translated/` before editing.

### Step 4: Assess Paper Size & Choose Strategy

Before translating, check total `.tex` file size to decide the right strategy:

```bash
find source/ -name "*.tex" | xargs wc -c | sort -rn | head -20
```

**Size thresholds:**

| Condition | Strategy |
|-----------|----------|
| Total < 100 KB **AND** single file < 80 KB | Single sub-agent, translate all at once |
| Total > 150 KB **OR** single file > 80 KB | **Split strategy** (see below) |
| Multi-file structure (10+ tex files) | Sub-agent can process file-by-file; usually fine without splitting |

**Key insight:** Multi-file papers (e.g. 11 separate section files) succeed even when total size is large, because the sub-agent reads one file at a time. Single large files (>80 KB) reliably cause token overrun in sub-agents.

### Step 5: Translate Content

#### Strategy A — Single Sub-agent (small papers / multi-file papers)

Spawn one sub-agent with full translation task. Works well when no single file exceeds 80 KB.

#### Strategy B — Split by Section (large single-file papers)

For papers with one large `.tex` file (>80 KB), split by section before translating:

**5B-1: Extract terminology (glossary)**

Read the abstract and introduction, then create a `glossary.md` with key term translations:
```
# Glossary
| English | 中文 |
|---------|------|
| Cardinality Estimation | 基数估计 |
| Bayesian Network (BN) | 贝叶斯网络 |
...
```

Save to `<paper_dir>/glossary.md`. All sub-agents must read and follow this file.

**5B-2: Identify section boundaries**

```bash
grep -n "\\\\section\|\\\\begin{abstract}\|\\\\end{document}\|\\\\appendix" source/main.tex
```

**5B-3: Split into parts (keep each part < 35 KB)**

```bash
mkdir -p parts/
# Extract by line range: sed -n 'START,ENDp' source/main.tex > parts/partN_name.tex
```

Target: 6–8 parts, each under 35 KB.

**5B-4: Spawn parallel sub-agents**

```
Sub-agent A: parts 0–4 (preamble + intro + early sections)
Sub-agent B: parts 5–7 (experiments + related work + appendix)
```

Each sub-agent writes to `parts/partN_translated.tex`. Both agents must be given the `glossary.md` path.

**5B-5: Assemble translated main.tex**

After both sub-agents complete, concatenate in order:
```bash
# Insert xeCJK config before \begin{document}, then concatenate parts
{
  sed '/\\begin{document}/Q' parts/part0_translated.tex
  printf '\n\\usepackage{fontspec}\n\\usepackage{xeCJK}\n\\setCJKmainfont{Noto Serif CJK SC}\n\\setCJKsansfont{Noto Sans CJK SC}\n\\setCJKmonofont{Noto Sans CJK SC}\n\n'
  sed -n '/\\begin{document}/,$p' parts/part0_translated.tex
  for i in 1 2 3 4 5 6 7; do cat parts/part${i}_translated.tex; done
} > translated/main.tex
```

**Translation guidelines (both strategies):**
- Keep academic/professional tone
- Translate figure/table captions
- Keep citations and references in original form
- Do not translate code listings, file paths, URLs, system names (e.g. PostgreSQL, BayesCard, Naru)
- Follow glossary strictly for domain terms

### Step 6: Update Main Document for Chinese

Add xeCJK configuration after `\documentclass{...}`:

**macOS fonts:**
```latex
\usepackage{fontspec}
\usepackage{xeCJK}
\setCJKmainfont{Songti SC}
\setCJKsansfont{Heiti SC}
\setCJKmonofont{Hiragino Sans GB W3}
```

**Linux fonts (Noto CJK, installed via yum/apt):**
```latex
\usepackage{fontspec}
\usepackage{xeCJK}
\setCJKmainfont{Noto Serif CJK SC}
\setCJKsansfont{Noto Sans CJK SC}
\setCJKmonofont{Noto Sans CJK SC}
```

Verify available fonts with: `fc-list :lang=zh`

### Step 7: Compile PDF

Use XeLaTeX (required for Chinese):

**macOS:**
```bash
export PATH="$HOME/.TinyTeX/bin/universal-darwin:$PATH"
```

**Linux:**
```bash
export PATH="$HOME/.TinyTeX/bin/x86_64-linux:$PATH"
```

**Compilation sequence (always run all 4 steps):**
```bash
cd translated/

# Pass 1: Generate aux files
xelatex -interaction=nonstopmode main.tex

# Pass 2: Resolve bibliography
bibtex main          # Most papers: traditional \bibliography{}
# biber main         # Papers using biblatex (check: ls main.bcf)

# Pass 3 & 4: Resolve cross-references
xelatex -interaction=nonstopmode main.tex
xelatex -interaction=nonstopmode main.tex
```

**If compilation fails with missing packages:**
```bash
tlmgr install <package-name>
# Common: algorithm2e, mathtools, ifoddpage, relsize, booktabs
```

Use `scripts/compile_latex_linux.sh` (Linux) or `scripts/compile_latex.sh` (macOS) as helpers.

## File Organization

**Working directory structure:**
```
arxiv_<id>/
├── source/              # Original arXiv files (READ-ONLY)
│   ├── main.tex
│   ├── sections/
│   └── figures/
├── parts/               # Section splits (large single-file papers only)
│   ├── part0_preamble_abstract.tex
│   ├── part1_intro.tex
│   ├── ...
│   ├── part0_translated.tex
│   └── ...
├── glossary.md          # Term glossary (large papers only)
├── translated/          # Your translation work
│   ├── main.tex        # Assembled translated file
│   └── ...
└── output/             # Final PDF
    └── paper_chinese.pdf
```

## Common Issues

### Missing Chinese Fonts

If compilation fails with font errors, check available fonts:
```bash
fc-list :lang=zh
```

**macOS** common Chinese fonts:
- `Songti SC` (宋体)
- `Heiti SC` (黑体)
- `Hiragino Sans GB` (冬青黑体)

**Linux** — install Noto CJK:
```bash
yum install -y google-noto-cjk-fonts    # RHEL/CentOS/TencentOS
apt install -y fonts-noto-cjk           # Debian/Ubuntu
```
Then use `Noto Serif CJK SC` / `Noto Sans CJK SC`.

### Missing LaTeX Packages

Install with tlmgr:
```bash
tlmgr install <package-name>
```

Common packages needed:
- `ctex` (Chinese support - if not using xeCJK directly)
- `xecjk` (XeLaTeX Chinese)
- `fontspec` (font handling)
- `algorithm2e`, `mathtools`, `ifoddpage`, `relsize` (paper-specific)

### Bibliography Issues (Citations showing as ???)

**Symptoms**: Citations appear as `[???]` or `[1, 2]` instead of proper citation numbers.

**Root Cause**: Missing bibtex/biber compilation step.

**Solution**:
1. Check bibliography type:
   ```bash
   grep -n "bibliography\|biblatex" main.tex
   ```

2. For traditional `\bibliography{ref}` (most common):
   ```bash
   xelatex main.tex && bibtex main && xelatex main.tex && xelatex main.tex
   ```

3. For biblatex (check for `main.bcf`):
   ```bash
   tlmgr install biber && biber main
   ```

### Multiply-Defined Labels

**Symptom**: `LaTeX Warning: Label 'sectX' multiply defined.`

**Root Cause**: When splitting a paper by section, two sections may accidentally get the same `\label{}` in the translated output (e.g., sub-agent copies the wrong label).

**Fix**: `grep -n 'label{sectX}' translated/main.tex` and rename duplicates.

### Page Count Mismatch

**Symptoms**: Translated PDF has significantly fewer pages than original.

**Root Cause**: References section not generated due to missing bibtex step.

**Verification**:
- Check if references section exists at end of PDF
- Check if citations display as numbers `[1]` vs question marks `[???]`

## Resources

- `scripts/arxiv_download.py` - URL conversion and download
- `scripts/setup_tinytex.sh` - TinyTeX installation (macOS)
- `scripts/compile_latex.sh` - LaTeX compilation helper (macOS)
- `scripts/compile_latex_linux.sh` - LaTeX compilation helper (Linux)

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
- [ ] No "multiply defined label" warnings
- [ ] Chinese characters render correctly (not boxes/question marks)
