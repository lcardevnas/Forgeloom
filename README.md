# Forgeloom

A spec-driven workflow and a reusable, per-stack knowledge library for AI-assisted development (iOS/Swift, web, backend).

Forgeloom has two layers:

- **An agnostic core**: plain Markdown in `knowledge/` (conventions, gotchas, audit checklists, design themes). Any assistant that reads `AGENTS.md` can use it.
- **Adapters** on top of it. The main one is a set of **Claude Code plugins** (commands, subagents, skills, hooks). Codex and Cursor read the core almost as-is; `install.sh` puts it in your project.

What you write once, in `knowledge/`, every project of that stack inherits. What a project teaches you, you promote back into `knowledge/<stack>/patterns/` so the next project does not repeat the mistake.

## Contents

- [Install](#install)
- [Use case 1 — Bootstrap a new project](#use-case-1--bootstrap-a-new-project)
- [Use case 2 — A feature on an existing project](#use-case-2--a-feature-on-an-existing-project)
- [Use case 3 — A bug](#use-case-3--a-bug)
- [Use case 4 — From a chat, without Claude Code](#use-case-4--from-a-chat-without-claude-code)
- [Use case 5 — Equivalent in each adapter](#use-case-5--equivalent-in-each-adapter)
- [What each plugin gives you](#what-each-plugin-gives-you)
- [Repository layout](#repository-layout)
- [Known limits](#known-limits)

## Install

**Requirements**: Claude Code, and for the commit gate `bash`, `git`, `curl` and `jq`, plus network access to [OSV.dev](https://osv.dev), the free, open vulnerability database that the dependency check queries (no API key needed; it covers every package manager the check supports).

Add the marketplace once (a local checkout works too: `claude plugin marketplace add /path/to/forgeloom`):

```bash
claude plugin marketplace add lcardevnas/Forgeloom
```

Or, inside Claude Code: `/plugin marketplace add lcardevnas/Forgeloom` (the repository is <https://github.com/lcardevnas/Forgeloom>).

Install the stack plugin for your project. It declares the `fl` plugin as a dependency, so `fl` (the commands `/fl:define`, `/fl:fix`, `/fl:promote`) is installed with it automatically:

```bash
claude plugin install ios-swift@forgeloom --scope project   # or: web, backend
```

`fl` is a separate plugin on purpose: a plugin's commands are always invoked as `/<plugin-name>:<command>`, so if the commands lived inside a stack plugin they would be `/ios-swift:define` in one project and `/web:define` in another. Keeping them in `fl` makes `/fl:define` identical in every project. You can also install it on its own, at user scope, to have the commands everywhere: `claude plugin install fl@forgeloom`.

All four are available:

| Plugin | Gives you |
|---|---|
| `fl` | The commands `/fl:define`, `/fl:fix`, `/fl:promote`. Independent of the stack, so the command names never change with the stack you install. |
| `ios-swift` | (installs `fl` too) 7 skills, 4 audit subagents, 3 shared subagents, the commit gate. |
| `web` | (installs `fl` too) 4 skills (with 4 design themes), 4 audit subagents, 3 shared subagents, the commit gate. |
| `backend` | (installs `fl` too) 4 skills, 2 audit subagents, 3 shared subagents, the commit gate. |

Use `--scope project` for the stack plugin so your team gets it through the project's `.claude/settings.json`. Install **one stack plugin per repo**: the shared subagents and the gate are bundled in each stack plugin, so installing several in the same project duplicates them (see [Known limits](#known-limits)).

Verify: run `/fl:define` in Claude Code. Commands always carry the plugin name (`/fl:...`), whatever stack plugin is installed next to it.

## Use case 1 — Bootstrap a new project

You are starting from zero. The first thing that comes out of the definition chat is not a feature spec: it is the project's **foundation** (stack, hosting, architecture). That is permanent context, and if you bury it inside a feature spec it is lost as soon as that feature closes.

**In Claude Code** (empty repo, no `AGENTS.md`):

```text
/fl:define my-project-name
```

`/fl:define` detects that `AGENTS.md` does not exist, talks the foundation through with you, and then writes:

- `AGENTS.md` — Technical stack, Hosting/infrastructure, General architecture, Planned commands. Only what was explicitly decided.
- `decisions/0001-foundation.md` — an ADR: what was chosen, the alternatives if any were mentioned, and why.

Anything left undecided is marked as an **open question** instead of assumed. Review those first. Nothing is committed for you.

**From a chat**: see [Use case 4](#use-case-4--from-a-chat-without-claude-code) and use `prompts/chat-to-charter.md`.

Then install your stack plugin and continue with [Use case 2](#use-case-2--a-feature-on-an-existing-project) for the first feature. The stack is not decided again: plan mode inherits it from `AGENTS.md`.

## Use case 2 — A feature on an existing project

The stack and architecture are already fixed in `AGENTS.md`; only the spec of this feature comes out of the definition.

1. **Define → spec.** In Claude Code:

   ```text
   /fl:define feature-name
   ```

   It detects the existing `AGENTS.md`, grounds its questions in the real code, and writes `specs/feature-name.md`: Objective, Scope (including what is explicitly out), Constraints, Acceptance criteria (a verifiable checklist) and Relevant prior decisions. Open questions are marked, not assumed.

2. **Plan before code.** Open the tool in the repo (not in a parent folder) and start with:

   ```text
   Implement according to specs/feature-name.md
   ```

   Use plan mode, review the plan and approve or correct it. Do not open with "I want to do X".

3. **Implement.** Skills of your stack plugin (for example `ios-swift:modern-swiftui`) inform the code as it is written. For critical logic, write the tests first; for the rest, derive them from the acceptance criteria before you call the feature done. The `test-writer` subagent does exactly that: it turns each acceptance criterion into a test.

4. **Hard gate + review.** Two things run before you look at the change:
   - the **commit gate** (a hook) blocks a `git commit` that adds a secret or a dependency with a known vulnerability;
   - the `code-reviewer` subagent reviews the diff against the spec and your conventions, criterion by criterion.

   Then the audit subagent of your stack when relevant: `security-review-owasp-mobile`, `security-review-owasp-web`, `api-security-review-owasp`, and so on.

5. **Commit.** If you learned something that generalizes to the stack (not just this feature), run:

   ```text
   /fl:promote
   ```

   It writes a pattern to `knowledge/<stack>/patterns/` in your forgeloom checkout and **leaves it staged**. You make the commit.

## Use case 3 — A bug

A bug **does not start with a spec: it starts with a test that reproduces the failure.** Feature: spec first, test after, to validate what you decided to build. Bug: test first, fix after, to prove that what was broken no longer is.

```text
/fl:fix "Checkout crashes when the cart has a discounted item and the coupon expires"
```

or point it at a written report: `/fl:fix bugs/123.md`. It runs these steps in order:

1. **Bug report, not a spec**: symptom, reproduction, expected vs. observed, fix scope (related causes you will *not* touch now).
2. **Root cause before solution.** It reproduces the bug, finds the root cause and explains it to you *before* proposing a fix, and does not apply anything yet. Legacy or large areas are delegated to the `explorer` subagent.
3. **A regression test, red.** It writes the test that reproduces the bug and confirms it fails *for the bug's reason*.
4. **Minimal fix**, scoped to the report. No opportunistic refactors: anything else it notices becomes a separate spec or bug.
5. **Verification**: the regression test turns green, the suite and lint pass, `code-reviewer` runs on the diff.
6. **Commit, with the regression test included** (you make the commit). If the root cause reveals a repeatable pattern, it suggests `/fl:promote`.

## Use case 4 — From a chat, without Claude Code

Thinking happens in a chat; the mistake is not starting there, it is jumping from "it is clear in the conversation" to coding without leaving that result in an artifact that outlives the session. For a **new project**, defining in a chat is strictly better: there is no code to ground the questions in, and a coding tool would only add fixed per-turn overhead.

1. Have the definition conversation in any chat.
2. At the end, paste the matching closing prompt from `prompts/`:

   | You are defining | Paste | Save the result as |
   |---|---|---|
   | A brand-new project | `prompts/chat-to-charter.md` | `AGENTS.md` and `decisions/0001-foundation.md` at the repo root |
   | A feature on an existing project | `prompts/chat-to-spec.md` | `specs/<feature>.md` |
   | A bug | `prompts/chat-to-bug.md` | `bugs/<id>.md` (or keep it in the prompt) |

   The last sentence of each prompt is the one that matters: it stops the model from filling gaps with plausible assumptions you never made.
3. Review the **open questions** first.
4. Move the files into the repo, then give your coding tool its first prompt: "implement according to `specs/<feature>.md`".

For a **feature on an existing project**, defining inside the coding tool is a real trade-off: it can ground the conversation in the current architecture and code, which a separate chat only gets if you paste the files in by hand. If that grounding matters for the feature, use `/fl:define`; if the feature is as definable without reading code, a chat is cheaper.

To use the stack knowledge from a tool that is not Claude Code, run the installer (below).

## Use case 5 — Equivalent in each adapter

| Step | Claude Code | Codex | Cursor / others |
|---|---|---|---|
| Get the stack knowledge | `claude plugin install <stack>@forgeloom` | `./install.sh <stack> <project>` — Codex reads `AGENTS.md` natively | `./install.sh <stack> <project>` — Cursor reads `AGENTS.md` natively |
| New-project charter | `/fl:define` | paste `prompts/chat-to-charter.md` | paste `prompts/chat-to-charter.md` |
| Feature spec | `/fl:define feature-name` | paste `prompts/chat-to-spec.md` | paste `prompts/chat-to-spec.md` |
| Bug | `/fl:fix "..."` | paste `prompts/chat-to-bug.md`, then ask for root cause before any fix, a red test, then a minimal fix | same as Codex |
| Reviewer / test-writer | subagents (`code-reviewer`, `test-writer`) | a second session: "review this diff against `specs/<feature>.md` and the checklists in `AGENTS.md`" | same as Codex |
| Commit gate | plugin hook | `git` pre-commit hook (below) | `git` pre-commit hook (below) |
| Promote a lesson | `/fl:promote` | write `knowledge/<stack>/patterns/<slug>.md` by hand from `templates/pattern.md`, commit | same as Codex |

The installer copies a stack's `AGENTS.md` into a project and points `CLAUDE.md` at it (a symlink, or a one-line `@AGENTS.md` file where symlinks are not available):

```bash
./install.sh ios-swift /path/to/your/project      # or: web, backend
```

It never overwrites a project's own `AGENTS.md` (that file usually holds its charter): if one exists, the stack knowledge is written next to it as `forgeloom-<stack>.md` and you reference it from your `AGENTS.md`.

To get the commit gate outside Claude Code, install it as a git hook:

```bash
ln -s /path/to/forgeloom/common/hooks/pre-commit-gate.sh .git/hooks/pre-commit
```

Details and what does not carry over: [`adapters/codex/README.md`](adapters/codex/README.md) and [`adapters/cursor/README.md`](adapters/cursor/README.md).

## What each plugin gives you

Every stack plugin also ships three shared subagents (`code-reviewer`, `test-writer`, `explorer`), the commit-gate hook and the `dependency-scan` skill.

**Skills** inform code as it is written. **Subagents** audit code already written, in an isolated pass.

| Stack | Skills | Audit subagents |
|---|---|---|
| `ios-swift` | `swift-high-standard`, `swift6-concurrency`, `modern-swiftui`, `swift-testing`, `swiftdata-persistence`, `networking-async-await`, `privacy-manifest` | `security-review-owasp-mobile`, `accessibility-review-ios`, `memory-review-ios`, `performance-review-ios` |
| `web` | `professional-web-design` (4 themes), `core-web-vitals`, `technical-seo`, `web-accessibility` | `security-review-owasp-web`, `core-web-vitals-audit`, `accessibility-audit-web`, `design-system-compliance` |
| `backend` | `api-design-contract-first`, `database-design`, `auth-patterns`, `observability-logging` | `api-security-review-owasp`, `contract-compliance-checker` |

Every entry follows the same three parts — *Objective*, *Must include*, *Must never assume* — the last being the one that keeps the model from filling a gap with a default that is not valid for your project. The full definitions are in `knowledge/<stack>/AGENTS.md`.

Each subagent runs on the model that fits its job: Opus only where a false negative is expensive (security), Haiku for mechanical checks, Sonnet for judgment.

| Model | Subagents |
|---|---|
| Opus (`high`) | `security-review-owasp-mobile`, `security-review-owasp-web`, `api-security-review-owasp` |
| Sonnet | `code-reviewer` (high), `test-writer` (medium), `accessibility-review-ios` (medium), `memory-review-ios` (medium), `performance-review-ios` (medium), `core-web-vitals-audit` (low), `accessibility-audit-web` (medium) |
| Haiku | `explorer`, `design-system-compliance` (low), `contract-compliance-checker` (low), `dependency-scan` (low, a skill) |

**Web design themes.** `professional-web-design` has you pick one of four themes and apply it across the whole site, never mixing them: minimalist editorial, dark tech / SaaS, warm artisanal, corporate fintech. Palette, typography and motion for each are in `knowledge/web/design-system/themes/`. The `design-system-compliance` subagent checks that new code uses the theme's tokens.

**The commit gate** (`common/hooks/`) runs before every `git commit` that Claude Code performs, and blocks it when:

- `secret-scan` finds a secret in the added lines (cloud keys, tokens, private keys, credentials in URLs, literals assigned to names like `password`/`api_key`, `.env` and key files). It reports `file:line` and the rule, never the value. A confirmed false positive is allowed with `fl:allow-secret` on that line.
- `dependency-scan` finds a new or changed dependency with a known vulnerability in [OSV.dev](https://osv.dev): SPM (`Package.resolved`, `Package.swift`), npm (`package.json`, `package-lock.json`), PyPI (`requirements*.txt`), Go (`go.mod`), Cargo (`Cargo.lock`). To check before adding one:

  ```bash
  bash common/hooks/dependency-scan.sh --check npm lodash 4.17.15
  ```

  A justified exception is `FL_DEPSCAN_ALLOW=GHSA-xxxx,CVE-xxxx`; `FL_DEPSCAN_STRICT=1` also fails when OSV.dev is unreachable (by default it only warns); `FL_SKIP_DEPSCAN=1` turns the check off.

## Repository layout

```text
forgeloom/
├── .claude-plugin/marketplace.json   # catalog: fl, ios-swift, web, backend
├── knowledge/                        # the agnostic core: plain Markdown
│   ├── ios-swift/  { AGENTS.md, patterns/ }
│   ├── web/        { AGENTS.md, design-system/themes/, patterns/ }
│   └── backend/    { AGENTS.md, patterns/ }
├── common/                           # shared across all stacks
│   ├── agents/                       # code-reviewer, test-writer, explorer
│   ├── skills/dependency-scan/
│   └── hooks/                        # hooks.json, pre-commit-gate.sh, secret-scan.sh, dependency-scan.sh
├── plugins/
│   ├── fl/                           # commands only: define, fix, promote
│   ├── ios-swift/  web/  backend/    # per-stack skills + subagents; shared pieces symlinked from common/
├── prompts/                          # closing prompts for chat
├── templates/                        # adr.md, pattern.md
├── adapters/                         # cursor/, codex/
└── install.sh                        # generic installer
```

In each stack plugin, the shared subagents are **individual symlinks** into `common/agents/` (never the whole folder, because each stack also has real agents of its own), `hooks` links to `common/hooks`, and `knowledge` links to that stack's core. The `fl` commands live only in `plugins/fl/`, with `name: "fl"`, so `/fl:define` is identical whichever stack plugin is installed.

## Known limits

Behaviors that were verified against a real install and are worth knowing:

- **Installed plugins contain copies, not symlinks.** Claude Code dereferences symlinks that point elsewhere inside the same marketplace when it copies a plugin to its cache. Content and executable bits survive, but a change in `common/` reaches an installed plugin only after you update the marketplace and the plugin.
- **One stack plugin per repo.** The shared subagents, the `dependency-scan` skill and the gate are bundled in every stack plugin. With two stack plugins in one project, the shared subagents appear once per stack (`ios-swift:code-reviewer`, `web:code-reviewer`) and the gate runs once per plugin.
- **The gate anticipates chained `git add`s.** A Claude Code hook runs before the whole command, so in `git add -A && git commit` the `git add` has not happened yet. The gate therefore scans what that `git add` is about to stage (all changes and untracked files for `-A`/`.`/`-u`, or just the listed paths), plus `git commit -a`. This was found by testing against a real session, where the first version let such a commit through.
- **The gate only sees commits Claude Code runs.** A commit you type by hand in your terminal does not trigger a Claude Code hook; use the git `pre-commit` install above for that.
- **`dependency-scan` checks what a commit adds or changes.** With no lockfile it queries the lower bound of the declared range; `Package.swift` dependencies are read only when on a single line; other package managers (`yarn.lock`, `pnpm-lock.yaml`, `poetry.lock`, ...) produce a warning, not a check. It needs network access.
- **`/fl:promote` needs a real forgeloom checkout** to write into (it never writes into the plugin cache). It looks for `$FORGELOOM_DIR`, then the current directory, then a local marketplace entry, and otherwise asks you.
- **Theme palettes are AA-checked, and the dark theme has a gradient limit.** Each theme's colors were adjusted so the listed pairs reach 4.5:1 as normal text (for example the terracotta accent on the editorial background, or the mustard accent on cream); every pair is measured in the theme file, next to the value it replaced. Text cannot sit directly over the dark theme's full violet→cyan gradient, because no single text color passes on both ends.

## License

[MIT](LICENSE) © 2026 Luis Cárdenas.
