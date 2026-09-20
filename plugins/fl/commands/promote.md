---
description: Promotes a generalizable lesson from the current project into forgeloom/knowledge/<stack>/patterns/ and leaves it staged (no commit). You make the commit.
argument-hint: "[ios-swift|web|backend] [lesson title]"
disable-model-invocation: true
---

# /fl:promote

You turn a lesson learned in the current project into a reusable pattern of the stack, in the `forgeloom` repo (layer 2), so the next project of the same kind inherits it.

Input: `$ARGUMENTS` (optionally the stack and/or a title; if missing, you determine them below).

**Design decision (fixed): this command leaves the file *staged* and does NOT commit.** The commit belongs to the user: that way they review what enters the shared library, and the commit goes through the secrets/dependencies gate.

## Step 1 — Is it really generalizable?

Before writing anything, check that the lesson holds for **any project of that stack**, not just this one.

- If it is specific to this project (a product decision, a house convention), it belongs in its `AGENTS.md`, `specs/` or `decisions/` (layer 3), not in forgeloom. Tell the user and **stop here**.
- Identify where it comes from (bug, feature, review) and what the actionable rule is. If the user has not stated it clearly, ask.

## Step 2 — Stack

Use the first token of `$ARGUMENTS` if it is `ios-swift`, `web` or `backend`. Otherwise deduce it from the repo (`Package.swift`/`*.xcodeproj` → `ios-swift`; `package.json` with a frontend → `web`; server/API → `backend`). If there is reasonable doubt, **ask**.

## Step 3 — Locate the forgeloom checkout

You must write into a real `forgeloom` checkout, **never** inside `${CLAUDE_PLUGIN_ROOT}` (it is a cached copy that is overwritten when the plugin updates). Look, in this order:

1. The `FORGELOOM_DIR` environment variable (`echo "$FORGELOOM_DIR"`).
2. The current directory or an ancestor, if it contains `knowledge/` and `.claude-plugin/marketplace.json` with `"name": "forgeloom"`.
3. `claude plugin marketplace list --json`: a `forgeloom` entry with a local origin (`"source": "directory"` and its path). A GitHub entry points to a copy managed by Claude Code: do not use it as the destination.
4. If none of the above works, **ask the user for the path** and suggest exporting `FORGELOOM_DIR` for next time.

Check that the destination exists: `<forgeloom>/knowledge/<stack>/patterns/`. If not, do not invent it: warn.

## Step 4 — Avoid duplicates

Search `<forgeloom>/knowledge/<stack>/patterns/` and `<forgeloom>/knowledge/<stack>/AGENTS.md` to see whether the lesson is already there. If it exists, propose **updating that file** instead of creating another one, and wait for confirmation.

## Step 5 — Draft the pattern

Use the template `<forgeloom>/templates/pattern.md` (read it from there). One pattern = **one `.md` file**, with a descriptive kebab-case name (`swiftdata-cloudkit-optional-relationships.md`). Content rules:

- **Plain Markdown, no tool-specific syntax** (no skill frontmatter, XML or Claude Code commands): this library is read by any assistant.
- **Sanitize**: forgeloom is published (open source). Do not include names of private projects or clients, internal URLs, keys or user data. In *Origin* put something generic, unless the user confirms it can be named.
- Be concrete: the minimal case that reproduces the problem, the root cause, the actionable rule and **when it does not apply**. If you do not know when it does not apply, write "not checked" instead of inventing it.
- Do not add anything the user has not confirmed. Mark anything doubtful as "to be confirmed".

Show the draft to the user and **wait for their OK** before writing the file.

## Step 6 — Write and stage

1. Write the file at `<forgeloom>/knowledge/<stack>/patterns/<slug>.md`.
2. `git -C <forgeloom> add knowledge/<stack>/patterns/<slug>.md` — **only that file**. If the checkout had other uncommitted changes, do not touch them.
3. **Do not run `git commit`.**
4. Confirm to the user: the file path, that it is staged, and propose the commit message (e.g. `patterns(<stack>): <title>`).
