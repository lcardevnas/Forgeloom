# Visual system

Part of `professional-apple-ui`.

Every value comes from `Theme.swift` (generated from `docs/ui-style.json`). A literal color, padding, font size or corner radius in a view is a bug. The reason is practical: light and dark, a second platform and a later restyle all happen in one file instead of in every view.

## Color tokens: where each one goes

| Token | Use | Never |
| --- | --- | --- |
| `canvas` | Window / screen background | As a card fill |
| `sidebar` | Sidebar (macOS, iPad), tab bar tint surface | |
| `card` | Cards | Nested inside another card |
| `well` | Image wells, inset areas and empty progress tracks inside a card | As a third surface tone of its own |
| `checker` | Second square of the transparency checkerboard | |
| `line` | Hairlines between compact rows inside one card | Around cards (cards have no borders) |
| `text` | Titles and body | Pure black or white instead |
| `text2` | Secondary text, meta, captions | On a tint |
| `text3` | Placeholders, decorative labels, disabled | For anything the user has to read |
| `hero` / `onHero` / `chipOnHero` | The one hero card per screen: its fill, its text, the chips inside it | On more than one card per screen |
| `accent` | Progress fills, done state, sidebar symbols | As text or as a tint for text (too light); as a large fill |
| `primary` / `onPrimary` | The primary button; also the app's `AccentColor`, which tints tab labels, links and toolbar items | On secondary buttons |
| `brandTint` / `onBrandTint` | Brand or done chips, the selected sidebar row | |
| `info` / `onInfo` | In progress, informational | |
| `plan` / `onPlan` | Planning, drafts, secondary categories | |
| `attention` / `onAttention` | Needs the user: review, warnings, missing things | |
| `danger` / `onDanger` | Failed, destructive, broken limits | Decoration |
| `…Strong` (`infoStrong`…) | Solid dots, small indicators, stage bars, graph series | Text on a tint |

**Tints always pair with their own text color:** `info` with `onInfo`, and so on. Black, gray or `text2` on a tint looks dirty and fails contrast. Status is never shown by color alone either: every chip has a symbol and a word.

## Surfaces

There are two levels: the canvas, and the cards on it. An image well inside a card uses `well` (the canvas tone), never a third shade. Cards have no borders and no drop shadows. The tone difference between canvas and card is the separation, and it holds in dark mode because the dark tokens keep the same order of lightness.

## Type

Use the style's font design everywhere (`AppTheme.bodyDesign` at the root, `AppTheme.headingDesign` on titles). Build hierarchy from heavy weights, not from many sizes, and use at most three sizes per screen. Map everything onto text styles, so Dynamic Type (iOS) and accessibility sizes keep working:

| Role | Text style | Roughly |
| --- | --- | --- |
| Page greeting / title | `.largeTitle.bold()` | 32 bold |
| Section header | `.title3.bold()` | 18 bold |
| Card title | `.headline` | 15–17 semibold |
| Stat number | `.title.bold()` with `.monospacedDigit()` | 28 bold |
| Body, meta | `.body` / `.subheadline` in `text2` | 13–15 regular |
| Chips, badges | `.caption.weight(.semibold)` | 11–12 semibold |

## Spacing

A 4 pt scale: `xs 4`, `s 8`, `m 12`, `l 18`, `xl 24`, `xxl 36`.
- Card padding is 22, and 26 on the hero card. The gap between cards is 18.
- The macOS detail pane has insets of 36 horizontal and 26 top. On iPhone, use the system margins (`.contentMargins` / `.scenePadding()`) plus `l` between cards.
- Within a card, `m` separates related elements and `l` separates groups.

## Shapes

- `Radius.hero` for the hero card, `Radius.card` for cards, `Radius.tile` for image wells and big thumbnails, `Radius.thumbnail` for small ones. Use `.continuous` corner style (`RoundedRectangle(cornerRadius:style: .continuous)`).
- Buttons, chips, badges and the search field are capsules. Icon-only buttons are circles.
- SF Symbols on stat cards sit in 40 pt tinted circles (`IconCircle`), using the role tint and its `on…` color, with `.symbolRenderingMode(.hierarchical)`.

## Density

Be generous but never wasteful. A screen's most important blocks fit without scrolling at its reference size (macOS 1440×900 for a dashboard, the smallest supported iPhone for the first screen). Collections of many items use compact rows inside one card, not one card per row. One card per row is right only for a few rich items.

## Dark mode

Check it on its own; it isn't the light mode inverted. The dark tokens deepen and desaturate the tints and lighten their text. Look for secondary text fading into cards, for chips that glow, and for the hero card becoming the loudest thing on screen. Thumbnails of transparent art need a neutral well (or the checkerboard) in both modes.

## Custom views

A custom view (a canvas, an image preview, a chart) still:
- opens at a sensible framing (zoom to fit, content centered), never clipped or scrolled to an arbitrary offset;
- uses the tokens: a subtle dot grid in `line` on `canvas` for a workspace, and a `well` or checkerboard for images;
- has an accessible alternative for anything mouse- or gesture-only (a list view of a node graph, for example).

## Changing the style later

Edit `docs/ui-style.json` (or regenerate it with `make_style.py`), run `check_style.py`, regenerate `Theme.swift`, and run the whole tour, because this change reaches every screen. Never hand-edit colors in `Theme.swift`.
