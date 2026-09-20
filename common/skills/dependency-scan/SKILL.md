---
name: dependency-scan
description: Before adding or upgrading a dependency (SPM, npm, PyPI, Go, Cargo or the backend's package manager), checks for known unpatched CVEs and picks the latest stable version. Use it whenever you are about to add a new dependency to a project.
model: haiku
effort: low
---

# dependency-scan

Informational skill: it guides the choice when adding the dependency. The **blocking** is done by the gate hook (`pre-commit-gate.sh`), which queries OSV.dev for the dependencies added or changed in every `git commit`.

## Objective

Do not introduce dependencies with known vulnerabilities.

## Must include

- Check for known unpatched CVEs **before** adding a new dependency (SPM/npm/the backend's package manager). To check without committing:

  ```bash
  bash "${CLAUDE_PLUGIN_ROOT}/hooks/dependency-scan.sh" --check <ecosystem> <package> <version>
  ```

  Ecosystems: `npm`, `PyPI`, `Go`, `crates.io`, `SwiftURL` (SPM; the package is written `github.com/<org>/<repo>`). It exits with code 1 if there are vulnerabilities and lists each advisory with the version that fixes it.
- Prefer the latest stable version instead of pinning an old one without reviewing pending security fixes.
- If the candidate version has vulnerabilities, propose the fixed version the advisory names, or an alternative; do not pin the vulnerable version.
- Remember that the gate will block the commit if the dependency is still affected; a justified exception is declared with `FL_DEPSCAN_ALLOW=<ID,ID>` and explained to the user.

## Must never assume

- Adding a new dependency for something trivial that 10 lines of your own code can solve, without raising the alternative first.
- That a dependency is safe because it is popular or because you used it before: check the specific version.
- That the check was done if OSV.dev did not respond: say explicitly that it was left unchecked.
