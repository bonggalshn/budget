# Quickstart: User Registration

## Prerequisites

- Go 1.23+
- PostgreSQL 14+
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

Response (201):
```json
{
  "message": "Registration successful. Please verify your email.",
  "user_id": "uuid"
}
```

Validation errors (400):
```json
{"error_code": "invalid_request", "message": "..."}
```

Duplicate errors (409):
```json
{"error_code": "duplicate", "message": "Email already registered"}
```

### Verify Email

```bash
# Verify with token from email
curl -X POST http://localhost:8080/api/v1/auth/verify \
  -H "Content-Type: application/json" \
  -d '{
    "token": "verification-token-from-email"
  }'
```

Response (200):
```json
{"message": "Email verified successfully"}
```

Invalid/expired token (400):
```json
{"error_code": "invalid_token", "message": "Verification token invalid or expired"}
```

## Request Schema

### Register Request

```json
{
  "username": "string (3-50 chars, a-z0-9_)",
  "email": "string (valid email)",
  "password": "string (8+ chars, 1+ number)"
}
```

### Verify Request

```json
{
  "token": "string (from verification email)"
}
```

## Password Requirements

- Minimum 8 characters
- At least one number required
- No special character requirement

## Testing

Run existing tests:
```bash
cd budget-be && go test ./...
```