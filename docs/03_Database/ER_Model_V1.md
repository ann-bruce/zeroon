# ER Model V1

`Init_SQL_V1.sql` is the original baseline. Flyway migrations under
`backend/src/main/resources/db/migration/` are the canonical executable schema
evolution.

## Identity

- `users`: identity, current state, lifecycle status, and explicit
  `language_preference` (`FOLLOW_SYSTEM`, `ZH_CN`, or `EN`)
- `user_roles`: `USER` and `ADMIN` authorization
- `refresh_sessions`: hashed rotating refresh tokens by device

## Product Data

- `state_history`: immutable state transitions
- `zero_records`: private user records
- `conversations`: user-owned AI conversations
- `messages`: ordered user, assistant, and system messages
- `memory_entries`: derived long-term memory summaries
- `support_requests`: private owner-scoped requests with opaque public
  references, status, bounded diagnostics, and idempotent client submission id
- `support_messages`: explicitly user-visible or internal human support text
- `support_status_history`: immutable user-visible lifecycle transitions
- `support_admin_audit`: content-free administrator mutation evidence scoped
  to one support request

## Operations

- `prompt_templates`: immutable prompt versions
- `ai_usage_logs`: provider outcome, latency, prompt version, character counts,
  and optional provider-reported token counts without prompt or response text
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
├── support_requests
│   ├── support_messages
│   ├── support_status_history
│   └── support_admin_audit
└── audit_events (actor, nullable)
```

All private product tables delete with their owning user. Operational audit
records preserve the event while nulling a deleted actor reference.

`language_preference` is an account interaction preference introduced by V11.
It is not stored in `user_profiles`, does not grant AI context consent, and is
removed with the user row.

V12 introduces the support-request foundation. Public references contain no
database or user id, ownership queries begin with the authenticated user, and
all support rows hard-delete with the owner. Internal notes and future admin
audit remain distinct from user-visible DTOs and exports.

V13 adds nullable administrator assignment, reviewed escalation state, and a
request-cascading admin audit. Deleting an administrator nulls assignment and
audit actor references; deleting the request owner removes the request,
messages, history, and support audit together. Audit values are bounded
structured transition metadata and never copy request or message bodies.

## Query Baseline

- User-owned timeline indexes begin with `user_id`.
- Conversation messages are indexed by `conversation_id, created_at`.
- List APIs sort newest-first and use bounded pagination.
- Cross-user reads are forbidden outside reviewed admin services.
