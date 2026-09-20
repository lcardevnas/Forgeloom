---
description: Splits an existing all-in-one spec file into the Forgeloom layout of a multi-repo project (AGENTS.md, decisions/, specs/, docs/ per repo; shared specs and openapi.yaml in the contracts repo) without losing any of its text. Run it once per repo.
argument-hint: "<path to the source spec.md> | --check"
disable-model-invocation: true
---

# /fl:import

You place the content of a spec that already exists as **one file** (built over many chat iterations: features, architecture, API contracts, configuration...) into the Forgeloom layout of a multi-repo project. This is **not** `/fl:define`: `define` writes from what was discussed and may summarize; `import` **moves text that is already written** and must lose none of it.

The rule that overrides everything else: **do not rewrite, summarize, improve or reconcile the source.** Move its lines word for word. Add structure around them (headings, the section skeleton of a spec). Where the layout needs something the source does not say, write `Open question: not specified in the source spec` — never fill it in. Where the source contradicts itself (an earlier iteration says one thing, a later one another), keep **both** and mark it as an open question: which one is right is the user's call. **Never overwrite a file that already exists without asking first.**

Argument received: `$ARGUMENTS` (the path to the source spec, or `--check`).

## How the multi-repo layout works

Forgeloom uses one repo per stack plus a contracts repo. They sit side by side in an **umbrella folder**:

```text
acme-product/                 <- umbrella: holds the source spec and import-map.md (scaffolding, not versioned)
├── source-spec.md
├── import-map.md
├── acme-ios/                 <- stack ios-swift
├── acme-backend/             <- stack backend
└── acme-contracts/           <- openapi.yaml, specs/ shared between platforms, decisions/, design/
```

A session works in **one** repo, so the import runs in two phases and **once per repo**: a map is made first (Phase 1), then each repo receives only its own rows (Phase 2). The script `${CLAUDE_PLUGIN_ROOT}/scripts/import-check.sh` verifies each step; it is what makes "nothing was lost" a fact instead of a claim. If `${CLAUDE_PLUGIN_ROOT}` did not resolve, look for `import-check.sh` under `~/.claude/plugins/` and use that path.

The source and the map live outside the current repo. If reading `../` is denied, tell the user to restart the session with `claude --add-dir <umbrella folder>`; do not copy the source into a repo.

## Step 0 — Where am I, which phase

1. Repo root: `git rev-parse --show-toplevel`. Its folder name is `REPO`. If the current directory is not a repo of the project (for example the umbrella folder itself), say so and ask the user to open the tool inside a repo.
2. Resolve the source path from `$ARGUMENTS` (relative to the current directory). Its folder is the umbrella. The map is `<umbrella>/import-map.md`.
3. `$ARGUMENTS` is `--check`: run `bash <script> <umbrella>/import-map.md` (no `--repo`: every row of every repo), show the real output and stop. That is the final check, run after every repo has been imported.
4. No map yet → **Phase 1**. Map exists → **Phase 2** for `REPO`.
5. Tell the user in one line which phase you detected and why.

## Phase 1 — Make the map (writes only `import-map.md`)

1. Read the **whole** source with line numbers (`cat -n`, in chunks if it is long). Never skim: every line will be assigned.
2. Ask, in one round, only what you cannot see: the repo folder names of the project and the stack of each (`ios-swift`, `web`, `backend`), and which one is the contracts repo (if there is one). List the umbrella's subfolders first; most answers are visible there. The repos may not exist yet: the map only needs their names.
3. Compute the source hash: `shasum -a 256 <source>`. It goes in the map header, so a source edited mid-import is detected.
4. Split the source into **contiguous blocks** and give each one a row (`templates/import-map.md` in the forgeloom checkout shows the format; the columns are `ID | Lines | Section | Destination | Treatment | Notes`). Route by this table:

   | Source content | Destination | Treatment |
   |---|---|---|
   | Stack, hosting/infrastructure, general architecture, planned commands of one platform | `<repo>/AGENTS.md` if short; otherwise `<repo>/docs/<topic>.md` (AGENTS.md links to it) | `verbatim` |
   | Why a stack/architecture choice was made, alternatives | `<repo>/decisions/0001-foundation.md` | `verbatim` |
   | A feature that needs work in **one** platform | `<repo>/specs/<feature>.md` | `verbatim` |
   | A feature that needs work in **more than one** platform (for example the app and the API) | `<contracts>/specs/<feature>.md`, acceptance criteria grouped per platform | `verbatim` |
   | API contract (endpoints, payloads, errors, versioning) | `<contracts>/openapi.yaml` | `openapi` |
   | A product decision that spans platforms | `<contracts>/decisions/NNNN-<slug>.md` | `verbatim` |
   | Design tokens | `<contracts>/design/<topic>.md` | `verbatim` |
   | Reference material that is not a decision, a feature or a convention (data model, animation catalog, settings inventory) | `<repo>/docs/<topic>.md` | `verbatim` |
   | Not project content (the document title, chat pleasantries) | `-` | `dropped`, with the reason in Notes |

   Rules for the split:
   - Every non-blank source line belongs to **at least one** row. Content that applies to two repos (a rule both sides follow) gets one row per repo, same lines.
   - Decide whether a feature is cross-platform from what the source says. If it does not say, do not guess: put it in Open questions.
   - `dropped` is only for text that is not project content. Text that looks outdated, duplicated or contradicted is **kept** and listed under Open questions.
