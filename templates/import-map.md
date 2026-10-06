# Import map — <project name>

source: <path to the source spec, relative to this file, e.g. source-spec.md>
sha256: <output of: shasum -a 256 <source>>

This file lives in the umbrella folder (the parent of the repos), next to the source spec. It is scaffolding for one import, not part of any repo. `plugins/fl/scripts/import-check.sh` reads it.

One table row per contiguous block of source lines. The columns, in order:

- **ID**: `R1`, `R2`, ...
- **Lines**: `N` or `N-M`, the block's lines in the source file.
- **Section**: the source heading the block belongs to (a label for the human reader).
- **Destination**: `<repo folder>/<path>`, relative to this file. Examples: `AcmeProductAppleApp/specs/login.md`, `AcmeProductBackend/docs/data-model.md`, `AcmeProductContracts/openapi.yaml`. Leave it as `-` for `dropped`.
- **Treatment**:
  - `verbatim`: every line of the block appears, word for word, in the destination.
  - `openapi`: the same, inside the `description` of the matching operation or schema in `openapi.yaml`.
  - `dropped`: the block is not project content (a document title, chat pleasantries). Never use it because text looks outdated or contradicted: keep it and list it under Open questions.
- **Notes**: required for `dropped` (the reason); free text otherwise. No `|` characters inside cells.

Every non-blank source line must be in at least one row. A block that applies to several repos gets one row per repo, with the same lines.

| ID | Lines | Section | Destination | Treatment | Notes |
|----|-------|---------|-------------|-----------|-------|
| R1 | 1-1 | <title> | - | dropped | document title only |

## Open questions

<Contradictions between iterations of the source, blocks whose destination is unclear, features whose platform scope is unclear. If none, write "none".>
