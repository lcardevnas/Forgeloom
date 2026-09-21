# Forgeloom

A spec-driven workflow and a reusable, per-stack knowledge library for AI-assisted development (iOS/Swift, web, backend).

Forgeloom has two layers:

- **An agnostic core**: plain Markdown in `knowledge/` (conventions, gotchas, audit checklists, design themes). Any assistant that reads `AGENTS.md` can use it.
- **Adapters** on top of it. The main one is a set of **Claude Code plugins** (commands, subagents, skills, hooks). Codex and Cursor read the core almost as-is; `install.sh` puts it in your project.

What you write once, in `knowledge/`, every project of that stack inherits. What a project teaches you, you promote back into `knowledge/<stack>/patterns/` so the next project does not repeat the mistake.

## Contents

- [Install](#install)
- [Multi-repo projects](#multi-repo-projects)
- [Use case 1 — Bootstrap a new project](#use-case-1--bootstrap-a-new-project)
- [Use case 2 — A feature on an existing project](#use-case-2--a-feature-on-an-existing-project)
- [Use case 3 — A bug](#use-case-3--a-bug)
- [Use case 4 — From a chat, without Claude Code](#use-case-4--from-a-chat-without-claude-code)
- [Use case 5 — Split an existing all-in-one spec](#use-case-5--split-an-existing-all-in-one-spec)
- [Use case 6 — Equivalent in each adapter](#use-case-6--equivalent-in-each-adapter)
- [Working rules](#working-rules)
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

Install the stack plugin for your project. It declares the `fl` plugin as a dependency, so `fl` (the commands `/fl:define`, `/fl:fix`, `/fl:promote`, `/fl:import`) is installed with it automatically:

```bash
claude plugin install ios-swift@forgeloom --scope project   # or: web, backend
```

`fl` is a separate plugin on purpose: a plugin's commands are always invoked as `/<plugin-name>:<command>`, so if the commands lived inside a stack plugin they would be `/ios-swift:define` in one project and `/web:define` in another. Keeping them in `fl` makes `/fl:define` identical in every project. You can also install it on its own, at user scope, to have the commands everywhere: `claude plugin install fl@forgeloom`.

All four are available:

| Plugin | Gives you |
|---|---|
| `fl` | The commands `/fl:define`, `/fl:fix`, `/fl:promote`, `/fl:import` and the script that verifies an import. Independent of the stack, so the command names never change with the stack you install. |
| `ios-swift` | (installs `fl` too) 7 skills, 4 audit subagents, 3 shared subagents, the commit gate. |
| `web` | (installs `fl` too) 4 skills (with 4 design themes), 4 audit subagents, 3 shared subagents, the commit gate. |
| `backend` | (installs `fl` too) 4 skills, 2 audit subagents, 3 shared subagents, the commit gate. |

Use `--scope project` for the stack plugin so your team gets it through the project's `.claude/settings.json`. Install **one stack plugin per repo**: the shared subagents and the gate are bundled in each stack plugin, so installing several in the same project duplicates them (see [Known limits](#known-limits)).

Verify: run `/fl:define` in Claude Code. Commands always carry the plugin name (`/fl:...`), whatever stack plugin is installed next to it.

## Multi-repo projects

A Forgeloom project is **one repo per stack plus a contracts repo**, side by side in an umbrella folder. Each coding session is opened in **one** repo, so it loads only that stack's context.

```text
AcmeProduct/                  # umbrella folder (not a repo)
├── AcmeProductAppleApp/      # stack ios-swift: AGENTS.md, decisions/, specs/, docs/
├── AcmeProductBackend/       # stack backend:   AGENTS.md, decisions/, specs/, docs/
└── AcmeProductContracts/     # openapi.yaml, specs/ (shared between platforms), decisions/, design/
```

Folder names are `<ProjectName><Suffix>`, the project name in PascalCase and the suffix `AppleApp`, `AndroidApp`, `Backend`, `Website` or `Contracts`. `/fl:import` creates them for you; there is no Forgeloom stack for `AndroidApp` yet.

Every repo uses **git flow** from its first commit: `develop` is created at `git init` and the first commit is made there (`main` appears with the first release).

| What | Where |
|---|---|
| Stack, hosting, architecture and commands of a platform | that repo's `AGENTS.md` (under 200 lines), with the reasons in its `decisions/` |
| A feature that needs one repo | that repo's `specs/<feature>.md` |
| A feature that needs more than one repo | `<contracts>/specs/<feature>.md`, with the acceptance criteria grouped per platform (`### iOS`, `### Backend`) |
| The API contract | `<contracts>/openapi.yaml`, contract-first: it changes before the endpoint exists |
| Reference material that is not a decision, a feature or a convention (data model, animation catalog, settings inventory) | `<repo>/docs/<topic>.md`, linked from `AGENTS.md` |
| Where the contracts repo and the sibling repos are | the *Related repositories* section of each repo's `AGENTS.md` |

**When a feature needs work in another repo.** Sessions do not command each other: the contracts repo is the handoff and you carry it.

1. In the session where the need appears (say iOS), `/fl:define <feature>` notices that the feature needs more than one repo. It writes the shared spec in the contracts repo and proposes the `openapi.yaml` change, which it applies only after your OK. Writing outside the repo needs the sibling folder added: `claude --add-dir ../AcmeProductContracts`. Without it the command stops and tells you.
2. It ends by giving you the first prompt for each repo. In a session opened in the backend repo: `Implement according to ../AcmeProductContracts/specs/<feature>.md, Backend section only`. From there it is the usual feature flow: plan mode, implementation, `contract-compliance-checker` against `openapi.yaml`.
3. Each session works only on its own group and never edits the other repo. The feature is done when **every** group is done.
4. If a session only finds out mid-implementation that it needs something from another repo, the `cross-repo-work` rule in each stack's `AGENTS.md` makes it stop at the boundary and route through the contracts repo, instead of inventing the contract or editing the other repo.

## Use case 1 — Bootstrap a new project

You are starting from zero. The first thing that comes out of the definition chat is not a feature spec: it is the project's **foundation** (stack, hosting, architecture). That is permanent context, and if you bury it inside a feature spec it is lost as soon as that feature closes.

**In Claude Code** (empty repo, no `AGENTS.md`):

```text
/fl:define my-project-name
```

`/fl:define` detects that `AGENTS.md` does not exist, talks the foundation through with you, and then writes:

- `AGENTS.md` — Technical stack, Hosting/infrastructure, General architecture, Planned commands and, if the project spans several repos, Related repositories (where the contracts repo and the sibling repos are). Only what was explicitly decided.
- `decisions/0001-foundation.md` — an ADR: what was chosen, the alternatives if any were mentioned, and why.

Both files end up in a repo that follows the [working rules](#working-rules) below. Anything left undecided is marked as an **open question** instead of assumed. Review those first. Nothing is committed for you.

**From a chat**: see [Use case 4](#use-case-4--from-a-chat-without-claude-code) and use `prompts/chat-to-charter.md`.

Then install your stack plugin and continue with [Use case 2](#use-case-2--a-feature-on-an-existing-project) for the first feature. The stack is not decided again: plan mode inherits it from `AGENTS.md`.

## Use case 2 — A feature on an existing project

The stack and architecture are already fixed in `AGENTS.md`; only the spec of this feature comes out of the definition.

1. **Define → spec.** In Claude Code:

   ```text
   /fl:define feature-name
   ```

   It detects the existing `AGENTS.md`, grounds its questions in the real code, and writes `specs/feature-name.md`: Objective, Scope (including what is explicitly out), Constraints, Acceptance criteria (a verifiable checklist) and Relevant prior decisions. Open questions are marked, not assumed. If the feature needs more than one repo, the spec goes in the contracts repo instead, with the criteria grouped per platform: see [Multi-repo projects](#multi-repo-projects).

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
   | A definition that already exists as one big file | `prompts/import-spec.md` | see [Use case 5](#use-case-5--split-an-existing-all-in-one-spec) |

   The last sentence of each prompt is the one that matters: it stops the model from filling gaps with plausible assumptions you never made.
3. Review the **open questions** first.
4. Move the files into the repo, then give your coding tool its first prompt: "implement according to `specs/<feature>.md`".

For a **feature on an existing project**, defining inside the coding tool is a real trade-off: it can ground the conversation in the current architecture and code, which a separate chat only gets if you paste the files in by hand. If that grounding matters for the feature, use `/fl:define`; if the feature is as definable without reading code, a chat is cheaper.

To use the stack knowledge from a tool that is not Claude Code, run the installer (below).

## Use case 5 — Split an existing all-in-one spec

You already have the whole definition as one big Markdown file (features, architecture, API contracts, configuration, built over many chat iterations) and you must not lose any of it. `chat-to-*` and `/fl:define` write *from what was discussed*, which can summarize; this flow **moves existing text** and proves that it kept all of it. It needs the [multi-repo layout](#multi-repo-projects), and it **creates the repos for you**.

Put the source file in an empty folder (the umbrella), open Claude Code there and run:

```bash
cd AcmeProduct && claude
```

```text
/fl:import source-spec.md
```

1. **Map (first run).** It detects the project name and the technologies in the spec, and writes `import-map.md` in the umbrella: every block of source lines with its destination repo, file and treatment (`verbatim`, `openapi`, or `dropped` with a reason). It shows you the technologies it found, the folders it will create, the rows left out and the open questions, and **nothing is created or written until you approve**. `import-check.sh --map-only` proves that every non-blank source line is accounted for and that the source has not changed since.
2. **Repos.** After your OK it creates one folder per technology (`<ProjectName>AppleApp`, `AndroidApp`, `Backend`, `Website`, `Contracts`), runs `git init` in each and leaves it on `develop`. Then it fills each repo with its own rows: `AGENTS.md` (with *Related repositories*, links to `docs/` and the [working rules](#working-rules)), `decisions/`, `specs/` and `docs/`; in the contracts repo, the shared specs and `openapi.yaml`. Text moves word for word. What the layout needs and the source does not say is marked `Open question: not specified in the source spec`, never filled in. If two iterations of the source contradict each other, **both are kept and marked**, not reconciled. Existing files are never overwritten.
3. **Verify.** After each repo the command runs `import-check.sh --repo <repo>`: every line of every row of that repo must be in its destination file, word for word. At the end, `/fl:import --check` verifies all repos at once and runs an OpenAPI structural lint on `openapi.yaml` (`redocly lint --extends minimal`; install it with `npm install -g @redocly/cli`; the check fails on purpose if it is not found).

Everything Forgeloom writes is in English. The source is moved word for word, so a source in another language stays in that language: the command lists it as an open question and does not translate it.

Nothing is committed and the source file stays where it is. Review the open questions first.

Without Claude Code: paste `prompts/import-spec.md`, then run the script yourself. It needs only `bash`, `awk` and `shasum` or `sha256sum`:

```bash
bash /path/to/forgeloom/plugins/fl/scripts/import-check.sh ../import-map.md --repo AcmeProductAppleApp
```

## Use case 6 — Equivalent in each adapter

| Step | Claude Code | Codex | Cursor / others |
|---|---|---|---|
| Get the stack knowledge | `claude plugin install <stack>@forgeloom` | `./install.sh <stack> <project>` — Codex reads `AGENTS.md` natively | `./install.sh <stack> <project>` — Cursor reads `AGENTS.md` natively |
| New-project charter | `/fl:define` | paste `prompts/chat-to-charter.md` | paste `prompts/chat-to-charter.md` |
| Feature spec | `/fl:define feature-name` | paste `prompts/chat-to-spec.md` | paste `prompts/chat-to-spec.md` |
| Bug | `/fl:fix "..."` | paste `prompts/chat-to-bug.md`, then ask for root cause before any fix, a red test, then a minimal fix | same as Codex |
| Split an existing all-in-one spec (creates the repos) | `/fl:import <source.md>` | paste `prompts/import-spec.md`, then run `plugins/fl/scripts/import-check.sh` yourself | same as Codex |
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

## Working rules

Four rules apply to every project, whatever the stack. They are in each stack's `AGENTS.md` (so `install.sh` brings them), and `/fl:define` and `/fl:import` write them into the `AGENTS.md` of every repo they create.

| Rule | What it says |
|---|---|
| Git flow | `develop` is created at `git init` and the first commit is made there; `feature/`, `release/` and `hotfix/` branches, merges with `--no-ff`; `main` holds tagged releases and appears with the first. |
| Commits | English, conventional style, 2 lines at most. Never a `Co-Authored-By` or any other attribution trailer. |
| Language | Every `.md` file and every other document is in English, whatever language you chat in. |
| Final summaries | What changed and what needs your decision or review, straight to the point; no long explanations unless you ask. |

These are instructions the model follows, not a hook that blocks: the commit gate checks secrets and dependencies, not the commit message.

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
│   ├── fl/                           # commands (define, fix, promote, import) + scripts/import-check.sh
│   ├── ios-swift/  web/  backend/    # per-stack skills + subagents; shared pieces symlinked from common/
├── prompts/                          # closing prompts for chat
├── templates/                        # adr.md, pattern.md, import-map.md
├── adapters/                         # cursor/, codex/
└── install.sh                        # generic installer
```

In each stack plugin, the shared subagents are **individual symlinks** into `common/agents/` (never the whole folder, because each stack also has real agents of its own), `hooks` links to `common/hooks`, and `knowledge` links to that stack's core. The `fl` commands live only in `plugins/fl/`, with `name: "fl"`, so `/fl:define` is identical whichever stack plugin is installed. `import-check.sh` lives there too, as a real file, next to the command that uses it.

## Known limits

Behaviors that were verified against a real install and are worth knowing:

- **Installed plugins contain copies, not symlinks.** Claude Code dereferences symlinks that point elsewhere inside the same marketplace when it copies a plugin to its cache. Content and executable bits survive, but a change in `common/` reaches an installed plugin only after you update the marketplace and the plugin.
- **One stack plugin per repo.** The shared subagents, the `dependency-scan` skill and the gate are bundled in every stack plugin. With two stack plugins in one project, the shared subagents appear once per stack (`ios-swift:code-reviewer`, `web:code-reviewer`) and the gate runs once per plugin.
- **The gate anticipates chained `git add`s.** A Claude Code hook runs before the whole command, so in `git add -A && git commit` the `git add` has not happened yet. The gate therefore scans what that `git add` is about to stage (all changes and untracked files for `-A`/`.`/`-u`, or just the listed paths), plus `git commit -a`. This was found by testing against a real session, where the first version let such a commit through.
- **The gate only sees commits Claude Code runs.** A commit you type by hand in your terminal does not trigger a Claude Code hook; use the git `pre-commit` install above for that.
- **`dependency-scan` checks what a commit adds or changes.** With no lockfile it queries the lower bound of the declared range; `Package.swift` dependencies are read only when on a single line; other package managers (`yarn.lock`, `pnpm-lock.yaml`, `poetry.lock`, ...) produce a warning, not a check. It needs network access.
- **`/fl:promote` needs a real forgeloom checkout** to write into (it never writes into the plugin cache). It looks for `$FORGELOOM_DIR`, then the current directory, then a local marketplace entry, and otherwise asks you.
- **`/fl:import` proves the text is there, not that it is in the right place.** `import-check.sh` verifies, line by line and word for word, that everything in the map reached its destination file, and that no source line was left out. It cannot tell whether a line sits under the right heading of that file, whether a feature was assigned to the right repo, or whether a `dropped` row really was not project content: that is what the map review and the open-questions list are for. It ignores indentation, heading levels, list and checkbox markers, so text can move under other headings; reworded text fails.
- **`/fl:import` runs from the umbrella folder.** The source and the map live there, and the repos are created inside it, so no `--add-dir` is needed. If you run it from inside one repo instead, start the session with `claude --add-dir ..`; the command never copies the source into a repo. `/fl:define` writing a shared spec in a sibling contracts repo still needs the sibling folder added.
- **`/fl:import` decides the repos from the spec.** Technologies and the `Contracts` repo are inferred from what the source says, and you approve them before anything is created. Two projects of the same technology (two backends) and technologies outside the naming table are asked, not guessed. `AndroidApp` gets a folder but has no Forgeloom stack yet.
- **The English rule and word-for-word import can collide.** A non-English source stays as written (translating would fail the check); the command reports it and leaves the translation to you.
- **The working rules are instructions, not enforcement.** Nothing blocks a `Co-Authored-By` trailer or a first commit on another branch; the commit gate checks secrets and dependencies only.
- **The OpenAPI conversion keeps the source text but does not fill gaps.** Each operation carries its source lines verbatim in `description`; types, required fields, status codes and auth that the source never states are left empty and marked `x-open-question`. The result is a skeleton the contract review must complete, not a finished contract. The lint checks structure (valid YAML and OpenAPI, no dangling `$ref`), not style completeness: Redocly's `recommended` rules (servers, security, summaries, operationIds) would demand facts the source never states, so they are off by default; set `FL_IMPORT_LINT_CMD` for a stricter ruleset. The linter is required and is not bundled.
- **Sessions do not talk to each other.** A session that needs work in another repo leaves it in the contracts repo (shared spec and `openapi.yaml`) and you start the other repo's session. This is deliberate: it works the same in Codex and Cursor, and no session directs another unseen.
- **Theme palettes are AA-checked, and the dark theme has a gradient limit.** Each theme's colors were adjusted so the listed pairs reach 4.5:1 as normal text (for example the terracotta accent on the editorial background, or the mustard accent on cream); every pair is measured in the theme file, next to the value it replaced. Text cannot sit directly over the dark theme's full violet→cyan gradient, because no single text color passes on both ends.

## License

[MIT](LICENSE) © 2026 Luis Cárdenas.
