# ADR 006 Support Request Policy and Lifecycle V1

Status: Accepted for engineering
Date: 2026-07-23

## Context

ZEROON stores private records and companion conversations. A user must be able
to reach the people responsible for the service when login, data control,
privacy, safety, or the product itself is not working. The companion is not a
support agent and support content must not become companion context.

Sprint 11 therefore needs one accountable support lifecycle before database,
API, mobile, and admin implementation starts. This decision covers the in-app
authenticated path and the packaged external fallback available before login
or during an API outage.

## Decision

ZEROON will provide private, human-operated support requests with durable
receipts and owned status history. It will also package one verified external
contact route that does not depend on authentication or the ZEROON API.

The external route must be an actually monitored HTTPS help page or email
address. A placeholder, unverified domain, public issue tracker, social account,
or AI chat endpoint is not an acceptable production fallback.

### Supported channels

| Channel | Availability | Receipt and status | Content boundary |
|---|---|---|---|
| Authenticated in-app request | Signed in and API reachable | Durable opaque reference, status history, and user-visible operator replies | Only fields previewed and submitted by the user |
| Packaged external fallback | Before login and during API outage | Governed by the external channel; ZEROON must not claim in-app tracking | User composes the message outside the app; no automatic attachment |

Remote configuration may replace the packaged external value only with another
verified HTTPS or `mailto` destination. Missing, malformed, or empty remote
configuration falls back to the packaged value and can never hide the contact
entry.

The packaged fallback is `mailto:zeroon_ai@gmail.com`. Bruce Ann monitors this
mailbox for the closed Beta. It must be present in build-time configuration and
tested before S11-03 is complete.

### Categories and accountable roles

| Category | Primary handling role | Required escalation role |
|---|---|---|
| `PRODUCT_PROBLEM` | Beta Support Operator | Engineering Owner when reproduction or a product fix is needed |
| `SUGGESTION` | Product Owner | Beta Support Operator for acknowledgement and closure |
| `ACCOUNT_DATA_PRIVACY` | Privacy Owner | Engineering Owner for verified data-control execution |
| `AI_RESPONSE_SAFETY` | Safety Owner | Product Owner and Engineering Owner for boundary review |
| `COMPLAINT_RIGHTS` | Complaint Owner | Privacy Owner; professional review when legal rights are asserted |
| `OTHER` | Beta Support Operator | Reassign to the applicable owner after review |

Roles are authorization and routing responsibilities, not labels shown as a
promise to users. Bruce Ann is the accountable primary for all roles during the
closed Beta. `chao.fan` is the named backup, but mailbox and ADMIN access must
be tested before recruitment. Naming a backup does not establish continuous
coverage, so no response SLA may be shown. An unassigned request remains
visible in the queue and cannot be auto-closed.

### Status model

Supported user-visible states are:

- `RECEIVED`: durably stored but not yet taken for review;
- `IN_REVIEW`: assigned to or actively reviewed by a human operator;
- `WAITING_FOR_USER`: a visible operator reply asks for clarification;
- `REPLIED`: a human response has been provided and no clarification is
  currently required;
- `CLOSED`: handling has ended; the user may create a new request if needed.

Allowed transitions:

| From | To | Rule |
|---|---|---|
| `RECEIVED` | `IN_REVIEW`, `CLOSED` | Closing requires a user-visible reason |
| `IN_REVIEW` | `WAITING_FOR_USER`, `REPLIED`, `CLOSED` | A reply and transition are one audited admin operation |
| `WAITING_FOR_USER` | `IN_REVIEW`, `CLOSED` | A user follow-up returns the request to `IN_REVIEW` |
| `REPLIED` | `IN_REVIEW`, `CLOSED` | A user follow-up returns the request to `IN_REVIEW` |
| `CLOSED` | none | V1 does not reopen; a new concern creates a new request |

Creation is the only path into `RECEIVED`. Status cannot move backward through
arbitrary admin updates. Every transition records request identity, prior and
next state, authenticated actor, timestamp, and a bounded reason code. Internal
notes are separate records and never appear in user APIs.

### Human response and language

- Support copy uses direct human-service language, not ZEROON companion voice.
- The submission records the resolved interface locale as optional bounded
  diagnostics only when the user explicitly enables diagnostic sharing.
- Operators respond in the request's current user-selected reply language when
  supported. If unclear, they ask the user rather than infer identity,
  nationality, location, or preference from private text.
- Human-authored request and reply content is stored exactly as submitted. It
  is not automatically translated and is never sent to the companion model.
- Chinese and English templates may guide operators, but no AI-generated final
  reply, automatic complaint decision, or automatic closure ships in V1.

### Truthful service expectations

Successful in-app submission may say that ZEROON received the request and a
team member will review it. It must not say the issue is resolved, promise a
response deadline, or imply continuous monitoring.

The Beta does not publish an SLA until staffing and coverage are measured.
The UI may show the last status update time and whether the team is waiting for
the user. External email or web fallback must not claim an in-app reference or
status unless it actually creates one.

