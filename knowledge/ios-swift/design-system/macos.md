# macOS

Part of `professional-apple-ui`.

The model is Photos, Pixelmator Pro and Finder: a sidebar, a toolbar, selection, an inspector and keyboard commands. The soft card style lives in the detail pane. The shell stays native.

## Structure

- **The sidebar is the map of the app.** `NavigationSplitView` with a `List(.sidebar)`. Top-level areas are sidebar destinations, not toolbar buttons buried in a detail pane: a *Home* dashboard selected on launch, work queues with count badges, then the user's collections (expandable into their children). Account and Settings sit at the bottom. Don't give the sidebar a custom background.
- **Home is a dashboard:** a greeting with one line on what needs attention, the one hero card for the most urgent thing, stat cards, running work with progress, and recent items. Every card leads somewhere; nothing on it is only decoration.
- **Push only to drill down** (collection → item → detail). Use a `NavigationStack` in the detail column, reset with `.id(selection)` when the sidebar selection changes, so a stale pushed screen can't survive a switch.
- **The inspector (`.inspector`)** shows the properties of the selected thing, instead of a long page that scrolls past them.
- **Sheets are only for short modal tasks.** Work queues and editors are sidebar destinations or pushed screens.
- **Settings** is a `Settings { }` scene (⌘,) with tabs, each a `Form` with `.formStyle(.grouped)`.
- **Windows** get a minimum size (for example `.frame(minWidth: 1100, minHeight: 700)`), and every screen works at that size and at full screen. The window title always says where the user is, never the app's bundle name.

## Controls

| Need | Use | Don't |
| --- | --- | --- |
| App shell | `NavigationSplitView` + `List(.sidebar)` | A custom sidebar |
| Tabular data | `Table` with sortable columns | Hand-built `HStack` rows |
| Settings, properties | `Form` + `.formStyle(.grouped)`, `LabeledContent` | Raw `VStack`s of labels |
| Numbers | `TextField(value:format:)` + a small `Stepper` in a `LabeledContent` | `Stepper("Label: \(n)")` |
| Status | A `StatusChip` (capsule, tint, symbol + text) | Plain gray text |
| Empty, error, first run | `ContentUnavailableView` with an action | A caption in the middle of nothing |
| Icons | SF Symbols, `.symbolRenderingMode(.hierarchical)` | Custom images for standard concepts |
| Primary action | `.borderedProminent` (tinted `primary`), in the toolbar or at the end of its section, with `.keyboardShortcut` | A plain gray button in its own `Form` section |
| Destructive action | `role: .destructive` + `.confirmationDialog` | Instant deletion |
| Choosing among few | `Picker(.segmented)` or a capsule segmented control | A menu for 2–3 options |

## Toolbar

- Buttons have visible text labels whenever the meaning isn't universal (`.labelStyle(.titleAndIcon)`). Only add, share, the sidebar toggle and search may be icon-only, and every icon-only button has a `.help()` tooltip.
- Group related items. The primary action goes last (rightmost).
- The toolbar must fit at the minimum window width in every language. Check that nothing collapses into the overflow chevron at launch.

## Selection and interaction

- **Every list or grid supports selection,** including multi-select (⌘-click and ⇧-click), a context menu that mirrors the toolbar's actions, and batch actions for the selection ("Process 8 Designs").
- **Keyboard:** every command is in the menu bar (`.commands`) with a shortcut. ⌘N for new, ⌘I for import, ⌘R for run, ⌘⌫ for delete (with confirmation), Space for Quick Look on a selected item, ⌘1…⌘9 for the sidebar areas. Tab order follows the visual order.
- **Hover** reveals secondary actions on cards and rows, never the primary ones.
- **Drag and drop** wherever it's natural (files onto the library, onto a row, onto a step), with a visible drop highlight.
- **Progress** is determinate when the work is measurable ("Cleaning up alpha, 3 of 6") and cancellable. Use an indeterminate indicator only for external calls.
- Without undo, destructive actions confirm and name what will be lost. With undo, prefer undo over confirmation.

## Pitfalls met in practice

- **`.preferredColorScheme` on the WindowGroup's root content** (even set to `nil`) changed the window's identity and left its toolbar collapsed into the overflow menu at launch. Apply appearance through `NSApp.appearance` from inside the root view (`assets/swift/Appearance.swift`). Apply `.fontDesign` inside the root view too, not around it.
- **`@Query(filter:)` built in `init`** in a view pushed from another view that also queries made the window re-layout forever, until AppKit aborted ("more Layout Window passes than views"). Each parent redraw rebuilt the child's query, and every refetch redrew the parent. Use a fixed `@Query` and filter in code, or pass the data down.
- **Banners above the detail pane:** use `.safeAreaInset(edge: .top)`. Stacking the banner in a `VStack` with `fixedSize` text made the window taller than the screen.
- **Accessibility identifiers for UI tests.** An identifier on a container fans out to its children unless the container has `.accessibilityElement(children: .contain)`, and then it's found as `app.groups[…]`, not `app.otherElements[…]`. An identifier on a `ScrollView` is `app.scrollViews[…]`.
- **Popovers near a window edge** extend past the window. macOS keeps them on screen, but a window screenshot crops them. Anchor popovers so they open inward, or screenshot the popover element.
- **A second `Scene`** (the Settings window) is flaky to open from UI tests after another test in the same run. Prefer a launch flag that opens the app straight into that screen for the tour.
- **Screenshot tour:** click only, and never send keystrokes. If the app isn't frontmost, keystrokes go to whatever app is.
