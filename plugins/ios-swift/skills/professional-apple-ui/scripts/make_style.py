#!/usr/bin/env python3
"""Builds a complete light + dark token set from a brand color, the way the
bundled presets were built, and checks its contrast.

The lightness/chroma recipe is calibrated on Mint Studio (the approved
reference style): same structure, same depth, only the hues change. Text that
must be read (body, secondary, text on tints, button labels) is pushed until
it reaches WCAG AA (4.5:1).

Usage:
  make_style.py --id my-style --name "My Style" --brand "#7FB8E6" \
      [--canvas warm|cool|neutral|brand] [--font rounded|default|serif] \
      [--corners soft|rounder|crisp] [--button-text auto|light|dark] \
      [--info H] [--plan H] [--attention H] [--danger H] [--vivid 1.0]
Prints the style as JSON (the same shape as assets/styles.json entries).
Save it as a project's docs/ui-style.json. To add a preset, add it to build_presets.py.
"""
import sys
sys.dont_write_bytecode = True  # keep the plugin folder free of __pycache__
import argparse
import json
import sys
import os

sys.path.insert(0, os.path.dirname(__file__))
from colorlib import oklch_to_hex, rgb_to_oklch, hex_to_rgb, contrast  # noqa: E402

CORNERS = {
    "soft": {"hero": 28, "card": 24, "tile": 16, "thumbnail": 14},
    "rounder": {"hero": 32, "card": 26, "tile": 18, "thumbnail": 14},
    "crisp": {"hero": 20, "card": 16, "tile": 12, "thumbnail": 10},
}
CANVAS = {  # (hue, chroma) of the light canvas; None hue = brand hue
    "warm": (85, 0.006),
    "cool": (240, 0.006),
    "neutral": (0, 0.0),
    "brand": (None, 0.008),
}
AA = 4.5


def solve(L, C, H, against, target=AA, direction=-1, lo=0.15, hi=0.98):
    """Moves lightness from L in `direction` until contrast with `against` reaches target."""
    color = oklch_to_hex(L, C, H)
    while contrast(color, against) < target and lo <= L <= hi:
        L += 0.005 * direction
        color = oklch_to_hex(L, C, H)
    return color


