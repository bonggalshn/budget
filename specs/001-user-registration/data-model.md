# Data Model: User Registration

## Entities

### User

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY, NOT NULL | Unique user identifier |
| `username` | VARCHAR(50) | UNIQUE, NOT NULL | Display name |
| `email` | VARCHAR(255) | UNIQUE, NOT NULL | User email |
| `password_hash` | VARCHAR(255) | NOT NULL | bcrypt hash |
| `email_verified` | BOOLEAN | DEFAULT FALSE | Email verification status |
| `created_at` | TIMESTAMP | NOT NULL | Account creation time |
| `updated_at` | TIMESTAMP | NOT NULL | Last update time |
| `deleted_at` | TIMESTAMP | NULL | Soft delete timestamp |

### VerificationToken

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY, NOT NULL | Token identifier |
| `user_id` | UUID | FOREIGN KEY → users.id, NOT NULL | Reference to user |
| `token` | VARCHAR(255) | UNIQUE, NOT NULL | Verification token |
| `expires_at` | TIMESTAMP | NOT NULL | Token expiration |
| `created_at` | TIMESTAMP | NOT NULL | Token creation time |

## Relationships

- `User` 1 → `VerificationToken` 0..1 (one-time verification)
- `VerificationToken.user_id` references `User.id` with CASCADE DELETE

## Key Indices

- `users.email` - UNIQUE for duplicate check
- `users.username` - UNIQUE for duplicate check  
- `verification_tokens.token` - UNIQUE for verification lookup
- `verification_tokens.user_id` - INDEX for cleanup queries

## Validation Rules (from requirements)

- `username`: 3-50 chars, alphanumeric + underscore only
- `email`: Valid email format (RFC 5322)
- `password`: 8+ chars, at least 1 number

## State Transitions

### User Status

```
UNVERIFIED (email_verified=false) 
    ↓ (email verified)
VERIFIED (email_verified=true)
    ↓ (account deleted)
DELETED (deleted_at set)
```