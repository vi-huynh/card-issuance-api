## As Admin 

### 7. Log all user actions (audit logging)
**Requirements**
- Every create/update/delete/state-change action by any authenticated user (admin or client) is logged to `audit_logs`: `user_id`, `action`, `auditable_type`, `auditable_id`, `changes` (diff), `ip_address`, `created_at`.
- Covers: brand/product/client CRUD, status changes, authentication events (login success/failure), card issuance/cancellation.
- Logs are immutable (no update/delete endpoint exposed) and queryable/filterable by admin.

**Scenarios**
- Given any authenticated user performs a create, update, delete, or status-change action, when the action completes, then a corresponding audit log entry is created with the correct `auditable_type`/`auditable_id` and a diff of changed fields.
- Given an admin filters the audit log by user, date range, or entity type, when they run the search, then only matching entries are returned.
- Given an audit log entry exists, when any user (including admin) attempts to modify or delete it via the API, then the request is rejected.
- Given a login attempt (successful or failed) occurs, when an admin views the audit log, then the attempt is recorded with the associated user (if identifiable) and IP address.