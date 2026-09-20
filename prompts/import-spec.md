# Import prompt: existing all-in-one spec → Forgeloom layout (case 0.3)

Use it when the definition already exists as **one big Markdown file** (built over many chat iterations: features, architecture, API contracts, configuration...) and you need to place it into the Forgeloom layout of a multi-repo project **without losing any of it**. It is not one of the `chat-to-*` prompts: those write from what was discussed and may summarize; this one **moves existing text** and must keep all of it.

Inside Claude Code, `/fl:import <source.md>` runs this same flow and runs the check for you.

The layout is one repo per stack plus a contracts repo, side by side in an umbrella folder. The source file and the map live in the umbrella folder. The work is done **once per repo**, opening your tool inside that repo. The check script is what proves nothing was lost, so run it: it is in your forgeloom checkout, `plugins/fl/scripts/import-check.sh`, and needs only `bash` and `awk`.

1. **Once, in any repo**: paste the prompt below with **Phase 1** and review the map it writes.
2. **In each repo**: paste it with **Phase 2**, then run `bash <forgeloom>/plugins/fl/scripts/import-check.sh <umbrella>/import-map.md --repo <repo folder name>`. It must print `OK`.
3. **At the end**: run the same script without `--repo`.

---

You are placing an existing spec file into the Forgeloom layout. The rule that overrides everything: **do not rewrite, summarize, improve or reconcile the source.** Move its lines word for word and add only structure around them. Where the layout needs something the source does not say, write "Open question: not specified in the source spec" instead of filling it in. Where the source contradicts itself, keep both versions and mark it as an open question. Never overwrite a file that already exists without asking, and do not commit.

The source is `<path to source spec>`. The repos of this project are `<folder names, and the stack of each>`; the contracts repo is `<folder name>`.

**Phase 1 — the map** (write only `import-map.md`, in the umbrella folder). Copy the format of `templates/import-map.md`. Record the source path and its `shasum -a 256`. Split the source into contiguous blocks of lines, one table row each (`ID | Lines | Section | Destination | Treatment | Notes`), so that every non-blank source line is in at least one row. Route each block:

- one platform's stack, hosting, architecture, commands → `<repo>/AGENTS.md` if short, otherwise `<repo>/docs/<topic>.md`; why they were chosen → `<repo>/decisions/0001-foundation.md`
- a feature that needs one repo → `<repo>/specs/<feature>.md`
- a feature that needs more than one repo → `<contracts>/specs/<feature>.md`, acceptance criteria grouped per platform
- the API contract → `<contracts>/openapi.yaml` (treatment `openapi`)
- a product decision across platforms → `<contracts>/decisions/NNNN-<slug>.md`; design tokens → `<contracts>/design/<topic>.md`
- reference material that is not a decision, a feature or a convention (data model, animation catalog, settings inventory) → `<repo>/docs/<topic>.md`
- text that is not project content (the title, pleasantries) → treatment `dropped`, with the reason in Notes. Text that only looks outdated or contradicted is kept and listed under Open questions.

Treatment is `verbatim`, `openapi` or `dropped`. End the map with an Open questions section. Show it to me and wait for my OK.

**Phase 2 — import `<this repo's folder name>`** (only the rows whose destination starts with that folder). `AGENTS.md` has the sections Technical stack, Hosting/infrastructure, General architecture, Planned commands, Related repositories (relative paths of the sibling repos) and links to every file in `docs/`, under 200 lines; long text goes in `docs/`. `decisions/0001-foundation.md` follows `templates/adr.md`. A spec has Objective, Scope (including what is out), Constraints, Acceptance criteria (a bullet that is already checkable becomes `- [ ]`; prose is not rephrased) and Relevant prior decisions; source lines that fit no section go under `## Additional source text`. A shared spec groups acceptance criteria under `### <Platform>` headings. `openapi.yaml` (OpenAPI 3.1) contains only what the source states, with the source lines verbatim in a literal block scalar `description: |` on each operation or schema. Other repos are built against it, so state no `type`, `required`, status code, auth requirement or `format` that the source does not state: leave that schema empty (`{}`) and add `x-open-question`. Then run the check script; it needs an OpenAPI linter (`npm install -g @redocly/cli`), and if none is installed, tell me instead of installing one or skipping it. When done, list the open questions and the files you created.
