# Research: Home Page Authentication

## API Contract Alignment

After analyzing the backend implementation, the following corrections were made:

| Item | Backend Reality | Initial Contract |
|------|----------------|------------------|
| Login field | `identifier` (username OR email) | `email` |
| Register response | `{message, user_id}` (no token!) | Included token |
| Register fields | `username, email, password` | `name, email, password` |
| `/me` response | Direct fields (no wrapper) | Wrapped in `data.user` |
| Error format | `error_code` | `code` |

## Email Verification Required

The backend implements email verification:
- Registration returns NO token (user must verify email first)
- Login fails with `email_not_verified` if email not verified
- `/verify` endpoint accepts verification token from email link

**User Flow**: Register → Check email → Click verification link → Login

## Authentication Strategy

**Decision**: JWT tokens with React Context

**Rationale**:
- Stateless authentication scales well
- JWT can be validated client-side without API calls
- React Context provides singleton auth state
- localStorage persists across page refreshes

**Alternatives considered**:
- Session cookies: Requires SameSite=Strict, backend changes
- Server-side sessions: More complex, not REST-friendly

## Routing Architecture

**Decision**: React Router v6 with ProtectedRoute wrapper

**Rationale**:
- Standard SPA pattern
- Easy integration with Context
- Declarative route protection

**Alternatives considered**:
- External router library: Added dependency, no benefit
- Custom navigation: More code, less maintainable

## Form Handling

**Decision**: React Hook Form + Zod validation

**Rationale**:
- Type-safe validation schemas
- Minimal re-renders
- Used in project technology stack

**Alternatives considered**:
- Native HTML validation: Not type-safe
- Yup: Zod is more modern, better TypeScript support

## State Management

**Decision**: React Context API for auth state

**Rationale**:
- Built into React, no extra dependencies
- Sufficient for auth state (simple key-value)
- Used in project constitution

**Alternatives considered**:
- Zustand: Overkill for single auth state
- Redux: Heavy, not justified for auth-only state

## Error Handling

**Decision**: Component-level error states + React Error Boundary

**Rationale**:
- Per-form error display for validation
- Error Boundary for component crashes
- Console logging for debugging

## Performance Targets

| Metric | Target | Justification |
|--------|--------|--------------|
| LCP | < 2.5s | Core Web Vitals |
| FID | < 100ms | Core Web Vitals |
| Login completion | < 30s | User expectation |
| Register completion | < 60s | User expectation |
| Navigation | < 1s | Per constitution |

## Accessibility Requirements

- Keyboard navigation support
- ARIA labels on interactive elements
- Focus management on page transitions
- Color contrast WCAG 2.1 AA compliant
- Screen reader announcements for errors