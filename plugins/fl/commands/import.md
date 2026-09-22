---
description: Splits an existing all-in-one spec file into the Forgeloom layout of a multi-repo project (AGENTS.md, decisions/, specs/, docs/ per repo; shared specs and openapi.yaml in the contracts repo) without losing any of its text. It detects the technologies in the spec, creates one folder per technology and runs git init (on develop) in each. Run it from the folder that holds the spec.
argument-hint: "<path to the source spec.md> | --check"
disable-model-invocation: true
---

# /fl:import

You place the content of a spec that already exists as **one file** (built over many chat iterations: features, architecture, API contracts, configuration...) into the Forgeloom layout of a multi-repo project, **creating the repo folders yourself**. This is **not** `/fl:define`: `define` writes from what was discussed and may summarize; `import` **moves text that is already written** and must lose none of it.

The rule that overrides everything else: **do not rewrite, summarize, improve or reconcile the source.** Move its lines word for word. Add structure around them (headings, the section skeleton of a spec). Where the layout needs something the source does not say, write `Open question: not specified in the source spec` — never fill it in. Where the source contradicts itself (an earlier iteration says one thing, a later one another), keep **both** and mark it as an open question: which one is right is the user's call. **Never overwrite a file that already exists without asking first.**

Argument received: `$ARGUMENTS` (the path to the source spec, or `--check`).

## How the multi-repo layout works

Forgeloom uses one repo per technology plus a contracts repo. They sit side by side in an **umbrella folder**: the folder that holds the source spec, where you run this command. **You create the repos**: the user does not name or make the folders.

```text
AcmeProduct/                    <- umbrella: holds the source spec and import-map.md (scaffolding, not versioned)
├── source-spec.md
├── import-map.md
├── AcmeProductAppleApp/        <- stack ios-swift
├── AcmeProductBackend/         <- stack backend
└── AcmeProductContracts/       <- openapi.yaml, specs/ shared between platforms, decisions/, design/
```

**Folder names** are `<ProjectName><Suffix>`: the project name in PascalCase (`acme product` → `AcmeProduct`, no spaces, hyphens or underscores) followed by one suffix per technology:

| Technology detected in the spec | Suffix | Stack |
|---|---|---|
| iOS, iPadOS, macOS, watchOS or any Apple app (Swift, SwiftUI) | `AppleApp` | `ios-swift` |
| Android app (Kotlin, Compose, Java) | `AndroidApp` | none yet: Forgeloom has no Android stack, say so |
| Backend or API service | `Backend` | `backend` |
| Website or web app | `Website` | `web` |
| The API contract and the features shared between platforms | `Contracts` | none (only `openapi.yaml`, specs, decisions, design) |

Detect the technologies **yourself, from what the source says** (stack sections, architecture, hosting, the platforms a feature names); never make the user list them. `Contracts` exists when the source has an API contract or features that need more than one platform. If the source names two projects of the same technology (two backends), or the technology is not in this table, do not invent a suffix: it is an open question for the user.

A session works in **one** repo when coding, but the import is a one-off move of text, so it runs from the umbrella and can fill every repo in the same run. It is done in two phases: a map first (Phase 1), then the repos (Phase 2). The script `${CLAUDE_PLUGIN_ROOT}/scripts/import-check.sh` verifies each step; it is what makes "nothing was lost" a fact instead of a claim. If `${CLAUDE_PLUGIN_ROOT}` did not resolve, look for `import-check.sh` under `~/.claude/plugins/` and use that path.

**Language.** Everything you write is in English, whatever language the user chats in: the skeleton you add, the `Open question` lines, the map. The source is moved **word for word**, so text that is not in English stays as it is in the source; if the source is not in English, list it under Open questions and do not translate it (a translation would fail the check by design). The user decides that as a separate step.

The umbrella is the working directory, so the repos you create are inside it. If the source is somewhere else and reading it is denied, tell the user to restart the session in the umbrella folder or with `claude --add-dir <folder>`; do not copy the source into a repo.

## Step 0 — Where am I, which phase

1. Resolve the source path from `$ARGUMENTS` (relative to the current directory). Its folder is the **umbrella**; the map is `<umbrella>/import-map.md`.
2. `$ARGUMENTS` is `--check`: run `bash <script> <umbrella>/import-map.md` (no `--repo`: every row of every repo), show the real output and stop. That is the final check, run after every repo has been imported.
3. No map yet → **Phase 1**. Map exists → **Phase 2**, for the repos of the map: every one that has rows when the current directory is the umbrella, or only `REPO` (the folder name) when the current directory is inside one repo of the map.
4. Tell the user in one line which phase you detected and why.

## Phase 1 — Make the map (writes only `import-map.md`)

