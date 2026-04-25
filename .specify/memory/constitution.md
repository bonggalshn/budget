<!-- SYNC IMPACT REPORT: Constitution v1.1.0 amended
- Version: 1.0.1 → 1.1.0 (MINOR: backend budget service domain principles)
- Added: Data Integrity and Auditability principle, API Design and Contract Stability principle, Backend Service Requirements section
- Updated: Purpose (backend budget planner context), User Experience Consistency (API-focused), Core Principles (financial data emphasis)
- New focus: Financial data accuracy, audit trails, API versioning, system reliability, security for sensitive data
- Templates: Pending review for financial domain context
-->

# Budget Constitution

## Purpose

This Constitution establishes the core engineering principles and governance standards for the Budget backend service. The Budget application provides a reliable, secure, and consistent API for budget planning and financial data management. This Constitution ensures all development activities maintain the trust, accuracy, and reliability required for a financial service while upholding Go/PostgreSQL best practices.

## Technology Stack

**Language**: Go (Golang) — Modern, statically typed, compiled language optimized for concurrent systems  
**Primary Database**: PostgreSQL — Robust, ACID-compliant relational database with JSON support  
**Deployment Target**: Linux servers (containers/VMs)  
**Code Quality Tools**: golangci-lint (static analysis), gofmt (code formatting), Go vet  
**Testing Framework**: Go's standard `testing` package with benchmarking support  
**Build System**: Go modules for dependency management

**Implications for This Constitution:**
- All code MUST be formatted with `gofmt` and pass `golangci-lint` with no warnings
- Go idioms and patterns MUST be preferred over generic approaches (error handling, interfaces, goroutines)
- All database interactions MUST use prepared statements and connection pooling (e.g., pgx, sqlc)
- PostgreSQL MUST be the system-of-record for all persistent data

## Core Principles

### I. Code Quality Discipline

Code MUST be written with clarity, maintainability, and robustness as primary concerns.

**Non-Negotiable Rules:**
- All code MUST pass automated linting and formatting standards without exception
  - **Go-specific:** `gofmt` MUST be run on all files; `golangci-lint` MUST pass with no errors or warnings
  - **Style:** Follow Effective Go conventions; use receiver method style; interface{} only when type unknown
- Complexity metrics MUST remain within established thresholds (cyclomatic complexity ≤ 10 per function; max function length 50 lines)
- Code duplication MUST be eliminated through abstraction and reuse
- All public APIs MUST have clear, accurate documentation describing purpose, parameters, and return values
  - **Go-specific:** All exported functions/types MUST have godoc comments starting with their name
- Comments MUST explain *why*, not *what*; code should be self-documenting through clear naming
- Magic numbers and strings MUST be replaced with named constants
- **Go-specific Error Handling:** Errors MUST be checked and handled explicitly; panic() is prohibited except in unrecoverable conditions

**Rationale:** Clear, maintainable code reduces defects, accelerates onboarding, and facilitates refactoring. Quality is not optional and prevents technical debt accumulation.

### II. Data Integrity and Auditability (NON-NEGOTIABLE for Financial Data)

All financial data MUST maintain strict integrity, consistency, and auditability to ensure accuracy and regulatory compliance.

**Non-Negotiable Rules:**
- All financial transactions MUST be recorded atomically; partial updates are prohibited
  - **PostgreSQL:** Use transactions (BEGIN/COMMIT/ROLLBACK); no business logic outside transaction boundaries
  - **Go-specific:** Leverage sqlc for type-safe SQL with transaction support; never nest transactions without explicit handling
- Database constraints MUST enforce data validity at the schema level
  - **Constraints required:** NOT NULL on critical fields, UNIQUE on identifiers, FOREIGN KEY for references, CHECK for domain rules
  - **Example:** account.balance >= 0, budget.limit >= 0, transaction amounts precise to 2 decimal places (use NUMERIC type)
- All data modifications MUST be logged with audit trail (who, what, when, why)
  - **Audit table pattern:** track_audit trigger on critical tables recording user_id, operation (INSERT/UPDATE/DELETE), old/new values, timestamp
  - **Go:** Provide audit_log endpoints that return historical changes for any entity
