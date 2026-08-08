## As Client

### 9. Authentication of each operation
**Requirements**
- Every client-facing API operation requires a valid authenticated session/token.
- Expired or invalid tokens are rejected with 401; the client is not authenticated implicitly by a prior request.
- Client actions are scoped to their own `client_id` — no access to other clients' data.

**Scenarios**
- Given a client has a valid session token, when they call any catalog/card/report endpoint, then the request succeeds and returns only their own data.
- Given a client's session token has expired, when they attempt any operation, then the request is rejected with a 401 and they must re-authenticate.
- Given client A is authenticated, when they attempt to access client B's cards or reports by manipulating an ID, then the request is rejected with a 403.