def build(args):
    bL, bC, bH = rgb_to_oklch(hex_to_rgb(args.brand))
    v = args.vivid
    cH, cC = CANVAS[args.canvas]
    cH = bH if cH is None else cH
    roles = {"info": args.info, "plan": args.plan, "attention": args.attention, "danger": args.danger}

    # Light ----------------------------------------------------------------
    card = "#FFFFFF"
    bg = oklch_to_hex(0.962, cC, cH)
    light = {
        "canvas": bg,
        "sidebar": oklch_to_hex(0.940, cC * 1.2, cH),
        "card": card,
        "well": bg,
        "checker": oklch_to_hex(0.926, cC * 1.5 + 0.002, cH),
        "text": oklch_to_hex(0.339, 0.019, bH),
    }
    light["line"] = light["text"] + "14"  # 8 % alpha
    light["text2"] = solve(0.568, 0.016, bH, bg)
    light["text3"] = oklch_to_hex(0.707, 0.012, bH)
    # Yellows only read as yellow when light and saturated; at Mint's
    # lightness they turn khaki. Lift them, and warm the dark fill toward gold.
    yellow = 75 <= bH <= 115
    light["hero"] = oklch_to_hex(0.905, 0.115 * v, bH) if yellow else oklch_to_hex(0.844, 0.074 * v, bH)
    light["onHero"] = solve(0.315, 0.046 * v, bH, light["hero"], 7)
    light["chipOnHero"] = "#FFFFFF8C"
    light["accent"] = oklch_to_hex(0.80, 0.13 * v, bH) if yellow else oklch_to_hex(0.714, 0.107 * v, bH)
    light["brandTint"] = oklch_to_hex(0.952, 0.021 * v, bH)
    light["onBrandTint"] = solve(0.524, 0.089 * v, bH, light["brandTint"])

    # Dark -----------------------------------------------------------------
    dbg = oklch_to_hex(0.234, 0.013, bH)
    dark = {
        "canvas": dbg,
        "sidebar": oklch_to_hex(0.258, 0.015, bH),
        "card": oklch_to_hex(0.286, 0.016, bH),
        "well": oklch_to_hex(0.247, 0.013, bH),
        "checker": oklch_to_hex(0.282, 0.016, bH),
        "line": "#FFFFFF12",
        "text": oklch_to_hex(0.955, 0.004, bH),
    }
    dark["text2"] = solve(0.747, 0.014, bH, dark["card"], direction=1)
    dark["text3"] = oklch_to_hex(0.589, 0.015, bH)
    dark["hero"] = oklch_to_hex(0.56, 0.085 * v, bH - 12) if yellow else oklch_to_hex(0.547, 0.076 * v, bH)
    dark["onHero"] = solve(0.979, 0.012, bH, dark["hero"], direction=1)
    dark["chipOnHero"] = "#FFFFFF24"
    dark["accent"] = oklch_to_hex(0.82, 0.12 * v, bH) if yellow else oklch_to_hex(0.775, 0.104 * v, bH)
    dark["brandTint"] = oklch_to_hex(0.323, 0.032 * v, bH)
    dark["onBrandTint"] = solve(0.855, 0.077 * v, bH, dark["brandTint"], direction=1)

    # Primary button: white label on a deeper brand fill, or a dark label
    # on a light fill for hues that turn muddy when darkened (yellows).
    mode = args.button_text
    if mode == "auto":
        mode = "dark" if 70 <= bH <= 115 else "light"
    if mode == "light":
        light["primary"] = solve(0.632, 0.106 * v, bH, "#FFFFFF")
        light["onPrimary"] = "#FFFFFF"
    else:
        light["primary"] = oklch_to_hex(0.84, 0.14 * v, bH)
        light["onPrimary"] = solve(0.30, 0.05, bH, light["primary"])
    dark["primary"] = oklch_to_hex(0.74, 0.11 * v, bH)
    dark["onPrimary"] = solve(0.22, 0.03, bH, dark["primary"])

    for role, h in roles.items():
        light[role] = oklch_to_hex(0.936, 0.026, h)
        light["on" + role.capitalize()] = solve(0.46, 0.095, h, light[role])
        light[role + "Strong"] = oklch_to_hex(0.74, 0.10, h)
        dark[role] = oklch_to_hex(0.31, 0.034, h)
        dark["on" + role.capitalize()] = solve(0.835, 0.062, h, dark[role], direction=1)
        dark[role + "Strong"] = oklch_to_hex(0.74, 0.095, h)

    return {
        "id": args.id,
        "name": args.name,
        "mood": args.mood,
        "font": args.font,
        "radius": CORNERS[args.corners],
        "roles": {"brand": round(bH), **{k: round(h) for k, h in roles.items()}},
        "light": light,
        "dark": dark,
    }


def parser():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--id", required=True)
    p.add_argument("--name", required=True)
    p.add_argument("--brand", required=True, help="brand color, any lightness; only its hue is used (--vivid sets saturation)")
    p.add_argument("--mood", default="")
    p.add_argument("--canvas", choices=CANVAS, default="warm")
    p.add_argument("--font", choices=["rounded", "default", "serif"], default="rounded")
    p.add_argument("--corners", choices=CORNERS, default="soft")
    p.add_argument("--button-text", choices=["auto", "light", "dark"], default="auto")
    p.add_argument("--vivid", type=float, default=1.0, help="chroma multiplier for brand colors (0.6 muted … 1.3 vivid)")
    p.add_argument("--info", type=float, default=236)
    p.add_argument("--plan", type=float, default=300)
    p.add_argument("--attention", type=float, default=55)
    p.add_argument("--danger", type=float, default=25)
    return p


if __name__ == "__main__":
    print(json.dumps(build(parser().parse_args()), indent=2))