- Financial calculations MUST use consistent precision (decimal, not float)
  - **PostgreSQL:** Use NUMERIC(precision, scale) for all monetary values; e.g., NUMERIC(15, 2)
  - **Go:** Use github.com/shopspring/decimal or similar for safe financial arithmetic
- Reconciliation and balance verification MUST be built-in
  - **Daily reconciliation:** Verify sum of all transactions equals account balance (automated test)
  - **Go:** Implement invariant checks in critical path; abort on mismatch
- Data deletion is prohibited; only logical deletion (soft delete with updated_at)
  - **PostgreSQL:** Include deleted_at TIMESTAMP column; queries MUST filter WHERE deleted_at IS NULL by default
  - **Go:** Never physically delete financial records; enforce via repository layer

**Rationale:** Financial data accuracy is non-negotiable; errors compound and erode user trust. Auditability enables forensics, compliance, and dispute resolution. Integrity constraints prevent invalid states at source.

### III. API Design and Contract Stability

Test-Driven Development (TDD) is MANDATORY for all production code and features.

**Non-Negotiable Rules:**
- Tests MUST be written and approved by stakeholders BEFORE implementation begins
- Red-Green-Refactor cycle MUST be strictly enforced: test fails → implementation passes → refactor for quality
- Unit test coverage MUST exceed 80% for all new code; existing coverage MUST not decrease
  - **Go-specific:** Use `go test -cover ./...` to verify coverage; use `-coverprofile` flag for detailed analysis
- Every code path, error condition, and edge case MUST have corresponding test coverage
  - **Go-specific:** Test table-driven tests for multiple input scenarios; use t.Run() for subtests
- Integration tests MUST validate interactions between components and external dependencies
  - **Database tests:** Use PostgreSQL test fixtures or containers; MUST NOT use mocks for DB interaction validation
  - **Transaction tests:** MUST verify rollback behavior and constraint enforcement
- Regression tests MUST be added for every bug fix to prevent recurrence
- **Go-specific Benchmarks:** Performance-critical functions MUST include `Benchmark*` tests; benchmarks MUST document baseline metrics in code comments
- **Financial logic tests:** Every calculation, constraint, and edge case in monetary operations MUST be explicitly tested
  - **Coverage:** Positive cases (happy path), boundary conditions (balance=0, negative, max precision), error conditions (overflow, negative balance)
  - **Go:** Use table-driven tests for numeric precision validation

**Rationale:** Test-first development ensures requirements are clear before coding, provides living documentation, catches defects early, and enables confident refactoring. Tests are not overhead—they are specification.

### V. Performance Excellence

Performance MUST be a first-class concern from design through implementation.

**Non-Negotiable Rules:**
- Performance targets MUST be defined and documented for all user-facing operations (e.g., response time ≤ 200ms for critical paths)
- Algorithms MUST use appropriate complexity: O(n) preferred, O(n log n) acceptable, O(n²) requires explicit justification
- Memory usage MUST be monitored; leaks or excessive allocation MUST be identified and eliminated
  - **Go-specific:** Goroutine leaks MUST be prevented; all goroutines MUST have bounded lifetime or explicit shutdown
  - **Heap usage:** Use `runtime/debug.ReadGCStats()` and `pprof` for profiling; excessive allocations in hot paths require justification
- Database queries MUST be optimized; N+1 queries are prohibited unless explicitly documented with remediation plan
  - **PostgreSQL-specific:** Batch queries where possible; use indexes on frequently queried columns; EXPLAIN ANALYZE MUST be used for query validation
  - **Connection pooling:** MUST use configured pool (e.g., pgx pool with min/max conns); idle connections MUST be bounded
  - **Prepared statements:** MUST be used to prevent SQL injection and improve execution efficiency
- Caching strategies MUST be employed where performance gains justify added complexity
- Performance regressions MUST be detected and addressed in code review
  - **Go-specific:** Run benchmarks before and after changes; benchmark delta ≥ 5% MUST be justified

**Rationale:** Poor performance erodes user experience and system reliability. Performance engineering at design time is exponentially cheaper than post-launch optimization.

### VI. User Experience Consistency (API Perspective)

Backend APIs MUST provide predictable, well-documented, and consistent behavior across all endpoints.

