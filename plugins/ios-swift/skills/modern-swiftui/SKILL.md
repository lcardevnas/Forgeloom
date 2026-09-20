---
name: modern-swiftui
description: Apply when writing or modifying SwiftUI views: @Observable, decomposing body, spring/easeInOut animations and built-in accessibility. Use it on any new SwiftUI view.
---

# modern-swiftui

**Objective**: Views written with the current API, not iOS 13-14 patterns.

## Must include

- `@Observable` (Observation) instead of `ObservableObject`/`@Published`, unless the project already uses that pattern
- Break `body` into subviews when it exceeds ~30-40 lines
- `.spring()` for direct user interactions, `.easeInOut` for state transitions
- Accessibility built in as you write (`accessibilityLabel`/`accessibilityHint`, Dynamic Type respected)

## Must never assume

- That `@Observable` is available without checking the deployment target (requires iOS 17+)
- A visual style without checking whether the project already has its own design system

## Accumulated stack knowledge

Full definition and lessons already learned: `${CLAUDE_PLUGIN_ROOT}/knowledge/AGENTS.md` and `${CLAUDE_PLUGIN_ROOT}/knowledge/patterns/` (if there are patterns, review the ones that apply before writing). Anything learned that generalizes is promoted with `/fl:promote`.
