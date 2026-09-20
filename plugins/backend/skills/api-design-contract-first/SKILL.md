---
name: api-design-contract-first
description: Apply when designing or adding an API endpoint: the contract (OpenAPI/GraphQL) is updated before the handler, with consistent REST conventions, limit/cursor pagination, a uniform error shape and /v1/ versioning.
---

# api-design-contract-first

**Objective**: Design the API in the contract before the handler.

## Must include

- OpenAPI/GraphQL updated in `acme-contracts/` (the contracts repo) before writing the endpoint
- Consistent REST conventions (plural resources, `limit`/`cursor` pagination, uniform error shape `{error:{code,message}}`)
- Explicit versioning (`/v1/`) from the first endpoint

## Must never assume

- That an already-published contract can be changed incompatibly without a new version

## Accumulated stack knowledge

Full definition and lessons already learned: `${CLAUDE_PLUGIN_ROOT}/knowledge/AGENTS.md` and `${CLAUDE_PLUGIN_ROOT}/knowledge/patterns/` (if there are patterns, review the ones that apply before writing). Anything learned that generalizes is promoted with `/fl:promote`.
