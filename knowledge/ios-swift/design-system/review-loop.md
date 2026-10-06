# The review loop: mockups, demo data, screenshots

Part of `professional-apple-ui`. `$SKILL` is the skill's folder (see `project-setup.md`).

## Mockups

A mockup settles layout, hierarchy and wording while changing them is still cheap. The user approves the mockup, not the idea. Keep approved mockups in `docs/ui-references/mockups/`; they are the reference each built screen is compared against.

```bash
python3 "$SKILL/scripts/mockup_kit.py" starter docs/ui-style.json docs/ui-references/mockups/library.html --platform macos --title "Library"
```

The starter has the style's tokens as CSS variables, the component classes (`.card`, `.hero`, `.chip.info`, `.btn.primary`, `.btn.secondary` (on the canvas and in toolbars), `.btn.ghost` (inside cards only), `.search`, `.circle.plan`, `.num`, `.t1`/`.t2`/`.t3`, `.bar`, `.row`, `.tile`), a light/dark toggle, and a frame: a 1280×800 window with a sidebar and toolbar, or a 393×852 phone with a tab bar. Build the screen inside `<!-- screen -->`. For icons, the Tabler webfont is linked; pick glyphs that match the SF Symbol you'll use.

Rules for mockups:

- **Same tokens as the app.** Use only the CSS variables and the type scale; add no new colors. If a mockup needs a color the style lacks, that's a style decision to take to the user.
- **Real content.** Use real names, real numbers and the longest realistic strings, plus the translated version of the longest label. Lorem ipsum hides every truncation problem.
- **Show the hard states** as extra frames or toggles: empty, error, many items, and the narrowest column.
- **Nothing overflows,** not even by a pixel. Check every card edge at the frame's width. A button row that doesn't fit gets its fallback now (wrap, stack or a shorter label), not in SwiftUI later.
- **Show both modes** before asking for the OK. The toggle is there for that.
- Where a mockup and SwiftUI disagree for a good reason (a control behaves differently, a label is too long in Spanish), update the mockup to match. The mockup stays the truth.

## Demo seed

Screens built against one test item hide density, truncation and hierarchy problems, so the tour runs against a seed that looks like a real user's data three months in:

- several of each top-level thing (collections, projects, accounts), with realistic names of different lengths, including one long name;
- lists with 8–30 items, so scrolling and compact rows get exercised;
- every status the model has (queued, running, needs attention, failed, done) present somewhere;
- one entity in each empty, error and partially done state the screens handle;
- real images (generated shapes are fine) rather than gray boxes, because thumbnails change how a screen reads.

Extend the seed in the same change that needs it. Stand-in services, under `UI_TESTING`, answer after a short delay (about 2 s), so loading and progress states can be screenshotted.

## Running the tour

```bash
scripts/screenshot-tour.sh home library              # light and dark
scripts/screenshot-tour.sh -m light,dark,locale home # plus the second language
scripts/screenshot-tour.sh -m ax library             # iOS: largest Dynamic Type
```

- **Run only the sections you touched.** The whole tour is for changes that reach every screen, such as the theme or a shared component. A full run is slow, and slowness makes people skip the loop.
- **One clean run is enough.** If it passed and the screenshots are fine, don't rerun it "to confirm".
- **Each new screen gets a section, and each new state a step.** Name screenshots with a number and the state (`04-library-empty`, `04b-library-selection`) so they sort in tour order.
- On macOS the tour clicks only and never sends keystrokes. If the app isn't frontmost, keystrokes land in whatever app is (in one project they opened Finder windows). Reach every state by clicking an accessibility identifier, or by a launch-environment flag that opens the app in that state (`UI_TESTING_OPEN_SETTINGS=1`).
- Drive by accessibility identifiers (`library.importButton`), not by visible text, so the locale run works without a translation table.

## Reading the screenshots

Open the PNGs (`screenshots/<timestamp>/`) and look at each changed one. Don't skim; go through the review checklist of `professional-apple-ui` (in `knowledge/ios-swift/AGENTS.md` and the skill), in this order:

1. **Squint test.** In 3 seconds: where am I, what matters most, what's the primary action?
2. **Edges.** Go around every card, button row, chip group and column: nothing crosses a boundary or touches its neighbor, and nothing is clipped or cut mid-word.
3. **Words.** No raw identifiers, and correct case: Title Case on buttons, menus and window titles; sentence case everywhere else.
4. **Tokens.** Radii, padding and type sizes look like the mockup, with no stray gray text on a tint.
5. **Dark.** The dark screenshot gets its own pass. It must look designed, not inverted, and secondary text must stay readable.
6. **States.** Empty, loading, error and many items: each one has a screenshot and each one looks intended.

Fix what you find and rerun only those sections. When you report back, name the screenshots you looked at and what you changed after looking. "Built and tests pass" says nothing about how a screen looks.
