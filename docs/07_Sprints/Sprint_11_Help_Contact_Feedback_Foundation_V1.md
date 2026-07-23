# Sprint 11 Help, Contact, and Feedback Foundation V1

Status: Complete
Prepared: 2026-07-22

## Sprint Goal

Ensure that a user who has a product problem, suggestion, account or privacy
concern, AI safety concern, or complaint can always find the real ZEROON team,
submit a bounded request, receive a durable receipt, and understand its status.

This sprint follows Sprint 10 so every contact, failure, privacy, and safety
state ships coherently in Simplified Chinese and English. The scope previously
discussed but undocumented as Sprint 10 moves to Sprint 12.

## Product Decision

### Mainline fit

Reachable support is part of the trust contract for a private memory product.
Users should not have to rely on an AI companion when they need help from the
people responsible for the service.

### Drift risk

- Do not present AI as a human support agent or complaint handler.
- Do not turn feedback into a public feed, voting system, or community.
- Do not automatically attach Record, Memory, Profile, conversation, prompt,
  or diagnostic-log content.
- Do not require authentication as the only route to contact; login failure is
  itself a support case.
- Do not promise a response time that operations cannot consistently meet.
- Do not treat the feedback channel as an emergency or professional crisis
  service.

### Abstract capability

**Reachable and accountable user support**: a resilient path from user concern
to a real operator, with receipt, ownership, status, privacy, and escalation
boundaries.

### Roadmap decision

Accept as an independent Sprint 11 and a closed-beta readiness gate. Keep
language infrastructure in Sprint 10. Move any older undocumented Sprint 10
scope to Sprint 12 rather than mixing it into support work.

## Service Model

### Authenticated path

Signed-in users can submit and later view their own requests in the app. Each
successful submission receives an opaque public reference and one status:

- `RECEIVED`;
- `IN_REVIEW`;
- `WAITING_FOR_USER`;
- `REPLIED`;
- `CLOSED`.

Users can read operator replies intended for them and add a bounded follow-up
when clarification is requested. They cannot read internal notes or another
user's request.

### Pre-auth and outage path

Login exposes a quiet `Help and contact` entry. The app contains a build-time
fallback support address or HTTPS help URL that remains visible when the API is
unavailable. A remotely configurable value may override it, but cannot remove
the packaged fallback.

The pre-auth fallback must not depend on successful authentication or on the
same API whose failure the user may be reporting.

### Categories

Use a small reviewed enum:

- `PRODUCT_PROBLEM`;
- `SUGGESTION`;
- `ACCOUNT_DATA_PRIVACY`;
- `AI_RESPONSE_SAFETY`;
- `COMPLAINT_RIGHTS`;
- `OTHER`.

Complaint and rights concerns remain explicit rather than being hidden inside
Other. Billing is added only when a paid workflow exists.

## Implementation Sequence

| Item | Status | Done when |
|---|---|---|
| S11-01 Support policy and data lifecycle | Complete | Real owners, supported channels, categories, status transitions, response language, retention/export/deletion decisions, escalation boundaries, and truthful service expectations are approved |
| S11-02 Support request data and API | Complete | Authenticated create/list/detail/follow-up endpoints use opaque references, ownership isolation, bounded input, rate limits, migration/test-schema/OpenAPI parity, and idempotent submission behavior |
| S11-03 Resilient mobile entry | Complete | Login and Settings expose localized contact paths; forms preserve drafts on recoverable failure; API outage still reveals the packaged external fallback |
| S11-04 User receipt, status, and replies | Complete | Users receive a durable reference, can view only their requests, see status history and user-visible replies, and understand when more information is requested |
| S11-05 Admin handling, audit, and escalation | Complete | ADMIN can triage, reply, and change state through bounded APIs; every mutation records actor, time, transition, and request id without copying private app content |
| S11-06 Privacy, abuse, and runtime acceptance | Complete | Data minimization, export/deletion, anonymous-channel boundary, rate limiting, bilingual UI, outage fallback, cross-user isolation, admin audit, and end-to-end response are verified |

