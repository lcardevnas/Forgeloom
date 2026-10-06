#!/usr/bin/env python3
"""Writes a project's SwiftUI theme file from a style.

Usage: make_theme.py <style-id | style.json> <out/Theme.swift> [--platform macos|ios|both]

The file has AppTheme (every color token, adaptive to light and dark),
Spacing (the 4 pt scale), Radius (from the style) and the font designs.
Views use only these; a literal color, padding, radius or font size in a
view is a bug. Regenerate it when the style changes; don't hand-edit colors
in it (add project-specific tokens in a separate extension instead).
"""
import sys
sys.dont_write_bytecode = True  # keep the plugin folder free of __pycache__
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from mockup_kit import load_style  # noqa: E402

DOCS = {
    "canvas": "Window background behind cards.",
    "sidebar": "Sidebar / tab bar surface.",
    "card": "Cards. Two surface levels only: canvas → card.",
    "well": "Image wells and insets inside a card (the canvas tone, never a third one).",
    "checker": "Second square of the transparency checkerboard (the first is `well`).",
    "line": "Hairlines between rows inside one card.",
    "text": "Primary text. Never pure black.",
    "text2": "Secondary text and meta.",
    "text3": "Tertiary: placeholders and decorative labels only (not AA on every surface).",
    "hero": "Fill of the one hero card per screen.",
    "onHero": "Text and symbols on `hero`.",
    "chipOnHero": "Chip background inside the hero card.",
    "accent": "Progress bars, done states, sidebar symbols.",
    "brandTint": "Brand chip / selected row background.",
    "onBrandTint": "Text on `brandTint`.",
    "primary": "Primary button fill.",
    "onPrimary": "Primary button label.",
}
ROLE_DOCS = {"info": "in progress, information", "plan": "planning, secondary categories",
             "attention": "needs the user's attention", "danger": "failed, destructive"}


def swift_name(k):
    return k


def hex_parts(h):
    h = h.lstrip("#")
    rgb = int(h[:6], 16)
    alpha = int(h[6:8], 16) / 255 if len(h) == 8 else 1
    return f"0x{rgb:06X}", round(alpha, 3)


def main():
    a = sys.argv[1:]
    if len(a) < 2:
        sys.exit(__doc__)
    style = load_style(a[0])
    out = a[1]
    platform = a[3] if len(a) > 3 and a[2] == "--platform" else "both"

    lines = []
    for key in style["light"]:
        lh, la = hex_parts(style["light"][key])
        dh, da = hex_parts(style["dark"][key])
        doc = DOCS.get(key)
        if doc is None:
            base = re.sub(r"^on|Strong$", "", key)
            base = base[0].lower() + base[1:]
            meaning = ROLE_DOCS.get(base, "")
            doc = (f"Text on `{base}`." if key.startswith("on") else
                   f"Solid `{base}` for dots, progress and icons." if key.endswith("Strong") else
                   f"Tint for {meaning}. Pair with `on{base.capitalize()}` text.")
        alpha = "" if la == 1 and da == 1 else f", lightAlpha: {la}, darkAlpha: {da}"
        lines.append(f"    /// {doc}\n    static var {swift_name(key)}: Color {{ adaptive(light: {lh}, dark: {dh}{alpha}) }}")

    font = style["font"]
    body_design = {"rounded": ".rounded", "default": ".default", "serif": ".default"}[font]
    head_design = {"rounded": ".rounded", "default": ".default", "serif": ".serif"}[font]
    r = style["radius"]

    mac = """        Color(nsColor: NSColor(name: nil) { appearance in
            let isDark = appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
            return rgb(isDark ? dark : light, alpha: isDark ? darkAlpha : lightAlpha)
        })"""
    ios = """        Color(uiColor: UIColor { traits in
            let isDark = traits.userInterfaceStyle == .dark
            return rgb(isDark ? dark : light, alpha: isDark ? darkAlpha : lightAlpha)
        })"""
    platform_type = {"macos": "NSColor", "ios": "UIColor"}
    if platform == "both":
        imports = "#if os(macOS)\nimport AppKit\n#else\nimport UIKit\n#endif\nimport SwiftUI"
        body = f"        #if os(macOS)\n{mac}\n        #else\n{ios}\n        #endif"
        rgb_fn = """    #if os(macOS)
    private static func rgb(_ hex: UInt32, alpha: Double) -> NSColor {
        NSColor(srgbRed: Double((hex >> 16) & 0xFF) / 255, green: Double((hex >> 8) & 0xFF) / 255, blue: Double(hex & 0xFF) / 255, alpha: alpha)
    }
    #else
    private static func rgb(_ hex: UInt32, alpha: Double) -> UIColor {
        UIColor(red: Double((hex >> 16) & 0xFF) / 255, green: Double((hex >> 8) & 0xFF) / 255, blue: Double(hex & 0xFF) / 255, alpha: alpha)
    }
    #endif"""
    else:
        t = platform_type[platform]
        imports = f"import {'AppKit' if platform == 'macos' else 'UIKit'}\nimport SwiftUI"
        body = mac if platform == "macos" else ios
        init = "srgbRed" if platform == "macos" else "red"
        rgb_fn = f"""    private static func rgb(_ hex: UInt32, alpha: Double) -> {t} {{
        {t}({init}: Double((hex >> 16) & 0xFF) / 255, green: Double((hex >> 8) & 0xFF) / 255, blue: Double(hex & 0xFF) / 255, alpha: alpha)
    }}"""

    src = f"""// Generated by Forgeloom's professional-apple-ui skill from style "{style['name']}" ({style['id']}).
// Regenerate with make_theme.py instead of editing colors here.
{imports}

/// The {style['name']} palette. Every token adapts to light and dark on its own,
/// so views never branch on the color scheme. Where each one goes: the skill's
/// knowledge/design-system/visual-system.md.
nonisolated enum AppTheme {{
{chr(10).join(lines)}

    /// Body text design. Apply once at the root: `.fontDesign(AppTheme.bodyDesign)`.
    static let bodyDesign: Font.Design = {body_design}
    /// Headings (page title, section headers, stat numbers).
    static let headingDesign: Font.Design = {head_design}

    private static func adaptive(light: UInt32, dark: UInt32, lightAlpha: Double = 1, darkAlpha: Double = 1) -> Color {{
{body}
    }}

{rgb_fn}
}}

/// A 4 pt scale. Nothing in a view uses another number.
nonisolated enum Spacing {{
    static let xs: CGFloat = 4
    static let s: CGFloat = 8
    static let m: CGFloat = 12
    static let l: CGFloat = 18
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 36
    /// Detail-pane insets (macOS). On iOS use the system's readable margins.
    static let pageHorizontal: CGFloat = 36
    static let pageTop: CGFloat = 26
    static let cardPadding: CGFloat = 22
    static let heroPadding: CGFloat = 26
}}

nonisolated enum Radius {{
    static let hero: CGFloat = {r['hero']}
    static let card: CGFloat = {r['card']}
    static let tile: CGFloat = {r['tile']}
    static let thumbnail: CGFloat = {r['thumbnail']}
}}
"""
    os.makedirs(os.path.dirname(os.path.abspath(out)), exist_ok=True)
    open(out, "w").write(src)
    print(out)


if __name__ == "__main__":
    main()
