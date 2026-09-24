# iOS and iPadOS

Part of `professional-apple-ui`.

The model is Apple's own iPhone apps: Health, Fitness, Reminders and Photos. The same soft card style and tokens as on macOS, with a touch-first shell. On iPad, lean toward the macOS rules (sidebar, inspector, keyboard) through `NavigationSplitView`, which collapses to a stack on iPhone.

## Structure

- **Tab and link tint** comes from `AccentColor`, which is the style's `primary` (see project-setup.md). The light `accent` is unreadable as small tab labels.
- **Tabs are the map on iPhone.** `TabView` with 3–5 tabs, each a `NavigationStack`, and one tab per top-level area. Badges go on tabs that hold work waiting for the user. Anything beyond 5 areas goes under a "More"-style tab or into Settings, never behind a hamburger menu.
- **iPad:** a `NavigationSplitView` with a sidebar (or `TabView` with `.tabViewStyle(.sidebarAdaptable)`), an `.inspector` for the selected item's properties, and multi-column layouts at full width. Check it at both full screen and Split View widths.
- **Home is a dashboard,** as on macOS, adapted to one column: a greeting with one line on what needs attention, the hero card, a two-column grid of stat cards, then lists. The first screen fits its most important blocks on the smallest supported iPhone without scrolling.
- **Push to drill down** with `NavigationStack` and `navigationDestination(for:)`. Large titles (`.navigationBarTitleDisplayMode(.large)`) on the root of each tab, inline titles when pushed.
- **Sheets are for short tasks:** create, edit one thing, confirm. Use detents (`.presentationDetents([.medium, .large])`) when the content is small. Sheets are natural on iOS for these; a work queue or an editor the user lives in is still a tab or a pushed screen.
- **Settings** is a `Form` (inset grouped) in its own tab or pushed from the profile. Apply the style's tokens to its background and rows only if they still look native.

## Controls

| Need | Use | Don't |
| --- | --- | --- |
| App shell | `TabView` + `NavigationStack` per tab (iPad: `NavigationSplitView` or `.sidebarAdaptable`) | A custom tab bar or hamburger menu |
| Many items | `List` rows, or compact rows inside one card in a `ScrollView` + `LazyVStack` | One card per row for many items |
| Settings, properties | `Form`, `LabeledContent`, `Toggle`, `Picker` | Raw `VStack`s |
| Numbers | `TextField(value:format:)` with `.keyboardType(.decimalPad)`, or a `Stepper` in `LabeledContent` | A free text field for a number |
| Status | `StatusChip` (tint + symbol + text) | Color alone |
| Empty, error, first run | `ContentUnavailableView` with an action | A caption in the middle of nothing |
| Primary action | Bottom of the content, or a `.confirmationAction` toolbar item in sheets; `.borderedProminent` in `primary`, full width where it ends a flow | Several prominent buttons on one screen |
| Secondary actions on a row | `.swipeActions` plus the same actions in `.contextMenu` | Actions only reachable by swipe |
| Destructive action | `role: .destructive` + `.confirmationDialog` | Instant deletion |
| Refresh | `.refreshable` | A refresh button on a list |
| Search | `.searchable` | A custom search field |

## Touch and interaction

- **Targets are at least 44×44 pt**, even when the visible glyph is smaller (`.contentShape` + padding). Keep destructive buttons away from frequent ones.
- **The primary action is in thumb reach:** at the bottom of the content or in the bottom toolbar on long screens, or top-right in sheets.
- **Everything a swipe or long-press does is also reachable another way,** such as a context menu, an edit mode or a detail screen. Gestures aren't discoverable.
- **Haptics** confirm meaningful outcomes (`.sensoryFeedback(.success, trigger:)` when something finishes), never every tap.
- **Keyboard:** fields have the right `.keyboardType`, `.textContentType` and `.submitLabel`, and focus moves to the next field on return (`@FocusState`). On iPad with a keyboard, add `.keyboardShortcut` to the main commands; they show in the ⌘-hold overlay.
- **Progress:** the same as macOS. Use determinate progress when measurable, say what is happening, and make it cancellable. Long work that continues in the background should say so.

## Dynamic Type and sizes

- Use text styles only, never fixed font sizes, so the whole screen scales. At accessibility sizes, horizontal rows must reflow: switch `HStack` to `VStack` with `ViewThatFits` or `@Environment(\.dynamicTypeSize)`, let text wrap instead of truncating, and scroll instead of clipping.
- Run the tour's `ax` mode on every screen with a layout change. The largest size is where overlaps and clipped text show up first.
- Check the smallest supported iPhone (the SE / mini class width, 375 pt) and the largest (Pro Max class, 440 pt), plus landscape if supported. Point `DESTINATION` at the small device when adding the tour, and add a second run for the large one if layouts differ.
- Respect safe areas. Backgrounds (`canvas`) extend under them with `.ignoresSafeArea()` on the background only, never on the content.

## Spacing on iPhone

Use the system margins (`.scenePadding()` or `.contentMargins`), not the macOS 36 pt insets. Cards keep their internal padding (22, or `l` 18 on compact width if the content is dense) and an `l` gap between them. The hero card spans the full content width.

## Pitfalls

- A `List` puts its own background and insets around rows. To show the card style, hide it (`.scrollContentBackground(.hidden)`, and `.listRowBackground` in `card`), or use a `ScrollView` with `LazyVStack`.
- `.preferredColorScheme` works as expected on iOS, so apply it at the root with `.appAppearance(mode)`. The macOS toolbar problem doesn't apply here.
- `XCUIScreen.main.screenshot()` includes the status bar. Set the simulator's status bar to a clean state before the tour (`xcrun simctl status_bar booted override --time 9:41 --batteryLevel 100 --cellularBars 4`), so screenshots compare cleanly.
- Sheets with a text field: test with the keyboard up. The primary button must stay visible, or be reachable by scrolling.