Support is not an emergency, medical, legal, financial, or psychological crisis
service. Safety and complaint submissions remain accepted, but boundary copy
must direct immediate danger to appropriate local emergency resources without
diagnosing, scoring risk, or silently escalating private content.

## Data Contract Boundary

### User-submitted fields

The first request contains only:

- `clientSubmissionId`: client-generated UUID used for owner-scoped
  idempotency;
- reviewed category enum;
- subject, 1 to 120 Unicode characters;
- description, 1 to 4000 Unicode characters;
- optional reply contact, at most 200 characters;
- optional diagnostic consent and a separately previewed diagnostic envelope.

User follow-up messages are limited to 2000 Unicode characters. Attachments,
screenshots, clipboard content, Record, Memory, Profile, conversation text,
prompt/reply bodies, tokens, verification codes, secrets, and complete logs are
not accepted fields.

### Diagnostic envelope

Diagnostic sharing is off by default. When enabled, the previewed envelope is
limited to application version/build, platform and OS family, resolved locale,
request timestamp, and a bounded product error or correlation code. The server
validates an allowlist and rejects unknown diagnostic properties rather than
storing arbitrary JSON.

### Public identity and ownership

The server generates an opaque, non-sequential reference that contains no user
or database id. All user list, detail, and follow-up queries are scoped by the
authenticated owner before reference lookup. Missing and cross-owner
references return the same not-found response.

Retrying a create request with the same `(owner, clientSubmissionId)` returns
the original request and reference without creating a second request. Reusing
that id with different content returns a conflict and never overwrites the
first submission.

## Retention, Export, and Deletion

### Retention

- Open requests remain while the account exists.
- A request and its messages, user-visible replies, internal notes, transition
  history, and mutation audit are hard-deleted 180 days after `CLOSED`.
- This is a maximum support retention period, not a minimum promise.
- V1 implements no complaint, incident, or legal-hold exception. Any exception
  requires professional review, a separate decision, explicit disclosure, and
  implementation before it can override deletion.

### Export

The owned data export includes the public reference, category, user-visible
status/history, user-authored messages, user-visible operator replies, submitted
diagnostic envelope, and timestamps. It excludes internal notes, assignment,
administrator identity, internal reason codes, and security audit details.

Support export extends the versioned export schema in S11-02. Existing Record,
Memory, Profile, and conversation content is not copied into the support
section.

### Deletion

Account deletion hard-deletes every owned support request and all dependent
messages, replies, diagnostics, internal notes, transitions, assignments, and
support audit rows before returning success. V1 retains no deidentified support
row after account deletion. The packaged Gmail channel follows a separately
disclosed manual process: messages are deleted no later than 180 days after
handling closes, and earlier after a verified deletion request. Account
deletion cannot automatically match and delete external email, so the app must
state this boundary and provide the address for an external-copy deletion
request.

## Operator Access and Audit

- Only authenticated `ADMIN` authority may list or mutate support requests.
- Operator list responses default to metadata and a bounded preview; full
  description and user-visible conversation require opening one request.
- Access does not expose any unrelated ZEROON private content.
- Assignment, category change, internal note, reply, escalation, and status
  transition are audited with actor and timestamp.
- Internal notes and user-visible replies use distinct persistence types and
  response DTOs so visibility is not inferred from free text.
- Support content and admin notes are excluded from application logs and AI
  usage metadata.

## Planned API Boundary

- `POST /api/v1/support/requests`
- `GET /api/v1/me/support-requests`
- `GET /api/v1/me/support-requests/{reference}`
- `POST /api/v1/me/support-requests/{reference}/messages`
- ADMIN-only resources below `/api/v1/admin/support-requests`

S11-02 will finalize request/response schemas, pagination, rate limits, conflict
responses, and admin mutations in OpenAPI together with the implementation.
There is no anonymous support-submission API in V1; the external fallback is
the pre-auth and outage route.

## Consequences

- Users have a private, accountable path to real operators without turning the
  companion into support infrastructure.
- Data minimization and deterministic ownership increase implementation work
  but reduce accidental access to private product content.
- A packaged fallback makes contact resilient to auth and API failures. The
  current one-person staffing is truthful for closed Beta but blocks an SLA and
  wider recruitment until backup coverage exists.
- The 180-day closed-request limit is enforced by an hourly UTC purge with
  database-cascade and boundary tests. Configuration below one day fails
  startup rather than permitting accidental immediate deletion.

## Approval Record

Approved on 2026-07-23 for engineering and the one-person closed Beta:

- packaged fallback: `zeroon_ai@gmail.com`;
- accountable primary: Bruce Ann;
- external mail retention/deletion: the recommended 180-day maximum and
  separately disclosed verified-deletion process are accepted;
- service expectation: no SLA or continuous-monitoring claim.

`chao.fan` was named as backup on 2026-07-23. Mailbox and ADMIN access testing
remains a recruitment-readiness gate, not a reason to invent coverage or delay
Sprint 12 engineering.
