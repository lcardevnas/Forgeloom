# Closing prompt: chat → project charter (case 0.1)

Use it at the end of a definition chat about a **brand-new project**. It does not produce a feature spec: it produces the project's foundation (stack, hosting, architecture), which is permanent context. Paste it as-is, then move the two resulting files to the repo root (`AGENTS.md`) and to `decisions/0001-foundation.md`.

Inside Claude Code, `/fl:define` runs this same flow and writes the files for you.

---

Based on everything we have discussed, generate two Markdown files:

1. `AGENTS.md` with the sections Technical stack, Hosting/infrastructure, General architecture and Planned commands — only what we explicitly decided, nothing invented. If the project spans several repos, add a Related repositories section with the relative paths of the contracts repo and the sibling repos, exactly as we named them.
2. `decisions/0001-foundation.md` as an ADR with those same stack/hosting decisions: what was chosen, which alternatives were considered if we mentioned them, and why.

If anything about stack, hosting or architecture was left undecided, mark it as an "open question" in both files instead of assuming an option.
