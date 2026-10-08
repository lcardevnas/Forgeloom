<div align="center">

# Forgeloom

**Spec-driven AI development, with the lessons of every project kept for the next one.**

A workflow and a per-stack knowledge library (iOS/Swift, web, backend) that makes your AI coding assistant work from a written spec, follow your conventions and stop guessing.

[![Release](https://img.shields.io/github/v/tag/lcardevnas/Forgeloom?label=release&sort=semver)](https://github.com/lcardevnas/Forgeloom/tags)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Claude Code plugins](https://img.shields.io/badge/Claude%20Code-plugins-D97757)](#install)
[![Stacks](https://img.shields.io/badge/stacks-iOS%2FSwift%20%C2%B7%20web%20%C2%B7%20backend-informational)](#what-each-plugin-gives-you)
[![Works with AGENTS.md](https://img.shields.io/badge/AGENTS.md-Codex%20%C2%B7%20Cursor-lightgrey)](#other-tools-codex-cursor)

[Why Forgeloom](#why-forgeloom) · [Install](#install) · [Getting started](#getting-started) · [Plugins](#what-each-plugin-gives-you) · [Known limits](#known-limits)

</div>

---

## Why Forgeloom

AI assistants fail in predictable ways: they start coding from a vague sentence, fill every gap with a plausible default, forget what was decided yesterday, ship a leaked key or a vulnerable dependency, and repeat the same mistake in the next project. Forgeloom is a set of small, enforceable habits that remove those failures.

**Install it if you want:**

- **A repo set up in one command.** `/fl:init` adds the working rules to the `AGENTS.md` you already have (or creates one from the code it finds), points `CLAUDE.md` at it, puts the repo on git flow and checks that the commit gate's tools are installed. Safe to re-run, and it never overwrites what you wrote.
- **A written definition before any code.** `/fl:define` turns a conversation into `AGENTS.md`, a decision record or a feature spec with checkable acceptance criteria. Anything undecided is marked as an *open question*, never assumed.
- **Bugs fixed with proof.** `/fl:fix` finds the root cause first, writes a test that fails for the bug's reason, then makes the minimal fix.
- **Your stack's conventions applied while the code is written.** Skills for Swift 6 concurrency, SwiftUI, SwiftData, Core Web Vitals, WCAG, API contracts and more, each with a *Must never assume* part that stops the model from using a default that is wrong for your project.
- **A review before you look.** Audit subagents (OWASP, accessibility, performance, memory, contract compliance) and a `code-reviewer` that checks the diff against the spec, criterion by criterion.
- **A commit gate.** A hook blocks a commit that adds a secret or a dependency with a known vulnerability (checked against [OSV.dev](https://osv.dev)).
- **A polished Apple UI.** `professional-apple-ui` gives macOS and iOS apps one of ten native-feeling styles, an approved HTML mockup per screen and a screenshot tour looked at in light and dark.
- **Lessons that compound.** `/fl:promote` turns what a project taught you into a pattern every later project of that stack inherits.
- **A way in from a chat.** Define a product in any chat with the prompts in `prompts/`, or split an existing all-in-one spec into one repo per platform with `/fl:import`, with a check that no text was lost.

**It is not** a code generator or a framework. It adds no runtime dependency to your app: it is Markdown, prompts, a few shell scripts and Claude Code plugins. Codex and Cursor can use the knowledge core through `AGENTS.md`, without the commands and hooks.

### How it works

```text
 define                 plan                  implement            check                 learn
 /fl:define      →      plan mode      →      skills inform   →    commit gate     →     /fl:promote
 AGENTS.md              "implement            the code             + code-reviewer       pattern in
 specs/<feature>.md      according to          (tests from          + audit subagents     knowledge/<stack>/
                         specs/..."            acceptance           (OWASP, a11y, ...)    patterns/
                                               criteria)
 bug: /fl:fix = root cause → red test → minimal fix → same checks
```

Forgeloom has two layers: an **agnostic core** (`knowledge/`, plain Markdown any assistant that reads `AGENTS.md` can use) and **adapters** on top of it, mainly the Claude Code plugins. What you write once in `knowledge/` every project of that stack inherits.

## Install

**Requirements**: Claude Code, and for the commit gate `bash`, `git`, `curl` and `jq`, plus network access to [OSV.dev](https://osv.dev), the free, open vulnerability database that the dependency check queries (no API key needed; it covers every package manager the check supports). The scripts of `professional-apple-ui` need Python 3 (included with Xcode's Command Line Tools).

**1. Add the marketplace** (once; a local checkout works too: `claude plugin marketplace add /path/to/forgeloom`):

```bash
claude plugin marketplace add lcardevnas/Forgeloom
```

Or, inside Claude Code: `/plugin marketplace add lcardevnas/Forgeloom` (the repository is <https://github.com/lcardevnas/Forgeloom>).

**2. Install the stack plugin** for your project. It declares the `fl` plugin as a dependency, so the commands `/fl:init`, `/fl:define`, `/fl:fix`, `/fl:promote` and `/fl:import` come with it:

```bash
claude plugin install ios-swift@forgeloom --scope project   # or: web, backend
```

**3. Set the repo up**: open Claude Code in the repo and run `/fl:init`. The plugin itself writes nothing into your repo, so this is the step that adds the working rules to your `AGENTS.md`. Commands always carry the plugin name (`/fl:...`), whatever stack plugin is installed next to it. See [Adopt Forgeloom in an existing repo](#adopt-forgeloom-in-an-existing-repo).

| Plugin | Gives you |
|---|---|
| `fl` | The commands `/fl:init`, `/fl:define`, `/fl:fix`, `/fl:promote`, `/fl:import` and the scripts that check a source spec and verify an import. Independent of the stack, so the command names never change with the stack you install. |
| `ios-swift` | (installs `fl` too) 8 skills (with 10 UI styles), 4 audit subagents, 3 shared subagents, the commit gate. |
| `web` | (installs `fl` too) 4 skills (with 4 design themes), 4 audit subagents, 3 shared subagents, the commit gate. |
| `backend` | (installs `fl` too) 4 skills, 2 audit subagents, 3 shared subagents, the commit gate. |

Use `--scope project` for the stack plugin so your team gets it through the project's `.claude/settings.json`. Install **one stack plugin per repo**: the shared subagents and the gate are bundled in each stack plugin, so installing several in the same project duplicates them (see [Known limits](#known-limits)).

`fl` is a separate plugin on purpose: a plugin's commands are always invoked as `/<plugin-name>:<command>`, so if the commands lived inside a stack plugin they would be `/ios-swift:define` in one project and `/web:define` in another. You can also install it alone, at user scope, to have the commands everywhere: `claude plugin install fl@forgeloom`.

### Update

Installed plugins are copies, so new commands, rules and skills reach you only when you update. Update the marketplace first, then each plugin you use, and restart Claude Code:

```bash
claude plugin marketplace update forgeloom
claude plugin update fl@forgeloom --scope project
claude plugin update ios-swift@forgeloom --scope project   # or: web, backend
claude plugin list                                         # check the versions
```

Use the scope you installed with (`--scope user` for `fl` if you installed it there). Then run `/fl:init` again in each repo: it compares the working rules in your `AGENTS.md` with the ones in the new version and offers only the difference, so a repo set up with an older release picks up new rules without losing anything of yours. A release that adds or changes commands, rules or skills is described in its tag message (`git tag -n99 vX.Y.Z`, or the [Tags](https://github.com/lcardevnas/Forgeloom/tags) page).

## Getting started

Pick the place where you will do the thinking. Both paths end in the same place: files in your repo (`AGENTS.md`, `specs/`, `decisions/`) and a coding session that implements from them.

| | Start in a **chat** (any assistant) | Start in **Claude Code** |
|---|---|---|
| Best for | A new product or project, a big definition, thinking before any repo exists, or when you prefer a cheaper, code-free conversation | A feature or bug in a repo that already has code, a new project you want to scaffold right away |
| Needs installed | Nothing to think. Forgeloom's prompts are plain text | The plugins ([Install](#install)) |
| You use | The prompts in `prompts/` | The commands `/fl:define`, `/fl:fix`, `/fl:import` |
| Why | No code to read, so no per-turn overhead; works with any model | It reads your real code, so the questions are grounded in it |

You can mix them: define a new product in a chat, then continue in Claude Code for every feature.

### Path A: you start in a chat

You do not need Forgeloom installed to think. You need it when you move to coding.

**Step 1. Choose the prompt for what you are doing.**

| You are defining | Paste this | Where | Save the result as |
|---|---|---|---|
| A product with several platforms (app + backend + website), from scratch | [`prompts/chat-to-source-spec.md`](prompts/chat-to-source-spec.md) | as the **first** message of a new chat | `source-spec.md` |
| A single project from scratch | [`prompts/chat-to-charter.md`](prompts/chat-to-charter.md) | at the **end** of your conversation | `AGENTS.md` and `decisions/0001-foundation.md` |
| A feature on an existing project | [`prompts/chat-to-spec.md`](prompts/chat-to-spec.md) | at the **end** | `specs/<feature>.md` |
| A bug | [`prompts/chat-to-bug.md`](prompts/chat-to-bug.md) | at the **end** | `bugs/<id>.md` |
| A definition that already exists as one big file | [`prompts/import-spec.md`](prompts/import-spec.md) | with the file attached | see "Split an existing spec" below |

Most prompts are *closing* prompts: you talk first, then paste them and they summarize what was decided. The exception is `chat-to-source-spec.md`, an *opening* prompt that interviews you in stages, because a closing prompt cannot ask about what nobody mentioned. The last sentence of every prompt is the one that matters: it stops the model from filling gaps with assumptions you never made.

**Step 2. Review the open questions first.** Whatever the chat did not settle comes out as `Open question: ...`. Answer them (or leave them open on purpose) before going further.

**Step 3. Put the files in a repo and start coding**, depending on what you defined:

- **A single project (charter) or a feature (spec).** Move the files into the repo, install the stack plugin ([Install](#install)), open Claude Code **in that repo**, run `/fl:init` (it keeps the `AGENTS.md` you brought and only completes what it lacks) and start with `Implement according to specs/<feature>.md` in plan mode. For a new project, define the first feature next with `/fl:define <feature>` or paste `chat-to-spec.md` again.
- **A multi-platform product (source spec).** Save `source-spec.md` in an empty folder (the umbrella) and check its shape:

  ```bash
  bash /path/to/forgeloom/plugins/fl/scripts/source-check.sh source-spec.md
  ```

  A `FAIL` is a required part the interview never produced (a feature with no `Out of scope:`, a platform without acceptance criteria, a duplicated feature); a `WARN` is something likely wrong. Fix it by going back to the chat. Then open Claude Code **in the umbrella folder** and run `/fl:import source-spec.md`: see [Split an existing spec](#split-an-existing-all-in-one-spec).
- **A bug.** Open Claude Code in the repo and run `/fl:fix bugs/<id>.md`, or paste `chat-to-bug.md`'s output and ask for the root cause before any fix.

**Using Codex, Cursor or another tool instead of Claude Code?** Run the installer to bring the stack knowledge, and see [Other tools](#other-tools-codex-cursor).

#### Defining a product in one chat: how the interview works

`chat-to-source-spec.md` runs in stages, each ending with a gate: project (name, problem, users, non-goals, global constraints), platforms, the foundation of each platform, a feature inventory (names only), each feature in full, contracts derived from the features, cross-platform decisions, an audit, and a single render. Four things make the result importable:

- **Sections are printed and frozen as they are confirmed**, so nothing depends on the model remembering a long chat, and a correction replaces text instead of appending a contradiction.
- **A feature is not closed** until it has an objective, scope with an explicit `Out of scope:`, constraints and, for every platform it involves, at least one checkable criterion. The assistant proposes criteria (including failure, empty and offline cases) and you confirm them; nobody writes them from a blank page.
- **Unknown is written down**: `Open question: <what is missing>`, never an empty part or a plausible default.
- **The document holds the current state only** (no history, no "as we discussed"), in the exact order and headings `/fl:import` routes.

### Path B: you start in Claude Code

Install the plugins first ([Install](#install)), then open Claude Code **in the repo** (not in a parent folder), and follow the row that matches your situation.

| Situation | Run | You get | Do next |
|---|---|---|---|
| Existing repo with code, first time | `/fl:init` | The working rules in `AGENTS.md` (created from the code if missing), `CLAUDE.md`, `develop` | Review the open questions, then define a feature |
| Empty repo, new project | `/fl:define my-project` | `AGENTS.md` + `decisions/0001-foundation.md` | Review open questions, then define the first feature |
| Repo with `AGENTS.md`, new feature | `/fl:define feature-name` | `specs/feature-name.md` | Plan mode: `Implement according to specs/feature-name.md` |
| A bug | `/fl:fix "symptom"` or `/fl:fix bugs/123.md` | Root cause, red test, minimal fix | Review, commit with the test |
| Building or restyling a SwiftUI screen | ask for the screen (see below) | Brief, mockup, code, screenshots | Approve the mockup, review the screenshots |
| A big all-in-one spec file | `/fl:import source-spec.md` in the umbrella folder | One repo per platform | Review the map and open questions |
| A lesson that generalizes | `/fl:promote` | A staged pattern file | You make the commit |

#### Adopt Forgeloom in an existing repo

```text
/fl:init
```

Run it once per repo, after installing the plugins. It starts read-only: it looks at your branch, `AGENTS.md`, `CLAUDE.md`, the manifests that show the stack, the enabled plugins and the tools the commit gate needs, and tells you what it found before asking anything. Then, depending on what is there:

| What it finds | What it does |
|---|---|
| Code and **no `AGENTS.md`** | Creates one with the stack and the commands that your manifests state (each with its source file), `Open question:` for hosting and architecture, and the working rules. It never infers architecture from folder names. |
| An `AGENTS.md` **without the working rules** (hand-written, from another tool, or from an older Forgeloom) | Appends the section, or adds only the missing rules, and shows you the difference where a rule differs from yours. It never reorders or edits anything else, and it reports a conflict (for example a rule that asks for `Co-Authored-By`) instead of resolving it. |
| An `AGENTS.md` that came from a chat (`chat-to-charter.md`) | Keeps it as is and only verifies the rules. |
| A real `CLAUDE.md` and no `AGENTS.md` | Leaves your file alone and, with your OK, appends one line `@AGENTS.md` so Claude Code loads both. |
| No `CLAUDE.md` | Creates it as a link to `AGENTS.md`. |
| A repo on `main` with history and no `develop` | Offers `git switch -c develop` and says what it means: the history stays, `main` is not touched, releases start being tagged from the next one. |
| No code and no `AGENTS.md` (a brand-new project) | Only sets up git flow; `/fl:define my-project` writes the charter and the rules together. |
| A folder with a `source-spec.md`, or several repos side by side | Stops and points you to `/fl:import`, or to running `/fl:init` inside each repo. |

It also tells you, with the exact command and without running it, if the stack plugin is not installed for the repo, if two are, or if `git`, `curl` or `jq` (or `python3` for iOS) is missing. It asks before every write, never commits or installs, and a second run changes nothing. For a multi-repo project, run it in each repo, the contracts repo included.

**Next:** `/fl:define <feature>`. If `AGENTS.md` has `Open question:` lines in its foundation sections, `/fl:define` raises the ones that feature depends on and closes them with you first.

#### New project

```text
/fl:define my-project-name
```

`/fl:define` detects that `AGENTS.md` does not exist, talks the foundation through with you (stack, hosting, architecture, planned commands) and writes:

- `AGENTS.md`: Technical stack, Hosting/infrastructure, General architecture, Planned commands and, if the project spans several repos, Related repositories. Only what was explicitly decided.
- `decisions/0001-foundation.md`: an ADR with what was chosen, the alternatives if any were mentioned, and why.

Both end up in a repo that follows the [working rules](#working-rules). Anything undecided is an **open question**: review those first. Nothing is committed for you. The foundation is permanent context, which is why it is not a feature spec: buried in one, it would be lost when that feature closes.

**Next:** define the first feature (below). The stack is not decided again: plan mode inherits it from `AGENTS.md`.

#### A feature on an existing project

1. **Define.** `/fl:define feature-name` detects the existing `AGENTS.md`, grounds its questions in the real code, and writes `specs/feature-name.md`: Objective, Scope (including what is explicitly out), Constraints, Acceptance criteria (a verifiable checklist) and Relevant prior decisions. If the feature needs more than one repo, the spec goes in the contracts repo instead: see [Multi-repo projects](#multi-repo-projects).
2. **Plan before code.** Start with `Implement according to specs/feature-name.md` in plan mode. Review the plan and approve or correct it. Do not open with "I want to do X".
3. **Implement.** Skills of your stack plugin (for example `ios-swift:modern-swiftui`) inform the code as it is written. For critical logic, write the tests first; for the rest, the `test-writer` subagent turns each acceptance criterion into a test.
4. **Check.** The commit gate blocks a `git commit` that adds a secret or a vulnerable dependency; the `code-reviewer` subagent reviews the diff against the spec and your conventions; then the audit subagent of your stack when relevant (`security-review-owasp-mobile`, `security-review-owasp-web`, `api-security-review-owasp`, ...).
5. **Commit, and promote.** If you learned something that generalizes to the stack, run `/fl:promote`: it writes a pattern to `knowledge/<stack>/patterns/` in your forgeloom checkout and **leaves it staged**. You make the commit.

#### A bug

A bug **does not start with a spec: it starts with a test that reproduces the failure.** Feature: spec first, test after. Bug: test first, fix after, to prove that what was broken no longer is.

```text
/fl:fix "Checkout crashes when the cart has a discounted item and the coupon expires"
```

or point it at a written report: `/fl:fix bugs/123.md`. In order:

1. **Bug report, not a spec**: symptom, reproduction, expected vs. observed, fix scope (related causes you will *not* touch now).
2. **Root cause before solution.** It reproduces the bug, finds the cause and explains it *before* proposing a fix. Legacy or large areas go to the `explorer` subagent.
3. **A regression test, red**, failing for the bug's reason.
4. **Minimal fix**, scoped to the report. No opportunistic refactors: anything else becomes a separate spec or bug.
5. **Verification**: the test turns green, the suite and lint pass, `code-reviewer` runs on the diff.
6. **Commit with the regression test** (you make the commit). A repeatable pattern suggests `/fl:promote`.

#### A SwiftUI screen (iOS/macOS)

With the `ios-swift` plugin, any request to create or change a screen follows `professional-apple-ui`; you do not need to name it. For a new screen:

1. **Pick the look, once per project.** If `AGENTS.md` does not say `UI style: <id>`, Claude opens the style gallery (10 styles, light and dark side by side), proposes one and waits for your pick. You can also describe your own: it builds a full, AA-checked token set from a brand color. The choice is saved in `docs/ui-style.json` and `AGENTS.md`, and `Theme.swift` is generated from it.
2. **Design brief**, in the chat: who uses the screen, the one primary action, the hierarchy and an ASCII wireframe.
3. **HTML mockup, approved by you.** Saved in `docs/ui-references/mockups/`, shown in light and dark. Nothing is written in SwiftUI until you say OK. It is skipped when the change keeps the screen's layout and flow, and then Claude tells you it skipped it and why.
4. **Build and look.** It builds with native controls and your theme tokens, runs a screenshot tour of only the touched sections in light and dark, and goes through a review checklist against the screenshots.

The mockup settles layout, hierarchy and wording. Native rendering (fonts, materials, toolbars, Dynamic Type) is judged by the real screenshots, and for screens that depend on a toolbar, sidebar or sheet only the content area is mocked up.

#### Split an existing all-in-one spec

You already have the whole definition as one big Markdown file (features, architecture, API contracts, configuration, built over many chat iterations) and you must not lose any of it. `/fl:define` and the `chat-to-*` prompts write *from what was discussed*, which can summarize; this flow **moves existing text** and proves that it kept all of it. It needs the [multi-repo layout](#multi-repo-projects) and **creates the repos for you**.

Put the source file in an empty folder (the umbrella), open Claude Code there and run:

```bash
cd AcmeProduct && claude
```

```text
/fl:import source-spec.md
```

1. **Map (first run).** It detects the project name and the technologies, and writes `import-map.md` in the umbrella: every block of source lines with its destination repo, file and treatment (`verbatim`, `openapi`, or `dropped` with a reason). It shows you the technologies it found, the folders it will create, the rows left out and the open questions, and **nothing is created until you approve**. `import-check.sh --map-only` proves that every non-blank source line is accounted for and that the source has not changed since.
2. **Repos.** After your OK it creates one folder per technology (`<ProjectName>AppleApp`, `AndroidApp`, `Backend`, `Website`, `Contracts`), runs `git init` in each and leaves it on `develop`. Then it fills each repo with its own rows: `AGENTS.md` (with *Related repositories*, links to `docs/` and the [working rules](#working-rules)), `decisions/`, `specs/` and `docs/`; in the contracts repo, the shared specs and `openapi.yaml`. Text moves word for word. What the layout needs and the source does not say is marked `Open question: not specified in the source spec`, never filled in. If two iterations of the source contradict each other, **both are kept and marked**. Existing files are never overwritten.
3. **Verify.** After each repo, `import-check.sh --repo <repo>` checks that every line of every row is in its destination file, word for word. At the end, `/fl:import --check` verifies all repos and runs an OpenAPI structural lint on `openapi.yaml` (`redocly lint --extends minimal`; install it with `npm install -g @redocly/cli`; the check fails on purpose if it is not found).

Everything Forgeloom writes is in English; a source in another language stays as written and is listed as an open question. Nothing is committed and the source file stays where it is.

**Next:** review the map and the open questions, then open a Claude Code session **in each repo** and use the feature flow above. A feature that spans repos goes through the contracts repo: see [Multi-repo projects](#multi-repo-projects).

Without Claude Code: paste `prompts/import-spec.md`, then run the script yourself. It needs only `bash`, `awk` and `shasum` or `sha256sum`:

```bash
bash /path/to/forgeloom/plugins/fl/scripts/import-check.sh ../import-map.md --repo AcmeProductAppleApp
```

If the source came from the `chat-to-source-spec.md` interview, `/fl:import` runs the same shape check as `source-check.sh` by itself and shows what failed, but never edits the source. Import can only move text: the quality of an import is decided when the source is written.

### Other tools (Codex, Cursor)

| Step | Claude Code | Codex | Cursor / others |
|---|---|---|---|
| Get the stack knowledge | `claude plugin install <stack>@forgeloom` | `./install.sh <stack> <project>`; Codex reads `AGENTS.md` natively | `./install.sh <stack> <project>`; Cursor reads `AGENTS.md` natively |
| Set an existing repo up (working rules, `CLAUDE.md`, git flow) | `/fl:init` | paste `prompts/init-repo.md` | paste `prompts/init-repo.md` |
| New-project charter | `/fl:define` | paste `prompts/chat-to-charter.md` | paste `prompts/chat-to-charter.md` |
| Feature spec | `/fl:define feature-name` | paste `prompts/chat-to-spec.md` | paste `prompts/chat-to-spec.md` |
| Bug | `/fl:fix "..."` | paste `prompts/chat-to-bug.md`, then ask for root cause before any fix, a red test, then a minimal fix | same as Codex |
| Define a new product as an import-ready source spec | paste `prompts/chat-to-source-spec.md` as the first message of a chat, then `source-check.sh` | same as Claude Code | same as Claude Code |
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

## Working rules

Seven rules apply to every project, whatever the stack. They are in each stack's `AGENTS.md` (so `install.sh` brings them), `/fl:define` and `/fl:import` write them into the `AGENTS.md` of every repo they create, and `/fl:init` adds or updates them in a repo that already exists.

| Rule | What it says |
|---|---|
| Git flow | `develop` is created at `git init` and the first commit is made there; `feature/`, `release/` and `hotfix/` branches, merges with `--no-ff`; `main` holds tagged releases and appears with the first. |
| Commits | English, conventional style, 2 lines at most. Never a `Co-Authored-By` or any other attribution trailer. |
| Language | Every `.md` file and every other document is in English, whatever language you chat in. |
| Cross-repo work | If a feature needs another repo, never edit it: create or extend the shared spec in the contracts repo with a group for that platform. |
| Next steps | "What is next" reads the unticked acceptance criteria in this repo's specs and in its group of the contracts specs. |
| Challenge decisions | If a decision looks wrong or a clearly better option exists, it says so once, shows the alternative and lets you decide; then it follows your choice. |
| Final summaries | What changed and what needs your decision or review, straight to the point; no long explanations unless you ask. |

These are instructions the model follows, not a hook that blocks: the commit gate checks secrets and dependencies, not the commit message.

## What each plugin gives you

Every stack plugin also ships three shared subagents (`code-reviewer`, `test-writer`, `explorer`), the commit-gate hook and the `dependency-scan` skill.

**Skills** inform code as it is written. **Subagents** audit code already written, in an isolated pass.

| Stack | Skills | Audit subagents |
|---|---|---|
| `ios-swift` | `swift-high-standard`, `swift6-concurrency`, `modern-swiftui`, `professional-apple-ui` (10 styles), `swift-testing`, `swiftdata-persistence`, `networking-async-await`, `privacy-manifest` | `security-review-owasp-mobile`, `accessibility-review-ios`, `memory-review-ios`, `performance-review-ios` |
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

**Apple UI styles.** `professional-apple-ui` gives macOS and iOS apps one soft, card-based look on a native shell, from one of ten styles (Mint Studio, Sky Harbor, Lavender Loft, Peach Bakery, Sage Garden, Butter Sun, Blush Petal, Aqua Pool, Terracotta Clay, Indigo Ink) or a custom one built from a brand color. The user picks the style in a gallery that shows each one in light and dark. The style is recorded once per project, and `Theme.swift` is generated from it. Every screen then goes through a design brief, an HTML mockup the user approves before any SwiftUI, and a screenshot tour reviewed in light and dark against a checklist. The skill bundles the scripts for this (style builder with a contrast check, theme generator, mockup starter) and templates for shared components, appearance, localization and the screenshot tour. Tokens, measured contrast and the platform rules are in `knowledge/ios-swift/design-system/`.

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
│   ├── ios-swift/  { AGENTS.md, design-system/{styles/}, patterns/ }
│   ├── web/        { AGENTS.md, design-system/themes/, patterns/ }
│   └── backend/    { AGENTS.md, patterns/ }
├── common/                           # shared across all stacks
│   ├── agents/                       # code-reviewer, test-writer, explorer
│   ├── skills/dependency-scan/
│   └── hooks/                        # hooks.json, pre-commit-gate.sh, secret-scan.sh, dependency-scan.sh
├── plugins/
│   ├── fl/                           # commands (init, define, fix, promote, import) + scripts/{import-check,source-check}.sh
│   ├── ios-swift/  web/  backend/    # per-stack skills + subagents; shared pieces symlinked from common/
├── prompts/                          # prompts for chat: closing prompts, plus the opening chat-to-source-spec
├── templates/                        # adr.md, pattern.md, import-map.md
├── adapters/                         # cursor/, codex/
└── install.sh                        # generic installer
```

In each stack plugin, the shared subagents are **individual symlinks** into `common/agents/` (never the whole folder, because each stack also has real agents of its own), `hooks` links to `common/hooks`, and `knowledge` links to that stack's core. The `fl` commands live only in `plugins/fl/`, with `name: "fl"`, so `/fl:define` is identical whichever stack plugin is installed. `import-check.sh` and `source-check.sh` live there too, as real files, next to the command that uses them.

## Known limits

Behaviors that were verified against a real install and are worth knowing:

- **Installed plugins contain copies, not symlinks.** Claude Code dereferences symlinks that point elsewhere inside the same marketplace when it copies a plugin to its cache. Content and executable bits survive, but a change in `common/` reaches an installed plugin only after you update the marketplace and the plugin.
- **One stack plugin per repo.** The shared subagents, the `dependency-scan` skill and the gate are bundled in every stack plugin. With two stack plugins in one project, the shared subagents appear once per stack (`ios-swift:code-reviewer`, `web:code-reviewer`) and the gate runs once per plugin.
- **The gate anticipates chained `git add`s.** A Claude Code hook runs before the whole command, so in `git add -A && git commit` the `git add` has not happened yet. The gate therefore scans what that `git add` is about to stage (all changes and untracked files for `-A`/`.`/`-u`, or just the listed paths), plus `git commit -a`. This was found by testing against a real session, where the first version let such a commit through.
- **The gate only sees commits Claude Code runs.** A commit you type by hand in your terminal does not trigger a Claude Code hook; use the git `pre-commit` install above for that.
- **`dependency-scan` checks what a commit adds or changes.** With no lockfile it queries the lower bound of the declared range; `Package.swift` dependencies are read only when on a single line; other package managers (`yarn.lock`, `pnpm-lock.yaml`, `poetry.lock`, ...) produce a warning, not a check. It needs network access.
- **`/fl:promote` needs a real forgeloom checkout** to write into (it never writes into the plugin cache). It looks for `$FORGELOOM_DIR`, then the current directory, then a local marketplace entry, and otherwise asks you.
- **`/fl:import` proves the text is there, not that it is in the right place.** `import-check.sh` verifies, line by line and word for word, that everything in the map reached its destination file, and that no source line was left out. It cannot tell whether a line sits under the right heading of that file, whether a feature was assigned to the right repo, or whether a `dropped` row really was not project content: that is what the map review and the open-questions list are for. It ignores indentation, heading levels, list and checkbox markers, so text can move under other headings; reworded text fails.
- **`source-check.sh` checks shape, not quality, and the interview is not proven.** It confirms the required parts exist and are not empty (a declared `Open question:` counts as filled), that platform names agree across sections and that no feature is duplicated. It cannot tell a weak acceptance criterion from a good one, and the assistant can still drift in a long chat: the frozen sections and the audit stage reduce that, they do not remove it. The check reads only the format of `prompts/chat-to-source-spec.md`; a spec in any other shape is imported as before and is not checked.
- **`/fl:import` runs from the umbrella folder.** The source and the map live there, and the repos are created inside it, so no `--add-dir` is needed. If you run it from inside one repo instead, start the session with `claude --add-dir ..`; the command never copies the source into a repo. `/fl:define` writing a shared spec in a sibling contracts repo still needs the sibling folder added.
- **`/fl:import` decides the repos from the spec.** Technologies and the `Contracts` repo are inferred from what the source says, and you approve them before anything is created. Two projects of the same technology (two backends) and technologies outside the naming table are asked, not guessed. `AndroidApp` gets a folder but has no Forgeloom stack yet.
- **The English rule and word-for-word import can collide.** A non-English source stays as written (translating would fail the check); the command reports it and leaves the translation to you.
- **`/fl:init` records facts, it does not decide.** It reads manifests and scripts, never folder names, so a stack it cannot read from a file stays an `Open question` and a `package.json` that could be a front end or a server is asked, not guessed. It has not been tested against every project layout; read the proposed `AGENTS.md` before accepting it. The Working rules text it writes is copied from the command itself, so a repo set up with an older release keeps its older rules until you update the plugin and run `/fl:init` again.
- **The working rules are instructions, not enforcement.** Nothing blocks a `Co-Authored-By` trailer or a first commit on another branch; the commit gate checks secrets and dependencies only.
- **The OpenAPI conversion keeps the source text but does not fill gaps.** Each operation carries its source lines verbatim in `description`; types, required fields, status codes and auth that the source never states are left empty and marked `x-open-question`. The result is a skeleton the contract review must complete, not a finished contract. The lint checks structure (valid YAML and OpenAPI, no dangling `$ref`), not style completeness: Redocly's `recommended` rules (servers, security, summaries, operationIds) would demand facts the source never states, so they are off by default; set `FL_IMPORT_LINT_CMD` for a stricter ruleset. The linter is required and is not bundled.
- **Sessions do not talk to each other.** A session that needs work in another repo leaves it in the contracts repo (shared spec and `openapi.yaml`) and you start the other repo's session. This is deliberate: it works the same in Codex and Cursor, and no session directs another unseen.
- **Theme palettes are AA-checked, and the dark theme has a gradient limit.** Each theme's colors were adjusted so the listed pairs reach 4.5:1 as normal text (for example the terracotta accent on the editorial background, or the mustard accent on cream); every pair is measured in the theme file, next to the value it replaced. Text cannot sit directly over the dark theme's full violet→cyan gradient, because no single text color passes on both ends.

- **Apple UI styles are AA-checked, except the reference style.** Nine of the ten styles are generated from a brand hue and pushed until every reading pair (body and secondary text, text on tints, button labels) reaches 4.5:1; `check_style.py` measures them and each style file lists the ratios. `mint-studio` keeps the values of the design it was taken from, with five pairs below AA (white on the primary button, secondary text on canvas and cards, and in dark mode text on the hero card); its file says so and shows how to make an AA copy. The screenshot tour needs a UI test target and runs `xcodebuild`, so it is only as fast as the project's build.

## License

[MIT](LICENSE) © 2026 Luis Cárdenas.
