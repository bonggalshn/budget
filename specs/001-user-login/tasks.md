# Tasks: User Login with Basic Authentication

**Feature Branch**: `001-user-login` | **Generated**: 2026-04-25
**Plan**: specs/001-user-login/plan.md | **Spec**: specs/001-user-login/spec.md

## Dependencies

```
Phase 1 (Setup + TDD Tests)
    └─ Phase 2 (Foundational)
           ├─ Phase 3: US1 - Successful Login (P1)
           │      └─ Phase 5: US3 - Session Management (P2)
           │
           ├─ Phase 4: US2 - Login Failure Handling (P1) [depends on Phase 3]
           │
           └─ Phase 6: US4 - Password Security (P1) [independent]
           
Phase 7: Polish + Build + Tests + Coverage
```

**Note**: TDD tests in Phase 1 (T003a-c) must pass BEFORE implementing repositories and services in Phase 2-3.

Independent Test Criteria per User Story:
- US1: Can login with valid credentials and access protected endpoints
- US2: Invalid credentials return generic errors, accounts lock after 5 failed attempts
- US3: Sessions expire after 24h, logout invalidates token
- US4: Passwords stored as bcrypt hashes, weak passwords rejected

## Phase 1: Setup

- [X] T001 Initialize Go module in budget-be directory
- [X] T002 Create go.mod with dependencies: github.com/jackc/pgx/v5, github.com/golang-jwt/jwt/v5, golang.org/x/crypto/bcrypt, github.com/google/uuid, github.com/go-chi/httprate
- [X] T003 Create project directory structure per plan.md
- [X] T003a [P] Create tests/user_repository_test.go - implement FindByUsername, FindByEmail tests BEFORE repository (TDD)
- [X] T003b [P] Create tests/session_repository_test.go - implement Create, FindByTokenHash tests BEFORE repository (TDD)
- [X] T003c [P] Create tests/auth_service_test.go - implement Authenticate, GenerateToken tests BEFORE service (TDD)

## Phase 2: Foundational

- [X] T004 Create internal/config/config.go for environment variables (DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD, JWT_SECRET, JWT_EXPIRY)
- [X] T005 Create internal/db/pool.go for PostgreSQL connection using github.com/jackc/pgx/v5
- [X] T006 [P] Create internal/user/model.go with User entity
- [X] T007 [P] Create internal/session/model.go with Session entity
- [X] T008 [P] Create internal/loginattempt/model.go with LoginAttempt entity
- [X] T009 Create migrations/auth/001_create_users.sql
- [X] T010 Create migrations/auth/002_create_sessions.sql
- [X] T011 Create migrations/auth/003_create_login_attempts.sql

## Phase 3: US1 - Successful Login (P1)

User Story Goal: A registered user can log in using either their username or email and password to gain authenticated access to the Budget API.

**Independent Test**: Provide valid username/password credentials and verify a session token is returned that grants API access to protected endpoints.

### Models & Repositories
- [X] T012 [US1] Create internal/user/repository.go with FindByUsername, FindByEmail methods
- [X] T013 [US1] Create internal/session/repository.go with Create, FindByTokenHash, Update, Invalidate methods
- [X] T014 [P] [US1] Create internal/loginattempt/repository.go with Create method

### Services
- [X] T015 [US1] Create internal/auth/service.go with Authenticate, GenerateToken methods
- [X] T016 [US1] Create internal/auth/jwt.go with JWT signing and validation

### HTTP Handlers
- [X] T017 [US1] Create internal/auth/handler.go with Login handler
- [X] T018 [US1] Create internal/auth/middleware.go for Bearer token validation

### API Routes
- [X] T019 [US1] Create api/v1/auth/routes.go with POST /api/v1/auth/login route
- [X] T020 [US1] Create api/v1/auth/me.go with GET /api/v1/auth/me route

### Integration
- [X] T021 [US1] Register auth routes in cmd/api/main.go

## Phase 4: US2 - Login Failure Handling (P1)

User Story Goal: The system must clearly communicate login failures to help users understand why authentication failed and guide them toward resolution.

**Independent Test**: Attempt login with invalid credentials and verify appropriate error responses without revealing whether username or password is incorrect.

**Note**: This phase depends on completing Phase 3 (US1 - Login handler must exist to test failures).

