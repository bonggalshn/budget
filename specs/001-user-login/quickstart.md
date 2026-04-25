# Quickstart: User Login Authentication

**Feature Branch**: 001-user-login  
**Date**: 2026-04-25

## Prerequisites

- Go 1.21+
- PostgreSQL 14+
- Budget database running

## Quick Setup

### 1. Environment Variables

```bash
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=budget
export DB_USER=budget_user
export DB_PASSWORD=your_password

export JWT_SECRET=your-256-bit-secret-key-at-least-32-chars!
export JWT_EXPIRY=24h
```

### 2. Run Migrations

```bash
cd migrations/auth
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f 001_create_users.sql
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f 002_create_sessions.sql
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f 003_create_login_attempts.sql
```

### 3. Start the Service

```bash
go run cmd/api/main.go
```

Server starts on `http://localhost:8080`

## API Usage

### Login

```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "identifier": "alice",
    "password": "securepass123"
  }'
```

**Response**:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "expires_at": "2026-04-26T12:42:00Z",
  "user": {
    "id": "...",
    "username": "alice",
    "email": "alice@example.com",
    "created_at": "2026-01-01T00:00:00Z"
  }
}
```

### Get Current User

```bash
curl http://localhost:8080/api/v1/auth/me \
  -H "Authorization: Bearer <token>"
```

### Logout

```bash
curl -X POST http://localhost:8080/api/v1/auth/logout \
  -H "Authorization: Bearer <token>"
```

## Test Users

Create a test user manually:

```sql
INSERT INTO users (username, email, password_hash)
VALUES (
  'alice',
  'alice@example.com',
  '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYIq8r5jQ7Ue'
);
```

The password hash is bcrypt of "securepass123" with cost 12.

## Project Structure

```
budget-be/
├── internal/
│   ├── auth/
│   │   ├── handler.go       # HTTP handlers
│   │   ├── service.go      # Business logic
│   │   └── model.go       # Domain models
│   ├── user/
│   ├── session/
│   ├── loginattempt/
│   └── db/
├── migrations/auth/
├── api/v1/auth/
└── cmd/api/main.go
```

## Commands

| Command | Description |
|---------|-------------|
| `go test ./...` | Run all tests |
| `go build ./cmd/api` | Build binary |
| `golangci-lint run` | Lint code |
| `go fmt ./...` | Format code |