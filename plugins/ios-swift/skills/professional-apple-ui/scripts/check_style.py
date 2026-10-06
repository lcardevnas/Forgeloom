#!/usr/bin/env python3
"""Checks the contrast of every pair a reader has to read in a style.

Usage: check_style.py <styles.json | style.json> [style-id ...]
Exit code 1 when a pair is below its target. Tertiary text is decorative
(placeholders, timestamps next to a primary label) and only reported.
"""
import sys
sys.dont_write_bytecode = True  # keep the plugin folder free of __pycache__
import json
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from colorlib import contrast  # noqa: E402

PAIRS = [
    ("text", "canvas", 7), ("text", "card", 7),
    ("text2", "canvas", 4.5), ("text2", "card", 4.5),
    ("onHero", "hero", 4.5), ("onBrandTint", "brandTint", 4.5),
    ("onPrimary", "primary", 4.5),
    ("onInfo", "info", 4.5), ("onPlan", "plan", 4.5),
    ("onAttention", "attention", 4.5), ("onDanger", "danger", 4.5),
]


def check(style):
    failures = []
    for mode in ("light", "dark"):
        t = style[mode]
        for fg, bg, target in PAIRS:
            ratio = contrast(t[fg][:7], t[bg][:7])
            if ratio < target:
                failures.append(f"{style['id']} {mode}: {fg} on {bg} is {ratio:.2f}:1 (needs {target})")
    return failures


if __name__ == "__main__":
    data = json.load(open(sys.argv[1]))
    styles = data["styles"] if "styles" in data else [data]
    wanted = set(sys.argv[2:])
    failures = []
    for s in styles:
        if not wanted or s["id"] in wanted:
            failures += check(s)
    print("\n".join(failures) or f"All pairs pass for {len(styles) if not wanted else len(wanted)} style(s).")
    sys.exit(1 if failures else 0)
