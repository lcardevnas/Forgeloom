---
description: Fixes a bug with discipline. Root cause before proposing a fix, regression test red first, minimal fix after.
argument-hint: "[bug description | path to bugs/<id>.md]"
disable-model-invocation: true
---

# /fl:fix

A bug **does not start with a spec: it starts with a test that reproduces the failure.** Without that test up front, "it is fixed" is a claim with nothing to verify it, and it is easy for the fix to hide the symptom without touching the cause. Follow the steps in order and do not skip any.

Input: `$ARGUMENTS` (a description of the bug or the path to a `bugs/<id>.md`).

## Step 1 — Bug report (not a spec)

If `$ARGUMENTS` is a path to a file, read it. If it is text, use it. Make sure you have these four points and ask about the missing ones (in a single round of questions):

- **Symptom**: what happens.
- **Reproduction**: exact steps, or the case/input that triggers it.
- **Expected vs. observed.**
- **Fix scope**: related causes you detect but will NOT touch now.

If the bug is complex or recurring, offer to write it down in `bugs/<id>.md`. Do not turn it into a spec.

## Step 2 — Root cause, before solution

Reproduce the bug, locate the **root cause** and explain it to the user **before proposing any fix. Do not apply any code change yet.**

- The most common failure here is patching the symptom in the layer where it shows (the UI, the endpoint) instead of the cause (the state that produces it further down). Follow the path from the symptom to the state that originates it.
- If there is legacy code or the area is large, delegate the reading to an `explorer` subagent (or the native `Explore`) so the main thread is not filled up; ask it for `file:line` references.
- Present: the root cause, the evidence (`file:line`), and why the symptom follows from it.
- If you cannot demonstrate the cause with evidence, say so: it is a hypothesis. State how to check it and ask the user before continuing.

## Step 3 — Regression test, red

Write the test that reproduces the bug **before touching the fix** (use the `test-writer` subagent if available; otherwise do it yourself). Follow the test framework and style the project already uses; the test command is in `AGENTS.md`.

- Run it and **confirm that it fails, and that it fails for the bug's reason** (not for a compile, import or setup error). Show the real failure output.
- If the bug cannot be covered by an automated test (UI, visual, environment), say so explicitly and propose the alternative verification. Do not claim "verified" without evidence.

## Step 4 — Minimal fix

Apply the **minimal fix, scoped to the bug report**. No opportunistic refactors mixed in: if you see something that deserves fixing, note it as a separate spec or bug; do not sneak it into this change. If the diff grows well beyond what the cause justifies, stop and explain why before continuing: a bugfix that touches dozens of files is a warning sign, not diligence.

## Step 5 — Verification

1. Run the regression test: it must turn **green**. That is the verification, not "I tried it by hand and it works".
2. Run the project's test suite to check you are not breaking anything, and the lint/build that `AGENTS.md` specifies.
3. If a `code-reviewer` subagent is available, run it over the diff. Do not skip the review because it is "just a bug".

## Step 6 — Wrap up

- Leave the changes ready, **with the regression test included**, and propose a commit message. **Do not make the commit yourself** unless the user asks: committing runs the secrets and dependencies gate, and the user reviews first.
- If the root cause reveals a pattern ("this kind of error recurs because X") that generalizes beyond this project, suggest `/fl:promote` to move it into `knowledge/<stack>/patterns/`.
