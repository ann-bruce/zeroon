# Sprint 11 Help, Contact, and Feedback Foundation V1

Status: Planned
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
| S11-01 Support policy and data lifecycle | Planned | Real owners, supported channels, categories, status transitions, response language, retention/export/deletion decisions, escalation boundaries, and truthful service expectations are approved |
| S11-02 Support request data and API | Planned | Authenticated create/list/detail/follow-up endpoints use opaque references, ownership isolation, bounded input, rate limits, migration/test-schema/OpenAPI parity, and idempotent submission behavior |
| S11-03 Resilient mobile entry | Planned | Login and Settings expose localized contact paths; forms preserve drafts on recoverable failure; API outage still reveals the packaged external fallback |
| S11-04 User receipt, status, and replies | Planned | Users receive a durable reference, can view only their requests, see status history and user-visible replies, and understand when more information is requested |
| S11-05 Admin handling, audit, and escalation | Planned | ADMIN can triage, reply, and change state through bounded APIs; every mutation records actor, time, transition, and request id without copying private app content |
| S11-06 Privacy, abuse, and runtime acceptance | Planned | Data minimization, export/deletion, anonymous-channel boundary, rate limiting, bilingual UI, outage fallback, cross-user isolation, admin audit, and end-to-end response are verified |

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
