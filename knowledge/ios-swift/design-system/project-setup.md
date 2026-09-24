# Project setup (once per project)

Part of `professional-apple-ui`. Do this before building the first screen, or when bringing an existing app under the skill. `$SKILL` below is the skill's folder: `${CLAUDE_PLUGIN_ROOT}/skills/professional-apple-ui` with the Claude Code plugin, or `plugins/ios-swift/skills/professional-apple-ui` in a Forgeloom checkout. Its scripts need Python 3 (included with Xcode's Command Line Tools); the styles and these docs are plain files and work without it.

## 1. Choose the style with the user

The look is the user's call, so show them the options instead of picking one:

```bash
open "$SKILL/assets/style-gallery.html"
```

The gallery shows the same small dashboard in each style, in light and dark, with a "Use this style" button that copies the style's id. Each style's tokens and measured contrast are also in `styles/<id>.md` next to this file. The 10 presets:

| id | Feel | Type | Corners |
| --- | --- | --- | --- |
| `mint-studio` | Mint hero on a warm light-grey canvas (the original reference style) | Rounded | Soft |
| `sky-harbor` | Sky blue on a cool canvas: calm, for utilities and planners | Rounded | Soft |
| `lavender-loft` | Lilac: dreamy, for journaling and art tools | Rounded | Soft |
| `peach-bakery` | Apricot on cream: warm, for food, home and hobbies | Rounded | Soft |
| `sage-garden` | Muted sage: quiet, for reading and wellbeing | Serif headings | Crisp |
| `butter-sun` | Butter yellow with dark button text: cheerful | Rounded | Rounder |
| `blush-petal` | Blush pink: playful, for lifestyle and gifting | Rounded | Rounder |
| `aqua-pool` | Turquoise: fresh, for health, water and travel | Rounded | Soft |
| `terracotta-clay` | Clay on sand: earthy, for makers and shops | Serif headings | Crisp |
| `indigo-ink` | Periwinkle, SF Pro default: focused, for pro tools | Default | Crisp |

`mint-studio` is kept exactly as it was approved, including five pairs below WCAG AA (its file lists them). Every other preset passes `check_style.py`. If the user wants Mint for a new app, offer the AA copy: `make_style.py --id mint-studio-aa --name "Mint Studio AA" --brand "#58B893"`.

**A custom style.** Ask for a brand color (hex, or a description you turn into one) and optionally: canvas (`warm`, `cool`, `neutral` or `brand`-tinted), type (`rounded`, `default` or `serif` headings), corners (`soft`, `rounder` or `crisp`) and saturation (`--vivid 0.6…1.3`). The four role hues are `--info` (blue), `--plan` (purple), `--attention` (orange) and `--danger` (red). Move a role hue only when it lands too close to the brand hue, so that "done" and "failed" still read differently.

```bash
python3 "$SKILL/scripts/make_style.py" --id ocean-desk --name "Ocean Desk" --brand "#3E8FB0" \
  --canvas cool --font default --corners crisp > docs/ui-style.json
python3 "$SKILL/scripts/check_style.py" docs/ui-style.json
python3 "$SKILL/scripts/mockup_kit.py" gallery /tmp/style-preview.html docs/ui-style.json && open /tmp/style-preview.html
```

Show the preview and adjust until the user likes it. For a preset, write its entry to the project as-is:

```bash
python3 "$SKILL/scripts/mockup_kit.py" export sky-harbor > docs/ui-style.json
```

`docs/ui-style.json` is the project's source of truth for the look. It's versioned with the code, so the theme can be regenerated and later mockups use the same tokens. Also record the choice in the project's `AGENTS.md`, one line: `UI style: <id>` (custom styles: `UI style: custom, docs/ui-style.json`), so later sessions use it without asking.

## 2. Generate the theme

```bash
python3 "$SKILL/scripts/make_theme.py" docs/ui-style.json MyApp/UI/Theme/Theme.swift --platform both   # or macos / ios
```

This writes `AppTheme` (every token, light and dark), `Spacing` (the 4 pt scale), `Radius` and the two font designs. Apply the font design once at the root (`.fontDesign(AppTheme.bodyDesign)`), and use `AppTheme.headingDesign` on titles when it differs (serif styles). Project-specific tokens go in a separate `extension AppTheme`, so regenerating never loses them. Set the asset catalog's `AccentColor` to the style's `primary` (light and dark values), not `accent`. The system tints text with it (tab bar labels, links, toolbar buttons, `.borderless` buttons), and `accent` is too light to read as text. Use `AppTheme.accent` explicitly where a light fill is wanted: progress fills, done states and sidebar symbols.

Next to the theme, copy `assets/swift/Components.swift`: the component set every screen reuses, built only from tokens. It has `.card()` / `.heroCard()` / `.pageBackground()`, `StatusChip(title, symbol:, role:)`, `CountBadge`, `IconCircle`, `CapsuleButtonStyle(.primary / .secondary / .destructive)`, `SectionHeader`, `PillProgressBar` and `CheckerboardBackground`. `ToneRole` picks a tint and its text color together, so a tint never gets the wrong text. Extend these instead of restyling per screen.

## 3. Appearance and localization

- Copy `assets/swift/Appearance.swift` and `assets/swift/Localization.swift` into the app. Store `AppearanceMode` with `@AppStorage("appearanceMode")` and apply it with `.appAppearance(mode)` inside the root view's body. Don't apply it at the `WindowGroup` level on macOS; `macos.md` explains why.
- Add `Localizable.xcstrings`. Ask the user which languages the app ships in; English plus one is typical. Every string gets translated from the first screen, because retrofitting translation later means touching every view twice.

## 4. The review loop

- Add a UI test target if there isn't one. Copy `assets/tour/ScreenshotTourUITests.swift` into it, and `assets/tour/screenshot-tour.sh` to `scripts/`, then set `PROJECT`, `SCHEME`, `UI_TEST_TARGET` and `DESTINATION` at its top. Add `screenshots/` to `.gitignore`.
- In the app's entry point, read `UI_TESTING=1`: use an in-memory store, stand-ins for every network service (answering after a short delay, so loading states show), and skip onboarding. When `UI_TESTING_SEED_DEMO=1` is also set, fill the store from a `UITestingDemoSeed`. What goes in the seed is in [review-loop.md](review-loop.md).

## 5. Tell future sessions

Add to the project's `AGENTS.md`:

```markdown
## UI work
UI style: <id>
Every SwiftUI change follows `professional-apple-ui`: design brief, approved mockup in docs/ui-references/mockups/, then `scripts/screenshot-tour.sh <section>` in light and dark and the skill's review checklist. Tokens come from docs/ui-style.json (Theme.swift is generated from it).
```

A project may keep its own `docs/ui-guidelines.md` for app-specific rules: its sidebar areas, its keyboard shortcuts, its hero content. Those rules add to the skill and don't repeat it.
