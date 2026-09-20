# iOS and macOS (Swift) — conventions and gotchas

Forgeloom's agnostic core for Apple projects. Plain Markdown: any assistant that loads `AGENTS.md` can read it.

Reading rules:
- **Skill** = informs new code while it is being written. **Subagent** = audits code that has already been written, in an isolated pass. They do not compete for the same context.
- Every entry has three parts: *Objective*, *Must include* (or *review*) and *Must never assume* (or *Must never*). The third part prevents filling gaps with a reasonable default that is not valid for the real project: **check against the project, do not assume**.
- Before applying any rule, read from the project: Swift/iOS version (`Package.swift`, `AGENTS.md`), deployment target, and whether a `.swiftlint.yml` exists.
- New, generalizable lessons go in `knowledge/ios-swift/patterns/` (one lesson per file).

## Skills

### `swift-high-standard`
- **Objective**: Idiomatic Swift code following Apple's API Design Guidelines.
- **Must include**:
  - Naming that reads as phrases (`remove(at index:)`, not `getX()`)
  - `struct`/`enum` by default; `class` only for reference identity or real inheritance
  - `guard` for early returns
  - `if let a, let b` instead of nesting
  - Avoid `!`/`try!` outside tests
- **Must never assume**:
  - That the project uses SwiftLint without checking whether a `.swiftlint.yml` exists
  - The Swift/iOS version without reading it from `Package.swift`/`AGENTS.md`

### `swift6-concurrency`
- **Objective**: Code that compiles in strict concurrency mode with no isolation warnings.
- **Must include**:
  - Explicit `Sendable` on anything that crosses concurrency boundaries
  - Never `@unchecked Sendable` without a comment justifying why it is safe
  - `@MainActor` on anything that touches UI
  - Explicit cancellation in long-running `Task`s
- **Must never assume**:
  - That the project is already in strict mode — check the Swift target first
  - That a non-`Sendable` type can become `Sendable` without checking whether it is truly thread-safe

### `modern-swiftui`
- **Objective**: Views written with the current API, not iOS 13-14 patterns.
- **Must include**:
  - `@Observable` (Observation) instead of `ObservableObject`/`@Published`, unless the project already uses that pattern
  - Break `body` into subviews when it exceeds ~30-40 lines
  - `.spring()` for direct user interactions, `.easeInOut` for state transitions
  - Accessibility built in as you write (`accessibilityLabel`/`accessibilityHint`, Dynamic Type respected)
- **Must never assume**:
  - That `@Observable` is available without checking the deployment target (requires iOS 17+)
  - A visual style without checking whether the project already has its own design system

### `swift-testing`
- **Objective**: Tests that use Swift Testing as the default framework.
- **Must include**:
  - `@Test`/`#expect`/`#require` in projects on Xcode 16+
  - XCTest only if the project already uses it extensively or for UI testing
  - `@Test(arguments:)` instead of manual loops
  - Descriptive names that state the intent
- **Must never assume**:
  - That it can be freely mixed with XCTest in the same target without checking that the setup supports it

### `swiftdata-persistence`
- **Objective**: Correct data modeling and safe migrations.
- **Must include**:
  - `@Relationship` with delete rules (`.cascade`/`.nullify`) declared on purpose
  - A versioned `SchemaMigrationPlan` as soon as the model changes with real user data in production
- **Must never assume**:
  - That CloudKit sync is enabled without checking
  - That you must migrate from Core Data to SwiftData if the project already uses Core Data and no migration was requested

### `networking-async-await`
- **Objective**: A modern networking layer with no completion handlers.
- **Must include**:
  - `URLSession` with `data(for:)` + `async`/`await`
  - Explicit `Codable`/`CodingKeys` when the JSON does not map 1:1 to the model
  - Typed errors per layer (network / decoding / domain)
- **Must never assume**:
  - An API contract without checking `acme-contracts/openapi.yaml` (the contracts repo) if the project has one — the Swift model reflects the real contract; fields are not invented