1. Read the **whole** source with line numbers (`cat -n`, in chunks if it is long). Never skim: every line will be assigned. If it has the shape of `prompts/chat-to-source-spec.md` (`## Platforms` and `## Feature:` headings), also run `bash ${CLAUDE_PLUGIN_ROOT}/scripts/source-check.sh <source>` (same folder as `import-check.sh`) and show its real output: each `FAIL` is a part the chat never produced and this import will have to mark as an open question. Tell the user in one line that they can go back to the chat to close them first; import anyway if they prefer. Do not edit the source to fix them.
2. **Detect the project name and the technologies** from the source (see *How the multi-repo layout works*), and derive the repo folder names from them. The project name is the product's name in the source; if it does not have one, use the umbrella folder's name. Ask, in one round, only what you cannot see: a missing project name, two projects of the same technology, a technology that is not in the table. The repo folders usually do not exist yet: the map only needs their names. If some already exist, list them and use them as they are.
3. Compute the source hash: `shasum -a 256 <source>`. It goes in the map header, so a source edited mid-import is detected.
4. Split the source into **contiguous blocks** and give each one a row (`templates/import-map.md` in the forgeloom checkout shows the format; the columns are `ID | Lines | Section | Destination | Treatment | Notes`). Route by this table:

   | Source content | Destination | Treatment |
   |---|---|---|
   | Project overview: name, problem, users, non-goals, global constraints, platform list | `<repo>/docs/product.md` in **every** repo of the map (one row per repo, same lines; AGENTS.md links it) | `verbatim` |
   | Stack, hosting/infrastructure, general architecture, planned commands of one platform | `<repo>/AGENTS.md` if short; otherwise `<repo>/docs/<topic>.md` (AGENTS.md links to it) | `verbatim` |
   | Why a stack/architecture choice was made, alternatives | `<repo>/decisions/0001-foundation.md` | `verbatim` |
   | A feature that needs work in **one** platform | `<repo>/specs/<feature>.md` | `verbatim` |
   | A feature that needs work in **more than one** platform (for example the app and the API) | `<contracts>/specs/<feature>.md`, acceptance criteria grouped per platform | `verbatim` |
   | API contract (endpoints, payloads, errors, versioning) | `<contracts>/openapi.yaml` | `openapi` |
   | A product decision that spans platforms | `<contracts>/decisions/NNNN-<slug>.md` | `verbatim` |
   | Design tokens | `<contracts>/design/<topic>.md` | `verbatim` |
   | Reference material that is not a decision, a feature or a convention (data model, animation catalog, settings inventory). A `### Data model — <Platform>` section goes to that platform's repo, not to `openapi.yaml`, which only holds what crosses the API | `<repo>/docs/<topic>.md` | `verbatim` |
   | Not project content (the document title, chat pleasantries) | `-` | `dropped`, with the reason in Notes |

   Rules for the split:
   - Every non-blank source line belongs to **at least one** row. Content that applies to two repos (a rule both sides follow) gets one row per repo, same lines.
   - Decide whether a feature is cross-platform from what the source says (a `Platforms:` line under the feature heading says it). If it does not say, do not guess: put it in Open questions.
   - `dropped` is only for text that is not project content. Text that looks outdated, duplicated or contradicted is **kept** and listed under Open questions.
5. End the map with an **Open questions** section: contradictions between iterations, blocks with an unclear destination, features with an unclear platform scope.
6. Write `<umbrella>/import-map.md` (ask first if one somehow exists). Run `bash <script> <map> --map-only`. It must pass (source frozen, every line accounted for); fix the map until it does.
7. Show the user: the technologies you detected with the source lines that show each one, the folders you will create (and, per folder, the stack plugin to install), rows per repo, the `dropped` rows and the Open questions, and **wait for their OK before creating any folder or writing anything in a repo.** Correct the map if they ask. When they approve, continue straight into Phase 2.

## Phase 2 — Import each repo

