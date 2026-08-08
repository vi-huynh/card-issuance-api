## As Admin

### 4. Change brand and product state (active / inactive)
**Requirements**
- Admin can toggle a brand's and a product's status between `active` and `inactive`.
- Inactive products/brands are excluded from client catalog search/filter and card issuance.
- Status changes are recorded in `audit_logs`.

**Scenarios**
- Given an active product, when an admin sets it to `inactive`, then it no longer appears in any client's catalog search results.
- Given a client attempts to issue a card for a product that was just deactivated, when the issuance request is submitted, then it is rejected with a "product not available" error.
- Given a status change occurs, when an admin views the audit log, then the change (old status → new status, who made it, when) is recorded.