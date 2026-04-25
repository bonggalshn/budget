# API Contracts: Authentication

> **Note**: Base URL is `/api/v1/auth`

## POST /api/v1/auth/login

**Description**: Authenticate user with username or email

### Request

```json
{
  "identifier": "johndoe or john@example.com",
  "password": "password123"
}
```

### Response (200 OK)

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_at": "2026-04-27T00:00:00Z",
  "user": {
    "id": "uuid",
    "username": "johndoe",
    "email": "john@example.com",
    "created_at": "2026-04-26T00:00:00Z"
  }
}
```

### Errors

| Code | HTTP Status | Message |
|------|-------------|---------|
| `invalid_credentials` | 401 | Invalid username/email or password |
| `account_locked` | 429 | Account temporarily locked. Try again in 15 minutes. |
| `email_not_verified` | 403 | Please verify your email before logging in |

---

## POST /api/v1/auth/register

**Description**: Create new user account

### Request

```json
{
  "username": "johndoe",
  "email": "john@example.com",
  "password": "password123"
}
```

### Validation Rules
- **username**: Required, must be unique
- **email**: Required, must be valid format, must be unique
- **password**: Required, minimum 8 characters with at least one number

### Response (201 Created)

```json
{
  "message": "Registration successful. Please verify your email.",
  "user_id": "uuid"
}
```

> **Note**: Registration does NOT return a token. User must verify email first, then login to get token.

### Errors

| Code | HTTP Status | Message |
|------|-------------|---------|
| `duplicate_email` | 409 | Email already registered |
| `username_taken` | 409 | Username already taken |
| `invalid_email` | 400 | Invalid email format |
| `weak_password` | 400 | Password must be at least 8 characters with at least one number |

---

## POST /api/v1/auth/verify

> **Note**: This endpoint is part of a separate email verification feature journey. Included here for reference only.

**Description**: Verify user email address

### Request

```json
{
  "token": "verification-token-from-email"
}
```

### Response (200 OK)

```json
{
  "message": "Email verified successfully"
}
```

### Errors

| Code | HTTP Status | Message |
|------|-------------|---------|
| `invalid_token` | 400 | Verification token invalid or expired |

---

## POST /api/v1/auth/logout

**Description**: Terminate user session

### Request Headers

```
Authorization: Bearer <token>
```

### Response (200 OK)

```json
{
  "message": "Logged out successfully"
}
```

### Errors

| Code | HTTP Status | Message |
|------|-------------|---------|
| `unauthorized` | 401 | Missing or invalid authorization header |

---

## GET /api/v1/auth/me

**Description**: Get current authenticated user

### Request Headers

```
Authorization: Bearer <token>
```

### Response (200 OK)

```json
{
  "id": "uuid",
  "username": "johndoe",
  "email": "john@example.com",
  "created_at": "2026-04-26T00:00:00Z"
}
```

### Errors

| Code | HTTP Status | Message |
|------|-------------|---------|
| `unauthorized` | 401 | Missing or invalid authorization header |

---

## Error Response Format

All error responses follow this structure:

```json
{
  "error_code": "ERROR_CODE",
  "message": "Human readable message"
}
```