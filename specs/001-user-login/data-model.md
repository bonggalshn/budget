# Data Model: User Login with Basic Authentication

**Feature Branch**: 001-user-login  
**Date**: 2026-04-25  

## Entities

### User Entity

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | UUID | PRIMARY KEY, NOT NULL | Unique user identifier |
| username | VARCHAR(50) | NOT NULL, UNIQUE | User's login name |
| email | VARCHAR(255) | NOT NULL, UNIQUE | User's email address |
| password_hash | VARCHAR(60) | NOT NULL | bcrypt hash (cost ≥12) |
| created_at | TIMESTAMP | NOT NULL | Account creation timestamp |
| updated_at | TIMESTAMP | NOT NULL | Last update timestamp |
| deleted_at | TIMESTAMP | NULL | Soft delete marker |

**Indexes**:
- `idx_user_username` on username
- `idx_user_email` on email

### LoginAttempt Entity

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | UUID | PRIMARY KEY, NOT NULL | Unique attempt identifier |
| user_id | UUID | FK → User(id), NOT NULL | Reference to user |
| identifier_provided | VARCHAR(255) | NOT NULL | Username or email provided (for audit) |
| ip_address | INET | NOT NULL | Client IP address |
| success | BOOLEAN | NOT NULL | Whether login succeeded |
| attempted_at | TIMESTAMP | NOT NULL | When attempt occurred |
| failure_reason | VARCHAR(50) | NULL | Reason if failed |

**Indexes**:
- `idx_login_attempt_user_id` on user_id
- `idx_login_attempt_attempted_at` on attempted_at

### Session Entity

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | UUID | PRIMARY KEY, NOT NULL | Unique session identifier |
| user_id | UUID | FK → User(id), NOT NULL | Reference to user |
| token_hash | VARCHAR(64) | NOT NULL, UNIQUE | SHA256 hash of JWT |
| created_at | TIMESTAMP | NOT NULL | Session creation time |
| expires_at | TIMESTAMP | NOT NULL | Session expiry time |
| invalidated_at | TIMESTAMP | NULL | When session was invalidated |
| last_activity_at | TIMESTAMP | NOT NULL | Last activity timestamp |

**Indexes**:
- `idx_session_user_id` on user_id
- `idx_session_token_hash` on token_hash
- `idx_session_expires_at` on expires_at (for cleanup)

## Database Relationships

```
User (1) ──< (many) LoginAttempt
User (1) ──< (many) Session
```

## Validation Rules

### Password Rules
- Minimum length: 8 characters
- Stored as bcrypt hash with cost ≥ 12

### Username Rules
- 1-50 characters
- Alphanumeric and underscores only
- Case-sensitive (stored as provided)

### Email Rules
- Valid email format
- 1-255 characters
- Stored lowercase for consistency

## State Transitions

### Session States

| State | invalidated_at | Description |
|-------|---------------|-------------|
| Active | NULL | Valid session, can be used |
| Invalidated | SET | User logged out or admin terminated |
| Expired | NULL | Past expires_at timestamp |

### Account Lockout

| State | Condition | Auto-Reset |
|-------|-----------|------------|
| Active | Normal | N/A |
| Locked | 5 failed attempts in 15 min | After 15 minutes |

## Migration Notes

### Users Table
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(60) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_user_username ON users(username);
CREATE INDEX idx_user_email ON users(email);
```

### LoginAttempts Table
```sql
CREATE TABLE login_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    identifier_provided VARCHAR(255) NOT NULL,
    ip_address INET NOT NULL,
    success BOOLEAN NOT NULL,
    attempted_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    failure_reason VARCHAR(50)
);

CREATE INDEX idx_login_attempt_user_id ON login_attempts(user_id);
CREATE INDEX idx_login_attempt_attempted_at ON login_attempts(attempted_at);
```

### Sessions Table
```sql
CREATE TABLE sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    token_hash VARCHAR(64) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    invalidated_at TIMESTAMP WITH TIME ZONE,
    last_activity_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_session_user_id ON sessions(user_id);
CREATE INDEX idx_session_token_hash ON sessions(token_hash);
CREATE INDEX idx_session_expires_at ON sessions(expires_at);
```

## API Models

### LoginRequest
```go
type LoginRequest struct {
    Identifier string `json:"identifier"` // username or email
    Password  string `json:"password"`
}
```

### LoginResponse
```go
type LoginResponse struct {
    Token     string `json:"token"`
    ExpiresAt string `json:"expires_at"` // ISO 8601
    User      User   `json:"user"`
}
```

### User
```go
type User struct {
    ID        string `json:"id"`
    Username  string `json:"username"`
    Email     string `json:"email"`
    CreatedAt string `json:"created_at"`
}
```

### ErrorResponse
```go
type ErrorResponse struct {
    ErrorCode string `json:"error_code"`
    Message  string `json:"message"`
    Details  any    `json:"details,omitempty"`
}
```