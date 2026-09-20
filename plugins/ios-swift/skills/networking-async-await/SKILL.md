---
name: networking-async-await
description: Apply when writing the networking layer in Swift: URLSession with async/await, Codable/CodingKeys, typed errors per layer and models that reflect the real API contract.
---

# networking-async-await

**Objective**: A modern networking layer with no completion handlers.

## Must include

- `URLSession` with `data(for:)` + `async`/`await`
- Explicit `Codable`/`CodingKeys` when the JSON does not map 1:1 to the model
- Typed errors per layer (network / decoding / domain)

## Must never assume

- An API contract without checking `acme-contracts/openapi.yaml` (the contracts repo) if the project has one — the Swift model reflects the real contract; fields are not invented

## Accumulated stack knowledge

Full definition and lessons already learned: `${CLAUDE_PLUGIN_ROOT}/knowledge/AGENTS.md` and `${CLAUDE_PLUGIN_ROOT}/knowledge/patterns/` (if there are patterns, review the ones that apply before writing). Anything learned that generalizes is promoted with `/fl:promote`.
