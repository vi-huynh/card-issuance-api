## As Admin 

### 6. Set accessible products per client
**Requirements**
- Admin manages a client's product access list (`client_products` join table).
- Admin can grant/revoke access to individual products per client.
- A client can only see and issue cards for products they've been granted access to (and that are `active`).
- Duplicate grants are prevented (`(client_id, product_id)` unique constraint).
- Changes recorded in `audit_logs`.

**Scenarios**
- Given an admin selects a client and a set of products, when they grant access, then those products appear in the client's catalog.
- Given an admin revokes a client's access to a product, when the client next searches their catalog, then that product no longer appears and card issuance for it is rejected.
- Given an admin attempts to grant access to the same product twice for the same client, when they submit the request, then it is a no-op or returns a validation error (no duplicate record created).
- Given a product a client has access to is later deactivated, when the client views their catalog, then the product does not appear even though the access grant still exists.

---