## Design System

### Architecture
- Project structure: Rails 7.x API-only, namespaced `api/v1/{admin,client}`
.
├── Dockerfile              # Build config for the app image (used together with docker-compose.yml)
├── Gemfile / Gemfile.lock  # Gem dependencies and their locked versions
├── README.md
├── Rakefile                # Entry point for rake tasks

├── app
│   ├── channels/           # ActionCable — real-time/websocket features (e.g. live notifications)
│   │
│   ├── controllers/
│   │   ├── api/v1/         # API versioning namespace — lets you add v2 later without breaking v1 clients
│   │   │   ├── admin/      # Controllers for the admin/back-office side (manage cards, users, audit logs...)
│   │   │   └── client/     # Controllers for the client/merchant side (issue cards, view cards...)
│   │   ├── application_controller.rb  # Base controller: auth, exception handling, current_user, etc.
│   │   └── concerns/       # Shared modules across controllers (e.g. Authenticatable, Paginatable)
│   │
│   ├── jobs/                # Background jobs (Sidekiq/ActiveJob) — e.g. sending invite emails, retraining jobs
│   │
│   ├── mailers/             # Mail logic — e.g. invite link emails, notification emails
│   │
│   ├── models/
│   │   ├── application_record.rb
│   │   └── concerns/        # Shared modules across models — this is where your Auditable concern belongs
│   │
│   ├── schemas/              # Validation logic decoupled from models — contract-first style
│   │   ├── inputs/           # Request param validation (commonly dry-validation / dry-schema)
│   │   └── outputs/          # Response shape definitions (acts as a substitute for traditional serializers)
│   │
│   ├── services/              # Actual business logic lives here (Service Object pattern)
│   │   └── v1/
│   │       ├── admin/         # Services for admin operations (e.g. RevokeCardService)
│   │       └── client/        # Services for client operations (e.g. IssueCardService)
│   │
│   └── views/
│       └── layouts/           # Used only for mailer views (since this is an API-only app, no regular HTML views)

├── bin/                        # Executable scripts (rails, rake, rubocop, brakeman, docker-entrypoint...)

├── config/
│   ├── application.rb          # Main app config (middleware, autoload paths, timezone, etc.)
│   ├── credentials.yml.enc + master.key  # Encrypted secrets (NEVER commit master.key)
│   ├── database.yml
│   ├── environments/            # Environment-specific config for dev/test/production
│   ├── initializers/
│   │   ├── cors.rb              # CORS configuration — important since this API serves a separate frontend
│   │   ├── filter_parameter_logging.rb  # Hides sensitive fields (password, token...) from logs
│   │   └── inflections.rb
│   ├── routes.rb
│   └── puma.rb

├── db/
│   ├── schema.rb
│   └── seeds.rb

├── docs/
│   ├── erd.dbml                 # Entity-Relationship Diagram in DBML format (easy to render as a diagram)
│   ├── spec.md                  # High-level system specification
│   └── specs/                   # Likely detailed specs, following Spec-Driven Development

├── lib/tasks/                   # Custom rake tasks

├── spec/
│   ├── integration/              # Integration tests — test full request/response flows (request specs)
│   └── services/                 # Unit tests — test individual Service Objects

├── storage/                      # ActiveStorage local files (usually empty if using S3 instead)
└── vendor/                       # Vendored gems (usually empty unless gems are vendored locally)

- Authentication: JWT (custom service) + invite-link account activation
  (Admin never sets Client passwords — see README)
- Authorization: Pundit, policy-per-resource, scoped by role
- Input validation: dry-validation as request
- Serialization: jsonapi-serializer (JSON:API response format)
- Audit logging: Auditable concern, auto-logs create/update/destroy + login events

### Testing
- Unit test: RSpec + FactoryBot (models, services...)
- Integration test: RSpec request specs + rspec-openapi (auto-generates OpenAPI doc from specs)
- Coverage target: every controller action — success, action - failed

### Gems
- jwt — token encode/decode
- pagy — pagination on all index/report endpoints
- pundit — authorization
- dry-validations

### Data Design
- Design ERD (Brand, Product, Client, ClientProduct, Card, User, AuditLog)
- Migration scripts — every FK + NOT NULL + CHECK constraint at DB level
- ActiveRecord models:
  - Associations (belongs_to/has_many)
  - Enums (status: active/inactive; role: admin/client)
  - Scopes (search, active_and_brand_active, in_range)
  - Shared concerns (Auditable)
- Seed data (db/seeds.rb) — sample admin, brand, product, client for local dev