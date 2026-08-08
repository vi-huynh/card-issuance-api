## As Admin

### 2. Create brand (up to 5 custom data fields)
**Requirements**
- Admin can create a brand with core fields (name, contact_email, description, logo_url)
- Action is recorded in `audit_logs` with `auditable_type = "Brand"` and `action = "create"`

**Scenarios**
- Given an admin provides a valid brand name and up to 5 custom fields, when they submit the create-brand form, then a new brand is created and appears in the brand list.
- Given an admin submits a brand name that already exists, when they submit the form, then the request is rejected with a "name already taken" validation error.
- Given a brand is created successfully, when an admin checks the audit log, then an entry exists showing who created the brand and what values were set.