---
description: Turns a definition into a written artifact. New project (no AGENTS.md) → charter (AGENTS.md + decisions/0001-foundation.md). Feature on an existing project (AGENTS.md present) → specs/<feature>.md.
argument-hint: "[project or feature name]"
disable-model-invocation: true
---

# /fl:define

You turn a spoken definition into an artifact that outlives the session. There are two distinct cases and they are NOT mixed: *foundation* decisions (stack, hosting, architecture) are permanent context and do not belong inside a feature spec; a feature on an existing project produces only its spec.

Argument received: `$ARGUMENTS` (may be empty).

## Step 0 — Detect the case

1. Go to the repo root (`git rev-parse --show-toplevel`; if it is not a git repo, the current directory).
2. Check whether `AGENTS.md` exists at that root.
   - **It does not exist** → case **0.1, charter** (project from scratch).
   - **It exists** → case **0.2, spec** (feature on an existing project). Read it in full before continuing: the stack and architecture are already decided there and are not decided again.
3. Tell the user in one line which case you detected and why. If the user had said explicitly in the chat the opposite (e.g. "this is a new feature" with no AGENTS.md), follow what the user says and point out the inconsistency.

## Step 1 — Define

Talk it through to close whatever is missing. Ask concrete questions, a few at a time, and do not treat anything as decided that the user has not said. If this was already discussed earlier in the conversation, do not repeat it: use it.

- Case **0.2**: ground the questions in the real code (read `AGENTS.md`, the architecture and the files the feature touches). That is the advantage of defining here rather than in a separate chat.
- Case **0.1**: there is no code to read; focus on technical stack, hosting/infrastructure, general architecture and planned commands (build, test, lint).

## Step 2 — Write the files

Write the files when you finish (do not just describe them). **Never overwrite a file that already exists without asking first.**

The rule that overrides everything else: **do not add anything that was not explicitly discussed. If something was left ambiguous or undecided, mark it as an "open question" instead of assuming it** (in the charter that means not inventing a hosting provider that was never discussed; in the spec, not inventing an acceptance criterion nobody asked for).

### Case 0.1 — Charter

Based on everything that has been discussed, generate two Markdown files:

1. `AGENTS.md` at the root, with the sections **Technical stack**, **Hosting/infrastructure**, **General architecture** and **Planned commands** — only what was explicitly decided, nothing invented. It must stay under 200 lines.
2. `decisions/0001-foundation.md` as an ADR with those same stack/hosting decisions: what was chosen, which alternatives were considered if they were mentioned, and why.

If anything about stack, hosting or architecture was left undecided, mark it as an "open question" in both files instead of assuming an option.

### Case 0.2 — Spec

Based on everything discussed, write the spec in Markdown at `specs/<feature-name>.md` (use `$ARGUMENTS` as the name if given; otherwise propose one in kebab-case and confirm it) with this structure:

- **Objective**: what problem it solves, in one sentence.
- **Scope**: including what is explicitly out of scope.
- **Constraints**: performance, compatibility, security.
- **Acceptance criteria**: a verifiable checklist (`- [ ]`), every item checkable with a test or a concrete check.
- **Relevant prior decisions**: a link to the ADR in `decisions/` if there is one.

Take the stack and architecture already fixed in `AGENTS.md` as given; do not repeat or change them.

## Step 3 — Wrap up

1. List the **open questions** you marked for the user: it is the first thing they need to review.
2. State which files you created and where.
3. Case 0.1: remind them that the next step is the first feature with `/fl:define` (there will already be an `AGENTS.md`, so it will be case 0.2). If `CLAUDE.md` does not exist, suggest `ln -s AGENTS.md CLAUDE.md` so Claude Code reads the same content; do not create it yourself.
4. Case 0.2: the next step is "implement according to `specs/<feature>.md`", with plan mode first. Tests are derived from the acceptance criteria (the `test-writer` subagent, if available, exists for that).
5. **Do not commit.** The files are left for the user to review.
