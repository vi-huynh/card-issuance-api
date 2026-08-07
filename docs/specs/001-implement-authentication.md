## As Admin

### 1. Log in and sign in with email
**Requirements**
- Admin authenticates using email + password.
- Invalid credentials return a generic error (no user enumeration).
- Failed login attempts are rate-limited / lockable.
- Successful and failed logins are recorded in `audit_logs`.

**Scenarios**
- Given an admin with a valid email and password, when they submit the login form, then they receive a valid JWT token 
- Given an admin submits a correct email with an incorrect password, when they attempt login, then the request is rejected with a generic "invalid credentials" message and no session is created.
- Given an admin submits an email that does not exist, when they attempt login, then the request is rejected with a generic "invalid credentials" message and no session is created.
- Given an admin exceeds the allowed number of failed login attempts, when they try again immediately, then the account/IP is temporarily locked out.

