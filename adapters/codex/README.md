# Codex adapter

No conversion is needed: Codex reads `AGENTS.md` natively, and Forgeloom's stack knowledge is plain Markdown with no tool-specific syntax.

```bash
./install.sh web /path/to/your/project
```

## How Codex loads it

Codex builds an instruction chain from `AGENTS.md` files: from the Git root down to the current directory, concatenated, with files closer to your working directory taking priority. The combined size is capped (`project_doc_max_bytes`, 32 KiB by default). Forgeloom's three stack files are 4-7 KB each, so one stack fits comfortably next to your project's own `AGENTS.md`, and even all three together stay well under the cap.

## What does not carry over

Claude Code assigns a model and effort per subagent and delegates automatically by role. Codex has no per-role auto-delegation inside one session, so the model table of the Forgeloom design is not reproducible 1:1; pick the model per session/profile in `~/.codex/config.toml` instead. The "audit as a separate reviewer" pattern is approximated by running a second session that reviews the diff against the checklist in the `AGENTS.md`.
