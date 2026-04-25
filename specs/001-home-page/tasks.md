# Tasks: Home Page Authentication

**Feature**: Home Page | **Branch**: `001-home-page` | **Generated**: 2026-04-26

## Dependencies

```
Phase 1 (Setup)
    │
    v
Phase 2 (Foundational) ──────┐
    │                        │
    v                        │
Phase 3 (US1)                │
    │                        │
    v                        │
Phase 4 (US2) ───────────────┤
    │                        │
    v                        │
Phase 5 (US3) ───────────────┤
    │                        │
    v                        │
Phase 6 (US4) ───────────────┤
    │                        │
    v                        │
Phase 7 (US5+6) ─────────────┘
    │
    v
Phase 8 (Polish)
```

## Parallel Execution

- **US2, US3, US4**: Can run in parallel after Phase 2 (all share AuthContext and API service)
- **US5, US6**: Can run in parallel within Phase 7

---

## Phase 1: Setup

**Goal**: Initialize frontend project structure

- [x] T001 Create project structure in budget-fe/src/ per plan.md
- [x] T002 Configure Vite with TypeScript strict mode in vite.config.ts
- [x] T003 Set up Tailwind CSS configuration in tailwind.config.js
- [x] T004 Add React Router v6 dependencies in package.json
- [x] T005 Add React Hook Form and Zod dependencies in package.json
- [x] T006 Add Vitest and React Testing Library dependencies in package.json
- [x] T007 Run npm install to install all dependencies

**Independent Test**: Project structure exists, dev server starts without errors

---

## Phase 2: Foundational

**Goal**: Create shared infrastructure needed by all user stories

- [x] T008 [P] Define TypeScript types in budget-fe/src/types/auth.ts
- [x] T009 [P] Create API service layer in budget-fe/src/services/api.ts
- [x] T010 Create AuthContext in budget-fe/src/context/AuthContext.tsx
- [x] T011 Create ProtectedRoute component in budget-fe/src/components/ProtectedRoute.tsx
- [x] T012 Create ErrorBoundary component in budget-fe/src/components/ErrorBoundary.tsx
- [x] T013 Configure React Router in budget-fe/src/App.tsx with routes: /, /login, /register
- [x] T014 Add Button component in budget-fe/src/components/Button.tsx
- [x] T015 Add Greeting component in budget-fe/src/components/Greeting.tsx

**Independent Test**: AuthContext provides user state, API service makes requests, ProtectedRoute guards routes

---

## Phase 3: User Story 1 - View Public Home Page [US1]

**Goal**: Create landing page for unauthenticated users

**Independent Test**: Load / → see greeting, login button, register button

- [ ] T016 [P] [US1] Create PublicHomePage component in budget-fe/src/pages/PublicHomePage.tsx
- [ ] T017 [P] [US1] Add navigation links to login and register in PublicHomePage
- [ ] T018 [US1] Verify PublicHomePage displays on root route /

**Tests**: None requested

---

## Phase 4: User Story 2 - Login [US2]

**Goal**: Authenticate users with identifier (username or email) and password

**Independent Test**: Submit valid credentials → access authenticated home; Submit invalid → error message

- [ ] T019 [P] [US2] Create LoginPage component in budget-fe/src/pages/LoginPage.tsx
- [ ] T020 [US2] Implement form with identifier and password fields in LoginPage
- [ ] T021 [US2] Add React Hook Form with Zod validation (identifier required, password min 8 chars)
- [ ] T022 [US2] Connect form to AuthContext login method on submit
- [ ] T023 [US2] Handle loading state during authentication
- [ ] T024 [US2] Display error message on failed login (invalid_credentials, account_locked, email_not_verified)
- [ ] T025 [US2] Add link to register page
- [ ] T026 [US2] Add link to home page (logo/header)
- [ ] T027 [US2] Redirect to authenticated home on success
- [ ] T028 [US2] Verify LoginPage displays on /login route

**Tests**: None requested

---

## Phase 5: User Story 3 - Register [US3]

**Goal**: Create new user accounts with username, email, and password

**Independent Test**: Submit valid data → account created, redirect to login; Submit duplicate → error message

