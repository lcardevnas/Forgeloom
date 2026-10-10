---
description: Sets a repo up for the Forgeloom workflow. Adds the Working rules to AGENTS.md (creating it from the real code if missing, or completing and upgrading an existing one), points CLAUDE.md at it, puts the repo on git flow and checks that the stack plugin and the gate's tools are in place. Safe to re-run; asks before every write.
argument-hint: "[ios-swift|web|backend]"
disable-model-invocation: true
---

# /fl:init

You set a repo up so that every later session in it follows the Forgeloom rules. This is **setup, not definition**: you do not decide the stack, the hosting or the architecture, and you do not write specs (that is `/fl:define`). You record what is already true, add Forgeloom's fixed rules, and leave everything else as it was.

Rules for the whole command:

- **Idempotent.** Running it twice changes nothing the second time. Running it after a plugin update brings the Working rules up to date.
- **Ask before every write**, showing what will be written (a diff when a file exists). Group the questions in one round.
- **Never overwrite or reorder content that is already there.** Only add what is missing.
- **Never commit, push or install anything.** Files are left for the user to review.
- Everything you write is in English, whatever language the user chats in.

Argument received: `$ARGUMENTS` (may be empty; if it is a stack name, it wins over detection).

## Step 0 — Look before touching (read-only)

Gather these facts and show them as one short block before asking anything:

1. **Where you are.** `git rev-parse --show-toplevel`; if it is not a git repo, the current directory. Whether it has commits, the current branch, and whether `develop` exists.
2. **Umbrella folder, not a repo.** If the folder is not a git repo and either contains a `source-spec.md` (or a similar all-in-one definition) or holds several repos side by side, **stop**: tell the user to run `/fl:import <file>` here to create the repos from the definition, or to open Claude Code inside one repo and run `/fl:init` there. Do not create anything.
3. **Files.** `AGENTS.md` (exists? has a `## Working rules` section? which of its bullets, by bold name?), `CLAUDE.md` (absent, a symlink, or a real file; does it reference `AGENTS.md`?), `forgeloom-<stack>.md` (left by `install.sh`; leave it alone), and `decisions/`, `specs/`, `bugs/`, `docs/`. Files that came from a chat session (a charter `AGENTS.md`, `decisions/0001-foundation.md`, `specs/*.md`) are already valid: you check them, you do not rewrite them.
4. **Code and stack.** Read the manifests, not the folder names:

   | Found | Stack |
   |---|---|
   | `Package.swift`, `*.xcodeproj`, `*.xcworkspace` | `ios-swift` |
   | `package.json` with a front-end framework, or `index.html` plus CSS | `web` |
   | `go.mod`, `Cargo.toml`, `pyproject.toml`, `requirements.txt`, `pom.xml`, `build.gradle*`, `Gemfile`, `composer.json`, `*.csproj`, or a `package.json` that is a server | `backend` |

   When two stacks are plausible (a `package.json` could be either), or the repo is a different kind of project, **ask**; never pick one. A repo with no code and no manifests has no stack yet.
5. **Forgeloom itself.** Which stack plugin is enabled for this repo: look at `.claude/settings.json` (`enabledPlugins`) and, if unsure, run `claude plugin list`. Note whether none is, and whether **more than one** stack plugin is (they duplicate the shared subagents and the gate).
6. **Tools the commit gate needs.** `command -v git curl jq`; also `python3` when the stack is `ios-swift`.

Tell the user in one line which situation you found (Step 1), and the stack you will assume.

## Step 1 — Route

| What you found | What to do |
|---|---|
| Not a repo, with a source spec or several repos | Stop, as in Step 0.2. |
| A repo with **no code and no `AGENTS.md`** (a brand-new project) | Do Step 3 only. Do **not** create `AGENTS.md`: `/fl:define <project>` writes the charter and the Working rules together. Say so, and that `/fl:define` ends by suggesting the `CLAUDE.md` link: there is no need to run `/fl:init` again for it. |
| **Code, no `AGENTS.md`** | Step 2a, then 2c, 3, 4. |
| `AGENTS.md` present, **without** the Working rules, or with only some (a hand-written file, one from another tool, or an older Forgeloom version) | Step 2b, then 2c, 3, 4. |
| `AGENTS.md` present with every rule identical to the canonical text | Nothing to write in `AGENTS.md`. Continue with 2c, 3, 4 and report that it is up to date. |
| Only a real `CLAUDE.md` (no `AGENTS.md`) | Step 2c first, because it decides where the rules go. |

## Step 2 — Write

### 2a — Create `AGENTS.md` from the code

Only when `AGENTS.md` does not exist and the repo has code. It has these sections, and **only facts that a file in the repo states**:

- `# <Project name>`: from the manifest or the folder; confirm it.
- **Technical stack**: language, framework and versions as the manifests declare them, each with the file it came from (for example `Swift 6, SwiftUI (Package.swift)`). Anything not declared is not listed.
- **Hosting/infrastructure**, **General architecture**: `Open question: not decided` unless a file states it (a `Dockerfile` or a CI file is a fact about how it is built, not a hosting decision). **Do not infer architecture from folder names.**
- **Planned commands**: build, test and lint commands that exist in the repo (`package.json` scripts, `Makefile` targets, the test command the language implies only if a manifest shows it). Each with its source. Otherwise `Open question`.
- **Related repositories**, only if the project spans several repos: ask whether it does; if so, ask for the folder names and write the relative paths exactly as given. A session in one repo must know where the contracts repo is, because the Cross-repo work and Next steps rules depend on it.
- **Working rules**: the section below, word for word.

