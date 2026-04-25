# Tasks: User Registration

**Input**: Design documents from `/specs/001-user-registration/`
**Prerequisites**: plan.md, spec.md, data-model.md, research.md

## Phase 1: Setup

**Purpose**: Verify existing project structure

- [x] T001 Review existing auth module structure in `budget-be/internal/auth/`
- [x] T002 Review existing user model in `budget-be/internal/user/model.go`
- [x] T003 Review existing repository patterns in `budget-be/internal/user/repository.go`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Database schema changes required before user stories

- [x] T004 Create migration for users table email verification fields in `budget-be/migrations/auth/004_add_email_verification.sql`
- [x] T005 [P] Create verification_tokens table migration in `budget-be/migrations/auth/005_create_verification_tokens.sql`
- [x] T006 Update User model with email_verified field in `budget-be/internal/user/model.go`
- [x] T007 Create VerificationToken model in `budget-be/internal/user/model.go`

**Checkpoint**: Database schema ready - user story implementation can begin

---

## Phase 3: User Story 1 - Register New Account (Priority: P1) 🎯 MVP

**Goal**: Users can register with username, email, and password

**Independent Test**: POST valid credentials → 201 Created → user in database (unverified)

- [x] T008 [P] [US1] Add RegisterRequest struct in `budget-be/internal/auth/handler.go`
- [x] T009 [P] [US1] Add RegisterResponse struct in `budget-be/internal/auth/handler.go`
- [x] T010 [US1] Add Register method to auth service in `budget-be/internal/auth/service.go`
- [x] T011 [US1] Add Register handler function in `budget-be/internal/auth/handler.go`
- [x] T012 [US1] Add registration route in `budget-be/api/v1/auth/routes.go`
- [x] T013 [US1] Add duplicate email check in `budget-be/internal/user/repository.go`
- [x] T014 [US1] Add duplicate username check in `budget-be/internal/user/repository.go`
- [x] T015 [US1] Add bcrypt password hashing in `budget-be/internal/auth/service.go`
- [x] T016 [US1] Add email format validation in `budget-be/internal/auth/service.go`

**Checkpoint**: User Story 1 functional - registration works with validation

---

## Phase 4: User Story 2 - Password Validation (Priority: P2)

**Goal**: System rejects weak passwords during registration

**Independent Test**: POST weak password → 400 error with clear message

- [x] T017 [US2] Add password validation function in `budget-be/internal/auth/service.go`
- [x] T018 [US2] Add password too short error message in `budget-be/internal/auth/handler.go`
- [x] T019 [US2] Add password needs number error message in `budget-be/internal/auth/handler.go`
- [x] T020 [US2] Integrate validation into Register handler

**Checkpoint**: User Story 2 functional - weak passwords rejected with clear messages

---

## Phase 5: User Story 3 - Email Verification (Priority: P3)

**Goal**: Users must verify email before login

**Independent Test**: Register → Verify token → Can login

- [x] T021 [P] [US3] Add token generation in `budget-be/internal/auth/service.go`
- [x] T022 [P] [US3] Add CreateVerificationToken method in `budget-be/internal/user/repository.go`
- [x] T023 [US3] Add VerifyEmail method to auth service in `budget-be/internal/auth/service.go`
- [x] T024 [US3] Add Verify handler in `budget-be/internal/auth/handler.go`
- [x] T025 [US3] Add verify route in `budget-be/api/v1/auth/routes.go`
- [x] T026 [US3] Update Login to require email_verified in `budget-be/internal/auth/service.go`
- [x] T027 [US3] Add expired/invalid token error in `budget-be/internal/auth/handler.go`

**Checkpoint**: User Story 3 functional - email verification flow complete

---

## Phase 6: Polish & Cross-Cutting Concerns

- [x] T028 [P] Update quickstart.md with registration examples
- [x] T029 Run `gofmt` on all modified files in `budget-be/`
- [x] T030 Run tests `go test ./...` in `budget-be/`
- [ ] T031 [P] Add migration rollback scripts

---

## Summary

| Metric | Count |
|--------|-------|
| Total Tasks | 31 |
| Phase 1 (Setup) | 3 |
| Phase 2 (Foundational) | 4 |
| Phase 3 (US1) | 9 |
| Phase 4 (US2) | 4 |
| Phase 5 (US3) | 7 |
| Phase 6 (Polish) | 4 |

**Completed**: 30/31 tasks (T031 pending - rollback scripts)

**MVP Scope**: Phase 3-5 (Full registration flow with email verification)