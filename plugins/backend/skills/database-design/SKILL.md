---
name: database-design
description: Apply when designing database schemas, queries or migrations: verified indexes, explicit eager loading against N+1, reversible non-locking migrations, and no direct destructive drops.
---

# database-design

**Objective**: Correct schemas and safe migrations.

## Must include

- Indexes on columns used in frequent `WHERE`/`JOIN`/`ORDER BY` (verify it; do not assume the ORM creates them on its own)
- Explicit eager loading to avoid N+1
- Reversible migrations, without production table locks when an online alternative exists

## Must never assume

- That a destructive migration (`DROP COLUMN`) is safe without a prior deprecation step

## Accumulated stack knowledge

Full definition and lessons already learned: `${CLAUDE_PLUGIN_ROOT}/knowledge/AGENTS.md` and `${CLAUDE_PLUGIN_ROOT}/knowledge/patterns/` (if there are patterns, review the ones that apply before writing). Anything learned that generalizes is promoted with `/fl:promote`.
