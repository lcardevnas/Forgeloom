---
name: swift-testing
description: Apply when writing Swift tests: Swift Testing (@Test, #expect, #require, arguments) by default, and XCTest only where the project already uses it or for UI testing.
---

# swift-testing

**Objective**: Tests that use Swift Testing as the default framework.

## Must include

- `@Test`/`#expect`/`#require` in projects on Xcode 16+
- XCTest only if the project already uses it extensively or for UI testing
- `@Test(arguments:)` instead of manual loops
- Descriptive names that state the intent

## Must never assume

- That it can be freely mixed with XCTest in the same target without checking that the setup supports it

## Accumulated stack knowledge

Full definition and lessons already learned: `${CLAUDE_PLUGIN_ROOT}/knowledge/AGENTS.md` and `${CLAUDE_PLUGIN_ROOT}/knowledge/patterns/` (if there are patterns, review the ones that apply before writing). Anything learned that generalizes is promoted with `/fl:promote`.