**Non-Negotiable Rules:**
- All API responses MUST follow consistent naming conventions and structure
  - **Naming:** Use snake_case for JSON keys; never mix camelCase/PascalCase; document enum values
  - **Structure:** Wrap data in consistent envelope (e.g., {"data": {...}, "meta": {...}} or top-level fields for simplicity)
- Error messages MUST be clear, actionable, and consistent in tone; APIs MUST communicate what went wrong and how to fix it
  - **Language:** Use present tense, imperative form; avoid technical jargon for end users
  - **Example:** "Account balance must be non-negative" vs. "Illegal operation"
- All endpoints MUST be discoverable and follow REST conventions
  - **Consistency:** GET for reads, POST for creates, PUT/PATCH for updates, DELETE for removal
  - **Filtering:** Support standard query parameters (limit, offset, sort, filter) consistently
- Timestamps and date formats MUST be standardized (ISO 8601 with timezone)
  - **Go:** Use time.RFC3339 for serialization; always include timezone; store UTC in database
- Pagination MUST be consistent across all list endpoints
  - **Format:** `limit`, `offset`, `total` count; optional `has_more` flag; default limit documented

**Rationale:** Consistency reduces client integration friction, improves developer experience, and minimizes support burden. Well-designed APIs are discoverable without extensive documentation.

## Backend Service Requirements

### Reliability and Uptime

The Budget service MUST maintain high availability and graceful degradation during failures.

**Requirements:**
- Target uptime: 99.9% (≤ 43 minutes downtime/month)
- Planned maintenance windows: Scheduled during low-traffic periods with advance notice
- Health checks: Implement `/health` endpoint (no auth required) that validates:
  - Service is running (lightweight check)
  - Database connectivity (timeout 5s)
  - External dependencies (API keys valid, services reachable)
- Graceful shutdown: Service MUST complete in-flight requests before terminating (timeout 30s)
  - **Go:** Use context cancellation and proper signal handling (SIGTERM)
  - **HTTP:** Return 503 Service Unavailable during shutdown to load balancer
- Circuit breaker pattern for external dependencies
  - **Go:** Use github.com/grpc-ecosystem/go-grpc-middleware or similar; fail fast on repeated failures
  - **Fallback:** Cache responses when possible; return degraded service rather than errors

### Security and Data Protection

Financial data requires strong security practices and regular auditing.

**Requirements:**
- Authentication: All non-public endpoints MUST require valid credentials (JWT, OAuth2, API key)
  - **Go:** Implement in middleware; validate tokens on every request; use short expiry + refresh tokens
  - **Database:** Hash passwords with bcrypt (cost ≥ 12); never store plain text credentials
- Authorization: Endpoints MUST enforce role-based access control (RBAC)
  - **Rules:** Users can only access their own data; admins can access all; no cross-tenant data leakage
  - **Go:** Middleware enforces RBAC; repository layer filters queries by authenticated user
- Encryption: Sensitive data MUST be encrypted at rest and in transit
  - **In transit:** TLS 1.2+ for all connections; HSTS header; disable insecure protocols
  - **At rest:** Encrypt passwords, API keys, PII using AES-256-GCM; document key management
- Input validation: All inputs MUST be validated and sanitized
  - **Go:** Use struct tags + validator; reject before DB query; prevent SQL injection via parameterized queries
  - **Limits:** Enforce size limits on strings; validate numeric ranges; reject unexpected types
- Logging and monitoring: Do NOT log sensitive data (passwords, tokens, account numbers)
  - **Go:** Redact sensitive fields in logs; use structured logging (JSON); include request_id for tracing
  - **Retention:** Keep logs for ≥ 90 days; archive for audit trail
- Security headers on all responses
  - **Required:** Content-Security-Policy, X-Content-Type-Options, X-Frame-Options, Strict-Transport-Security
  - **Go:** Set in middleware or HTTP handler

### Observability and Monitoring

Backend services MUST be instrumented for production visibility.

**Requirements:**
- Structured logging with correlation IDs
  - **Go:** Log at appropriate level (ERROR, WARN, INFO, DEBUG); include request_id, user_id, operation
  - **Format:** JSON for easy parsing; human-readable in development
- Metrics collection (RED method: Rate, Errors, Duration)
  - **Go:** Use github.com/prometheus/client_golang; instrument HTTP handlers, DB queries, business logic
  - **Metrics:** Request count/rate, latency (p50, p95, p99), error rate, active connections
