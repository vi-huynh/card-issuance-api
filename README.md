# Card Issuance API

A Rails API for admin-managed brand/product catalogs and client-facing card issuance.

> **Status:** early scaffold. Routes are defined; models, controllers, and database schema are not yet implemented. See `doc/spec.md` and `doc/specs/` for the functional spec and per-feature implementation specs, and `doc/erd.dbml` for the target database design.

## Stack & Setup

- Ruby `3.2.2` (see `.ruby-version`)
- Rails API `7.2.3.2`
- Authentication: JWT (`jwt` gem)
- Database: PostgreSQL (`pg`, driven by `db/database.yml`)
- Pagination: Pagy
- Input validation: dry-validation (`app/schemas/inputs`)
- Unit tests: RSpec (`rspec-rails`, `factory_bot_rails`, `faker`, `database_cleaner`)
- Integration tests: RSpec request specs + `rspec-openapi` (generates OpenAPI schema from request specs into `app/schemas/outputs` / API doc)
- Static analysis: Brakeman (security), Rubocop Rails Omakase (style)
- Coverage: SimpleCov

### Local setup

```bash
bin/setup            # bundle install, db prepare
bin/rails server      # start the app on :3000
```

### Docker

```bash
docker compose up     # Postgres + Rails app on :3000
```

Production image is built via the multi-stage `Dockerfile` (Kamal-compatible); requires `RAILS_MASTER_KEY` at runtime.

### Tests & linting

```bash
bin/rails test         # RSpec via CI (see below) / bin/rspec locally
bin/rubocop             # style
bin/brakeman             # security scan
```

CI (`.github/workflows/ci.yml`) runs Brakeman, Rubocop, and the test suite against Postgres on every PR and push to `main`.

## API

Base path: `/v1`. See `doc/erd.dbml` for the underlying entities (`users`, `clients`, `brands`, `products`, `client_products`, `cards`, `audit_logs`).

- API doc: `<api-host>/api-doc` (generated OpenAPI schema)

### Auth

| Method | Path | Description |
|---|---|---|
| POST | `/api/v1/login` | Authenticate and receive a JWT |

### Admin (`/api/v1/admin`)

| Resource | Routes | Notes |
|---|---|---|
| `brands` | full CRUD | manage brand catalog |
| `products` | full CRUD | manage products under brands |
| `clients` | full CRUD | manage client accounts, auth, payout rate |
| `clients/:client_id/accessible_products` | index, create, destroy | grant/revoke client access to products |
| `reports` | index | reporting by brand/client |

### Client (`/api/v1/client`)

| Resource | Routes | Notes |
|---|---|---|
| `products` | index | search/filter accessible catalog |
| `cards` | create, destroy | issue / cancel a card |
| `reports` | index | spending + cancellation report |

## Project structure

```
app/
  controllers/api/   # namespaced admin & client controllers (to be implemented)
  models/            # ActiveRecord models (to be implemented)
  schemas/inputs/     # dry-validation request schemas
  schemas/outputs/    # rspec-openapi generated response schemas
  services/v1/         # business logic / service objects
doc/
  spec.md            # functional requirements & scenarios
  specs/             # one implementation spec per feature (numbered)
  erd.dbml            # database entity/relationship design
```

## Security

- Passwords hashed with bcrypt.
- Sensitive parameters (passwords, tokens, PINs) excluded from logs via `config/initializers/filter_parameter_logging.rb`.
- All significant admin/client actions are recorded to an append-only `audit_logs` table (who, what, when, diff, IP) for accountability.
