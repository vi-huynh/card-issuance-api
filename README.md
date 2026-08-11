# Card Issuance API

A Rails API for admin-managed brand/product catalogs and client-facing card issuance.

See `doc/spec.md` and `doc/specs/` for the functional spec and per-feature implementation specs, and `doc/erd.dbml` for the database design.

## Stack & Setup

- Ruby `3.2.2` (see `.ruby-version`)
- Rails API `7.2.3.2`
- Authentication: JWT (`jwt` gem)
- Database: PostgreSQL (`pg`, driven by `config/database.yml`)
- Env vars: `.env` (`dotenv-rails` loads it in dev/test, both locally and in Docker)
- Pagination: Pagy
- Input validation: dry-validation (`app/validators`)
- Unit tests: RSpec (`rspec-rails`, `factory_bot_rails`, `faker`, `database_cleaner`)
- Integration tests: RSpec request specs + `rspec-openapi` (generates OpenAPI schema from request specs)
- Static analysis: Brakeman (security), Rubocop Rails Omakase (style)
- Coverage: SimpleCov

### Local setup (without Docker)

Requires a local PostgreSQL install (e.g. `brew install postgresql@16 && brew services start postgresql@16`).

1. Create a `postgres` superuser role matching the default credentials in `.env` (skip if you already have a role you'd rather use):
   ```bash
   psql -d postgres -c "CREATE ROLE postgres WITH LOGIN SUPERUSER PASSWORD 'password';"
   ```

2. Set local env
   ```bash
    cp .env.example .env

    -- Update POSTGRES_HOST
    POSTGRES_HOST=localhost
   ```
3. Install and boot:
   ```bash
   bin/setup            # bundle install, db prepare
   bin/rails server      # start the app on :3000
   ```

### Local setup with Docker

Requires docker install 

1. Set local env
  ```bash
    cp .env.example .env
  ```
2. Build docker image 
  ```bash
    docker compose build    # Postgres + Rails app on :3000
  ```
3. Start app  
```bash
  docker compose up 
```

Production image is built via the multi-stage `Dockerfile` (Kamal-compatible); requires `RAILS_MASTER_KEY` at runtime.

### Tests & linting

- Local without (docker) 
```bash
bin/rails db:test:prepare spec          # RSpec via CI (see below) / bin/rspec locally
bin/rubocop                             # style
bin/brakeman                            # security scan
```

- Run with docker 
```bash
docker compose run web bin/rails db:test:prepare spec         # RSpec via CI (see below) / bin/rspec locally
docker compose run web bin/rubocop                                                   # style
docker compose run web bin/brakeman                                                  # security scan
```

CI (`.github/workflows/ci.yml`) runs Brakeman, Rubocop, and the test suite against Postgres on every PR and push to `main`.

## API

Base path: `/v1`. See `doc/erd.dbml` for the underlying entities (`users`, `clients`, `brands`, `products`, `client_products`, `cards`, `audit_logs`).

- API doc: `<api-host>/api-docs` (generated OpenAPI schema)

## Project structure

```
app/
  controllers/v1/     # namespaced admin & client controllers
  models/              # ActiveRecord models
  validators/v1/       # dry-validation request validators
  services/v1/         # business logic / service objects
  serializers/v1/      # ActiveModel::Serializer response shapes
doc/
  spec.md            # functional requirements & scenarios
  specs/             # one implementation spec per feature (numbered)
  erd.dbml            # database entity/relationship design
```

## Security

- Passwords hashed with bcrypt.
- Sensitive parameters (passwords, tokens, PINs) excluded from logs via `config/initializers/filter_parameter_logging.rb`.
- All significant admin/client actions are recorded to an append-only `audit_logs` table (who, what, when, diff, IP) for accountability.
