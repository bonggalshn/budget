# Feature Specification: User Login with Basic Authentication

**Feature Branch**: `001-user-login`  
**Created**: 2026-04-25  
**Status**: Draft  
**Input**: User description: "We store user data such as user name, email, and password. To login, user can either use user name or email."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Successful Login (Priority: P1)

A registered user can log in using either their username or email and password to gain authenticated access to the Budget API.

**Why this priority**: Login is the critical entry point for all authenticated operations. Without a working login, users cannot access any Budget functionality. Supporting both username and email increases convenience and matches how users expect to authenticate.

**Independent Test**: Can be fully tested by providing valid username/password credentials and verifying a session token is returned that grants API access to protected endpoints.

**Acceptance Scenarios**:

1. **Given** a user exists with username "alice", email "alice@example.com", and password "securepass123", **When** the user sends a POST request to `/api/v1/auth/login` with username and password, **Then** the system returns HTTP 200 with a session token and user details (id, username, email, created_at)
2. **Given** a user exists with email "alice@example.com" and password "securepass123", **When** the user sends a POST request to `/api/v1/auth/login` with email and password, **Then** the system returns HTTP 200 with a session token and user details (id, username, email, created_at)
3. **Given** a user has successfully logged in, **When** the user includes the session token in the Authorization header of subsequent requests, **Then** the system authenticates the request and allows access to protected endpoints
4. **Given** a logged-in user, **When** the user requests `/api/v1/auth/me`, **Then** the system returns the current user's profile information (id, username, email, created_at)

---

### User Story 2 - Login Failure Handling (Priority: P1)

The system must clearly communicate login failures to help users understand why authentication failed and guide them toward resolution.

**Why this priority**: Error handling is critical for user experience and security. Users need clear feedback, and the system must not leak information that could aid attackers.

**Independent Test**: Can be fully tested by attempting login with invalid credentials and verifying appropriate error responses without revealing whether username or password is incorrect.

**Acceptance Scenarios**:

1. **Given** a user attempts to log in with a non-existent username or email, **When** the request is submitted to `/api/v1/auth/login`, **Then** the system returns HTTP 401 Unauthorized with error message "Invalid username/email or password" (generic to avoid user enumeration)
2. **Given** a user attempts to log in with correct username or email but wrong password, **When** the request is submitted, **Then** the system returns HTTP 401 Unauthorized with the same generic error message
3. **Given** a user has failed login attempts, **When** the failed attempt count exceeds 5 within a 15-minute window, **Then** the system locks the account and returns HTTP 429 Too Many Requests with message "Account temporarily locked. Try again in 15 minutes."
4. **Given** an account is temporarily locked due to failed attempts, **When** the user retries after 15 minutes, **Then** the system resets the failed attempt counter and allows login

---

### User Story 3 - Session Management (Priority: P2)

Users can maintain authenticated sessions with tokens that expire after a configurable period.

**Why this priority**: Session security is essential for protecting user data. Expiring tokens limit the damage from compromised sessions. This is P2 because login succeeds even with infinite-lived tokens, but security is compromised.

**Independent Test**: Can be fully tested by logging in, observing token expiry time, waiting for expiration, and verifying requests with expired tokens are rejected.

**Acceptance Scenarios**:

1. **Given** a user successfully logs in, **When** the session token is returned, **Then** the response includes token expiry time (expires_at field in ISO 8601 format) set to 24 hours from login
2. **Given** a user with a valid session token, **When** the token has not expired, **Then** requests with the token in Authorization header are authenticated successfully
3. **Given** a user's session token has expired, **When** a request is made with the expired token, **Then** the system returns HTTP 401 Unauthorized with error message "Session expired. Please log in again."
4. **Given** a user requests `/api/v1/auth/logout`, **When** the request succeeds, **Then** the session token is invalidated and subsequent requests with that token return HTTP 401

---

### User Story 4 - Password Security (Priority: P1)