## S11-01 Decision

`docs/02_Architecture/ADR_006_Support_Request_Lifecycle_V1.md` now fixes the
engineering policy for:

- private authenticated requests plus one packaged external pre-auth/outage
  fallback that cannot be removed by remote configuration;
- category ownership roles and explicit safety, privacy, and complaint
  escalation without AI triage or automatic closure;
- the allowed `RECEIVED`, `IN_REVIEW`, `WAITING_FOR_USER`, `REPLIED`, and
  `CLOSED` transitions and their audit boundary;
- human response language, exact-content preservation, and truthful no-SLA
  service copy;
- bounded request/follow-up fields, opt-in allowlisted diagnostics,
  owner-scoped idempotency, opaque references, and no anonymous submission API;
- export of user-visible support data, account-deletion hard deletion, and a
  180-day maximum after closure with no unreviewed retention exception.

Approved on 2026-07-23 with `zeroon_ai@gmail.com` as the packaged fallback and
Bruce Ann as the accountable primary for the current one-person closed Beta.
The recommended 180-day maximum and separately disclosed external-email
deletion process are accepted. No SLA or continuous coverage is promised; a
named, access-tested backup remains a wider-Beta readiness gate.

## S11-02 Verification

Completed on 2026-07-23:

- V12 adds owner-cascading support requests, user-visible/internal messages,
  and status history with constrained categories, states, actors, visibility,
  locale, opaque public reference, and owner-scoped client submission id.
- Authenticated create, owned list/detail, and follow-up APIs are implemented.
  The database id is never public; missing and cross-user references both
  return not found.
- Create is serialized per owner, limited to five new requests per hour, and
  idempotent on `(owner, clientSubmissionId)`. An identical retry returns the
  original reference; different content with the same id returns conflict.
- User follow-up is limited to twenty messages per hour, rejects `CLOSED`, and
  returns `WAITING_FOR_USER` or `REPLIED` to `IN_REVIEW` with immutable history.
- Subject, description, reply contact, and follow-up lengths are bounded.
  Diagnostic sharing is off unless explicitly consented, uses an allowlist,
  rejects unknown properties, and never accepts private product text, tokens,
  secrets, screenshots, attachments, or full logs.
- Export V3 includes only owned, user-visible support data and excludes internal
  notes, operator identity, assignment, internal reason codes, and audit detail.
  Account deletion cascades through every in-app support row.
- Full backend tests, all 29 mobile tests, Flutter analyze, admin lint/build,
  OpenAPI lint, health smoke, and `git diff --check` pass. The two existing
  non-blocking Admin React Hook warnings and Vite chunk-size warning remain.
- Real PostgreSQL 16.14 migrated from V11 to V12. A two-account runtime smoke
  proved create `201`, identical retry `200` with the same reference,
  cross-owner detail `404`, follow-up `201`, export V3 inclusion, and account
  cleanup `204` for both temporary accounts.

## S11-03 Verification

Completed on 2026-07-23:

- Login exposes a language-independent help icon next to the language picker.
  It opens a pre-auth page that never calls the support API and always displays
  the packaged `zeroon_ai@gmail.com` fallback as selectable and copyable text.
- Settings exposes Help and contact as a first-level card. Signed-in users can
  submit one of the six reviewed categories with a description; the bounded
  backend subject is derived from the first nonblank description line without
  changing the user-authored description.
- The per-form UUID remains stable across retries. A recoverable failure keeps
  category, description, diagnostic choice, and UUID, and displays retry plus
  a directly copyable external fallback in the same view.
- Basic diagnostics are off by default. Opt-in previews the exact allowlisted
  app version/build, platform, operating-system family when applicable,
  resolved locale, and frozen timestamp; no private ZEROON content or full log
  is collected.
