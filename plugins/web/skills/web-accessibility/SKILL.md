---
name: web-accessibility
description: Apply when writing the HTML/CSS/JS of a web interface to meet WCAG 2.2 AA: ARIA only when needed, visible focus, touch targets ≥24×24px and associated labels.
---

# web-accessibility

**Objective**: Accessible HTML by default, WCAG 2.2 AA.

## Must include

- ARIA only when semantic HTML is not enough (never a redundant `role` on an element with native semantics)
- Visible focus, always
- Touch target ≥24×24px (new criterion in 2.2)
- `<label>` associated with every input, not only a placeholder

## Must never assume

- That a third-party component (date picker, modal) is accessible without checking it — flag it if it cannot be verified

## Accumulated stack knowledge

Full definition and lessons already learned: `${CLAUDE_PLUGIN_ROOT}/knowledge/AGENTS.md` and `${CLAUDE_PLUGIN_ROOT}/knowledge/patterns/` (if there are patterns, review the ones that apply before writing). Anything learned that generalizes is promoted with `/fl:promote`.