User passwords are securely hashed and handled with industry best practices to prevent unauthorized access even if the database is compromised.

**Why this priority**: Password security is non-negotiable for a financial application. Weak password storage could expose all user accounts simultaneously, violating the Budget Constitution's Data Protection principle.

**Independent Test**: Can be verified through code review and database inspection—passwords in DB must be bcrypt hashes, not plaintext; endpoint must reject weak passwords.

**Acceptance Scenarios**:

1. **Given** a user is created with a password, **When** the password is stored in the database, **Then** the stored value is a bcrypt hash (cost ≥ 12), never plaintext
2. **Given** a login request is received, **When** the password is compared to the stored hash, **Then** a timing-safe comparison is used to prevent timing attacks
3. **Given** a user attempts to log in, **When** the request is processed, **Then** the password is never logged or exposed in error messages
4. **Given** a user account is created, **When** a password shorter than 8 characters is provided, **Then** the system returns HTTP 400 Bad Request with error "Password must be at least 8 characters"

---

### Edge Cases

- What happens when a user submits an empty username or password? → System returns HTTP 400 Bad Request with field-specific error message
- How does the system handle concurrent login attempts from the same user? → Each attempt is processed independently; all may succeed if within rate limits
- What happens if the database is temporarily unavailable during login? → System returns HTTP 503 Service Unavailable with message "Service temporarily unavailable. Please try again."
- How does the system prevent brute-force attacks? → Failed login attempts are rate-limited; accounts lock after 5 failed attempts in 15 minutes
- What happens when a user logs in from multiple devices simultaneously? → All sessions are valid independently; user is logged in from all locations (no single-session limit)
- What if the username contains special characters? → System accepts valid UTF-8 characters; validation rules documented in Requirements section

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide an HTTP endpoint POST `/api/v1/auth/login` that accepts a login identifier (username or email) and password
- **FR-002**: System MUST validate the provided username or email and password against stored credentials in the database
- **FR-003**: System MUST return a session token (JWT or similar) on successful authentication
- **FR-004**: System MUST include token expiry information in the login response (expires_at timestamp)
- **FR-005**: System MUST return HTTP 401 Unauthorized with generic error message "Invalid username/email or password" for both wrong identifier and wrong password (no user enumeration)
- **FR-006**: System MUST hash passwords using bcrypt with cost ≥ 12 before storage
- **FR-007**: System MUST track failed login attempts per login identifier/IP address combination
- **FR-008**: System MUST temporarily lock accounts after 5 failed login attempts within a 15-minute window
- **FR-009**: System MUST provide an HTTP endpoint GET `/api/v1/auth/me` to retrieve current authenticated user's profile
- **FR-010**: System MUST provide an HTTP endpoint POST `/api/v1/auth/logout` to invalidate the current session token
- **FR-011**: System MUST enforce rate limiting on login endpoint (max 10 attempts per IP per minute, max 5 per username per 15 minutes)
- **FR-012**: System MUST validate request format (application/json) and return HTTP 400 Bad Request for malformed requests
- **FR-013**: System MUST use timing-safe password comparison to prevent timing attacks
- **FR-014**: System MUST never log or expose passwords in any logs, error messages, or responses
- **FR-015**: System MUST return HTTP 401 Unauthorized for requests with missing or invalid Authorization header on protected endpoints
- **FR-016**: System MUST support token-based authentication via `Authorization: Bearer <token>` header on all protected endpoints

### Key Entities *(include if feature involves data)*

- **User**: Represents a Budget application user
  - Attributes: id (UUID), username (string, unique), email (string, unique), password_hash (bcrypt), created_at (timestamp), updated_at (timestamp), deleted_at (timestamp for soft deletes)
  - Constraints: username NOT NULL, UNIQUE; email NOT NULL, UNIQUE; password_hash NOT NULL; created_at NOT NULL
  - Relationships: One-to-Many with LoginAttempt (audit trail); One-to-Many with Session

