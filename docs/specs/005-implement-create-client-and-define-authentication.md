## As Admin

### 5. Add client, define authentication and payout rate
**Requirements**
- Admin creates a client, which is backed by a `users` record (role: client) and a `clients` record (`name`, `payout_rate`, `status`).
- Admin  define authentication credentials by  invite-based signup via `invite_token`
- Admin sets `payout_rate` (numeric, 0–100%, validated to a sane range).
- Action recorded in `audit_logs`

**Scenarios**
- Given an admin provides a client name, email, and payout rate, when they submit the create-client form, then a new client user is created with invite_token, invite_token_expires_at and an invite email is sent.
- Given an admin sets a payout rate outside the valid range (e.g., negative or > 100%), when they submit the form, then the request is rejected with a validation error.
- Given a client accepts their invite and sets a password, when they log in, then system log invite_accepted_at
