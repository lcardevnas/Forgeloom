---
name: technical-seo
description: Apply when writing the HTML of a web page: a single h1, heading hierarchy, per-page title/meta description/Open Graph, JSON-LD and semantic HTML.
---

# technical-seo

**Objective**: Technical SEO from the HTML, not added afterwards.

## Must include

- A single `<h1>`, heading hierarchy with no skipped levels
- Per-page `title`/`meta description`/Open Graph, not site-wide generics
- JSON-LD of the applicable type
- Semantic HTML (`<nav>`, `<main>`, `<article>`)

## Must never assume

- Duplicating `title`/`meta description` across pages

## Accumulated stack knowledge

Full definition and lessons already learned: `${CLAUDE_PLUGIN_ROOT}/knowledge/AGENTS.md` and `${CLAUDE_PLUGIN_ROOT}/knowledge/patterns/` (if there are patterns, review the ones that apply before writing). Anything learned that generalizes is promoted with `/fl:promote`.