- [ ] T029 [P] [US3] Create RegisterPage component in budget-fe/src/pages/RegisterPage.tsx
- [ ] T030 [US3] Implement form with username, email, and password fields in RegisterPage
- [ ] T031 [US3] Add React Hook Form with Zod validation (username required, email valid format, password min 12 chars with uppercase, lowercase, number and special character) [FR-017]
- [ ] T031a [US3] Implement password validation per FR-017 in RegisterPage form
- [ ] T032 [US3] Connect form to API register endpoint on submit
- [ ] T033 [US3] Handle loading state during registration
- [ ] T034 [US3] Display error message on failed registration (duplicate_email, username_taken, weak_password)
- [ ] T035 [US3] Show success message "Check your email to verify your account"
- [ ] T036 [US3] Add link to login page
- [ ] T037 [US3] Add link to home page (logo/header)
- [ ] T038 [US3] Redirect to login on success
- [ ] T039 [US3] Verify RegisterPage displays on /register route

**Tests**: None requested

---

## Phase 6: User Story 4 - Authenticated Home Page [US4]

**Goal**: Create personalized dashboard for logged-in users

**Independent Test**: Logged in user visits / → personalized greeting with username, quick links

- [ ] T040 [P] [US4] Create AuthenticatedHomePage component in budget-fe/src/pages/AuthenticatedHomePage.tsx
- [ ] T041 [US4] Display personalized greeting using username from AuthContext
- [ ] T042 [US4] Add quick navigation links (dashboard, transactions, budget overview)
- [ ] T043 [US4] Add logout button
- [ ] T044 [US4] Verify authenticated home displays for logged-in users on /

**Tests**: None requested

---

## Phase 7: User Stories 5 & 6 - Logout & Navigation [US5, US6]

**Goal**: Enable session termination and navigation flexibility

**Independent Test**: Click logout → session cleared, redirected to public home; Navigate from auth pages → can return to home

- [ ] T045 [P] [US5] Implement logout function in AuthContext
- [ ] T046 [P] [US6] Add home link/logo to all pages (LoginPage, RegisterPage)
- [ ] T047 [US5] Add logout button to AuthenticatedHomePage
- [ ] T048 [US5] Call logout API on click
- [ ] T049 [US5] Clear token from localStorage
- [ ] T050 [US5] Reset AuthContext state
- [ ] T051 [US5] Redirect to public home page on logout
- [ ] T052 [US5] Verify protected routes redirect to login after logout
- [ ] T053 [US6] Verify back button returns to public home
- [ ] T054 [US6] Verify home logo/link navigates to appropriate home page based on auth state

**Tests**: None requested

---

## Phase 8: Polish & Cross-Cutting Concerns

**Goal**: Ensure consistent UX and accessibility across all pages

- [ ] T055 Add loading spinners during API calls
- [ ] T056 Add keyboard navigation support (Tab, Enter, Escape)
- [ ] T057 Ensure ARIA labels on interactive elements
- [ ] T058 Test responsive design (mobile, tablet, desktop)
- [ ] T059 Add focus management on page transitions
- [ ] T060 Verify all forms show appropriate error states
- [ ] T061 Test edge case: expired token handling
- [ ] T062 Verify error boundary catches component crashes gracefully
- [ ] T063 Test responsive design across mobile, tablet, and desktop viewports
- [ ] T064 Measure and optimize login completion time to ensure < 30 seconds
- [ ] T065 Measure and optimize registration completion time to ensure < 60 seconds
- [ ] T066 Measure and optimize personalized content display time to ensure < 2 seconds
- [ ] T067 Conduct user testing to ensure 100% of unauthenticated users can locate both Login and Register options on first view [SC-002]
- [ ] T068 Measure and optimize navigation between pages to complete within 1 second [SC-003]

**Tests**: None requested

---

## Summary

| Metric | Count |
|--------|-------|
| Total Tasks | 69 |
| Phase 1 (Setup) | 7 |
| Phase 2 (Foundational) | 8 |
| Phase 3 (US1) | 3 |
| Phase 4 (US2) | 10 |
| Phase 5 (US3) | 11 |
| Phase 6 (US4) | 5 |
| Phase 7 (US5+6) | 10 |
| Phase 8 (Polish) | 15 |

**Parallel Opportunities**: 15 tasks marked [P] across phases
**MVP Scope**: Phase 3 (US1) - Public Home Page only