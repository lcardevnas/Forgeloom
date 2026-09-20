---
name: privacy-manifest
description: Apply when using "required reason" APIs (UserDefaults, file timestamps, disk space) or adding SPM dependencies, to keep PrivacyInfo.xcprivacy correct for the App Store.
---

# privacy-manifest

**Objective**: `PrivacyInfo.xcprivacy` compliance for the App Store.

## Must include

- Declare "required reason APIs" (UserDefaults, file timestamps, disk space, etc.) as soon as the code uses them
- Review the manifest of every new SPM dependency that also uses them

## Must never assume

- That a small app is exempt — the requirement is per API used, not per app size

## Accumulated stack knowledge

Full definition and lessons already learned: `${CLAUDE_PLUGIN_ROOT}/knowledge/AGENTS.md` and `${CLAUDE_PLUGIN_ROOT}/knowledge/patterns/` (if there are patterns, review the ones that apply before writing). Anything learned that generalizes is promoted with `/fl:promote`.
