# Data Model: Home Page Authentication

## Frontend Types

```typescript
// User entity (from API)
interface User {
  id: string;
  username: string;
  email: string;
  created_at: string;
}

// Login request
interface LoginRequest {
  identifier: string;  // username or email
  password: string;
}

// Register request
interface RegisterRequest {
  username: string;
  email: string;
  password: string;
}

// Login response (success)
interface LoginResponse {
  token: string;
  expires_at: string;
  user: User;
}

// Register response (success)
interface RegisterResponse {
  message: string;
  user_id: string;
}

// Logout response (success)
interface LogoutResponse {
  message: string;
}

// API error response
interface ApiError {
  error_code: string;
  message: string;
}

// Form validation errors
interface ValidationErrors {
  [field: string]: string;
}
```

## Component Props

```typescript
// PublicHomePage
interface PublicHomePageProps {}

// AuthenticatedHomePage
interface AuthenticatedHomePageProps {}

// LoginPage
interface LoginPageProps {}

// RegisterPage
interface RegisterPageProps {}

// AuthForm (shared)
interface AuthFormProps {
  mode: 'login' | 'register';
  onSubmit: (data: LoginRequest | RegisterRequest) => void;
  isLoading: boolean;
  error: string | null;
}

// Button
interface ButtonProps {
  children: React.ReactNode;
  variant?: 'primary' | 'secondary';
  type?: 'button' | 'submit';
  disabled?: boolean;
  onClick?: () => void;
}

// Greeting
interface GreetingProps {
  username?: string;
  isAuthenticated: boolean;
}
```

## State Transitions

```mermaid
stateDiagram-v2
  [*] --> Unauthenticated: Initial load
  Unauthenticated --> Unauthenticated: View public home page
  Unauthenticated --> LoginPage: Click Login
  Unauthenticated --> RegisterPage: Click Register
  LoginPage --> Unauthenticated: Cancel
  RegisterPage --> Unauthenticated: Cancel
  Unauthenticated --> Authenticated: Login success
  Authenticated --> Unauthenticated: Logout
  Authenticated --> Authenticated: View home page
```

> **Note**: Email verification flow (Register → Verify → Login) is out of scope. Backend requires email verification before login.

## Data Flow

1. **User loads app** → Check localStorage for token → If token exists, call `/me` → Set AuthContext state
2. **User registers** → POST to `/register` → Show "check email" message (no auto-login)
3. **User logs in** → POST credentials to `/login` → Store token in localStorage → Update AuthContext → Navigate to authenticated home
4. **User logs out** → POST to `/logout` → Clear localStorage → Reset AuthContext → Navigate to public home

> **Important**: Email verification is required before login. Users must verify their email after registration. The `/verify` endpoint exists but is part of a separate feature journey.