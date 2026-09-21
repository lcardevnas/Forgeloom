# Web — conventions and gotchas

Forgeloom's agnostic core for web projects. Plain Markdown: any assistant that loads `AGENTS.md` can read it.

Reading rules:
- **Skill** = informs new code while it is being written. **Subagent** = audits code that has already been written, in an isolated pass. They do not compete for the same context.
- Every entry has three parts: *Objective*, *Must include* (or *review*) and *Must never assume* (or *Must never*). The third part prevents filling gaps with a reasonable default that is not valid for the real project: **check against the project, do not assume**.
- New, generalizable lessons go in `knowledge/web/patterns/` (one lesson per file).

## Working rules

These apply to every project, whatever the stack.

- **Git flow.** Every repo uses git flow, with plain git. Right after `git init`, run `git symbolic-ref HEAD refs/heads/develop`: work starts on `develop` and the first commit is made there. `main` appears with the first release and holds released commits only, each tagged `vX.Y.Z`. After that: `feature/<name>` from `develop`, `release/X.Y.Z` for a release in flight, `hotfix/X.Y.Z` from `main` for urgent fixes; merge with `--no-ff`.
- **Commits.** English, conventional style (`feat(scope): ...`), 2 lines at most: a subject under about 72 characters and, only if it adds something the subject cannot, one line of context. **Never** add `Co-Authored-By` or any other attribution trailer, even if a tool suggests one.
- **Language.** Every `.md` file and every other document (specs, ADRs, READMEs, comments, OpenAPI descriptions) is written in English, whatever language the user chats in.
- **Final summaries.** When you finish, say what changed and what needs the user's decision or review (open questions, failures, skipped steps). Go straight to the point: **never** add long explanations or re-describe features unless the user asks for them.

## Skills

### `professional-web-design`
- **Objective**: sites with a design-studio level of polish, not a generic template.
- **Must include** (general rules for any theme):
  - Modular type scale (ratio 1.25 or 1.333, never loose sizes with no relationship)
  - Spacing in multiples of a base unit (4px or 8px)
  - AA contrast as a minimum, even in dark themes
  - `prefers-reduced-motion` respected
- **Must never**:
  - Invent a new palette per page within the same site
  - Use more than 2 type families without an explicit request
- **Theme choice**: pick ONE of the 4 themes explicitly (or the one the user asks for) and apply it consistently across the whole site — **never mix themes within the same project**. Each theme is detailed in `design-system/themes/<theme>.md`; the chosen theme is recorded in the project's own `AGENTS.md`.

| Theme | Palette | Typography | Motion | Fits |
|---|---|---|---|---|
| **1. Minimalist editorial** (`minimalist-editorial.md`) | Background `#FAFAF8`, text `#1A1A1A`, terracotta accent `#B25A2A` (adjusted from `#C1622D` to reach AA) | Serif display (Fraunces/Playfair Display) + sans body (Inter) | Subtle fade + slide, `ease-out`, 200-300ms, no bounce | Blogs, personal brand focused on reading — SwiftYourself.com |
| **2. Dark tech / modern SaaS** (`dark-tech-saas.md`) | Background `#0B0F19`, text `#E5E7EB`, violet→cyan accent gradient (`#7C3AED`→`#06B6D4`); violet as text: `#A78BFA` | Geometric display (Space Grotesk) + sans body (Inter) | Spring micro-interactions, subtle glow on hover, glassmorphism on cards | SaaS product, app landing page, developer tools |
| **3. Warm artisanal / boutique** (`warm-artisanal.md`) | Cream background `#F5EFE6`, deep green `#2F4739` (also the text color), mustard accent `#DAA644` (`#8D651C` as text on cream; adjusted from `#D9A441` to reach AA) | Humanist serif (Lora) + sans body (Work Sans) | Soft parallax, diffuse shadows, generous `border-radius` | Warm brand, artisanal/lifestyle product — Etsy shop |
| **4. Corporate trust / fintech** (`corporate-fintech.md`) | Background `#0F1B33` (dark variant) or `#FFFFFF` (light variant), blue accent `#2563EB` (`#60A5FA` as text on the dark variant), success green `#16A34A` (`#15803D` on the light variant) | Inter across the whole hierarchy (400/600/700), figures with `tabular-nums` | Fast and precise, 150ms `ease`, no bounce | Fintech, trading, financial content — Perfil Inversor |

