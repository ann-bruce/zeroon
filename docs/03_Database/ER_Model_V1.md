# ER Model V1

The canonical executable schema is `Init_SQL_V1.sql`.

## Identity

- `users`: profile, current state, lifecycle status
- `user_roles`: `USER` and `ADMIN` authorization
- `refresh_sessions`: hashed rotating refresh tokens by device

## Product Data

- `state_history`: immutable state transitions
- `zero_records`: private user records
- `conversations`: user-owned AI conversations
- `messages`: ordered user, assistant, and system messages
- `memory_entries`: derived long-term memory summaries

## Operations

- `prompt_templates`: immutable prompt versions
- `system_configs`: runtime configuration
- `audit_events`: authentication and admin mutation audit trail

## Relationships

```text
users
├── user_roles
├── refresh_sessions
├── state_history
├── zero_records
├── conversations
│   └── messages
├── memory_entries
└── audit_events (actor, nullable)
```

All private product tables delete with their owning user. Operational audit
records preserve the event while nulling a deleted actor reference.

## Query Baseline

- User-owned timeline indexes begin with `user_id`.
- Conversation messages are indexed by `conversation_id, created_at`.
- List APIs sort newest-first and use bounded pagination.
- Cross-user reads are forbidden outside reviewed admin services.

