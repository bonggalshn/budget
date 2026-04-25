# Quickstart: User Registration

## Prerequisites

- Go 1.23+
- PostgreSQL 14+
- Run migrations: `004_add_email_verification.sql` and `005_create_verification_tokens.sql`
- Running budget-be service

## API Endpoints

### Register New User

```bash
# Register with username, email, password
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "newuser",
    "email": "user@example.com",
    "password": "securepass123"
  }'
```

Response (201 Created):
```json
{
  "message": "Registration successful. Please verify your email.",
  "user_id": "550e8400-e29b-41d4-a716-446655440000"
}
```

Error responses (400):
```json
{"error_code": "invalid_request", "message": "Missing required field: username, email, or password"}
{"error_code": "invalid_email", "message": "Invalid email format"}
{"error_code": "weak_password", "message": "Password must be at least 8 characters with at least one number"}
{"error_code": "duplicate_email", "message": "Email already registered"}
{"error_code": "username_taken", "message": "Username already taken"}
```

### Verify Email

```bash
# Verify with token from database (verification_tokens table)
curl -X POST http://localhost:8080/api/v1/auth/verify \
  -H "Content-Type: application/json" \
  -d '{
    "token": "abc123verificationtoken"
  }'
```

Response (200 OK):
```json
{"message": "Email verified successfully"}
```

Error response (400):
```json
{"error_code": "invalid_token", "message": "Verification token invalid or expired"}
```

### Login (requires email verification)

```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "identifier": "newuser",
    "password": "securepass123"
  }'
```

Response (200 OK):
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "expires_at": "2026-04-27T12:00:00Z",
  "user": {...}
}
```

Error responses:
```json
{"error_code": "email_not_verified", "message": "Please verify your email before logging in"}
{"error_code": "invalid_credentials", "message": "Invalid username/email or password"}
```

## Request Schema

### Register Request

```json
{
  "username": "string (3-50 chars, alphanumeric + underscore)",
  "email": "string (valid email format)",
  "password": "string (8+ chars, at least 1 number)"
}
```

### Verify Request

```json
{
  "token": "string (from verification_tokens table)"
}
```

### Login Request

```json
{
  "identifier": "string (username or email)",
  "password": "string"
}
```

## Password Requirements

- Minimum 8 characters
- At least one number (0-9) required
- No special character requirement
- No case requirement

## Database Schema Changes

Two new migrations required:

1. `004_add_email_verification.sql` - Adds `email_verified` column to users table
2. `005_create_verification_tokens.sql` - Creates verification_tokens table

## Testing

Run all tests:
```bash
cd budget-be && go test ./...
```