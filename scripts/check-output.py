#!/usr/bin/env python3
"""Check the generated HTML and RSS without third-party dependencies."""
import sys
from pathlib import Path
from xml.etree import ElementTree


def check(root):
    pages = list((root / "site").glob("*.html"))
    if not pages:
        raise ValueError("No generated site HTML files")
    home = (root / "site/home.html").read_text(encoding="utf-8")
    if "<!doctype html>" not in home.lower() or "</html>" not in home.lower():
        raise ValueError("home.html is not a complete HTML document")
    for name in ("img", "log"):
        feed = ElementTree.parse(root / "links" / f"{name}.xml").getroot()
        if feed.tag != "rss" or feed.find("channel") is None:
            raise ValueError(f"{name}.xml is not an RSS feed with a channel")
        if not feed.findall("channel/item"):
            raise ValueError(f"{name}.xml contains no RSS items")
    print(f"Verified {len(pages)} HTML pages, home.html, and both RSS feeds")


if __name__ == "__main__":
    root = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path(__file__).resolve().parent.parent
    try:
        check(root)
    except (OSError, ValueError, ElementTree.ParseError) as error:
        sys.exit(f"Output verification failed: {error}")
