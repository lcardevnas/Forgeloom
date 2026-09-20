---
name: swiftdata-persistence
description: Apply when modeling data with SwiftData: @Relationship with explicit delete rules and a versioned SchemaMigrationPlan when the model changes with real data.
---

# swiftdata-persistence

**Objective**: Correct data modeling and safe migrations.

## Must include

- `@Relationship` with delete rules (`.cascade`/`.nullify`) declared on purpose
- A versioned `SchemaMigrationPlan` as soon as the model changes with real user data in production

## Must never assume

- That CloudKit sync is enabled without checking
- That you must migrate from Core Data to SwiftData if the project already uses Core Data and no migration was requested

## Accumulated stack knowledge

Full definition and lessons already learned: `${CLAUDE_PLUGIN_ROOT}/knowledge/AGENTS.md` and `${CLAUDE_PLUGIN_ROOT}/knowledge/patterns/` (if there are patterns, review the ones that apply before writing). Anything learned that generalizes is promoted with `/fl:promote`.