### `privacy-manifest`
- **Objective**: `PrivacyInfo.xcprivacy` compliance for the App Store.
- **Must include**:
  - Declare "required reason APIs" (UserDefaults, file timestamps, disk space, etc.) as soon as the code uses them
  - Review the manifest of every new SPM dependency that also uses them
- **Must never assume**:
  - That a small app is exempt — the requirement is per API used, not per app size

## Subagents

### `security-review-owasp-mobile`
- **Objective**: Audit against the OWASP Mobile Top 10 (2024).
- **Must explicitly review**:
  - M1 hardcoded credentials / credentials outside Keychain
  - M2 dependencies without pinning
  - M3 tokens without expiry, biometrics without a secure fallback
  - M4 server data used without validation
  - M5 HTTP without TLS or ATS disabled without justification
  - M6 personal data logged or sent to analytics without need
  - M7 insufficient binary protections: secrets, critical logic or models shipped in the binary without protection; local license/payment/security checks not enforced by the backend; no integrity or tamper detection where the app's popularity or value justifies it
  - M8 security misconfiguration: debugging features or verbose logging left on in release builds; insecure defaults or default credentials; permissions, entitlements and data-protection classes broader than needed; app surface exposed unnecessarily (URL schemes, universal links, app extensions, file sharing)
  - M9 sensitive data in `UserDefaults` instead of Keychain
  - M10 obsolete cryptography or hardcoded keys
- **Must never**:
  - Give a generic pass without listing each finding with file:line and severity

### `accessibility-review-ios`
- **Objective**: Audit accessibility against Apple's guidelines / WCAG 2.1 AA as applicable to native apps.
- **Must explicitly review**:
  - `accessibilityLabel` describes the action, not the visual type
  - Contrast 4.5:1 (normal text) / 3:1 (large text) against the real color tokens
  - Dynamic Type without truncation or broken layout up to large sizes
  - Logical VoiceOver order, grouping where appropriate
  - Touch targets ≥44×44pt
- **Must never**:
  - Mark a flow as accessible without describing the walkthrough with VoiceOver on

### `memory-review-ios`
- **Objective**: Detect retain cycles and memory leaks.
- **Must explicitly review**:
  - Closures with strong `self` in long-lived `Timer`/`NotificationCenter`/`Combine` (must use `[weak self]` unless explicitly justified)
  - Delegates as `weak var` where appropriate
  - Long-running `Task`s not cancelled in `deinit`
- **Must never**:
  - Mechanically add `[weak self]` to every closure without assessing whether there is a real cycle risk

### `performance-review-ios`
- **Objective**: Detect expensive work in the wrong place and rendering problems.
- **Must explicitly review**:
  - Heavy network/disk/compute work runs off `@MainActor`
  - Stable identity (`id:`) in SwiftUI lists
  - Images resized before being displayed
- **Must never**:
  - Recommend optimizations without evidence of a measured performance problem

## Cross-cutting

`dependency-scan`: before adding an SPM dependency, check for known unpatched CVEs and prefer the latest stable version instead of pinning an old one without reviewing pending security fixes. The gate is enforced by the hook in `common/hooks/` (it blocks); this rule informs the choice. **Never** add a new dependency for something trivial that 10 lines of your own code can solve without raising the alternative first.

`cross-repo-work`: when a feature needs something that lives in another repo (an endpoint the backend does not have, a field the API does not return), **stop at the repo boundary**: do not edit the other repo, do not invent the missing contract, do not mock it silently. Route it through the contracts repo (see *Related repositories* in this project's `AGENTS.md`): extend the shared spec `<contracts>/specs/<feature>.md` with a group for the other repo, and propose the `openapi.yaml` change (contract-first), each applied only after the user's OK. Then continue only with what this repo can do against the contract. The user starts the other repo's session with the spec as its prompt; sessions do not command each other. **Never** guess where the contract lives: if the project has no *Related repositories* section, ask.
