# Closing prompt: chat → bug report (bugs)

Use it at the end of a chat where you worked out a bug. A bug does **not** start with a spec: it starts with a lightweight report and then a test that reproduces the failure. Paste it as-is, then save the result as `bugs/<id>.md` (only if the bug is complex or recurring; otherwise the report can live in the prompt itself).

Inside Claude Code, `/fl:fix` runs the whole bug flow (root cause first, regression test red, minimal fix).

---

Based on everything we have discussed, write the bug report in Markdown for `bugs/<id>.md` with this structure: Symptom (what happens), Reproduction (exact steps, or the case/input that triggers it), Expected vs. observed, and Fix scope (related causes we noticed but will not touch now). Do not add anything we have not explicitly discussed — if something is unclear or unknown, mark it as an "open question" instead of assuming it.

Then, as the first prompt in the coding tool: "Reproduce this bug, locate the root cause and explain it to me before proposing a fix — do not apply it yet."
