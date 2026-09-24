#!/usr/bin/env python3
"""Regenerates the presets: Mint Studio verbatim plus nine generated relatives.

Writes knowledge/design-system/styles/styles.json (read by the scripts), one
Markdown file per style next to it (read by people and by tools without these
scripts), and assets/style-gallery.html. Run it only when a preset's recipe
changes, then run check_style.py on the result."""
import sys
sys.dont_write_bytecode = True  # keep the plugin folder free of __pycache__
import json
import os
import subprocess
import sys

here = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, here)
from colorlib import oklch_to_hex, contrast  # noqa: E402
from check_style import PAIRS  # noqa: E402
import mockup_kit  # noqa: E402

MINT = {
    "id": "mint-studio", "name": "Mint Studio",
    "mood": "Fresh and friendly: mint hero on a warm light-grey canvas. The original reference style.",
    "font": "rounded", "radius": {"hero": 28, "card": 24, "tile": 16, "thumbnail": 14},
    "roles": {"brand": 166, "info": 236, "plan": 298, "attention": 52, "danger": 24},
    "light": {
        "canvas": "#F4F2EE", "sidebar": "#EDEBE6", "card": "#FFFFFF", "well": "#F4F2EE", "checker": "#E9E6E0",
        "text": "#2E3B36", "line": "#2E3B3614", "text2": "#6E7A75", "text3": "#9AA39F",
        "hero": "#9BDCC4", "onHero": "#18392C", "chipOnHero": "#FFFFFF8C", "accent": "#58B893",
        "brandTint": "#E3F4EC", "onBrandTint": "#2F7A5C", "primary": "#3E9E7A", "onPrimary": "#FFFFFF",
        "info": "#DCEDF7", "onInfo": "#2C5B76", "infoStrong": "#6AAED6",
        "plan": "#ECE5F6", "onPlan": "#5A4682", "planStrong": "#9C85CC",
        "attention": "#FBE6D8", "onAttention": "#8A4A26", "attentionStrong": "#F0A77A",
        "danger": "#F9DEDC", "onDanger": "#8C3330", "dangerStrong": oklch_to_hex(0.68, 0.14, 24),
    },
    "dark": {
        "canvas": "#18201D", "sidebar": "#1D2622", "card": "#232D29", "well": "#1B2320", "checker": "#222C28",
        "line": "#FFFFFF12", "text": "#EEF1EF", "text2": "#A5B0AB", "text3": "#75807B",
        "hero": "#3F7F68", "onHero": "#F1FBF6", "chipOnHero": "#FFFFFF24", "accent": "#6FCBA6",
        "brandTint": "#24392F", "onBrandTint": "#9EE0C4", "primary": "#4FB48D", "onPrimary": "#FFFFFF",
        "info": "#223543", "onInfo": "#A9D2EA", "infoStrong": "#7DBBE0",
        "plan": "#2E2A3D", "onPlan": "#CDBFEA", "planStrong": "#AC98DA",
        "attention": "#3A2A20", "onAttention": "#F2BE9C", "attentionStrong": "#D98E62",
        "danger": "#3B2524", "onDanger": "#F1AFAB", "dangerStrong": oklch_to_hex(0.70, 0.12, 24),
    },
    "notes": "Kept exactly as first approved. Five pairs are below AA: white on the primary button (3.3:1 light, 2.5:1 dark), secondary text on the canvas (4.0:1) and on cards (4.46:1), and text on the dark hero card (4.47:1). For a new project, make an AA copy with: make_style.py --id mint-studio-aa --name \"Mint Studio AA\" --brand \"#58B893\".",
}

