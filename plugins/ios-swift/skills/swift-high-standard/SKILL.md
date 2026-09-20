---
name: swift-high-standard
description: Apply when writing or modifying Swift code: naming per Apple's API Design Guidelines, struct/enum by default, guard, multi-binding if let, and no force unwrapping. Use it on any Swift coding task.
---

# swift-high-standard

**Objective**: Idiomatic Swift code following Apple's API Design Guidelines.

## Must include

- Naming that reads as phrases (`remove(at index:)`, not `getX()`)
- `struct`/`enum` by default; `class` only for reference identity or real inheritance
- `guard` for early returns
- `if let a, let b` instead of nesting
- Avoid `!`/`try!` outside tests

## Must never assume

- That the project uses SwiftLint without checking whether a `.swiftlint.yml` exists
- The Swift/iOS version without reading it from `Package.swift`/`AGENTS.md`

## Accumulated stack knowledge

Full definition and lessons already learned: `${CLAUDE_PLUGIN_ROOT}/knowledge/AGENTS.md` and `${CLAUDE_PLUGIN_ROOT}/knowledge/patterns/` (if there are patterns, review the ones that apply before writing). Anything learned that generalizes is promoted with `/fl:promote`.
