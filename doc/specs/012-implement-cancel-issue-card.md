## As Client 

### 12. Cancel an already issued card
**Requirements**
- Client can cancel a card they own (`cards.client_id` matches authenticated client) that is currently `issued`.
- Cancelling an already-cancelled card is no-op.
- Cancellation sets `status = cancelled` and is recorded in `audit_logs`.

**Scenarios**
- Given a client owns a card with status `issued`, when they submit a cancel request, then the card's status changes to `cancelled`.
- Given a client attempts to cancel a card that is already `cancelled`, when they submit the request, then it is rejected with a validation error (no state change).
- Given a client attempts to cancel a card belonging to another client, when they submit the request, then it is rejected with a 403/404.
- Given a card is cancelled, when the audit log is checked, then an entry exists recording who cancelled it and when.