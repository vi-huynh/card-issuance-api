## As Admin

### 3. Add, update, and delete products from brands (up to 5 custom data fields)
**Requirements**
- Admin can create a product under a brand with core fields: `name` (required), `price` (required, numeric > 0), `status`.
- Admin can update any product field, including custom fields.
- Admin can delete a product only if it has no issued cards referencing it (per `products.brand_id [delete: restrict]` and `cards.product_id [delete: restrict]` in the ERD) — deletion should be blocked or the product should be soft-deleted/deactivated instead.
- All create/update/delete actions are recorded in `audit_logs` with `auditable_type = "Product"`.

**Scenarios**
- Given an admin selects an existing brand, when they create a product with a name, price, and up to 5 custom fields, then the product is created and linked to that brand.
- Given an admin attempts to create a product with a negative or zero price, when they submit the form, then the request is rejected with a validation error.
- Given an admin updates a product's price or custom field, when they save the change, then the product reflects the new values and the audit log records the diff.
- Given a product has one or more issued cards, when an admin attempts to delete it, then the deletion is rejected (or the product is deactivated instead of hard-deleted) to preserve referential integrity.
- Given a product has no issued cards, when an admin deletes it, then the product is removed (or archived) and no longer appears in the client catalog.

---