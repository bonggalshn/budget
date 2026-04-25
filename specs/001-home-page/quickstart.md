# Quickstart: Home Page Authentication

## Prerequisites

- Node.js 18+
- npm or yarn
- Backend API running at `http://localhost:8080`
- Frontend dev server will run at `http://localhost:5173`

## Setup

```bash
cd budget-fe
npm install
```

## Running

```bash
npm run dev
```

## Testing

```bash
npm run test
npm run test:watch
npm run test:coverage
```

## Key Files

| File | Purpose |
|------|---------|
| `src/pages/PublicHomePage.tsx` | Landing page for unauthenticated users |
| `src/pages/AuthenticatedHomePage.tsx` | Dashboard entry for logged-in users |
| `src/pages/LoginPage.tsx` | Login form |
| `src/pages/RegisterPage.tsx` | Registration form |
| `src/context/AuthContext.tsx` | Global authentication state |
| `src/App.tsx` | Route definitions and providers |

## API Endpoints Used

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/auth/register` | POST | Create new account (returns user_id, NOT token) |
| `/api/v1/auth/login` | POST | Authenticate (returns token + user info) |
| `/api/v1/auth/verify` | POST | Verify email (after clicking email link) |
| `/api/v1/auth/logout` | POST | End session |
| `/api/v1/auth/me` | GET | Get current user info |

## Environment Variables

```env
VITE_API_URL=http://localhost:8080
```

## User Flow

```
1. Visit app → PublicHomePage (Login/Register buttons)
2. Click Register → RegisterPage
3. Submit form → API creates account → Show "check email" message
4. Click verification link in email → Verify page → Show success
5. Click Login → LoginPage
6. Submit credentials → API validates → Store token
7. Redirect to AuthenticatedHomePage
8. Click Logout → Clear session → Return to PublicHomePage
```

## Verification Checklist

- [ ] Public home page displays at `/`
- [ ] Login navigates to `/login`
- [ ] Register navigates to `/register`
- [ ] Registration shows "check email" message (no auto-login)
- [ ] Successful login redirects to authenticated home
- [ ] Successful logout returns to public home
- [ ] Protected routes redirect unauthenticated users
- [ ] Form validation errors display correctly
- [ ] Loading states show during API calls
- [ ] Error messages are user-friendly
- [ ] Email verification flow works end-to-end