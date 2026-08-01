#!/usr/bin/env python3
"""Render Campaign markdown to standalone HTML (fallback when IDE preview is blank).

Usage:
  python tools/render-campaign-preview.py attack-matrix/Campaign/Runbooks/CAMPAIGNS-RUNBOOK-0.md
  python tools/render-campaign-preview.py --all

Opens in your default browser when --open is passed.
"""

from __future__ import annotations

import argparse
import html
import sys
import webbrowser
from pathlib import Path

try:
    import markdown
except ImportError as exc:  # pragma: no cover
    raise SystemExit(
        "Install markdown: pip install markdown"
    ) from exc

ROOT = Path(__file__).resolve().parents[1]
CAMPAIGN = ROOT / "attack-matrix" / "Campaign"
PREVIEW_DIR = CAMPAIGN / "archive" / "_preview"

STYLE = """
body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
       max-width: 52rem; margin: 2rem auto; padding: 0 1.25rem; line-height: 1.55;
       color: #1f2328; background: #fff; }
pre { background: #f6f8fa; padding: 1rem; overflow-x: auto; border-radius: 6px; }
code { font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; font-size: 0.9em; }
table { border-collapse: collapse; width: 100%; margin: 1rem 0; font-size: 0.92em; }
th, td { border: 1px solid #d0d7de; padding: 0.45rem 0.6rem; vertical-align: top; }
th { background: #f6f8fa; }
blockquote { border-left: 4px solid #d0d7de; margin-left: 0; padding-left: 1rem; color: #57606a; }
a { color: #0969da; }
h1, h2, h3 { scroll-margin-top: 1rem; }
.banner { background: #fff8c5; border: 1px solid #d4a72c; padding: 0.75rem 1rem;
           border-radius: 6px; margin-bottom: 1.5rem; font-size: 0.95em; }
"""


def render_md(src: Path) -> str:
    text = src.read_text(encoding="utf-8")
    body = markdown.markdown(
        text,
        extensions=["tables", "fenced_code", "sane_lists", "nl2br"],
    )
    rel = src.relative_to(ROOT)
    banner = (
        f"<div class='banner'><strong>Static preview</strong> — generated from "
        f"<code>{html.escape(str(rel))}</code>. "
        f"Regenerate: <code>python tools/render-campaign-preview.py {html.escape(str(rel))}</code>"
        f"</div>"
    )
    return (
        "<!DOCTYPE html><html><head><meta charset='utf-8'>"
        f"<title>{html.escape(src.stem)}</title><style>{STYLE}</style></head>"
        f"<body>{banner}{body}</body></html>"
    )


def out_path(src: Path) -> Path:
    try:
        rel = src.relative_to(CAMPAIGN)
        return PREVIEW_DIR / rel.with_suffix(".html")
    except ValueError:
        return PREVIEW_DIR / (src.stem + ".html")


def write_preview(src: Path) -> Path:
    dest = out_path(src)
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_text(render_md(src), encoding="utf-8")
    return dest


def default_targets() -> list[Path]:
    paths = [CAMPAIGN / "CAMPAIGNS-METADATA-v2.md"]
    paths.extend(sorted((CAMPAIGN / "Runbooks").glob("CAMPAIGNS-RUNBOOK*.md")))
    return paths


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("files", nargs="*", help="Markdown files to render")
    parser.add_argument("--all", action="store_true", help="Render runbooks + metadata")
    parser.add_argument("--open", action="store_true", help="Open first output in browser")
    args = parser.parse_args(argv)

    if args.all:
        sources = default_targets()
    elif args.files:
        sources = [Path(f) if Path(f).is_absolute() else ROOT / f for f in args.files]
    else:
        parser.print_help()
        return 1

    written: list[Path] = []
    for src in sources:
        if not src.is_file():
            print(f"skip (missing): {src}", file=sys.stderr)
            continue
        dest = write_preview(src)
        written.append(dest)
        print(dest)

    if args.open and written:
        webbrowser.open(written[0].as_uri())

    return 0 if written else 1


if __name__ == "__main__":
    raise SystemExit(main())
