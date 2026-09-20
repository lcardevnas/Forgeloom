---
name: auth-patterns
description: Apply when implementing authentication or authorization in a backend: short-lived JWT with a refresh token, ownership verification on every endpoint that touches user data, and bcrypt/argon2 hashing.
---

# auth-patterns

**Objective**: Correct authentication/authorization.

## Must include

- JWT with short expiry + refresh token
- Verification of resource *ownership* on every endpoint that accesses user data (being authenticated is not enough)
- Hashing with bcrypt/argon2

## Must never assume

- That logging tokens/passwords while debugging is harmless — never

## Accumulated stack knowledge

Full definition and lessons already learned: `${CLAUDE_PLUGIN_ROOT}/knowledge/AGENTS.md` and `${CLAUDE_PLUGIN_ROOT}/knowledge/patterns/` (if there are patterns, review the ones that apply before writing). Anything learned that generalizes is promoted with `/fl:promote`.
