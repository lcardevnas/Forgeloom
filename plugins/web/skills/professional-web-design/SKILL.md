---
name: professional-web-design
description: Apply when designing or laying out a website so it has design-studio polish rather than a generic template look: modular type scale, spacing in multiples of a base unit, AA contrast, prefers-reduced-motion, and ONE of 4 themes (minimalist editorial, dark tech SaaS, warm artisanal, corporate fintech) applied consistently.
---

# professional-web-design

**Objective**: sites with a design-studio level of polish, not a generic template.

## Must include (general rules for any theme)

- Modular type scale (ratio 1.25 or 1.333, never loose sizes with no relationship)
- Spacing in multiples of a base unit (4px or 8px)
- AA contrast as a minimum, even in dark themes
- `prefers-reduced-motion` respected

## Must never

- Invent a new palette per page within the same site
- Use more than 2 type families without an explicit request

## Theme choice

**Pick one of these 4 themes explicitly (or the one the user asks for) and apply it consistently across the whole site — never mix themes within the same project.**

1. If the project's `AGENTS.md` already declares a theme, use it and do not ask.
2. If not, propose the one that best fits according to the "Fits" column, say which one you chose and why, and wait for the user's confirmation.
3. Once chosen, record the theme in the project's `AGENTS.md` (one line: `Design theme: <name>`), so later sessions and `design-system-compliance` respect it.

The exact values of each theme are in the table and, in more detail (CSS tokens, measured contrast ratios, gaps), in `${CLAUDE_PLUGIN_ROOT}/knowledge/design-system/themes/<theme>.md`. Read only the file of the chosen theme.

| Theme | Palette | Typography | Motion | Fits |
|---|---|---|---|---|
| **1. Minimalist editorial** (`minimalist-editorial.md`) | Background `#FAFAF8`, text `#1A1A1A`, terracotta accent `#B25A2A` (adjusted from `#C1622D` to reach AA) | Serif display (Fraunces/Playfair Display) + sans body (Inter) | Subtle fade + slide, `ease-out`, 200-300ms, no bounce | Blogs, personal brand focused on reading — SwiftYourself.com |
| **2. Dark tech / modern SaaS** (`dark-tech-saas.md`) | Background `#0B0F19`, text `#E5E7EB`, violet→cyan accent gradient (`#7C3AED`→`#06B6D4`); violet as text: `#A78BFA` | Geometric display (Space Grotesk) + sans body (Inter) | Spring micro-interactions, subtle glow on hover, glassmorphism on cards | SaaS product, app landing page, developer tools |
| **3. Warm artisanal / boutique** (`warm-artisanal.md`) | Cream background `#F5EFE6`, deep green `#2F4739` (also the text color), mustard accent `#DAA644` (`#8D651C` as text on cream; adjusted from `#D9A441` to reach AA) | Humanist serif (Lora) + sans body (Work Sans) | Soft parallax, diffuse shadows, generous `border-radius` | Warm brand, artisanal/lifestyle product — Etsy shop |
| **4. Corporate trust / fintech** (`corporate-fintech.md`) | Background `#0F1B33` (dark variant) or `#FFFFFF` (light variant), blue accent `#2563EB` (`#60A5FA` as text on the dark variant), success green `#16A34A` (`#15803D` on the light variant) | Inter across the whole hierarchy (400/600/700), figures with `tabular-nums` | Fast and precise, 150ms `ease`, no bounce | Fintech, trading, financial content — Perfil Inversor |

Each theme file also defines what the original table left open (text and surface colors, state colors, type scale ratio, spacing base unit, effect parameters), with the source of every value tagged. Anything still not covered is decided once per project and documented in its `AGENTS.md`, not improvised page by page.

## Must never assume

- A theme without having chosen it or checked it in the project's `AGENTS.md`
- That a color pair meets AA contrast just because both colors belong to the theme: each theme file lists the pairs that were measured (all pass 4.5:1), and pairs that are not listed have not been checked (for example, text over the dark theme's full gradient cannot pass)

## Accumulated stack knowledge

Full definition and lessons already learned: `${CLAUDE_PLUGIN_ROOT}/knowledge/AGENTS.md` and `${CLAUDE_PLUGIN_ROOT}/knowledge/patterns/` (if there are patterns, review the ones that apply before writing). Anything learned that generalizes is promoted with `/fl:promote`.
