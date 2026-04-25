# Tasks: User Registration

**Input**: Design documents from `/specs/001-user-registration/`
**Prerequisites**: plan.md, spec.md, data-model.md, research.md

## Phase 1: Setup

**Purpose**: Verify existing project structure

- [ ] T001 Review existing auth module structure in `budget-be/internal/auth/`
- [ ] T002 Review existing user model in `budget-be/internal/user/model.go`
- [ ] T003 Review existing repository patterns in `budget-be/internal/user/repository.go`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Database schema changes required before user stories

- [ ] T004 Create migration for users table email verification fields in `budget-be/migrations/auth/004_add_email_verification.sql`
- [ ] T005 [P] Create verification_tokens table migration in `budget-be/migrations/auth/005_create_verification_tokens.sql`
- [ ] T006 Update User model with email_verified field in `budget-be/internal/user/model.go`
- [ ] T007 Create VerificationToken model in `budget-be/internal/user/model.go`

**Checkpoint**: Database schema ready - user story implementation can begin

---

## Phase 3: User Story 1 - Register New Account (Priority: P1) 🎯 MVP

**Goal**: Users can register with username, email, and password

**Independent Test**: POST valid credentials → 201 Created → user in database (unverified)

- [ ] T008 [P] [US1] Add RegisterRequest struct in `budget-be/internal/auth/handler.go`
- [ ] T009 [P] [US1] Add RegisterResponse struct in `budget-be/internal/auth/handler.go`
- [ ] T010 [US1] Add Register method to auth service in `budget-be/internal/auth/service.go`
- [ ] T011 [US1] Add Register handler function in `budget-be/internal/auth/handler.go`
- [ ] T012 [US1] Add registration route in `budget-be/api/v1/auth/routes.go`
- [ ] T013 [US1] Add duplicate email check in `budget-be/internal/user/repository.go`
- [ ] T014 [US1] Add duplicate username check in `budget-be/internal/user/repository.go`
- [ ] T015 [US1] Add bcrypt password hashing in `budget-be/internal/auth/service.go`
- [ ] T016 [US1] Add email format validation in `budget-be/internal/auth/service.go`

**Checkpoint**: User Story 1 functional - registration works with validation

---

## Phase 4: User Story 2 - Password Validation (Priority: P2)

**Goal**: System rejects weak passwords during registration

**Independent Test**: POST weak password → 400 error with clear message

- [ ] T017 [US2] Add password validation function in `budget-be/internal/auth/service.go`
- [ ] T018 [US2] Add password too short error message in `budget-be/internal/auth/handler.go`
- [ ] T019 [US2] Add password needs number error message in `budget-be/internal/auth/handler.go`
- [ ] T020 [US2] Integrate validation into Register handler

**Checkpoint**: User Story 2 functional - weak passwords rejected with clear messages

---

## Phase 5: User Story 3 - Email Verification (Priority: P3)

**Goal**: Users must verify email before login

**Independent Test**: Register → Verify token → Can login

- [ ] T021 [P] [US3] Add token generation in `budget-be/internal/auth/service.go`
- [ ] T022 [P] [US3] Add CreateVerificationToken method in `budget-be/internal/user/repository.go`
- [ ] T023 [US3] Add VerifyEmail method to auth service in `budget-be/internal/auth/service.go`
- [ ] T024 [US3] Add Verify handler in `budget-be/internal/auth/handler.go`
- [ ] T025 [US3] Add verify route in `budget-be/api/v1/auth/routes.go`
- [ ] T026 [US3] Update Login to require email_verified in `budget-be/internal/auth/service.go`
- [ ] T027 [US3] Add expired/invalid token error in `budget-be/internal/auth/handler.go`

**Checkpoint**: User Story 3 functional - email verification flow complete

---

## Phase 6: Polish & Cross-Cutting Concerns

- [ ] T028 [P] Update quickstart.md with registration examples
- [ ] T029 [P] Add migration rollback scripts
- [ ] T030 Run `gofmt` on all modified files in `budget-be/`
- [ ] T031 Run tests `go test ./...` in `budget-be/`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies
- **Foundational (Phase 2)**: Depends on Setup - BLOCKS all stories
- **User Story 1 (Phase 3)**: Depends on Foundational - MVP delivery
- **User Story 2 (Phase 4)**: Depends on Foundational - Can parallel US1
- **User Story 3 (Phase 5)**: Depends on Foundational - Can parallel US1/US2
- **Polish (Phase 6)**: Depends on all stories

### User Story Dependencies

- **US1 (P1)**: No dependencies on other stories
- **US2 (P2)**: No dependencies on other stories, integrates with US1 registration
- **US3 (P3)**: No dependencies on other stories

### Parallel Opportunities

- T008, T009 can run in parallel (different structs)
- T016, T008 can run in parallel (validation + structs)
- T021, T022 can run in parallel (token generation + DB method)

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1-2
2. Complete Phase 3: User Story 1
3. **STOP and VALIDATE**: Registration works
4. Deploy/demo if ready

### Full Delivery

1. Phase 1-2 → Foundation ready
2. Phase 3-5 → All user stories complete
3. Phase 6 → Polish
4. Deploy complete feature

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

**MVP Scope**: Phase 3 (User Story 1) - Basic registration without email verification