- **LoginAttempt**: Audit trail of login attempts (successful and failed)
  - Attributes: id (UUID), user_id (UUID, FK), identifier_provided (string for enumeration prevention), ip_address (string), success (boolean), attempted_at (timestamp), failure_reason (string: "invalid_credentials", "account_locked", etc.)
  - Constraints: user_id FK references User, attempted_at NOT NULL
  - Purpose: Track login attempts for security, rate limiting, and compliance auditing

- **Session**: Represents an authenticated user session
  - Attributes: id (UUID), user_id (UUID, FK), token_hash (SHA256), created_at (timestamp), expires_at (timestamp), invalidated_at (timestamp, NULL if active), last_activity_at (timestamp)
  - Constraints: user_id FK references User, created_at NOT NULL, expires_at NOT NULL
  - Purpose: Manage active sessions; enable logout; track session lifetime

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can successfully log in with valid credentials and receive a session token in ≤ 200ms p95 latency (per Constitution Performance Excellence principle)
- **SC-002**: Failed login attempts are rejected with generic error messages that do not reveal whether username/email or password was incorrect
- **SC-003**: Account lockout after 5 failed attempts is enforced; locked accounts cannot log in until the 15-minute timeout expires
- **SC-004**: 100% of passwords stored in database are bcrypt hashes (cost ≥ 12); zero plaintext passwords in production
- **SC-005**: Passwords are never logged or exposed in error messages (audit by grep for password mentions in logs)
- **SC-006**: All login endpoint responses follow the consistent API response format specified in Constitution Principle VI (error responses include error_code, message, details)
- **SC-007**: Test coverage for authentication logic exceeds 80% (unit tests for password hashing, comparison, token generation; integration tests for full login flow)
- **SC-008**: Session tokens expire after 24 hours; expired tokens are rejected with HTTP 401
- **SC-009**: Rate limiting prevents more than 10 login attempts per IP per minute (HTTP 429 response)
- **SC-010**: Timing-safe password comparison prevents timing attacks (verified through code review and benchmark tests)

## Assumptions

- **User Management Scope**: This spec covers authentication only. User registration (creating new accounts) is assumed to be handled in a separate feature ("User Registration"). For this feature, test users must be created manually in the database or via separate admin tooling. Users are identified by both username and email; either may be used at login.
- **Session Storage**: Sessions are stored in the PostgreSQL database. In-memory session storage (e.g., Redis) is not included in v1; can be optimized in future iterations.
- **Token Format**: JWT (JSON Web Tokens) are used for session tokens. This provides stateless authentication with built-in expiry. Token is signed with a server secret key (configuration TBD in planning phase).
- **Password Reset**: Password reset functionality is out of scope for this feature. Users with forgotten passwords cannot self-service in v1; manual admin reset required.
- **Username/Email Login**: Login accepts either username or email as the identifier; users may choose whichever is more convenient.- **Multi-Factor Authentication (MFA)**: MFA is not required for v1. Single-factor (username/password) authentication is sufficient for initial release.
- **Email Verification**: User email is not verified before account creation. Email/username are assumed pre-validated during user account setup (out of scope for login feature).
- **HTTPS Enforcement**: All login endpoints are assumed to be served over HTTPS. TLS termination is handled by load balancer or reverse proxy (not implemented in service itself).
- **Database Availability**: Login feature assumes PostgreSQL is available and operational. Fallback behavior for DB outages is documented in Backend Service Requirements (503 Service Unavailable).
- **Token Secrets**: JWT signing key and session encryption keys are managed via environment variables or secrets management system (specifics TBD in implementation planning).
- **Concurrency**: Multiple simultaneous login attempts from same user are allowed; no session affinity or "only one active session" requirement.
- **User Enumeration**: System intentionally returns generic errors to prevent username enumeration attacks (security best practice).