5. End the map with an **Open questions** section: contradictions between iterations, blocks with an unclear destination, features with an unclear platform scope.
6. Write `<umbrella>/import-map.md` (ask first if one somehow exists). Run `bash <script> <map> --map-only`. It must pass (source frozen, every line accounted for); fix the map until it does.
7. Show the user: rows per repo, the `dropped` rows and the Open questions, and **wait for their OK before writing anything in a repo.** Correct the map if they ask. When they approve, continue straight into Phase 2 for `REPO`, or tell them to run `/fl:import <source>` inside each repo.

## Phase 2 — Import this repo

1. Run `bash <script> <map> --map-only` first. If it fails (typically: the source changed), stop and report; do not import from a moving source.
2. Take the rows whose Destination starts with `REPO/`. Group them by destination file. For each destination that already exists, show it and ask (skip, or merge) instead of overwriting.
3. Write each file. Text from the source goes in **verbatim**; everything else you add is skeleton.
   - **`AGENTS.md`**: the sections **Technical stack**, **Hosting/infrastructure**, **General architecture**, **Planned commands** and, for a multi-repo project, **Related repositories** (the relative paths of the contracts repo and of the sibling platform repos, taken from the map), plus a list linking every file in `docs/`. Under 200 lines: long source text lives in `docs/` and is linked, never cut. A section with no source text says `Open question: not specified in the source spec`.
   - **`decisions/0001-foundation.md`**: the shape of `templates/adr.md` (Decision, Alternatives considered, Why, Open questions), filled only with source lines. Alternatives the source never mentions: "none discussed". If the source gives no reasons at all for the stack choices, do not create the file: say so under Open questions (the stack itself is already in `AGENTS.md`).
   - **`specs/<feature>.md`**: **Objective**, **Scope** (including what is explicitly out), **Constraints**, **Acceptance criteria**, **Relevant prior decisions**. Place each source line under the section it belongs to. A bullet that already states something checkable becomes `- [ ]`; prose is not rephrased into criteria. A section without source text says `Open question: not specified in the source spec` (typically Acceptance criteria: say so, do not invent any). Source lines that fit no section go under a final `## Additional source text`.
   - **Shared spec in the contracts repo**: the same sections, with **Acceptance criteria** grouped under one `### <Platform>` heading per platform involved, so each repo's session can work from its own group.
   - **`docs/<topic>.md`**: the source block verbatim, under a first line `> Imported from <source file>, lines N-M.`
   - **`openapi.yaml`** (OpenAPI 3.1): only endpoints and schemas the source states. Every operation/schema carries the source lines verbatim in a **literal block scalar** (`description: |`), never a quoted string. This is a contract that other repos will be built against, so **do not state anything the source does not state**: no `type`, no `required`, no status code, no auth requirement, no `format`. The structure the text implies may be written (an object with the fields it names); a field whose type is not stated gets an empty schema `{}` and an `x-open-question: "<what is missing>"`. OpenAPI requires `info.version` and at least one response per operation; when the source gives none, use `0.0.0` and a `default` response described as "Not specified in the source (open question)", each with an `x-open-question`.
4. Run `bash <script> <map> --repo REPO` and show its **real output**. If it fails, fix the files (never the map, unless a row was genuinely wrong, and then tell the user) and run it again. `openapi.yaml` also gets a structural OpenAPI lint (`redocly lint --extends minimal`): if Redocly is not installed the script fails on purpose. Do not "fix" lint output by adding facts the source lacks (servers, security, summaries): the minimal ruleset does not ask for them. **Do not install software yourself** and do not skip the step: tell the user to install one (`npm install -g @redocly/cli`), and re-run the check once they have.

## Step 3 — Wrap up

1. List the **open questions** you marked, with the file each one is in: it is the first thing the user reviews. Include the contradictions the source contained.
2. State the files you created and the check result.
3. Say which repos of the map still have rows to import (run `/fl:import <source>` inside each), and that `/fl:import --check` gives the final result once all are done. The source file and the map stay where they are.
4. If `CLAUDE.md` does not exist in this repo, suggest `ln -s AGENTS.md CLAUDE.md`; do not create it. Remind them to install the stack plugin for this repo (`claude plugin install <stack>@forgeloom --scope project`).
5. **Do not commit.** The files are left for the user to review.