- Success replaces only the form with a calm, copyable opaque reference. Copy
  explicitly says a human team member will review it and does not promise a
  response time or resolution.
- Focused repository and widget tests cover request shape, no-consent
  diagnostics omission, signed-out no-API behavior, exact draft preservation,
  failure fallback, honest receipt, and 390x844 English layout. The full mobile
  suite now has 34 passing tests.
- A real 390x844 runtime review covered Chinese and English Login, pre-auth
  fallback, Settings entry, signed-in form, and receipt without clipping,
  overlap, or companion-language drift. A temporary user received a real
  opaque support reference and was then deleted, cascading its support data.
- The full backend/mobile/admin/OpenAPI quality gate passes. The two existing
  Admin React Hook warnings and Vite chunk-size warning remain non-blocking.

## S11-04 Verification

Completed on 2026-07-23:

- Signed-in Help and feedback now exposes a first-level My support requests
  entry. The paged list uses only the owner-scoped `/me/support-requests`
  contract and presents category, updated date, and one of the five reviewed
  states without exposing database identity or internal handling data.
- Empty, loading, initial-error, refresh-error, pagination, and retry behavior
  are local and recoverable. A refresh failure keeps already displayed private
  requests rather than replacing the whole screen.
- Request detail separates the original user-authored request, user-visible
  human conversation, and immutable status progress. `WAITING_FOR_USER`
  explains exactly that the real team needs more information; `REPLIED` does
  not imply resolution, and `CLOSED` remains readable without allowing an
  invalid in-app follow-up.
- User follow-up keeps exact authored content, stays as a draft on recoverable
  failure, and clears only after the API accepts it. A successful follow-up is
  shown locally even if the immediate detail refresh fails, avoiding a false
  failure after a committed send.
- All category, state, actor, empty, error, reply, progress, follow-up, and
  closed-state copy is complete in Simplified Chinese and English. Human
  messages are labeled ZEROON team and are never written in companion voice.
- Repository tests cover list/detail parsing and the exact follow-up request.
  Widget tests cover empty and error states, waiting-for-user with a visible
  human reply and history, failed draft preservation, successful follow-up,
  closed-state controls, and narrow English detail. The full mobile suite now
  has 42 passing tests.
- A real PostgreSQL-backed 390x844 flow covered empty list, create, receipt,
  detail, follow-up, list refresh, and Chinese/English rendering. User-authored
  Chinese remained unchanged when the interface switched to English. The
  temporary account was then deleted, cascading its request and message.

## S11-05 Verification

Completed on 2026-07-23:

- V13 adds self-assignment, reviewed escalation codes, an admin-queue index,
  and request-cascading `support_admin_audit`. Audit rows retain request,
  authenticated actor, timestamp, bounded reason, transition values, and
  optional message identity without copying request, note, or reply bodies.
- `/admin/support-requests` provides ADMIN-only bounded queue filters and
  request-scoped detail. USER credentials receive `403`; the operator surface
  does not expose unrelated Record, Memory, Profile, or conversation content.
- Category, assignment, escalation, and the initial
  `RECEIVED -> IN_REVIEW` transition use bounded patch input. User-visible
  replies atomically apply only reviewed lifecycle transitions; closing always
  includes a visible human explanation, and closed requests cannot reopen.
- Internal notes and user-visible human replies use explicitly different
  visibility values and separate controls. Owner APIs and export V3 exclude
  internal notes, assignment, escalation, operator identity, and admin audit.
- The Admin user-support workbench provides metadata filters, a request-scoped
  drawer, fixed triage/escalation choices, separate reply and internal-note
  forms, visible status history, and content-free audit history. Copy identifies
  replies as human support and never presents AI as an operator.
- Tests cover unauthenticated and USER denial, filtered queue data, triage,
  internal-note isolation, user-visible reply and close, invalid transitions,
  unknown fields, immutable audit actor/count, no reopen, and account-deletion
  cascade. The full backend/mobile/admin/OpenAPI quality gate passes with all
  42 mobile tests; only the two existing Admin Hook warnings and Vite
  chunk-size warning remain non-blocking.
