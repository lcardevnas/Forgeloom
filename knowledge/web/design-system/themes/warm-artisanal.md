# Theme 3 — Warm artisanal / boutique

Theme of `professional-web-design`. Pick ONE per project and apply it across the whole site; never mix it with another theme.

**Fits**: warm brand, artisanal/lifestyle product — Etsy shop.

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
| Background (cream) | `#F5EFE6` | spec |
| Deep green | `#2F4739` | spec |
| Text | `#2F4739` (the deep green) | convention (inferred): the original table does not name the text color; the deep green is the only dark color and gives 8.83:1 on cream |
| Mustard accent, on deep green and as a fill | `#DAA644` | spec, adjusted (was `#D9A441`: 4.49:1 on deep green, 0.01 short of AA) |
| Mustard accent as text or icon on cream | `#8D651C` | spec, adjusted, computed: the original mustard is 1.97:1 on cream and cannot be text; this is the nearest same-hue shade that passes |
| Surface (cards) | `#FFFFFF` | convention |
| Border | `#D6D3D1` | Tailwind v3 (stone-300) |
| Error | `#B91C1C` | Tailwind v3 (red-700), AA-checked |
| Success | the deep green `#2F4739` | convention (the brand green already reads as positive) |

```css
:root {
  --color-bg: #F5EFE6;
  --color-text: #2F4739;
  --color-green-deep: #2F4739;
  --color-accent: #DAA644;          /* on deep green, and as a fill with deep-green labels */
  --color-accent-on-cream: #8D651C; /* mustard text/icons on cream or white */
  --color-surface: #FFFFFF;
  --color-border: #D6D3D1;
  --color-error: #B91C1C;
}
```

Measured contrast (WCAG; normal text needs 4.5:1):

| Pair | Ratio | Normal text (4.5:1) |
|---|---|---|
| Text (deep green) on background (cream) — `#2F4739` on `#F5EFE6` | 8.83:1 | pass |
| Text (deep green) on surface — `#2F4739` on `#FFFFFF` | 10.09:1 | pass |
| Mustard accent text on cream — `#8D651C` on `#F5EFE6` | 4.58:1 | pass |
| Mustard accent text on surface — `#8D651C` on `#FFFFFF` | 5.24:1 | pass |
| Mustard accent on deep green — `#DAA644` on `#2F4739` | 4.57:1 | pass |
| Deep green label on a mustard fill (button) — `#2F4739` on `#DAA644` | 4.57:1 | pass |
| Cream on deep green — `#F5EFE6` on `#2F4739` | 8.83:1 | pass |
| Error on background — `#B91C1C` on `#F5EFE6` | 5.66:1 | pass |

## Typography

| Item | Value | Source |
|---|---|---|
| Display | Humanist serif — Lora | spec |
| Body | Sans — Work Sans | spec |
| Families in total | At most 2 | spec (general rule) |
| Base font size | 16px | convention |
| Scale ratio | 1.25 (major third) | convention: gentle steps keep the warm, unhurried tone |

```css
:root {
  --font-display: "Lora", serif;
  --font-body: "Work Sans", sans-serif;
  --font-size-base: 1rem;
  --type-scale: 1.25;
}
```

## Spacing

Base unit **8px** (convention: roomy, boutique feel), all spacing in multiples of 8px, with 4px allowed for tight inline gaps.

## Motion and shape

| Item | Value | Source |
|---|---|---|
| Parallax | Soft | spec |
| Parallax amount | at most 24px of travel, speed factor 0.2 | convention |
| Shadows | Diffuse: `box-shadow: 0 8px 30px rgb(47 71 57 / 0.12)` | spec (diffuse) + convention (values, tinted with the deep green) |
| `border-radius` | Generous: 16px on cards and images, fully rounded (`9999px`) on buttons | spec (generous) + convention (values) |
| Reduced motion | Turn the parallax off entirely | `prefers-reduced-motion` |

## General rules that apply (inherited from `professional-web-design`)

- Modular type scale (ratio 1.25 or 1.333, never loose sizes with no relationship); base font size 16px.
- Spacing in multiples of the base unit.
- AA contrast as a minimum. Every color pair listed above was measured with the WCAG 2.x formula; a pair that is not listed has not been checked.
- `prefers-reduced-motion` respected.
