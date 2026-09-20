# Backend — language-agnostic principles

Forgeloom's agnostic core for backend services. Plain Markdown: any assistant that loads `AGENTS.md` can read it.

With no stack decided, what follows are agnostic principles. When a language/framework is chosen, each skill's spec is made concrete with its own details (for example, if it is Vapor on Swift, consistent with the rest of the stack).

Reading rules:
- **Skill** = informs new code while it is being written. **Subagent** = audits code that has already been written, in an isolated pass. They do not compete for the same context.
- Every entry has three parts: *Objective*, *Must include* (or *review*) and *Must never assume* (or *Must never*). The third part prevents filling gaps with a reasonable default that is not valid for the real project: **check against the project, do not assume**.
- New, generalizable lessons go in `knowledge/backend/patterns/` (one lesson per file).

## Skills

### `api-design-contract-first`
- **Objective**: Design the API in the contract before the handler.
- **Must include**:
  - OpenAPI/GraphQL updated in `acme-contracts/` (the contracts repo) before writing the endpoint
  - Consistent REST conventions (plural resources, `limit`/`cursor` pagination, uniform error shape `{error:{code,message}}`)
  - Explicit versioning (`/v1/`) from the first endpoint
- **Must never assume**:
  - That an already-published contract can be changed incompatibly without a new version

### `database-design`
- **Objective**: Correct schemas and safe migrations.
- **Must include**:
  - Indexes on columns used in frequent `WHERE`/`JOIN`/`ORDER BY` (verify it; do not assume the ORM creates them on its own)
  - Explicit eager loading to avoid N+1
  - Reversible migrations, without production table locks when an online alternative exists
- **Must never assume**:
  - That a destructive migration (`DROP COLUMN`) is safe without a prior deprecation step

### `auth-patterns`
- **Objective**: Correct authentication/authorization.
- **Must include**:
  - JWT with short expiry + refresh token
  - Verification of resource *ownership* on every endpoint that accesses user data (being authenticated is not enough)
  - Hashing with bcrypt/argon2
- **Must never assume**:
  - That logging tokens/passwords while debugging is harmless — never

### `observability-logging`
- **Objective**: Structured logging that does not expose sensitive data.
- **Must include**:
  - Structured JSON with level and request ID, not stray `print`
  - Never log passwords/tokens/cards/PII — ties into the existing secret-scanning hook (`common/hooks/`)
- **Must never assume**:
  - That verbose development logging is acceptable in production without being able to turn it off by level

## Subagents

### `api-security-review-owasp`
- **Objective**: Audit against the OWASP API Security Top 10 (2023).
- **Must review**:
  - API1 BOLA
  - API2 Broken Authentication
  - API3 Broken Object Property Level Authorization
  - API4 Unrestricted Resource Consumption
  - API5 Broken Function Level Authorization
  - API6 Unrestricted Access to Sensitive Business Flows
  - API7 SSRF
  - API8 Security Misconfiguration
  - API9 Improper Inventory Management
  - API10 Unsafe Consumption of APIs — with special focus on API1 (BOLA/IDOR), the most common flaw and the one an LLM most easily commits when generating an endpoint without thinking it through
- **Must never**:
  - Approve an endpoint that receives a resource ID without visibly checking that it verifies *ownership*

### `contract-compliance-checker`
- **Objective**: Verify that the endpoint matches `acme-contracts/openapi.yaml`.
- **Must review**:
  - Types, required/optional fields, status codes — exactly as in the contract
- **Must never**:
  - Treat a divergence from the contract as an "improvement" instead of a bug

## Cross-cutting

`dependency-scan`: before adding a new dependency (npm, PyPI, Go, Cargo or whichever manager the backend uses), check for known unpatched CVEs and prefer the latest stable version instead of pinning an old one without reviewing pending security fixes. The gate is enforced by the hook in `common/hooks/` (it blocks); this rule informs the choice. **Never** add a new dependency for something trivial that 10 lines of your own code can solve without raising the alternative first.
