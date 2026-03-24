#!/usr/bin/env python3
"""
Download arXiv LaTeX source and prepare workspace.
Handles URL conversion from various arXiv formats to LaTeX source URLs.
"""
import sys
import re
import urllib.request
import urllib.error
import os
import tarfile
from pathlib import Path

def convert_to_source_url(url: str) -> str:
    """
    Convert various arXiv URL formats to LaTeX source download URL.
    
    Supported formats:
    - https://arxiv.org/abs/XXXX.XXXXX (abstract page)
    - https://arxiv.org/pdf/XXXX.XXXXX.pdf (PDF link)
    - https://arxiv.org/e-print/XXXX.XXXXX (already source)
    - https://arxiv.org/src/XXXX.XXXXX (source listing)
    """
    # Extract arXiv ID
    patterns = [
        r'arxiv\.org/abs/(\d{4}\.\d{4,})',  # abstract page
        r'arxiv\.org/pdf/(\d{4}\.\d{4,})\.pdf',  # PDF link
        r'arxiv\.org/e-print/(\d{4}\.\d{4,})',  # e-print
        r'arxiv\.org/src/(\d{4}\.\d{4,})',  # source listing
    ]
    
    arxiv_id = None
    for pattern in patterns:
        match = re.search(pattern, url)
        if match:
            arxiv_id = match.group(1)
            break
    
    if not arxiv_id:
        # Try to extract ID from end of URL
        parts = url.rstrip('/').split('/')
        last_part = parts[-1]
        if re.match(r'^\d{4}\.\d{4,}$', last_part):
            arxiv_id = last_part
    
    if not arxiv_id:
        raise ValueError(f"Could not extract arXiv ID from URL: {url}")
    
    # Return source download URL
    return f"https://arxiv.org/e-print/{arxiv_id}", arxiv_id

def download_and_extract(source_url: str, arxiv_id: str, workspace: str):
    """Download arXiv source and extract to workspace."""
    workspace_path = Path(workspace)
    workspace_path.mkdir(parents=True, exist_ok=True)
    
    # Download
    tar_path = workspace_path / f"{arxiv_id}.tar.gz"
    print(f"Downloading from {source_url}...")
    
    try:
        urllib.request.urlretrieve(source_url, tar_path)
    except urllib.error.HTTPError as e:
        if e.code == 404:
            raise RuntimeError(
                f"No LaTeX source available for arXiv:{arxiv_id}. "
                "The paper may not have public source files."
            )
        raise
    
    # Extract
    source_dir = workspace_path / "source"
    source_dir.mkdir(exist_ok=True)
    
    print(f"Extracting to {source_dir}...")
    with tarfile.open(tar_path, 'r:gz') as tar:
        tar.extractall(source_dir)
    
    # Remove tar file
    tar_path.unlink()
    
    # Find main tex file
    tex_files = list(source_dir.glob("*.tex"))
    if not tex_files:
        # Check subdirectories
        tex_files = list(source_dir.rglob("*.tex"))
    
    main_tex = None
    for tex in tex_files:
        # Prefer files with \documentclass
        content = tex.read_text(errors='ignore')
        if '\\documentclass' in content:
            main_tex = tex
            break
    
    if not main_tex and tex_files:
        main_tex = tex_files[0]
    
    if main_tex:
        print(f"Main tex file: {main_tex.relative_to(workspace_path)}")
        return str(main_tex.relative_to(workspace_path))
    else:
        raise RuntimeError("No .tex files found in the downloaded source.")

def main():
    if len(sys.argv) < 3:
        print("Usage: arxiv_download.py <arxiv_url> <workspace_dir>")
        sys.exit(1)
    
    url = sys.argv[1]
    workspace = sys.argv[2]
    
    try:
        source_url, arxiv_id = convert_to_source_url(url)
        print(f"arXiv ID: {arxiv_id}")
        print(f"Source URL: {source_url}")
        
        main_tex = download_and_extract(source_url, arxiv_id, workspace)
        print(f"WORKSPACE:{workspace}")
        print(f"MAIN_TEX:{main_tex}")
        print(f"ARXIV_ID:{arxiv_id}")
        
    except Exception as e:
        print(f"ERROR:{e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
