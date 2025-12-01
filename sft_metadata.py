#!/usr/bin/env python3
import argparse
import json
import sys
from pathlib import Path

def read_metadata(path_str, backend="auto"):
    """
    Read safetensors metadata using the specified backend.
    backend: "pt", "np", or "auto" (tries pt then np)
    Returns metadata dict or None if not found.
    """
    from safetensors import safe_open

    path = Path(path_str)
    if not path.exists():
        raise FileNotFoundError(f"File not found: {path}")

    backends = []
    if backend == "auto":
        backends = ["pt", "np"]
    else:
        backends = [backend]

    for b in backends:
        try:
            with safe_open(str(path), framework=b) as f:
                meta = None
                m = getattr(f, "metadata", None)
                if m is not None:
                    meta = m() if callable(m) else m
                if meta is None:
                    gm = getattr(f, "get_metadata", None)
                    if callable(gm):
                        meta = gm()
                if meta is not None:
                    return meta
                # If no metadata for this backend, try next
        except Exception:
            # Try next backend; swallow the error to allow fallback
            continue

    return None

def main():
    parser = argparse.ArgumentParser(description="Read safetensors metadata and output as JSON.")
    parser.add_argument("path", help="Path to a safetensors file (.safetensors)")
    parser.add_argument("--backend", choices=["pt", "np", "auto"], default="auto",
                        help="Backend to try: pt, np, or auto (default: auto)")
    args = parser.parse_args()

    try:
        meta = read_metadata(args.path, backend=args.backend)
    except Exception as e:
        # Print error to stderr and output empty JSON on stdout for compatibility
        print(f"Error: {e}", file=sys.stderr)
        meta = None

    if meta is None:
        print("{}")
    else:
        print(json.dumps(meta, indent=2, ensure_ascii=False))

if __name__ == "__main__":
    main()
