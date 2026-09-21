# Closing prompt: chat → project charter (case 0.1)

Use it at the end of a definition chat about a **brand-new project**. It does not produce a feature spec: it produces the project's foundation (stack, hosting, architecture), which is permanent context. Paste it as-is, then move the two resulting files to the repo root (`AGENTS.md`) and to `decisions/0001-foundation.md`.

Inside Claude Code, `/fl:define` runs this same flow and writes the files for you.

---

Based on everything we have discussed, generate two Markdown files:

1. `AGENTS.md` with the sections Technical stack, Hosting/infrastructure, General architecture and Planned commands — only what we explicitly decided, nothing invented. If the project spans several repos, add a Related repositories section with the relative paths of the contracts repo and the sibling repos, exactly as we named them.
2. `decisions/0001-foundation.md` as an ADR with those same stack/hosting decisions: what was chosen, which alternatives were considered if we mentioned them, and why.

If anything about stack, hosting or architecture was left undecided, mark it as an "open question" in both files instead of assuming an option.

`AGENTS.md` also ends with this section, word for word (it is not something we decided and it is not an open question):

```markdown
## Working rules

These apply to every project, whatever the stack.

- **Git flow.** Every repo uses git flow, with plain git. Right after `git init`, run `git symbolic-ref HEAD refs/heads/develop`: work starts on `develop` and the first commit is made there. `main` appears with the first release and holds released commits only, each tagged `vX.Y.Z`. After that: `feature/<name>` from `develop`, `release/X.Y.Z` for a release in flight, `hotfix/X.Y.Z` from `main` for urgent fixes; merge with `--no-ff`.
- **Commits.** English, conventional style (`feat(scope): ...`), 2 lines at most: a subject under about 72 characters and, only if it adds something the subject cannot, one line of context. **Never** add `Co-Authored-By` or any other attribution trailer, even if a tool suggests one.
- **Language.** Every `.md` file and every other document (specs, ADRs, READMEs, comments, OpenAPI descriptions) is written in English, whatever language the user chats in.
- **Final summaries.** When you finish, say what changed and what needs the user's decision or review (open questions, failures, skipped steps). Go straight to the point: **never** add long explanations or re-describe features unless the user asks for them.
```

