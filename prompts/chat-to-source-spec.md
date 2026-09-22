# Opening prompt: chat → import-ready source spec (case 0.4)

Use it at the **start** of a definition chat about a **brand-new product**, not at the end. The other `chat-to-*` prompts summarize what was discussed, so whatever was never discussed stays missing. This one makes the assistant run an interview in stages, with a fixed format and an exit gate per stage, and it ends with **one Markdown file** that `/fl:import` can split into a multi-repo project without gaps. Paste it as your first message, then answer.

1. Have the chat. Confirm each section when the assistant prints it: a confirmed section is frozen.
2. At the end, save the document as `source-spec.md` in an empty folder named after the project (the umbrella folder).
3. Check its shape: `bash <forgeloom>/plugins/fl/scripts/source-check.sh source-spec.md`. A `FAIL` means a required part is missing: go back to the chat and close it. It checks shape, not quality: it cannot tell a good acceptance criterion from a poor one.
4. Run `/fl:import source-spec.md` in that folder (or paste `prompts/import-spec.md`).

If you already have the code, do not use this: use `/fl:define` (inside Claude Code) or `prompts/chat-to-spec.md`.

---

You will run a product-definition interview with me and end with ONE Markdown document in a fixed format. A tool will then split that document into a multi-repo project by moving its text word for word. It cannot add anything, so whatever is missing from the document stays missing. Your job is to make sure nothing is missing, or that what is unknown is written down as unknown.

Rules:

1. **Ask, do not assume.** Nothing is decided until I have said it or confirmed it. Ask at most 4 questions at a time, the most important first. Never ask me for something you can propose: propose a draft and ask me to confirm or correct it. A proposal becomes a decision only when I confirm it.
2. **Work in the stages below, in order.** Start each reply by naming the stage and what is still open in it. At the end of a stage, print the section it produced in its final form (exactly as it will appear in the document) and ask me to confirm. A confirmed section is frozen: do not change it unless I ask, and if I do, replace it, never append a correction.
3. **Unknown is a valid answer; silence is not.** If I do not know or do not want to decide, write `Open question: <what exactly is missing>` in that place. Never leave a required part empty and never fill it with a plausible default.
4. **The document holds the current state only.** No history, no "update:", no "as we discussed", no "see above". A reader who never saw this chat must understand it. Each feature is one contiguous block.
5. **Write the document in English**, whatever language we chat in.
6. Do not include git, commit or other workflow rules: the tool adds them.

Stages:

**Stage 1 — Project.** The name (it becomes folder names, so one PascalCase word such as `AcmeProduct`), the problem it solves, who uses it, the non-goals (what it will explicitly not be) and the global constraints (performance, security, privacy and data, compatibility, accessibility, offline behavior, languages). Produces `## Project`.

**Stage 2 — Platforms.** Every technology the product involves (Apple app, Android app, backend, website), each `in` or `out` with the reason. If two are of the same technology, name each one. Nothing else is decided until this is closed. Produces `## Platforms`.

**Stage 3 — Foundation, once per platform that is in.** Technical stack, hosting/infrastructure, general architecture, planned commands (build, test, lint), and the decisions behind them with the alternatives considered and why. Do not choose a stack for me: if I have no preference, offer 2-3 options with their trade-offs and let me choose. Produces one `## Foundation — <Platform name>` per platform.

**Stage 4 — Feature inventory.** A list only: name, one line, the platforms involved. No detail yet. Ask what is missing until I say it is complete. This list is not part of the document; it drives stage 5.

**Stage 5 — Features, one at a time.** For each feature, in this order: objective, scope (what is in and what is explicitly out), constraints, acceptance criteria per platform, relevant prior decisions. Draw the acceptance criteria out of me: from the scope, propose 3 to 8 per platform, each an observable behavior that a test or a concrete check can verify, and ask about the failure, empty, offline, permission and limit cases and about what must NOT happen. A feature is not closed until every platform involved has at least one criterion and `Out of scope:` is written. Produces one `## Feature: <name>` per feature.

**Stage 6 — Contracts.** Only what the features need. API: for each endpoint, method and path, purpose, request, response, errors, authentication and versioning. Data model per platform. Design tokens if any. Mark what is undecided as `Open question:`. Produces `## Contracts`, which you omit only if no feature needs an API, shared data or design tokens.

**Stage 7 — Cross-platform decisions.** Decisions that affect more than one platform and are not recorded yet, each with the alternatives considered and why. Produces `## Decisions`, which you omit if there are none.

**Stage 8 — Audit.** Before rendering, check the whole document and tell me what fails: every platform that is `in` has a foundation; every feature has all five parts, `Out of scope:` written and criteria for each of its platforms; every endpoint or field a feature depends on is in Contracts; the platforms named in features match `## Platforms`; anything I said in the chat that is in no section; sections that contradict each other (list them and ask me which is right). Fix them with me.

**Stage 9 — Render.** Print the complete document in ONE code block, in the exact order and format below, and nothing else. Then tell me how many `Open question:` lines it has and that I must save it as `source-spec.md`.

The format (platform names are written identically everywhere; use `Open question: ...` wherever something is not decided):

```markdown
# <Project name> — project definition

## Project
Name: <ProjectName>
Problem: <...>
Users: <...>
Non-goals: <...>
Global constraints: <...>

## Platforms
- <Platform name>: in
- <Platform name>: out — <reason>

## Foundation — <Platform name>
### Technical stack
<...>
### Hosting/infrastructure
<...>
### General architecture
<...>
### Planned commands
<...>
### Decisions
<one entry per decision: what was chosen, alternatives considered, why>

## Feature: <feature name>
Platforms: <Platform name>, <Platform name>
### Objective
<one sentence: the problem it solves>
### Scope
In scope: <...>
Out of scope: <...>
### Constraints
<performance, compatibility, security>
### Acceptance criteria
#### <Platform name>
- [ ] <observable, checkable statement>
### Relevant prior decisions
<...>

## Contracts
### API
<...>
### Data model — <Platform name>
<...>
### Design tokens
<...>

## Decisions
### <decision title>
Status: accepted
Decision: <...>
Alternatives considered: <...>
Why: <...>
```
