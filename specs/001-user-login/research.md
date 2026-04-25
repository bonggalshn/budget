# Research: User Login with Basic Authentication

**Feature Branch**: 001-user-login  
**Date**: 2026-04-25  
**Research Phase**: Phase 0 - Completed

## Decisions Made

### JWT Library Selection

**Decision**: Use `golang-jwt/jwt/v5`

**Rationale**:
- Most popular Go JWT library (9,000+ stars on GitHub)
- Active maintenance with regular security updates
- Clean, stable API with semantic versioning
- Well-documented with many integrations (Gin, Echo, Chi)
- Supports all standard signing algorithms
- MIT Licensed

**Alternatives Considered**:
- `lestrrat-go/jwx/v3` - Full JOSE support, but heavier/complex
- `cristalhq/jwt/v5` - Lightweight, but fewer features

### Rate Limiting Implementation

**Decision**: Use `go-chi/httprate` for chi-based routing

**Rationale**:
- Minimal dependencies
- Supports sliding window counter algorithm
- Built-in IP-based limiting
- Redis support for distributed deployments
- Properly implements RFC rate limit headers

**Alternatives Considered**:
- `krishna-kudari/ratelimit` - More algorithms, similar API
- Custom middleware - More control but requires more code

### Authentication Best Practices

**Decision**: Follow established JWT patterns

**Rationale**:
- Access tokens: 24-hour expiry (per spec requirement)
- Include unique ID (`jti`) for token revocation
- Use timing-safe password comparison
- Implement explicit algorithm verification
- Separate secrets for different token types (future consideration)

**Key Patterns**:
1. Token generated with user_id, email in claims
2. Short expiry + refresh token pattern (spec uses 24h, acceptable)
3. Rate limiting: 10 attempts/IP/min, 5 attempts/username/15min
4. Account lockout after 5 failed attempts in 15 minutes

## Technical Decisions Summary

| Area | Decision | Notes |
|------|----------|-------|
| JWT Library | golang-jwt/jwt/v5 | Most popular, well-maintained |
| Rate Limiting | go-chi/httprate or custom | Depends on HTTP router choice |
| Token Expiry | 24 hours | Per spec requirement |
| Password Hashing | bcrypt cost ≥12 | Constitution requirement |
| Session Storage | PostgreSQL | Per spec assumptions |
| Timing Attack Prevention | crypto/subtle.ConstantTimeCompare | Standard Go library |

## Implementation Notes

### JWT Implementation
- Claims struct includes UserID, Email, Role + RegisteredClaims
- Token signed with HMAC-SHA256 (HS256) for single-service deployment
- Include `jti` claim for token revocation support

### Rate Limiting Implementation
- Per-IP: 10 attempts per minute
- Per-username: 5 attempts per 15 minutes
- Sliding window counter algorithm
- Return standard headers: X-RateLimit-*, Retry-After

### Session Management
- JWT stored in database (token_hash for revocation)
- Track creation time, expiry, last activity
- Logout invalidates by marking invalidated_at

## Constitution Alignment Check

| Principle | Status | Notes |
|-----------|--------|-------|
| Testing (TDD) | Required | Must write tests first |
| gofmt/golangci-lint | Required | All code must pass |
| Password security | PASS | bcrypt cost ≥12 per spec |
| No password logging | Required | Must audit implementation |
| Timing-safe comparison | PASS | Using crypto/subtle |