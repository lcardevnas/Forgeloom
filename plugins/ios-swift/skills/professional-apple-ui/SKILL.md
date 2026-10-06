---
name: professional-apple-ui
description: Apply when designing, building, restyling or reviewing SwiftUI screens for a macOS or iOS app, so they look polished, native and consistent — a soft, card-based style from ONE of 10 styles (or a custom one) as design tokens, an HTML mockup approved before any SwiftUI, and a screenshot tour looked at in light and dark before a screen counts as done. Use it for any new or changed view, sheet, toolbar, sidebar, settings pane, onboarding or empty state, when starting an Apple app's UI or picking its look, and when a screen looks unfinished, cluttered or clipped — even if the user doesn't mention design.
---

# professional-apple-ui

**Objective**: Apple apps whose UI a picky user calls polished: a soft, friendly, card-based look from design tokens on a fully native shell (sidebar, toolbar, tab bar, inspector, menus, keyboard), built one screen at a time and looked at before it counts as done. It exists because UI built broad and blind (several screens per pass, nobody looking at the result) comes out with raw enum names, buried navigation, clipped text and controls poking out of their cards.

`$KNOWLEDGE` below is `${CLAUDE_PLUGIN_ROOT}/knowledge/design-system`; `$SKILL` is `${CLAUDE_PLUGIN_ROOT}/skills/professional-apple-ui`. The scripts need Python 3 (included with Xcode's Command Line Tools).

## Style choice

**Use ONE style per project, applied through `Theme.swift` everywhere. Never mix styles or add colors outside them.**

1. If the project's `AGENTS.md` declares `UI style: <id>` (or `docs/ui-style.json` exists), use it and do not ask.
2. If not, the look is the user's to choose. Open `$SKILL/assets/style-gallery.html` for them (10 styles, light and dark side by side), propose the one that fits best and say why, and wait for their pick. They can also describe their own: `$SKILL/scripts/make_style.py` builds a full, AA-checked token set from a brand color.
3. Once chosen, save it as `docs/ui-style.json`, add `UI style: <id>` to the project's `AGENTS.md`, and generate the theme with `$SKILL/scripts/make_theme.py`. The full setup (components, appearance, localization, screenshot tour, demo seed) is in `$KNOWLEDGE/project-setup.md`.

| Style | Feel | Type | Corners |
|---|---|---|---|
| `mint-studio` | Mint hero on a warm light-grey canvas; the reference style (5 pairs below AA, see its file) | Rounded | Soft |
| `sky-harbor` | Sky blue on a cool canvas: calm, utilities and planners | Rounded | Soft |
| `lavender-loft` | Lilac: dreamy, journaling and art tools | Rounded | Soft |
| `peach-bakery` | Apricot on cream: warm, food, home and hobbies | Rounded | Soft |
| `sage-garden` | Muted sage: quiet, reading and wellbeing | Serif headings | Crisp |
| `butter-sun` | Butter yellow, dark button text: cheerful | Rounded | Rounder |
| `blush-petal` | Blush pink: playful, lifestyle and gifting | Rounded | Rounder |
| `aqua-pool` | Turquoise: fresh, health, water and travel | Rounded | Soft |
| `terracotta-clay` | Clay on sand: earthy, makers and shops | Serif headings | Crisp |
| `indigo-ink` | Periwinkle, SF Pro default: focused, pro tools | Default | Crisp |

Each style's tokens and measured contrast ratios are in `$KNOWLEDGE/styles/<id>.md`. Read only the chosen one.

## The loop for every screen

One screen per pass; polish beats breadth.

1. **Design brief before code**, in the chat: who uses the screen and for what, the one primary action, the hierarchy (first, second, third), an ASCII wireframe, and a plan for the tight spots (button rows in narrow columns, long translated labels, many items).
2. **HTML mockup, approved.** For a new or reworked screen, start from `$SKILL/scripts/mockup_kit.py starter`, save it to `docs/ui-references/mockups/<screen>.html`, show it in light and dark, and get the user's OK before writing SwiftUI. Skip it only when the change keeps the screen's layout and flow (fixing wording, tokens, controls or states on an existing screen, or a standard `Form` following a pattern the app already has), and then say in the reply that it was skipped and why. Details: `$KNOWLEDGE/review-loop.md`.
3. **Build it** with native controls, the theme tokens and the shared components (`$SKILL/assets/swift/Components.swift`), against the realistic demo seed.
4. **Look at it**: `scripts/screenshot-tour.sh <sections>` for only the sections touched, in light and dark (plus `locale` when strings changed, `ax` on iOS when layout changed). One clean run is enough. Open the PNGs and go through the review checklist below.
5. **Fix and repeat** until it passes, then tell the user which screenshots you looked at and what you changed after looking.

## Must include

- Native structure first (`NavigationSplitView`, `TabView`, `NavigationStack`, `.inspector`, `Form`, `Table`/`List`, `ContentUnavailableView`, SF Symbols). Platform specifics and known pitfalls: `$KNOWLEDGE/macos.md` or `$KNOWLEDGE/ios.md`; read the one for your platform before building.
- Navigation that shows the map (sidebar or tabs); push only to drill down; sheets only for short modal tasks.
- One primary action per screen, visually distinct and with a shortcut; destructive actions confirm and name what will be lost.
- Every value from a token (`AppTheme`, `Spacing`, `Radius`): two surface levels (canvas → card, no borders or shadows), at most one hero card, status as a chip (tint + its own `on…` text + symbol + word), text styles with at most three sizes. Where each token goes: `$KNOWLEDGE/visual-system.md`.
- Words for a person: display names for every enum, context on numbers, one-sentence help next to its control, every string translated from day one. Rules: `$KNOWLEDGE/copy-and-localization.md`.
- Every state designed: empty (with the action that fills it), loading (determinate when measurable, cancellable), error (what happened and what to do), many items.

## Review checklist

Run it against the screenshots, in light and dark, not against the code:

- [ ] Within 3 seconds you can tell where you are, what matters most and what the primary action is.
- [ ] No raw identifiers, enum cases or developer wording.
- [ ] One primary action, visually distinct. Destructive actions confirm.
- [ ] Nothing clipped, overlapping, spilling out of its card or awkwardly truncated, at the smallest and largest supported size (iOS: also the largest text size).
- [ ] Spacing and type from the tokens; at most three type sizes.
- [ ] Light and dark both look intentional; secondary text readable on every surface.
- [ ] Empty, loading, error and many-items states handled.
- [ ] Every action reachable by keyboard (macOS: in the menu bar) or by VoiceOver with a 44 pt target (iOS).
- [ ] Status shown with a badge or symbol plus text, not by color alone.
- [ ] Next to the approved mockup it looks like the same app; the second language fits (when strings changed).

## Must never

- Build several screens in one pass, or call a screen done without having looked at its screenshots.
- Let any view overlap another or extend outside its container, by even a pixel, in any state or language.
- Put a literal color, padding, corner radius or font size in a view.
- Copy a name from this skill's examples or from another product into the app's UI text.

## Must never assume

- A style without checking the project's `AGENTS.md` / `docs/ui-style.json`, or without the user's pick.
- That a color pair meets contrast because both colors belong to the style: each style file lists the measured pairs, and unlisted pairs have not been checked.
- That a screen fits because it fits in English at the default size: check the second language, the smallest window or iPhone, and the largest text size.
- The deployment target, platforms (macOS, iPhone, iPad) or languages: read them from the project or ask.

## Accumulated stack knowledge

Full definition and lessons already learned: `${CLAUDE_PLUGIN_ROOT}/knowledge/AGENTS.md` and `${CLAUDE_PLUGIN_ROOT}/knowledge/patterns/` (if there are patterns, review the ones that apply before writing). Anything learned that generalizes is promoted with `/fl:promote`.
