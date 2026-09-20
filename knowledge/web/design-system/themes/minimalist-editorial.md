# Theme 1 — Minimalist editorial

Theme of `professional-web-design`. Pick ONE per project and apply it across the whole site; never mix it with another theme.

**Fits**: blogs, personal brand focused on reading — SwiftYourself.com.

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
| Background | `#FAFAF8` | spec |
| Text | `#1A1A1A` | spec |
| Accent (terracotta) | `#B25A2A` | spec, adjusted (was `#C1622D`: 3.98:1 on the background, below AA) |
| Surface (cards) | `#FFFFFF` | convention |
| Border / hairline | `#E7E5E4` | Tailwind v3 (stone-200) |
| Error | `#B91C1C` | Tailwind v3 (red-700), AA-checked |
| Success | `#15803D` | Tailwind v3 (green-700), AA-checked |

```css
:root {
  --color-bg: #FAFAF8;
  --color-text: #1A1A1A;
  --color-accent: #B25A2A;
  --color-surface: #FFFFFF;
  --color-border: #E7E5E4;
  --color-error: #B91C1C;
  --color-success: #15803D;
}
```

Measured contrast (WCAG; normal text needs 4.5:1):

| Pair | Ratio | Normal text (4.5:1) |
|---|---|---|
| Text on background — `#1A1A1A` on `#FAFAF8` | 16.65:1 | pass |
| Text on surface — `#1A1A1A` on `#FFFFFF` | 17.40:1 | pass |
| Accent on background — `#B25A2A` on `#FAFAF8` | 4.58:1 | pass |
| Accent on surface — `#B25A2A` on `#FFFFFF` | 4.78:1 | pass |
| White label on an accent fill (button) — `#FFFFFF` on `#B25A2A` | 4.78:1 | pass |
| Error on background — `#B91C1C` on `#FAFAF8` | 6.19:1 | pass |
| Success on background — `#15803D` on `#FAFAF8` | 4.80:1 | pass |

The border color is decorative (a hairline that does not carry information on its own), so it is not held to a text ratio.

## Typography

| Item | Value | Source |
|---|---|---|
| Display | Serif — Fraunces or Playfair Display (one of the two, not both) | spec |
| Body | Sans — Inter | spec |
| Families in total | At most 2 | spec (general rule) |
| Base font size | 16px | convention |
| Scale ratio | 1.333 (perfect fourth) | convention: a larger step suits a serif display hierarchy in reading-focused layouts |

```css
:root {
  --font-display: "Fraunces", "Playfair Display", serif; /* pick ONE per project */
  --font-body: "Inter", sans-serif;
  --font-size-base: 1rem;
  --type-scale: 1.333;
}
```

## Spacing

Base unit **8px** (convention: generous whitespace suits an editorial layout); all spacing in multiples of 8px, with 4px allowed only for tight inline gaps.

## Motion

| Item | Value | Source |
|---|---|---|
| Style | Subtle fade + slide | spec |
| Curve | `ease-out` | spec |
| Duration | 200-300ms | spec |
| Bounce | None | spec |
| Slide distance | 8px | convention |
| Reduced motion | Drop the slide, keep a plain fade | `prefers-reduced-motion` |

```css
:root {
  --motion-duration-min: 200ms;
  --motion-duration-max: 300ms;
  --motion-easing: ease-out;
  --motion-slide: 8px;
}
```

## General rules that apply (inherited from `professional-web-design`)

- Modular type scale (ratio 1.25 or 1.333, never loose sizes with no relationship); base font size 16px.
- Spacing in multiples of the base unit.
- AA contrast as a minimum. Every color pair listed above was measured with the WCAG 2.x formula; a pair that is not listed has not been checked.
- `prefers-reduced-motion` respected.