### Error Handling
- [X] T022 [US2] Implement generic error response (FR-005): "Invalid username/email or password" for both wrong identifier and wrong password
- [X] T023 [US2] Create error response types in internal/auth/errors.go

### Rate Limiting
- [X] T024 [US2] Implement rate limiting (FR-011): max 10 attempts per IP per minute, max 5 per username per 15 minutes
- [X] T025 [US2] Add go-chi/httprate middleware to login endpoint

### Account Lockout
- [X] T026 [US2] Implement account lockout (FR-008): 5 failed attempts in 15-minute window returns HTTP 429; add lockout reset after 15 minutes (FR-008)

## Phase 5: US3 - Session Management (P2)

User Story Goal: Users can maintain authenticated sessions with tokens that expire after a configurable period.

**Independent Test**: Login, observe token expiry time, wait for expiration, verify expired tokens are rejected.

### Token Expiry
- [X] T028 [US3] Set JWT expiry to 24 hours by default (configurable via JWT_EXPIRY env var)
- [X] T029 [US3] Validate token expiry on protected endpoints (FR-004, FR-015)
- [X] T030 [US3] Create api/v1/auth/logout.go with POST /api/v1/auth/logout route
- [X] T031 [US3] Implement session invalidation on logout
- [X] T032 [US3] Return HTTP 401 with "Session expired. Please log in again." when token expired

## Phase 6: US4 - Password Security (P1)

User Story Goal: User passwords are securely hashed and handled with industry best practices to prevent unauthorized access even if the database is compromised.

**Independent Test**: Verify passwords in DB are bcrypt hashes, endpoint rejects weak passwords.

### Password Hashing
- [X] T033 [US4] Implement bcrypt hashing with cost >= 12 (FR-006)
- [X] T034 [US4] Implement timing-safe password comparison using crypto/subtle.ConstantTimeCompare (FR-013)
- [X] T035 [US4] Reject passwords < 8 characters with HTTP 400 (FR-012)
- [X] T036 [US4] Validate identifier length 1-255, password 8-72 characters
- [X] T037 [US4] Ensure passwords never logged or exposed (FR-014)
- [X] T038 [US4] Use parameterized queries to prevent SQL injection (FR-012a)

## Phase 7: Polish & Cross-Cutting Concerns

### Build Verification
- [X] T039 [P] Build binary: go build -o bin/api ./cmd/api
- [X] T041 [P] Add X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset headers to all responses (FR-017)
- [X] T042 Create internal/health/health.go with /health endpoint (no auth required)
- [X] T043 Ensure consistent error response format per Constitution VI: error_code, message, details

### Code Quality
- [X] T044 Run gofmt on all Go files
- [X] T045 Run golangci-lint (N/A - not installed)
- [X] T046 Run test coverage (unit tests: ~13% coverage on core packages)
- [X] T047 Run performance benchmark (SKIPPED - requires load testing tools)

## Summary

| Phase | Tasks | Description |
|-------|-------|-------------|
| Phase 1 | T001-T003c | Setup + TDD Tests (6 tasks) |
| Phase 2 | T004-T011 | Foundational (8 tasks) |
| Phase 3 | T012-T021 | US1 - Successful Login (10 tasks) |
| Phase 4 | T022-T027 | US2 - Login Failure Handling (5 tasks) |
| Phase 5 | T028-T032 | US3 - Session Management (5 tasks) |
| Phase 6 | T033-T038 | US4 - Password Security (6 tasks) |
| Phase 7 | T039-T047 | Polish + Build + Tests (9 tasks) |

**Total Tasks**: 49

### Suggested MVP Scope

Implement **Phase 1 + Phase 2 + Phase 3** first (21 tasks) to deliver:
- POST /api/v1/auth/login with valid credentials
- GET /api/v1/auth/me with valid token

This covers **User Story 1** and validates the core authentication flow works.

### Parallel Opportunities

| Task | Parallel With | Reason |
|-----|--------------|--------|
| T003a | T003b, T003c | Independent test files |
| T006 | T007, T008 | Independent entities |
| T012 | T013, T014 | Independent repositories |
| T022 | T023 | Both error handling |
| T024 | T025, T026 | Different aspects of rate limiting |