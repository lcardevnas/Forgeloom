# Import prompt: existing all-in-one spec → Forgeloom layout (case 0.3)

Use it when the definition already exists as **one big Markdown file** (built over many chat iterations: features, architecture, API contracts, configuration...) and you need to place it into the Forgeloom layout of a multi-repo project **without losing any of it**. It is not one of the `chat-to-*` prompts: those write from what was discussed and may summarize; this one **moves existing text** and must keep all of it.

Inside Claude Code, `/fl:import <source.md>` runs this same flow and runs the check for you.

The layout is one repo per technology plus a contracts repo, side by side in an umbrella folder. The source file and the map live in the umbrella folder, and you open your tool there: the model detects the technologies in the spec, **creates the repo folders** and runs `git init` in each. The check script is what proves nothing was lost, so run it: it is in your forgeloom checkout, `plugins/fl/scripts/import-check.sh`, and needs only `bash` and `awk`.

0. If the source came from `prompts/chat-to-source-spec.md`, run `bash <forgeloom>/plugins/fl/scripts/source-check.sh <source>` first: each `FAIL` is a part the chat never produced, which the import can only mark as an open question.
1. **In the umbrella folder**: paste the prompt below with **Phase 1** and review the map it writes and the folders it proposes.
2. **After your OK**: paste it with **Phase 2**. For each repo, run `bash <forgeloom>/plugins/fl/scripts/import-check.sh <umbrella>/import-map.md --repo <repo folder name>`. It must print `OK`.
3. **At the end**: run the same script without `--repo`.

---

You are placing an existing spec file into the Forgeloom layout. The rule that overrides everything: **do not rewrite, summarize, improve or reconcile the source.** Move its lines word for word and add only structure around them. Where the layout needs something the source does not say, write "Open question: not specified in the source spec" instead of filling it in. Where the source contradicts itself, keep both versions and mark it as an open question. Never overwrite a file that already exists without asking, and do not commit. Everything you write is in English, whatever language we chat in; the source is moved word for word, so if it is not in English, list that under Open questions instead of translating it.

The source is `<path to source spec>`. Detect the project name and the technologies from it yourself. The repo folders are `<ProjectName><Suffix>` with the project name in PascalCase and one suffix per technology: `AppleApp` (iOS/macOS), `AndroidApp`, `Backend`, `Website`, and `Contracts` when the source has an API contract or features that span platforms. Do not invent a suffix for anything else: ask.

**Phase 1 — the map** (write only `import-map.md`, in the umbrella folder). Copy the format of `templates/import-map.md`. Record the source path and its `shasum -a 256`. Split the source into contiguous blocks of lines, one table row each (`ID | Lines | Section | Destination | Treatment | Notes`), so that every non-blank source line is in at least one row. Route each block:

- the project overview (name, problem, users, non-goals, global constraints, platform list) → `<repo>/docs/product.md` in every repo, one row per repo with the same lines
- one platform's stack, hosting, architecture, commands → `<repo>/AGENTS.md` if short, otherwise `<repo>/docs/<topic>.md`; why they were chosen → `<repo>/decisions/0001-foundation.md`
- a feature that needs one repo → `<repo>/specs/<feature>.md`
- a feature that needs more than one repo (a `Platforms:` line under its heading says so; if the source does not say, do not guess: open question) → `<contracts>/specs/<feature>.md`, acceptance criteria grouped per platform
- the API contract → `<contracts>/openapi.yaml` (treatment `openapi`)
- a product decision across platforms → `<contracts>/decisions/NNNN-<slug>.md`; design tokens → `<contracts>/design/<topic>.md`
- reference material that is not a decision, a feature or a convention (data model, animation catalog, settings inventory) → `<repo>/docs/<topic>.md`; a `### Data model — <Platform>` section goes to that platform's repo, not to `openapi.yaml`
- text that is not project content (the title, pleasantries) → treatment `dropped`, with the reason in Notes. Text that only looks outdated or contradicted is kept and listed under Open questions.

Treatment is `verbatim`, `openapi` or `dropped`. End the map with an Open questions section. Show me the technologies you detected (with the source lines that show each), the folders you will create and the map, and wait for my OK before creating anything.

**Phase 2 — import each repo** (only the rows whose destination starts with that repo's folder). First create the folder if it does not exist, run `git init` in it and `git symbolic-ref HEAD refs/heads/develop` so it starts on `develop` (git flow). `AGENTS.md` has the sections Technical stack, Hosting/infrastructure, General architecture, Planned commands, Related repositories (relative paths of the sibling repos) and links to every file in `docs/`, under 200 lines; long text goes in `docs/`. It ends with the section below, word for word (the contracts repo gets a short `AGENTS.md` with only Related repositories, the links to its `docs/` files and this section). `decisions/0001-foundation.md` follows `templates/adr.md`. A spec has Objective, Scope (including what is out), Constraints, Acceptance criteria (a bullet that is already checkable becomes `- [ ]`; prose is not rephrased) and Relevant prior decisions; source lines that fit no section go under `## Additional source text`. A shared spec groups acceptance criteria under `### <Platform>` headings. `openapi.yaml` (OpenAPI 3.1) contains only what the source states, with the source lines verbatim in a literal block scalar `description: |` on each operation or schema. Other repos are built against it, so state no `type`, `required`, status code, auth requirement or `format` that the source does not state: leave that schema empty (`{}`) and add `x-open-question`. Then run the check script; it needs an OpenAPI linter (`npm install -g @redocly/cli`), and if none is installed, tell me instead of installing one or skipping it. When done, list the open questions and the files you created.

The Working rules section:

```markdown
## Working rules

These apply to every project, whatever the stack.

- **Git flow.** Every repo uses git flow, with plain git. Right after `git init`, run `git symbolic-ref HEAD refs/heads/develop`: work starts on `develop` and the first commit is made there. `main` appears with the first release and holds released commits only, each tagged `vX.Y.Z`. After that: `feature/<name>` from `develop`, `release/X.Y.Z` for a release in flight, `hotfix/X.Y.Z` from `main` for urgent fixes; merge with `--no-ff`.
- **Commits.** English, conventional style (`feat(scope): ...`), 2 lines at most: a subject under about 72 characters and, only if it adds something the subject cannot, one line of context. **Never** add `Co-Authored-By` or any other attribution trailer, even if a tool suggests one.
- **Language.** Every `.md` file and every other document (specs, ADRs, READMEs, comments, OpenAPI descriptions) is written in English, whatever language the user chats in.
- **Final summaries.** When you finish, say what changed and what needs the user's decision or review (open questions, failures, skipped steps). Go straight to the point: **never** add long explanations or re-describe features unless the user asks for them.
```
