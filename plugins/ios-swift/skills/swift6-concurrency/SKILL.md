---
name: swift6-concurrency
description: Apply when writing Swift code that uses concurrency (async/await, Task, actors, @MainActor, Sendable) or when fixing isolation warnings under Swift 6 strict concurrency.
---

# swift6-concurrency

**Objective**: Code that compiles in strict concurrency mode with no isolation warnings.

## Must include

- Explicit `Sendable` on anything that crosses concurrency boundaries
- Never `@unchecked Sendable` without a comment justifying why it is safe
- `@MainActor` on anything that touches UI
- Explicit cancellation in long-running `Task`s

## Must never assume

- That the project is already in strict mode — check the Swift target first
- That a non-`Sendable` type can become `Sendable` without checking whether it is truly thread-safe

## Accumulated stack knowledge

Full definition and lessons already learned: `${CLAUDE_PLUGIN_ROOT}/knowledge/AGENTS.md` and `${CLAUDE_PLUGIN_ROOT}/knowledge/patterns/` (if there are patterns, review the ones that apply before writing). Anything learned that generalizes is promoted with `/fl:promote`.
