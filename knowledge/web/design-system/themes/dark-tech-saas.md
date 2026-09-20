# Theme 2 — Dark tech / modern SaaS

Theme of `professional-web-design`. Pick ONE per project and apply it across the whole site; never mix it with another theme.

**Fits**: SaaS product, app landing page, developer tools.

## Sources of the values

Every value below carries one of these tags:

| Tag | Meaning |
|---|---|
| **spec** | Value from Forgeloom's original theme table. |
| **spec, adjusted** | Original value changed as little as possible (same hue and saturation, only lightness) so it reaches WCAG AA. The original is shown. |
| **Tailwind v3** | Value verified against the Tailwind CSS v3 palette source. Notably, every non-brand color of the original table (`#E5E7EB`, `#7C3AED`, `#06B6D4`, `#2563EB`, `#16A34A`) is exactly a Tailwind v3 color, so Tailwind is the reference used to fill gaps. |
| **computed** | Derived by computation (WCAG 2.x contrast formula), not taken from a palette. |
| **convention** | A reasoned starting point, not verified against an authoritative source. Change it if the project has a reason to. |

## Palette

| Role | Value | Source |
|---|---|---|
| Background | `#0B0F19` | spec |
| Text | `#E5E7EB` | spec (Tailwind v3 gray-200) |
| Gradient accent, start (violet) | `#7C3AED` | spec (Tailwind v3 violet-600) |
| Gradient accent, end (cyan) | `#06B6D4` | spec (Tailwind v3 cyan-500) |
| Accent as text (violet) | `#A78BFA` | spec, adjusted (Tailwind v3 violet-400): the original violet is 3.36:1 on the background, below AA, so text and links use this lighter shade |
| Surface (cards) | `#111827` | Tailwind v3 (gray-900) |
| Border | `#1F2937` | Tailwind v3 (gray-800) |
| Error | `#F87171` | Tailwind v3 (red-400), AA-checked |
| Success | `#4ADE80` | Tailwind v3 (green-400), AA-checked |

```css
:root {
  --color-bg: #0B0F19;
  --color-text: #E5E7EB;
  --color-accent-from: #7C3AED;   /* solid fills, decoration */
  --color-accent-to: #06B6D4;
  --color-accent-text: #A78BFA;   /* text/links in the violet family */
  --gradient-accent: linear-gradient(90deg, var(--color-accent-from), var(--color-accent-to));
  --gradient-accent-text: linear-gradient(90deg, var(--color-accent-text), var(--color-accent-to));
  --color-surface: #111827;
  --color-border: #1F2937;
  --color-error: #F87171;
  --color-success: #4ADE80;
}
```

Measured contrast (WCAG; normal text needs 4.5:1):

| Pair | Ratio | Normal text (4.5:1) |
|---|---|---|
| Text on background — `#E5E7EB` on `#0B0F19` | 15.47:1 | pass |
| Text on surface — `#E5E7EB` on `#111827` | 14.33:1 | pass |
| Accent text (violet) on background — `#A78BFA` on `#0B0F19` | 7.04:1 | pass |
| Accent text (violet) on surface — `#A78BFA` on `#111827` | 6.52:1 | pass |
| Cyan on background — `#06B6D4` on `#0B0F19` | 7.89:1 | pass |
| Cyan on surface — `#06B6D4` on `#111827` | 7.31:1 | pass |
| White label on a solid violet fill (button) — `#FFFFFF` on `#7C3AED` | 5.70:1 | pass |
| Error on background — `#F87171` on `#0B0F19` | 6.92:1 | pass |
| Success on background — `#4ADE80` on `#0B0F19` | 10.99:1 | pass |

**Gradient usage rule.** Text cannot sit directly over the full violet→cyan gradient: light text on the cyan end is 1.96:1 and dark text on the violet end is 3.36:1, so no single text color passes across it. Use the gradient for fills, borders and glow; put labels on a solid violet fill with white text, and use `--gradient-accent-text` (both ends pass on the background) for gradient-clipped text.

## Typography

| Item | Value | Source |
|---|---|---|
| Display | Geometric — Space Grotesk | spec |
| Body | Sans — Inter | spec |
| Families in total | At most 2 | spec (general rule) |
| Base font size | 16px | convention |
| Scale ratio | 1.25 (major third) | convention: compact steps suit dense product UI |

```css
:root {
  --font-display: "Space Grotesk", sans-serif;
  --font-body: "Inter", sans-serif;
  --font-size-base: 1rem;
  --type-scale: 1.25;
}
```

## Spacing

Base unit **4px** (convention; also Tailwind's spacing base), all spacing in multiples of 4px.

## Motion and effects

| Item | Value | Source |
|---|---|---|
| Micro-interactions | Spring | spec |
| Spring parameters | stiffness 300, damping 30, mass 1 | convention (a common UI spring; retune per component) |
| Hover glow | subtle: `box-shadow: 0 0 24px rgb(139 92 246 / 0.35)` | spec (subtle glow) + convention (values) |
| Glassmorphism on cards | `background: rgb(255 255 255 / 0.06); backdrop-filter: blur(12px); border: 1px solid rgb(255 255 255 / 0.12)` | spec (glassmorphism) + convention (values) |
| Reduced motion | Turn off the spring and the animated glow; keep a plain opacity fade | `prefers-reduced-motion` |

Text on a glass card must be re-measured against the card's real blended background; the values above are not a guarantee.

## General rules that apply (inherited from `professional-web-design`)

- Modular type scale (ratio 1.25 or 1.333, never loose sizes with no relationship); base font size 16px.
- Spacing in multiples of the base unit.
- AA contrast as a minimum. Every color pair listed above was measured with the WCAG 2.x formula; a pair that is not listed has not been checked.
- `prefers-reduced-motion` respected.