- PostgreSQL 16.14 migrated from V12 to V13. A temporary owner and temporary
  ADMIN completed real create, USER-denied admin access, queue, assignment,
  escalation, internal note, `WAITING_FOR_USER` human reply, owner-side
  visibility isolation, six-row actor/timestamp audit, and full account/data
  cleanup. The Admin workbench was also visually checked with no clipping,
  overlap, or accidental private-content browser.

## S11-06 Verification

Completed on 2026-07-23:

- Closed requests now have an automated retention worker. It runs hourly by
  default, deletes requests whose `closedAt` is older than the configured
  180-day maximum, and relies on reviewed database cascades to remove messages,
  internal notes, history, assignment, diagnostics, and support audit.
  Retention days and the UTC cron are explicitly configurable; a value below
  one day fails startup instead of risking immediate deletion.
- Integration tests prove an expired closed request and all dependent support
  rows are removed while a recent closed request and an open request remain.
  Follow-up throttling now has explicit `429`, `Retry-After`, and stable error
  regression in addition to the existing request-creation limit.
- A mocked LLM provider receives zero calls through create, triage, internal
  note, reply, close, and retention flows. Database assertions also prove the
  support owner receives no conversation, Memory, Profile, or AI-usage row as a
  side effect.
- The support page now discloses in Simplified Chinese and English that closed
  in-app requests have a 180-day maximum and external email follows the
  separately disclosed maximum with an earlier-deletion request path. The
  notice remains visible before login, before submission, after a receipt, and
  when the API is unavailable.
- The full backend test suite, Flutter analyze and all 42 mobile tests, Admin
  lint/build, OpenAPI lint, and whitespace gate pass. The two existing Admin
  Hook warnings and Vite chunk-size warning remain non-blocking and are not
  support regressions.
- A real PostgreSQL 16.14 three-account flow proved anonymous denial,
  cross-owner `404`, privacy-category creation, ADMIN assignment/escalation,
  internal-note isolation, human clarification, exact user follow-up, visible
  close, eight actor-stamped audit rows, export isolation, and zero AI usage.
  With a temporary one-day retention configuration, the scheduler then purged
  the backdated closed request and all dependent rows; all temporary accounts
  were deleted.
- Real 390x844 English and Simplified Chinese review found no clipping or
  overlap. After the backend was stopped and the page reloaded, the packaged
  `zeroon_ai@gmail.com` route, external-channel boundary, retention statement,
  and non-emergency copy remained visible.
- Experience review accepts the calm, secondary privacy/retention treatment.
  Product-guardrail review confirms that support remains human-operated,
  request-scoped, and separate from companion context. Sprint 11 is complete.
  A named, access-tested backup remains a wider-Beta operations gate, and
  professional public-release review remains outside this sprint.

## Data Boundary

### User-submitted content

A request may contain:

- category;
- user-authored subject and description;
- optional reply contact chosen by the user;
- explicit consent to include a previewed diagnostic envelope.

The request and user-visible replies are private user support data. They must
have a documented export, deletion, retention, and operator-access decision
before implementation. Any retention exception for complaints or incidents
requires professional review and clear user-facing disclosure.

### Diagnostic envelope

If the user opts in after seeing what will be sent, diagnostics may include:

- application version and build;
- platform and operating-system family;
- resolved locale;
- request timestamp;
- a bounded product error code or correlation id.

Diagnostics must never automatically include:

- Record, Memory, Profile, or conversation text;
- AI prompt or reply bodies;
- authentication tokens, verification codes, API keys, or secrets;
- clipboard content, screenshots, files, or full application logs;
- precise location, contacts, advertising identifiers, or unrelated device
  data.

Attachments, screenshots, and unrestricted log upload are out of scope.

## API and Persistence Boundary

The final S11-01 design must document the exact contract. The planned shape is:

