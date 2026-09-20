---
name: observability-logging
description: Apply when adding logging to a backend: structured JSON with level and request ID, never passwords/tokens/cards/PII, and levels that let you silence detail in production.
---

# observability-logging

**Objective**: Structured logging that does not expose sensitive data.

## Must include

- Structured JSON with level and request ID, not stray `print`
- Never log passwords/tokens/cards/PII — ties into the existing secret-scanning hook (`common/hooks/`)

## Must never assume

- That verbose development logging is acceptable in production without being able to turn it off by level

## Accumulated stack knowledge

Full definition and lessons already learned: `${CLAUDE_PLUGIN_ROOT}/knowledge/AGENTS.md` and `${CLAUDE_PLUGIN_ROOT}/knowledge/patterns/` (if there are patterns, review the ones that apply before writing). Anything learned that generalizes is promoted with `/fl:promote`.
