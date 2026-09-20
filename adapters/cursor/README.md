# Cursor adapter

There is no automatic converter yet: the mapping below is manual.

## What Cursor already does on its own

Cursor natively reads `AGENTS.md` in the project root and in subdirectories (more specific files take precedence). So the simplest adapter is the generic installer, which puts the stack's `AGENTS.md` in your project:

```bash
./install.sh ios-swift /path/to/your/project
```

## Scoping a stack's knowledge to certain files (optional)

If you want the knowledge to apply only when certain files are in play, map it to a Cursor project rule: `.cursor/rules/<name>.mdc`. Cursor ignores plain `.md` files in that folder, and each `.mdc` file has three frontmatter fields: `description`, `globs` and `alwaysApply`.

| Forgeloom source | Cursor rule | Suggested frontmatter |
|---|---|---|
| `knowledge/ios-swift/AGENTS.md` | `.cursor/rules/ios-swift.mdc` | `globs: "**/*.swift"`, `alwaysApply: false` |
| `knowledge/web/AGENTS.md` | `.cursor/rules/web.mdc` | `globs: "**/*.{html,css,js,jsx,ts,tsx}"`, `alwaysApply: false` |
| `knowledge/web/design-system/themes/<theme>.md` | `.cursor/rules/web-theme.mdc` | the chosen theme only; same globs as `web` |
| `knowledge/backend/AGENTS.md` | `.cursor/rules/backend.mdc` | `globs` for your backend's source folders |

Example:

```markdown
---
description: Forgeloom iOS/Swift conventions and audit checklists
globs: "**/*.swift"
alwaysApply: false
---

<paste the contents of knowledge/ios-swift/AGENTS.md here>
```

The body is the same plain Markdown: no translation is needed, only the frontmatter wrapper.

## What does not carry over

Claude Code's per-subagent model and effort (`model`, `effort` in each subagent) have no 1:1 equivalent in Cursor. The "audit as a separate reviewer" pattern is approximated by asking, in a separate chat, for a review of the diff against the checklist in the relevant section of the `AGENTS.md`.
