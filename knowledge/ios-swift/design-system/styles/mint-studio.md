# Mint Studio (`mint-studio`)

Style of `professional-apple-ui`. Pick ONE per project, record it in the project's `AGENTS.md` (`UI style: mint-studio`) and in `docs/ui-style.json`, and generate `Theme.swift` from it; never mix styles.

**Feel**: Fresh and friendly: mint hero on a warm light-grey canvas. The original reference style.

**Source of the values**: **reference**: the values of the approved reference design, kept exactly.

**Note.** Kept exactly as first approved. Five pairs are below AA: white on the primary button (3.3:1 light, 2.5:1 dark), secondary text on the canvas (4.0:1) and on cards (4.46:1), and text on the dark hero card (4.47:1). For a new project, make an AA copy with: make_style.py --id mint-studio-aa --name "Mint Studio AA" --brand "#58B893".

## Type and shape

| Property | Value |
|---|---|
| Font design | `rounded` |
| Corner radii (hero / card / tile / thumbnail) | 28 / 24 / 16 / 14 pt |
| Role hues (OKLCH) | brand 166°, info 236°, plan 298°, attention 52°, danger 24° |

## Color tokens

Where each token goes is in `../visual-system.md`. Eight-digit values carry alpha.

| Token | Light | Dark |
|---|---|---|
| `canvas` | `#F4F2EE` | `#18201D` |
| `sidebar` | `#EDEBE6` | `#1D2622` |
| `card` | `#FFFFFF` | `#232D29` |
| `well` | `#F4F2EE` | `#1B2320` |
| `checker` | `#E9E6E0` | `#222C28` |
| `line` | `#2E3B3614` | `#FFFFFF12` |
| `text` | `#2E3B36` | `#EEF1EF` |
| `text2` | `#6E7A75` | `#A5B0AB` |
| `text3` | `#9AA39F` | `#75807B` |
| `hero` | `#9BDCC4` | `#3F7F68` |
| `onHero` | `#18392C` | `#F1FBF6` |
| `chipOnHero` | `#FFFFFF8C` | `#FFFFFF24` |
| `accent` | `#58B893` | `#6FCBA6` |
| `brandTint` | `#E3F4EC` | `#24392F` |
| `onBrandTint` | `#2F7A5C` | `#9EE0C4` |
| `primary` | `#3E9E7A` | `#4FB48D` |
| `onPrimary` | `#FFFFFF` | `#FFFFFF` |
| `info` | `#DCEDF7` | `#223543` |
| `onInfo` | `#2C5B76` | `#A9D2EA` |
| `infoStrong` | `#6AAED6` | `#7DBBE0` |
| `plan` | `#ECE5F6` | `#2E2A3D` |
| `onPlan` | `#5A4682` | `#CDBFEA` |
| `planStrong` | `#9C85CC` | `#AC98DA` |
| `attention` | `#FBE6D8` | `#3A2A20` |
| `onAttention` | `#8A4A26` | `#F2BE9C` |
| `attentionStrong` | `#F0A77A` | `#D98E62` |
| `danger` | `#F9DEDC` | `#3B2524` |
| `onDanger` | `#8C3330` | `#F1AFAB` |
| `dangerStrong` | `#E2726D` | `#DF7F7A` |

## Measured contrast

WCAG 2.x ratios, computed by `check_style.py`. Pairs not listed have not been checked.

| Pair | Target | Light | Dark |
|---|---|---|---|
| `text` on `canvas` | 7 | 10.46:1 | 14.62:1 |
| `text` on `card` | 7 | 11.70:1 | 12.49:1 |
| `text2` on `canvas` | 4.5 | 3.99:1 **below** | 7.44:1 |
| `text2` on `card` | 4.5 | 4.46:1 **below** | 6.36:1 |
| `onHero` on `hero` | 4.5 | 8.09:1 | 4.47:1 **below** |
| `onBrandTint` on `brandTint` | 4.5 | 4.54:1 | 8.18:1 |
| `onPrimary` on `primary` | 4.5 | 3.29:1 **below** | 2.55:1 **below** |
| `onInfo` on `info` | 4.5 | 6.11:1 | 7.90:1 |
| `onPlan` on `plan` | 4.5 | 6.50:1 | 8.08:1 |
| `onAttention` on `attention` | 4.5 | 5.64:1 | 8.24:1 |
| `onDanger` on `danger` | 4.5 | 6.27:1 | 7.76:1 |