Show the whole file and wait for the OK. It must stay under 200 lines. Mark every open question for the user; `/fl:define` closes them when a feature depends on them.

### 2b — Add or upgrade the Working rules in an existing `AGENTS.md`

1. If there is no `## Working rules` heading, append the whole section at the end of the file.
2. If there is one, compare it **bullet by bold name** with the canonical section below:
   - A bullet that is missing → add it in canonical position.
   - A bullet that exists but differs → show the old and new text side by side and ask; it is probably an older Forgeloom version, but it may be the user's own wording.
   - A bullet that is not canonical → leave it alone.
3. If the file already says something that contradicts a rule (for example it asks for a `Co-Authored-By` trailer, or another branching model), **report the conflict** and ask which wins; never resolve it silently.
4. If the result would pass 200 lines, say so and ask before appending; the user may prefer to move reference material to `docs/` first.

Touch nothing outside the `## Working rules` section.

### 2c — `CLAUDE.md` points at `AGENTS.md`

- Absent → create `CLAUDE.md` as a symlink to `AGENTS.md`; if symlinks fail, a one-line file containing `@AGENTS.md`.
- A symlink to `AGENTS.md` → nothing.
- A **real file** that does not mention `AGENTS.md` → it is the user's own instructions: **never move, rename or replace it.** Ask to append the line `@AGENTS.md` at the end, so Claude Code loads both. If the user would rather keep everything in `CLAUDE.md`, put the Working rules there instead (same 2b rules) and skip `AGENTS.md`.

### Working rules section (canonical)

```markdown
## Working rules

These apply to every project, whatever the stack.

- **Git flow.** Every repo uses git flow, with plain git. Right after `git init`, run `git symbolic-ref HEAD refs/heads/develop`: work starts on `develop` and the first commit is made there. `main` appears with the first release and holds released commits only, each tagged `vX.Y.Z`. After that: `feature/<name>` from `develop`, `release/X.Y.Z` for a release in flight, `hotfix/X.Y.Z` from `main` for urgent fixes; merge with `--no-ff`.
- **Commits.** English, conventional style (`feat(scope): ...`), 2 lines at most: a subject under about 72 characters and, only if it adds something the subject cannot, one line of context. **Never** add `Co-Authored-By` or any other attribution trailer, even if a tool suggests one.
- **Language.** Every `.md` file and every other document (specs, ADRs, READMEs, comments, OpenAPI descriptions) is written in English, whatever language the user chats in.
- **Cross-repo work.** If a feature needs work in another repo (an endpoint, a field or a screen on another platform), never edit that repo: create the shared spec at `<contracts>/specs/<feature>.md`, or extend the existing one, with a group for that platform, so its session finds the work there. The contracts repo comes from *Related repositories* in `AGENTS.md`; if the section is missing, ask.
- **Next steps.** When asked what is next, read the unticked `- [ ]` items in this repo's `specs/` and in this repo's group of each spec in `<contracts>/specs/`, and report them with the open questions. If the contracts repo is not reachable, say so; never guess its location.
- **Challenge decisions.** If you think the user's decision is wrong or a clearly better option exists, say so before acting: state the concern in a sentence or two, show the better way and its trade-off, and let the user decide. Raise it once; if they confirm their choice, follow it without bringing it up again. Speak up for real risks (security, data loss, rework, breaking the spec-first or contract-first flow), not for matters of taste.
- **Final summaries.** When you finish, say what changed and what needs the user's decision or review (open questions, failures, skipped steps). Go straight to the point: **never** add long explanations or re-describe features unless the user asks for them.
```

## Step 3 — Git flow (local only)

Ask once, then apply what was approved. Nothing is pushed.

- **Not a git repo** → `git init`, then `git symbolic-ref HEAD refs/heads/develop`, so work starts on `develop`.
- **A repo with no commits** → `git symbolic-ref HEAD refs/heads/develop`.
- **A repo with history, on `main` or `master`, and no `develop`** → offer `git switch -c develop` (the branch starts at the current commit). Say plainly what it means: the existing history stays where it is; from now on work goes through `feature/<name>` branches merged into `develop`; `main` is not renamed, retagged or touched, and the tagged-release practice begins with the next release. If the user declines, say that the Git flow rule will not match the repo.
- **`develop` already exists** → nothing.

Do not move uncommitted changes, delete branches or rewrite history.

## Step 4 — Wrap up

Keep it short. Do not re-describe what was written.

1. **Open questions** first: the ones in the new `AGENTS.md`, rule conflicts, anything the user left undecided.
2. **Files changed**, and the branch.
3. **What is missing in the environment**, with the exact command, never run by you:
   - No stack plugin: `claude plugin install <stack>@forgeloom --scope project`.
   - More than one stack plugin: keep one.
   - A missing `git`, `curl` or `jq` (or `python3` for iOS): the commit gate or the Apple UI scripts will not work until it is installed.
4. **A multi-repo project**: run `/fl:init` once in each repo, the contracts repo included.
5. **Next step**: `/fl:define <feature>` for the first feature (it will read the new `AGENTS.md`); `/fl:fix` for a bug; if a definition exists as one big file, `/fl:import` from the umbrella folder.
6. **Do not commit.** Suggest reviewing the diff and committing it on its own (`docs: add Forgeloom working rules`).
