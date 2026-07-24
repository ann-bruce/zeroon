# ZEROON Development Guide V1

## Technology Stack

### Mobile
Flutter 3.x
Riverpod
GoRouter
Dio

### Admin
React
Ant Design
Vite

### Backend
Java 21
Spring Boot 3.x
Spring Security
Spring AI
Spring Data JPA
Gradle

### Database
PostgreSQL 16
Redis 7

### Deployment
Docker
Docker Compose
Nginx
GitHub Actions

---

## Code Structure

backend/

src/main/java/com/zeroon

├── user
├── state
├── record
├── companion
├── memory
├── admin
├── common
└── config

---

## Naming Rules

Class:
UserService

Method:
getCurrentState()

Variable:
currentState

Constant:
DEFAULT_STATE

---

## API Rules

Prefix:

/api/v1

Response:

Successful responses use the resource schema and HTTP status code.

Errors use RFC 9457-compatible `application/problem+json`.

The canonical contract is:

docs/04_API/OpenAPI_V1.yaml

---

## Database Rules

snake_case

Examples:

user_id
created_at
updated_at

---

## Git Rules

feature/*
release/*
hotfix/*

Commit:

feat:
fix:
docs:
refactor:
test:

---

## AI Rules

Prompt Version Controlled

All prompts stored in:

prompt_template

No hardcoded prompt in controller.

Companion provider calls use an orchestration boundary rather than a database
transaction. `CompanionTurnPersistenceService` commits the user message,
assembles current consent-aware context in a short read transaction, and later
persists the assistant message plus usage metadata in a short completion
transaction. `LlmProvider.generate` must observe no active Spring transaction.

AI usage metadata may contain provider/model, outcome, latency, prompt code and
version, character counts, optional provider-reported token counts, and a
bounded technical error code. It must never contain prompt, Profile, Memory,
record, user-message, assistant-reply, provider request, or exception body text.
Mobile-generated companion requests must not rebuild Zero Record state, goal,
or content. Record-derived context enters the provider only through the
server-side, consent-aware Memory path.

---

## Documentation Rules

Architecture changes require:

ER update
API update
Sprint update

---

## Code Review Rules

Required before merge:

Unit Test Pass
Code Review Pass
Build Pass

---

## Production Configuration Safety

### Email verification delivery

The first production authentication channel is email verification. Configure a
verified transactional sender through SMTP; do not place a mailbox login
password in deployment configuration. For a 163 mailbox, enable SMTP in the
mailbox client settings, create a dedicated client authorization code, and use:

```bash
ZEROON_SMTP_HOST=smtp.163.com
ZEROON_SMTP_PORT=465
ZEROON_SMTP_USERNAME=zeroon_ai@163.com
ZEROON_SMTP_PASSWORD=<163-client-authorization-code>
ZEROON_EMAIL_FROM=zeroon_ai@163.com
ZEROON_SMTP_SSL_ENABLED=true
ZEROON_SMTP_STARTTLS_ENABLED=false
ZEROON_SMS_ENABLED=false
```

The authorization code is a production secret. POP and IMAP are not required
for sending verification messages. Before opening registration, perform a
controlled delivery test to domestic and international inboxes and inspect spam
placement.

For a one-recipient, local-infrastructure delivery check only, start with
`SPRING_PROFILES_ACTIVE=smtp-smoke`. This profile uses the local PostgreSQL and
Redis instances with the real SMTP sender, secure random one-time codes, and
the same delivery failure behavior as production. It is intentionally not a
production profile and must never be used for public registration traffic.

Production starts with the `prod` profile:

```bash
SPRING_PROFILES_ACTIVE=prod java -jar zeroon-backend.jar
```

Before the application context is created, ZEROON rejects production startup
when any of the following are missing, too short, or still use a known
development/example value:

- `ZEROON_ACCESS_TOKEN_SECRET`: at least 32 characters;
- `POSTGRES_PASSWORD`: at least 12 characters;
- `REDIS_HOST`: a shared host rather than loopback;
- `REDIS_PASSWORD`: at least 12 non-placeholder characters;
- `ZEROON_SMTP_HOST`, `ZEROON_SMTP_USERNAME`, and
  `ZEROON_SMTP_PASSWORD`;
- `ZEROON_EMAIL_FROM`: the verified sender address;
- when `ZEROON_SMS_ENABLED=true` only,
  `ZEROON_VERIFICATION_CODE_SENDER_URL` and
  `ZEROON_VERIFICATION_CODE_SENDER_TOKEN`.

The validator reports only the environment variable name and never logs its
value. Local and test profiles retain the documented development defaults.

### Verification-code environment boundary

The default/local/test profile deliberately keeps the fixed `000000` code,
in-memory state, and code logging for developer convenience. None of those
beans are active under `prod`.

Production uses a cryptographically secure six-digit generator, Redis-backed
atomic one-time consumption, and the SMTP email sender. Email addresses,
source IPs, and stable per-install device identifiers are SHA-256 digested
before entering Redis keys; codes expire after 10 minutes and are deleted
after success or five failed attempts. SMTP connection, read, and write
timeouts default to 5, 10, and 10 seconds and can be overridden with the
corresponding `ZEROON_SMTP_*_TIMEOUT_MILLIS` variables.

Default abuse controls are:

- one code request per email address every 60 seconds;
- five code requests per email address per hour;
- twenty code requests per source IP per hour;
- ten login attempts per device per 15 minutes;
- thirty login attempts per source IP per 15 minutes.

The mobile client creates one random installation identifier in secure storage.
Production UI never pre-fills an email address or verification code. The
legacy mobile-number API is disabled unless `ZEROON_SMS_ENABLED=true`; there is
no SMS-provider dependency for the first closed Beta.

The API returns `429` with `Retry-After` when a limit is reached. Redis or
sender failures fail closed with `503`; the service never falls back to a
fixed code or process-local state in production.

Source-IP limits use the servlet remote address. If ZEROON runs behind a load
balancer, set `SERVER_FORWARD_HEADERS_STRATEGY=NATIVE` only after the edge has
removed untrusted forwarded headers and supplies a canonical client address.
Do not expose the application port directly when proxy headers are trusted.

Provider procurement remains an operational dependency: the configured sender
must accept an authenticated JSON `POST` containing `mobile` and `code`, and
return a 2xx response. Token values and verification codes must not be logged
by production infrastructure.

## Data Control

The implemented Beta export, deletion, retention, and logout semantics are
defined in `docs/05_Engineering/Data_Control_Lifecycle_V1.md`. OpenAPI must not
describe planned asynchronous deletion as an implemented response.

Closed support requests are purged automatically after 180 days. Local or
deployment configuration may set `ZEROON_SUPPORT_CLOSED_RETENTION_DAYS` and
`ZEROON_SUPPORT_RETENTION_CRON`; retention below one day is rejected. Tests may
use a shorter positive window and frequent cron only for isolated runtime
acceptance, followed by temporary-data cleanup.

Closed-Beta evidence ingestion is off unless
`ZEROON_EVIDENCE_INGESTION_ENABLED=true`. The server publishes and accepts only
the reviewed `ZEROON_EVIDENCE_NOTICE_VERSION` (default
`beta-evidence-v2`). `ZEROON_EVIDENCE_EVENT_HOURLY_LIMIT` bounds ingestion per
evidence subject. `ZEROON_EVIDENCE_RETENTION_DAYS` defaults to 180 and rejects
values below one or above 180; `ZEROON_EVIDENCE_RETENTION_CRON` controls the UTC
purge. Development, test, and synthetic acceptance environments must not point
at participant evidence storage.

The Flutter client generates a UUID per event, uses the fixed Asia/Shanghai
calendar date, and queues at most 50 content-free events in process for at most
seven days. It does not persist the queue or backfill while collection is off.
Only event-specific enums, booleans, bounded version/alias strings, and buckets
may be submitted. Callers must use the best-effort repository without awaiting
it as part of a primary-flow success condition. Invalid 4xx events are dropped;
network, `429`, and `5xx` failures remain bounded for a later in-process retry.

Companion responses expose content-free evidence metadata separately from the
reply: reviewed outcome, latency bucket, prompt-family version, provider-path
alias, and enabled Profile/Memory context-class names. Raw model ids, prompts,
private context, messages, and replies must not be copied into evidence events.

The reproducible cohort, activation, retention, reliability, and trust-control
formulas are fixed in
`docs/05_Engineering/Beta_Evidence_Cohort_Computation_V1.md`. Operators may
read them only through `GET /api/v1/admin/evidence/cohorts`. The server returns
an empty suppression envelope below five cohort subjects and independently
hides any derived non-zero group or event cell involving fewer than five
distinct subjects. Do not add subject lookup, event drill-down, or client-only
suppression.

## Memory V1

Memory source, ownership, activation, AI-use, expiry, and deletion semantics
are defined in `docs/02_Architecture/ADR_004_Memory_V1.md`. New memory writers
must enforce source ownership and idempotency transactionally. Saving a record
does not itself grant permission to send derived memory to an AI provider.
The S9-02 writer runs after record commit in an independent transaction and
uses bounded user-authored text only; it must not add an external provider call
to the record transaction.
Memory control changes use `PATCH /api/v1/memory/{memoryId}` and hard deletion
uses `DELETE /api/v1/memory/{memoryId}`. Both resolve the current owner before
mutation. A disabled entry is ineligible for AI context regardless of its
stored per-entry AI preference.
The mobile Memory management page is entered from Archive. It uses local card
feedback for mutations, preserves the source Zero Record on Memory deletion,
and exposes an editable AI-use switch only because companion context assembly
consumes that permission.
Companion AI requests assemble Memory through `MemoryAiContextAssembler`:
owned, enabled, AI-permitted, unexpired entries only; newest first; capped by
entry count and character length; source class and source id included;
no personality labels, diagnoses, or scores. Profile AI context consent remains
an independent gate for profile fields. Companion continuity must not append
raw recent Zero Record goal/content outside that Memory path, because Memory
summaries are derived from those fields and an unconditional record channel
would bypass pause, AI-permission, and deletion. When Memory is paused, the
mobile AI-use control may still store preference, but UI copy must state that
the entry will not enter the next response until it is re-enabled. Memory
titles and summaries must not appear in logs, AI usage metadata, or exception
messages.

---

## MVP Principle

Simple First

No over-engineering

Deliver before optimize