- `POST /support/requests` for authenticated submission;
- `GET /me/support-requests` for the current user's list;
- `GET /me/support-requests/{reference}` for owned detail;
- `POST /me/support-requests/{reference}/messages` for bounded follow-up;
- `/admin/support-requests/**` for ADMIN-only triage and user-visible replies.

Recommended persistence separates:

- request identity, owner, category, status, and lifecycle timestamps;
- user/operator messages with explicit visibility;
- status transition history;
- administrator mutation audit.

Database ids are never used as public references. Retrying the same client
submission id must not create duplicate requests.

## Mobile Experience Requirements

- Settings exposes `Help and feedback` without hiding it under AI chat.
- Login exposes a language-independent help icon and localized contact copy.
- The first form asks for category and description only; optional diagnostics
  are secondary and off by default.
- Submission failure keeps the draft and shows both retry and external-contact
  fallback without replacing the whole page.
- Success shows a copyable reference and calm receipt. It does not claim that
  the issue is resolved or promise an unsupported response time.
- Status and replies use human support language, not ZEROON companion voice.
- A safety or complaint category may show reviewed boundary information, but it
  must still submit to the real support process.
- Chinese and English layouts work at narrow mobile width without clipped
  category, privacy, confirmation, or response copy.

## Admin and Operations Requirements

- USER tokens receive 403 for all admin support APIs.
- ADMIN list/detail responses expose only information needed to handle the
  request; they do not create a general private-content browser.
- Every reply, category change, assignment, escalation, and status transition
  records the authenticated administrator and timestamp.
- Internal notes are clearly separate from user-visible replies and never
  enter user APIs accidentally.
- Operations defines who owns each category and what happens when no operator
  is available. The UI communicates only promises operations can meet.
- AI may assist neither automatic closing nor final complaint decisions in this
  sprint.

## Acceptance Criteria

- A user can find a real-team contact path within two actions from Settings.
- A signed-out user can find the external contact path without understanding
  the default language or completing login.
- API outage does not remove the packaged support address or HTTPS help URL.
- Authenticated submission returns one opaque reference; safe retry with the
  same client id does not create a duplicate.
- Recoverable submission failure preserves every user-entered field locally.
- Users can list and read only their own requests, status history, and visible
  replies; cross-user references return no data.
- ADMIN can triage and reply only with ADMIN authority, and every mutation has
  an audit record.
- Complaint and rights categories are explicit and have an approved operational
  owner before Beta recruitment.
- Diagnostic sharing is off by default, previewed before consent, bounded, and
  covered by tests proving prohibited private fields are absent.
- Support data appears in export and follows the accepted deletion/retention
  policy; any exception is disclosed and professionally reviewed.
- No support request or reply is sent to the companion model or used to infer
  Profile, Memory, diagnosis, risk score, or personality.
- Simplified Chinese and English success, empty, loading, error, retry, receipt,
  privacy, status, and admin-facing user-visible reply states are complete.
- Backend, migration, test schema, OpenAPI, mobile, admin, lifecycle docs,
  focused tests, full quality gate, and end-to-end runtime acceptance pass.

## Out of Scope

- public feedback boards, votes, comments, or community;
- real-time chat, voice support, or call-center integration;
- AI chatbot support, AI-written final replies, or automated complaint closure;
- attachments, screenshots, unrestricted logs, or remote device access;
- billing disputes before payment exists;
- externally guaranteed response-time SLA;
- professional emergency, medical, legal, financial, or psychological support;
- third-party CRM procurement before the in-product data and privacy boundary
  is accepted.

## Sprint Exit

- Users can always find a real contact path, including before login and during
  an API outage.
- Signed-in users can submit, receive a durable reference, track status, and
  read a real operator reply without exposing unrelated private content.
- Operator access and mutations are authorized and audited.
- Support data lifecycle, escalation ownership, bilingual experience, and
  outage behavior are accepted before Sprint 12 or wider Beta recruitment.