PRESETS = [
    ["--id", "sky-harbor", "--name", "Sky Harbor", "--brand", "#6AAED6", "--canvas", "cool", "--info", "200", "--plan", "305",
     "--mood", "Calm and airy: soft sky-blue hero on a cool canvas, for utilities and planners."],
    ["--id", "lavender-loft", "--name", "Lavender Loft", "--brand", "#A08BD3", "--plan", "166",
     "--mood", "Dreamy and creative: lilac hero, mint for planning, for journaling and art tools."],
    ["--id", "peach-bakery", "--name", "Peach Bakery", "--brand", "#F0A77A", "--canvas", "brand", "--attention", "88", "--danger", "18",
     "--mood", "Warm and cosy: apricot hero on a cream canvas, for food, home and hobby apps."],
    ["--id", "sage-garden", "--name", "Sage Garden", "--brand", "#8FB08A", "--vivid", "0.7", "--font", "serif", "--corners", "crisp",
     "--mood", "Quiet and grounded: muted sage, serif headings, tighter corners, for reading and wellbeing."],
    ["--id", "butter-sun", "--name", "Butter Sun", "--brand", "#F2CF63", "--corners", "rounder", "--attention", "45", "--plan", "290",
     "--mood", "Cheerful and bright: butter-yellow hero with dark button text, extra-round cards."],
    ["--id", "blush-petal", "--name", "Blush Petal", "--brand", "#E9A0B8", "--corners", "rounder", "--attention", "70", "--danger", "28",
     "--mood", "Playful and soft: blush-pink hero, for lifestyle, beauty and gifting apps."],
    ["--id", "aqua-pool", "--name", "Aqua Pool", "--brand", "#5CC4C4", "--canvas", "cool", "--info", "255",
     "--mood", "Clean and refreshing: turquoise hero, for health, water and travel apps."],
    ["--id", "terracotta-clay", "--name", "Terracotta Clay", "--brand", "#C98A6B", "--vivid", "0.8", "--canvas", "brand",
     "--font", "serif", "--corners", "crisp", "--attention", "82", "--danger", "8",
     "--mood", "Earthy and crafted: clay hero on a sand canvas, serif headings, for makers and shops."],
    ["--id", "indigo-ink", "--name", "Indigo Ink", "--brand", "#7C86D9", "--canvas", "cool", "--font", "default", "--corners", "crisp",
     "--info", "215", "--plan", "320",
     "--mood", "Focused and professional: periwinkle hero, SF Pro default, crisper corners, for pro tools."],
]


TOKEN_ORDER = ["canvas", "sidebar", "card", "well", "checker", "line", "text", "text2", "text3",
               "hero", "onHero", "chipOnHero", "accent", "brandTint", "onBrandTint", "primary", "onPrimary"]
ROLES = ["info", "plan", "attention", "danger"]


def style_markdown(s):
    """The human-readable version of one style, in the shape of the web themes."""
    L, D = s["light"], s["dark"]
    mint = s["id"] == "mint-studio"
    source = ("**reference**: the values of the approved reference design, kept exactly." if mint else
              "**computed**: generated by `make_style.py` from the brand hue with the OKLCH recipe calibrated on Mint Studio, "
              "then pushed until every reading pair reaches WCAG AA.")
    r = s["radius"]
    rows = [f"| `{k}` | `{L[k]}` | `{D[k]}` |" for k in TOKEN_ORDER]
    for role in ROLES:
        for k in (role, "on" + role.capitalize(), role + "Strong"):
            rows.append(f"| `{k}` | `{L[k]}` | `{D[k]}` |")
    pairs = []
    for fg, bg, target in PAIRS:
        lr, dr = contrast(L[fg][:7], L[bg][:7]), contrast(D[fg][:7], D[bg][:7])
        mark = lambda v: f"{v:.2f}:1" + ("" if v >= target else " **below**")
        pairs.append(f"| `{fg}` on `{bg}` | {target} | {mark(lr)} | {mark(dr)} |")
    notes = f"\n\n**Note.** {s['notes']}" if s.get("notes") else ""
    return f"""# {s['name']} (`{s['id']}`)

Style of `professional-apple-ui`. Pick ONE per project, record it in the project's `AGENTS.md` (`UI style: {s['id']}`) and in `docs/ui-style.json`, and generate `Theme.swift` from it; never mix styles.

**Feel**: {s['mood']}

**Source of the values**: {source}{notes}

## Type and shape

| Property | Value |
|---|---|
| Font design | `{s['font']}`{" (serif headings, default body)" if s['font'] == "serif" else ""} |
| Corner radii (hero / card / tile / thumbnail) | {r['hero']} / {r['card']} / {r['tile']} / {r['thumbnail']} pt |
| Role hues (OKLCH) | brand {s['roles']['brand']}°, info {s['roles']['info']}°, plan {s['roles']['plan']}°, attention {s['roles']['attention']}°, danger {s['roles']['danger']}° |

## Color tokens

Where each token goes is in `../visual-system.md`. Eight-digit values carry alpha.

| Token | Light | Dark |
|---|---|---|
{chr(10).join(rows)}

## Measured contrast

WCAG 2.x ratios, computed by `check_style.py`. Pairs not listed have not been checked.

| Pair | Target | Light | Dark |
|---|---|---|---|
{chr(10).join(pairs)}
"""


def main():
    styles = [MINT]
    for args in PRESETS:
        out = subprocess.run([sys.executable, os.path.join(here, "make_style.py"), *args], capture_output=True, text=True, check=True)
        styles.append(json.loads(out.stdout))
    path = mockup_kit.STYLES
    json.dump({"version": 1, "styles": styles}, open(path, "w"), indent=2)
    folder = os.path.dirname(path)
    for s in styles:
        with open(os.path.join(folder, s["id"] + ".md"), "w") as f:
            f.write(style_markdown(s))
    mockup_kit.gallery(os.path.join(here, "..", "assets", "style-gallery.html"), path)
    print(f"Wrote {len(styles)} styles to {os.path.normpath(folder)}")


if __name__ == "__main__":
    main()
