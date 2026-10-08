# Prompt: set an existing repo up for Forgeloom (for tools without Claude Code)

Use it in a session opened **in the repo** (Codex, Cursor or any assistant that can read and write files). It is the equivalent of `/fl:init`: it adds Forgeloom's working rules to the project's `AGENTS.md`, without deciding anything about the project. Paste it as-is.

Inside Claude Code, `/fl:init` runs this same flow.

---

Set this repo up for the Forgeloom workflow. This is setup, not definition: do not decide the stack, hosting or architecture, and do not write specs. Record what is already true, add the fixed rules below, and leave everything else as it is.

Rules for the whole task: ask before every write and show what you will write (a diff for an existing file); never overwrite or reorder content that is already there, only add what is missing; never commit, push or install anything; write everything in English.

1. **Look first, read-only.** Tell me: the current branch and whether `develop` exists; whether `AGENTS.md` and `CLAUDE.md` exist and, if `AGENTS.md` does, which of the working rules below it already has (compare by the bold name of each bullet); the stack, read from manifests (`Package.swift`, `*.xcodeproj`, `package.json`, `go.mod`, `Cargo.toml`, `pyproject.toml`, ...) and not from folder names. If two stacks are plausible, ask me.
2. **If this folder is not a repo and holds a `source-spec.md` or several repos side by side, stop** and tell me to split the definition into one repo per platform first (`prompts/import-spec.md`), then run this in each repo.
3. **If `AGENTS.md` does not exist and the repo has code,** create it with: the project name (confirm it); **Technical stack** and **Planned commands** with only what the manifests and scripts state, each with the file it came from; **Hosting/infrastructure** and **General architecture** as `Open question: not decided` unless a file states it; **Related repositories** only if the project spans several repos (ask me, and write the relative paths I give you); and the Working rules section below. Keep it under 200 lines. If the repo has no code, do not create `AGENTS.md`: the charter prompt writes it together with the rules.
4. **If `AGENTS.md` exists,** append the Working rules section if it is missing. If it exists, add the bullets that are missing and show me old and new text side by side for any that differ. Leave bullets that are not in the canonical text alone. If something in the file contradicts a rule, tell me and ask which wins. Touch nothing outside that section.
5. **`CLAUDE.md`**: if it does not exist, make it point at `AGENTS.md` (a symlink, or a one-line file containing `@AGENTS.md`). If it exists as a real file, never move or replace it: ask me before appending `@AGENTS.md`.
6. **Git flow, local only.** No git repo: `git init`, then `git symbolic-ref HEAD refs/heads/develop`. A repo with history on `main` or `master` and no `develop`: offer `git switch -c develop`, saying that the history stays and `main` is not touched. Never delete or rename branches or rewrite history.
7. **Finish short:** open questions first, then the files changed, then what is missing in my environment (`git`, `curl`, `jq` for the commit gate), then the next step (define the first feature). Do not commit.

The Working rules section, word for word:

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