1. Run `bash <script> <map> --map-only` first, once. If it fails (typically: the source changed), stop and report; do not import from a moving source.
2. **Create the repo folder** if it does not exist: `mkdir <umbrella>/<RepoFolder>`, then `git -C <folder> init` and `git -C <folder> symbolic-ref HEAD refs/heads/develop`, so the repo starts on `develop` (git flow) and its first commit lands there. Confirm with `git -C <folder> branch --show-current`. If the folder already exists, keep everything in it: run `git init` only if it is not a repo yet, and never touch the branch of a repo that already has commits.
3. Take the rows whose Destination starts with `<RepoFolder>/`. Group them by destination file. For each destination that already exists, show it and ask (skip, or merge) instead of overwriting.
4. Write each file. Text from the source goes in **verbatim**; everything else you add is skeleton.
   - **`AGENTS.md`**: the sections **Technical stack**, **Hosting/infrastructure**, **General architecture**, **Planned commands** and, for a multi-repo project, **Related repositories** (the relative paths of the contracts repo and of the sibling platform repos, taken from the map), plus a list linking every file in `docs/`. Under 200 lines: long source text lives in `docs/` and is linked, never cut. A section with no source text says `Open question: not specified in the source spec`. It always ends with the **Working rules** section below, word for word: it is Forgeloom's, not source text and not an open question. The `Contracts` repo has no source rows for `AGENTS.md`, so it gets a short one with only **Related repositories**, the links to its `docs/` files and **Working rules**.
   - **`decisions/0001-foundation.md`**: the shape of `templates/adr.md` (Decision, Alternatives considered, Why, Open questions), filled only with source lines. Alternatives the source never mentions: "none discussed". If the source gives no reasons at all for the stack choices, do not create the file: say so under Open questions (the stack itself is already in `AGENTS.md`).
   - **`specs/<feature>.md`**: **Objective**, **Scope** (including what is explicitly out), **Constraints**, **Acceptance criteria**, **Relevant prior decisions**. Place each source line under the section it belongs to. A bullet that already states something checkable becomes `- [ ]`; prose is not rephrased into criteria. A section without source text says `Open question: not specified in the source spec` (typically Acceptance criteria: say so, do not invent any). Source lines that fit no section go under a final `## Additional source text`.
   - **Shared spec in the contracts repo**: the same sections, with **Acceptance criteria** grouped under one `### <Platform>` heading per platform involved, so each repo's session can work from its own group.
   - **`docs/<topic>.md`**: the source block verbatim, under a first line `> Imported from <source file>, lines N-M.`
   - **`openapi.yaml`** (OpenAPI 3.1): only endpoints and schemas the source states. Every operation/schema carries the source lines verbatim in a **literal block scalar** (`description: |`), never a quoted string. This is a contract that other repos will be built against, so **do not state anything the source does not state**: no `type`, no `required`, no status code, no auth requirement, no `format`. The structure the text implies may be written (an object with the fields it names); a field whose type is not stated gets an empty schema `{}` and an `x-open-question: "<what is missing>"`. OpenAPI requires `info.version` and at least one response per operation; when the source gives none, use `0.0.0` and a `default` response described as "Not specified in the source (open question)", each with an `x-open-question`.
5. Run `bash <script> <map> --repo <RepoFolder>` and show its **real output**. If it fails, fix the files (never the map, unless a row was genuinely wrong, and then tell the user) and run it again. `openapi.yaml` also gets a structural OpenAPI lint (`redocly lint --extends minimal`): if Redocly is not installed the script fails on purpose. Do not "fix" lint output by adding facts the source lacks (servers, security, summaries): the minimal ruleset does not ask for them. **Do not install software yourself** and do not skip the step: tell the user to install one (`npm install -g @redocly/cli`), and re-run the check once they have.
6. In umbrella mode, repeat 2 to 5 for the next repo of the map.

### Working rules section (goes in every repo's `AGENTS.md`)

```markdown
## Working rules

These apply to every project, whatever the stack.

- **Git flow.** Every repo uses git flow, with plain git. Right after `git init`, run `git symbolic-ref HEAD refs/heads/develop`: work starts on `develop` and the first commit is made there. `main` appears with the first release and holds released commits only, each tagged `vX.Y.Z`. After that: `feature/<name>` from `develop`, `release/X.Y.Z` for a release in flight, `hotfix/X.Y.Z` from `main` for urgent fixes; merge with `--no-ff`.
- **Commits.** English, conventional style (`feat(scope): ...`), 2 lines at most: a subject under about 72 characters and, only if it adds something the subject cannot, one line of context. **Never** add `Co-Authored-By` or any other attribution trailer, even if a tool suggests one.
- **Language.** Every `.md` file and every other document (specs, ADRs, READMEs, comments, OpenAPI descriptions) is written in English, whatever language the user chats in.
- **Final summaries.** When you finish, say what changed and what needs the user's decision or review (open questions, failures, skipped steps). Go straight to the point: **never** add long explanations or re-describe features unless the user asks for them.
```

## Step 3 — Wrap up

Keep it short: no re-description of what was imported.

1. List the **open questions** you marked, with the file each one is in: it is the first thing the user reviews. Include the contradictions the source contained and any part of the source that is not in English.
2. State the folders you created and the check result.
3. If a repo of the map was not imported (session opened inside one repo), say which ones remain and that `/fl:import --check` gives the final result once all are done. The source file and the map stay where they are.
4. If `CLAUDE.md` does not exist in a repo, suggest `ln -s AGENTS.md CLAUDE.md`; do not create it. Remind them to install the stack plugin in each repo (`claude plugin install <stack>@forgeloom --scope project`), and that `AndroidApp` has none.
5. **Do not commit.** The files are left for the user to review; the first commit goes on `develop`.