### `core-web-vitals`
- **Objective**: Meet Google's "good" thresholds.
- **Must include**:
  - LCP ≤2.5s (`fetchpriority="high"` on the above-the-fold image, `lazy` on the rest)
  - INP ≤200ms (no blocking JS on interaction)
  - CLS ≤0.1 (explicit `width`/`height` or `aspect-ratio` before loading)
  - Modern formats (WebP/AVIF) with fallback
- **Must never assume**:
  - That a third-party embed or script does not affect INP without measuring it

### `technical-seo`
- **Objective**: Technical SEO from the HTML, not added afterwards.
- **Must include**:
  - A single `<h1>`, heading hierarchy with no skipped levels
  - Per-page `title`/`meta description`/Open Graph, not site-wide generics
  - JSON-LD of the applicable type
  - Semantic HTML (`<nav>`, `<main>`, `<article>`)
- **Must never assume**:
  - Duplicating `title`/`meta description` across pages

### `web-accessibility`
- **Objective**: Accessible HTML by default, WCAG 2.2 AA.
- **Must include**:
  - ARIA only when semantic HTML is not enough (never a redundant `role` on an element with native semantics)
  - Visible focus, always
  - Touch target ≥24×24px (new criterion in 2.2)
  - `<label>` associated with every input, not only a placeholder
- **Must never assume**:
  - That a third-party component (date picker, modal) is accessible without checking it — flag it if it cannot be verified

## Subagents

### `security-review-owasp-web`
- **Objective**: Audit against the OWASP Top 10 for web (2025, current).
- **Must review / do**:
  - A01 Broken Access Control (includes SSRF)
  - A02 Security Misconfiguration
  - A03 Software Supply Chain Failures (includes vulnerable and outdated components)
  - A04 Cryptographic Failures
  - A05 Injection
  - A06 Insecure Design
  - A07 Authentication Failures
  - A08 Software or Data Integrity Failures
  - A09 Security Logging and Alerting Failures
  - A10 Mishandling of Exceptional Conditions (fail-open behavior, error messages that leak information, unhandled errors) — each one explicitly
- **Must never**:
  - Give a generic pass without going through the complete list

### `core-web-vitals-audit`
- **Objective**: Measure/estimate against the thresholds of the `core-web-vitals` skill.
- **Must review / do**:
  - Point to the concrete cause per file ("image X weighs Y, has no explicit dimensions, causes Z of CLS"), not a generic "optimize images"
- **Must never**:
  - Pass without a figure or a concrete cause

### `accessibility-audit-web`
- **Objective**: A real audit against WCAG 2.2 AA.
- **Must review / do**:
  - Go criterion by criterion through the accessibility skill, with concrete findings
- **Must never**:
  - Say "looks accessible" without going through the criteria

### `design-system-compliance`
- **Objective**: Verify use of the chosen theme.
- **Must review / do**:
  - That new code uses the theme's tokens (color/typography/spacing from the 4-theme table), not loose values
- **Must never**:
  - Approve a hardcoded value that should come from the theme

## Cross-cutting

`dependency-scan`: before adding an npm dependency, check for known unpatched CVEs and prefer the latest stable version instead of pinning an old one without reviewing pending security fixes. The gate is enforced by the hook in `common/hooks/` (it blocks); this rule informs the choice. **Never** add a new dependency for something trivial that 10 lines of your own code can solve without raising the alternative first.

`cross-repo-work`: when a feature needs something that lives in another repo (an endpoint the backend does not have, a field the API does not return), **stop at the repo boundary**: do not edit the other repo, do not invent the missing contract, do not mock it silently. Route it through the contracts repo (see *Related repositories* in this project's `AGENTS.md`): extend the shared spec `<contracts>/specs/<feature>.md` with a group for the other repo, and propose the `openapi.yaml` change (contract-first), each applied only after the user's OK. Then continue only with what this repo can do against the contract. The user starts the other repo's session with the spec as its prompt; sessions do not command each other. **Never** guess where the contract lives: if the project has no *Related repositories* section, ask.
