# Copy and localization

Part of `professional-apple-ui`.

## Words

- **Never show raw identifiers.** Enum raw values (`awaitingManualImport`), ids and keys (`refinedRgbaAsset`), dot paths (`Validate.assets`), ISO codes (`en`), file paths and error type names never reach the screen. Every user-facing enum gets a `displayName` (and a `symbolName` if it's a status). Keep them together in one file (`Domain/DisplayNames.swift`), so a missing one is easy to spot.
- **Name things by what they are.** A design is called "Pumpkin Sticker", not "Design imported 23 Sep 2026 at 1:57". Default names come from the content: a file name, a concept or a title.
- **Numbers get context.** Write "3 of 40 listings", not "Work items created: 3". Write "2 need you today", not "Pending: 2".
- **Write for the person using the app.** A developer note ("App Sandbox default", "not available offline", "requires provider") gets rewritten for the user ("Saved in your Pictures folder", "Needs a connection") or removed.
- **One sentence of explanation, next to its control.** Longer help goes behind a `?` / `.help()` or into documentation.
- **Case:** Title Case for buttons, menu items, window and navigation titles and tab names. Sentence case for everything else: labels, messages, section headers and chips.
- **Errors say what happened and what to do:** "Couldn't reach Dropbox. Check your connection and try again." Never write "Error 403" or "Something went wrong".
- **Destructive confirmations name what will be lost:** "Delete 'Autumn Stickers' and its 24 designs? This can't be undone."
- **Buttons are verbs** that name the result ("Build Pack", "Create Draft"), not "OK" or "Submit". The Cancel and Done that the platform places are the exception.

## Localization

Every string is translated from the first screen. Adding translation later means touching every view again, and untranslated strings are the easiest defect to ship without noticing.

- `Text("…")`, `Button("…")`, `Label("…", systemImage:)` and other SwiftUI literals are localized automatically.
- Any string that reaches the screen as a plain `String` goes through `L("…")` (the skill's `assets/swift/Localization.swift`). That includes display names, messages, a component's `String` parameter and anything built with interpolation. `L` takes a `LocalizedStringResource`, so Xcode extracts its literals into `Localizable.xcstrings`.
- **Whole sentences, numbers inside:** `L("\(count) designs ready")`. Never glue fragments (`"\(count) " + L("designs")`), because word order differs between languages. Use the catalog's plural variants for counts.
- **Add the translations by hand when needed.** `xcodebuild` doesn't always sync the catalog. After adding strings, check that `Localizable.xcstrings` has each key with its translation.
- **Leave room.** Spanish, French and German run 20–35 % longer than English. Every label in a fixed-width spot (toolbar buttons, chips, narrow columns, tab titles) needs a fallback: wrap, a shorter label, or `ViewThatFits`. Check it with the tour's `locale` mode.
- Format dates, numbers, currencies and file sizes with `.formatted()` / `FormatStyle` so they follow the locale. Never build them by hand.
- A text meant for someone other than the user (a buyer, a recipient) follows that person's language, not the interface language. Decide it explicitly.
