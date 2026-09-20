# Closing prompt: chat → feature spec (case 0.2)

Use it at the end of a definition chat about a **feature on an existing project**. The stack and architecture are already decided (they live in `AGENTS.md` and the ADRs), so only the spec of this feature comes out of the chat. Paste it as-is, then save the result as `specs/<feature-name>.md`.

If the feature needs work in **more than one repo** (for example the app needs an endpoint the backend does not have), save it instead as **one shared spec** in the contracts repo, `specs/<feature-name>.md`. The prompt below covers that case: it groups the acceptance criteria per repo.

Inside Claude Code, `/fl:define` runs this same flow (it detects that `AGENTS.md` already exists) and writes the file for you, in the right repo.

---

Based on everything we have discussed in this conversation, write the spec in Markdown for `specs/<feature-name>.md` with this structure: Objective, Scope (what is explicitly out), Constraints, Acceptance criteria (a verifiable checklist), and Relevant prior decisions if there are any. If the feature needs work in more than one repo, group the acceptance criteria under one heading per repo (for example `### iOS` and `### Backend`), each holding only what that repo must satisfy and can test on its own. Do not add anything we have not explicitly discussed — if something was left ambiguous or undecided, mark it as an "open question" instead of assuming it.
