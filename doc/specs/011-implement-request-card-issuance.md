## As Client 

### 11. Request card issuance (activation number + optional pin)
**Requirements**
- Client submits a request to issue a card for a specific product they have access to.
- System validates: client has access to the product, product is `active`.
- System generates a unique `activation_number`, optionally a `pin`, sets `status = issued`, `amount`/`current_balance` from the product price, and stores `purchase_details`.
- Action recorded in `audit_logs`.

**Scenarios**
- Given a client has access to an active product, when they request card issuance, then a card is created with a unique activation number, status `issued`, and the response includes activation number, optional pin, and purchase details.
- Given a client requests issuance for a product they do not have access to, when the request is submitted, then it is rejected with a 403.
- Given a client requests issuance for an inactive product , when the request is submitted, then it is rejected with a "product not available" error.
- Given a card issuance succeeds, when the audit log is checked, then an entry exists recording the issuance with client, product, and card reference.
