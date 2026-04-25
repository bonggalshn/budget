# API Contracts: Authentication

**Feature Branch**: 001-user-login  
**Date**: 2026-04-25

## API Contract: Authentication Service

### Base URL
`/api/v1/auth`

### Headers
- `Content-Type: application/json`
- `Authorization: Bearer <token>` (for protected endpoints)

---

## POST /api/v1/auth/login

Authenticate a user with username/email and password.

### Request

**Endpoint**: `POST /api/v1/auth/login`

**Headers**:
- `Content-Type: application/json`

**Body**:
```json
{
  "identifier": "alice",
  "password": "securepass123"
}
```

**Fields**:
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| identifier | string | Yes | Username or email address |
| password | string | Yes | User's password |

### Success Response

**Status**: `200 OK`

**Body**:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_at": "2026-04-26T12:42:00Z",
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "username": "alice",
    "email": "alice@example.com",
    "created_at": "2026-01-01T00:00:00Z"
  }
}
```

### Error Responses

**Status**: `400 Bad Request` (missing/invalid fields)
```json
{
  "error_code": "invalid_request",
  "message": "Missing required field: identifier"
}
```

**Status**: `401 Unauthorized` (invalid credentials)
```json
{
  "error_code": "invalid_credentials",
  "message": "Invalid username/email or password"
}
```

**Status**: `429 Too Many Requests` (account locked)
```json
{
  "error_code": "account_locked",
  "message": "Account temporarily locked. Try again in 15 minutes."
}
```

**Status**: `503 Service Unavailable` (DB unavailable)
```json
{
  "error_code": "service_unavailable",
  "message": "Service temporarily unavailable. Please try again."
}
```

---

## GET /api/v1/auth/me

Retrieve the current authenticated user's profile.

### Request

**Endpoint**: `GET /api/v1/auth/me`

**Headers**:
- `Authorization: Bearer <token>`

### Success Response

**Status**: `200 OK`

**Body**:
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "username": "alice",
  "email": "alice@example.com",
  "created_at": "2026-01-01T00:00:00Z"
}
```

### Error Responses

**Status**: `401 Unauthorized` (missing/invalid token)
```json
{
  "error_code": "unauthorized",
  "message": "Missing or invalid authorization header"
}
```

```json
{
  "error_code": "session_expired",
  "message": "Session expired. Please log in again."
}
```

---

## POST /api/v1/auth/logout

Invalidate the current session token.

### Request

**Endpoint**: `POST /api/v1/auth/logout`

**Headers**:
- `Authorization: Bearer <token>`

### Success Response

**Status**: `200 OK`

**Body**:
```json
{
  "message": "Logged out successfully"
}
```

### Error Responses

**Status**: `401 Unauthorized`
```json
{
  "error_code": "unauthorized",
  "message": "Missing or invalid authorization header"
}
```

---

## Rate Limiting Headers

All auth API responses include standard rate limit headers:

| Header | Description |
|--------|------------|
| X-RateLimit-Limit | Maximum requests per window |
| X-RateLimit-Remaining | Requests remaining |
| X-RateLimit-Reset | Unix timestamp when window resets |

When rate limited:
- **Status**: `429 Too Many Requests`
- **Header**: `Retry-After: <seconds>`

---

## Error Code Reference

| Code | HTTP Status | Description |
|------|------------|-------------|
| invalid_request | 400 | Malformed request or missing fields |
| invalid_credentials | 401 | Wrong username/email or password |
| account_locked | 429 | Too many failed attempts |
| unauthorized | 401 | Missing or invalid token |
| session_expired | 401 | Token has expired |
| service_unavailable | 503 | Database or service unavailable |