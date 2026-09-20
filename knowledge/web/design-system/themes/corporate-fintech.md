# Theme 4 — Corporate trust / fintech

Theme of `professional-web-design`. Pick ONE per project and apply it across the whole site; never mix it with another theme.

**Fits**: fintech, trading, financial content — Perfil Inversor.

The theme has two variants; pick one per project: **dark** (background `#0F1B33`) or **light** (white).

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

| Role | Dark variant | Light variant | Source |
|---|---|---|---|
| Background | `#0F1B33` | `#FFFFFF` | spec |
| Text | `#F1F5F9` | `#0F172A` | Tailwind v3 (slate-100 / slate-900): the original table does not give a text color |
| Accent, as a fill (label in white) | `#2563EB` | `#2563EB` | spec (Tailwind v3 blue-600) |
| Accent, as text or link | `#60A5FA` | `#2563EB` | spec, adjusted (dark only): blue-600 is 3.32:1 on `#0F1B33`; Tailwind v3 blue-400 passes on the background and on the surface |
| Success | `#16A34A` | `#15803D` | spec, adjusted (light only): `#16A34A` is 3.30:1 on white; Tailwind v3 green-700 passes and also carries a white label |
| Surface (cards) | `#1E293B` | `#F8FAFC` | Tailwind v3 (slate-800 / slate-50) |
| Border | `#334155` | `#E2E8F0` | Tailwind v3 (slate-700 / slate-200) |
| Error | `#F87171` | `#B91C1C` | Tailwind v3 (red-400 / red-700), AA-checked |

```css
:root, [data-theme="dark"] {
  --color-bg: #0F1B33;
  --color-text: #F1F5F9;
  --color-accent: #2563EB;        /* fills, with white labels */
  --color-accent-text: #60A5FA;   /* text and links */
  --color-success: #16A34A;       /* text/icons; use a dark label on a success fill */
  --color-surface: #1E293B;
  --color-border: #334155;
  --color-error: #F87171;
}
[data-theme="light"] {
  --color-bg: #FFFFFF;
  --color-text: #0F172A;
  --color-accent: #2563EB;
  --color-accent-text: #2563EB;
  --color-success: #15803D;
  --color-surface: #F8FAFC;
  --color-border: #E2E8F0;
  --color-error: #B91C1C;
}
```

Measured contrast, dark variant (WCAG; normal text needs 4.5:1):

| Pair | Ratio | Normal text (4.5:1) |
|---|---|---|
| Text on background — `#F1F5F9` on `#0F1B33` | 15.65:1 | pass |
| Text on surface — `#F1F5F9` on `#1E293B` | 13.35:1 | pass |
| Accent as text/link on background — `#60A5FA` on `#0F1B33` | 6.74:1 | pass |
| Accent as text/link on surface — `#60A5FA` on `#1E293B` | 5.75:1 | pass |
| White label on a blue fill (button) — `#FFFFFF` on `#2563EB` | 5.17:1 | pass |
| Success as text/icon on background — `#16A34A` on `#0F1B33` | 5.20:1 | pass |
| Dark label on a success fill — `#0F1B33` on `#16A34A` | 5.20:1 | pass |
| Error on background — `#F87171` on `#0F1B33` | 6.20:1 | pass |

Measured contrast, light variant:

| Pair | Ratio | Normal text (4.5:1) |
|---|---|---|
| Text on background — `#0F172A` on `#FFFFFF` | 17.85:1 | pass |
| Text on surface — `#0F172A` on `#F8FAFC` | 17.06:1 | pass |
| Accent as text/link on background — `#2563EB` on `#FFFFFF` | 5.17:1 | pass |
| Accent as text/link on surface — `#2563EB` on `#F8FAFC` | 4.94:1 | pass |
| White label on a blue fill (button) — `#FFFFFF` on `#2563EB` | 5.17:1 | pass |
| Success as text/icon on background — `#15803D` on `#FFFFFF` | 5.02:1 | pass |
| White label on a success fill — `#FFFFFF` on `#15803D` | 5.02:1 | pass |
| Error on background — `#B91C1C` on `#FFFFFF` | 6.47:1 | pass |

## Typography

| Item | Value | Source |
|---|---|---|
| Family | Inter across the whole hierarchy | spec |
| Weights | 400/600/700 | spec |
| Figures | `font-variant-numeric: tabular-nums` | spec |
| Families in total | One (below the maximum of 2) | spec (general rule) |
| Base font size | 16px | convention |
| Scale ratio | 1.25 (major third) | convention: compact steps suit data-dense screens |

```css
:root {
  --font-family: "Inter", sans-serif;
  --font-weight-regular: 400;
  --font-weight-semibold: 600;
  --font-weight-bold: 700;
  --font-size-base: 1rem;
  --type-scale: 1.25;
}
.num, td.numeric { font-variant-numeric: tabular-nums; }
```

## Spacing

Base unit **4px** (convention: tight, data-dense layouts; also Tailwind's spacing base), all spacing in multiples of 4px.

## Motion

| Item | Value | Source |
|---|---|---|
| Style | Fast and precise | spec |
| Duration | 150ms | spec |
| Curve | `ease` | spec |
| Bounce | None | spec |
| Reduced motion | Remove transforms, keep instant state changes | `prefers-reduced-motion` |

```css
:root {
  --motion-duration: 150ms;
  --motion-easing: ease;
}
```

## General rules that apply (inherited from `professional-web-design`)

- Modular type scale (ratio 1.25 or 1.333, never loose sizes with no relationship); base font size 16px.
- Spacing in multiples of the base unit.
- AA contrast as a minimum. Every color pair listed above was measured with the WCAG 2.x formula; a pair that is not listed has not been checked.
- `prefers-reduced-motion` respected.