- Distributed tracing (optional but recommended)
  - **Go:** Use OpenTelemetry; trace requests across services; identify bottlenecks
- Alerts and escalation
  - **Thresholds:** Alert if error rate > 1%, p99 latency > 500ms, uptime < 99.8%, DB connection pool exhausted
  - **Response:** On-call engineer notified; runbook available for common issues



### Code Review Requirements

- Every pull request MUST be reviewed by at least one other developer before merge
- Reviews MUST verify compliance with all Core Principles
- Reviewers MUST validate test coverage and that all tests pass
- Code style and naming conventions MUST be enforced (use linters and formatters)
  - **Go-specific:** Reviewers MUST verify `gofmt` and `golangci-lint` pass; no overrides without explicit justification
  - **PostgreSQL:** Reviewers MUST audit any database schema changes, migrations, and query performance
- Merges to main branch MUST require passing CI/CD pipeline with all checks green
  - **Go-specific:** CI MUST run `go test -race ./...` to detect concurrency issues
  - **Coverage:** CI MUST fail if coverage drops below 80%

### Quality Gates

- **Pre-commit:** Local linter and formatter checks (enforce via git hooks)
- **Pull request:** Automated testing, coverage analysis, performance regression detection
- **Pre-merge:** Manual review, documentation verification, accessibility audit for UI changes
- **Post-merge:** Deployment validation, monitoring for errors, performance metrics

### Documentation Standards

- All modules MUST have a comment block describing purpose and key responsibilities
  - **Go-specific:** Package-level comments MUST be included in a `doc.go` file or the first file in the package
- Public APIs MUST include JSDoc/docstring comments with type annotations
  - **Go-specific:** Godoc comments MUST start with the exported name; use examples in comments where helpful
- Complex algorithms MUST be documented with pseudocode or examples
- README files MUST be updated when public API changes
- Breaking changes MUST be documented in CHANGELOG
- **Database Documentation:** All schema changes MUST include migration scripts with comments explaining rationale

## Quality Assurance Standards

### Testing Pyramid

- **Unit Tests (60%):** Test individual functions and components in isolation with mocked dependencies
- **Integration Tests (30%):** Test interaction between components, services, and external systems
- **End-to-End Tests (10%):** Test complete workflows from user perspective

### Test Quality Criteria

- Tests MUST be deterministic (no flaky tests)
  - **Go-specific:** Use `t.Parallel()` for independent tests; avoid global state and file system dependencies
- Tests MUST run in <100ms on average (slower tests should be marked and justified)
  - **Integration tests:** Database tests may exceed 100ms; MUST use `-short` flag for fast test mode
- Test names MUST clearly describe what is being tested and expected outcome
  - **Go convention:** Use `TestFunctionName_Scenario` naming pattern for clarity
- Tests MUST clean up after themselves (no cross-test dependencies)
  - **Database tests:** Use transactions (ROLLBACK) or test fixtures to ensure isolation
- Negative test cases (error paths) MUST be comprehensive
  - **Go-specific:** Test all error types returned; verify errors wrap correctly with context

## Governance

### Amendment Procedure

This Constitution is the authoritative governance document and supersedes all other practices and informal conventions.

**Amendment Requirements:**
- Any proposed change MUST be documented in writing with rationale
- Changes MUST be discussed and approved by the development team and project stakeholders
- Amendments MUST include a migration plan if existing code is non-compliant
- All changes MUST be recorded with effective date and version bump

### Versioning Policy

Constitution versions follow Semantic Versioning (MAJOR.MINOR.PATCH):
- **MAJOR:** Backward-incompatible principle removal or fundamental redefinition (rare; requires stakeholder approval)
- **MINOR:** New principle, section, or materially expanded guidance
- **PATCH:** Clarifications, wording improvements, typo fixes, non-semantic refinements

### Compliance Enforcement

- All pull requests MUST be reviewed for Constitution compliance
- Deviations from principles MUST be documented in comments with explicit justification
- Complexity or principle conflicts MUST be escalated to the team before implementation
- Runtime development guidance is available in [COPILOT_INSTRUCTIONS](../../.github/copilot-instructions.md)

---

**Version**: 1.1.0 | **Ratified**: 2026-04-25 | **Last Amended**: 2026-04-25
