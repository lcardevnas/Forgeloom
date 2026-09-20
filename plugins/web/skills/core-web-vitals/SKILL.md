---
name: core-web-vitals
description: Apply when writing the HTML/CSS/JS of a web page to meet Google's "good" Core Web Vitals thresholds: LCP, INP and CLS, above-the-fold images, explicit dimensions and modern formats.
---

# core-web-vitals

**Objective**: Meet Google's "good" thresholds.

## Must include

- LCP ≤2.5s (`fetchpriority="high"` on the above-the-fold image, `lazy` on the rest)
- INP ≤200ms (no blocking JS on interaction)
- CLS ≤0.1 (explicit `width`/`height` or `aspect-ratio` before loading)
- Modern formats (WebP/AVIF) with fallback

## Must never assume

- That a third-party embed or script does not affect INP without measuring it

## Accumulated stack knowledge

Full definition and lessons already learned: `${CLAUDE_PLUGIN_ROOT}/knowledge/AGENTS.md` and `${CLAUDE_PLUGIN_ROOT}/knowledge/patterns/` (if there are patterns, review the ones that apply before writing). Anything learned that generalizes is promoted with `/fl:promote`.
