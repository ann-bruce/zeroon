# Sprint 12 Closed Beta Evidence and Recruitment Readiness V1

Status: Approved for engineering
Prepared: 2026-07-23

## Intake Decision

### 1. Mainline fit

Sprint 12 should help ZEROON learn whether people use and trust its primary
loop:

```text
Notice the present
  -> leave a low-pressure record
  -> preserve a user-owned memory
  -> receive a bounded reflection
  -> return across time
```

Privacy-safe activation, return, Archive review, consent-control, reliability,
and interview evidence directly support the 90-day decision. They test
long-term companionship and private memory without adding another product
surface.

### 2. Drift risk

The sprint must not become:

- a generic engagement or growth-hacking analytics project;
- measurement of chat duration, emotional intensity, or dependency;
- a broad administrator browser for individual behavior or private content;
- a reason to add Expression, Export, payment, hardware, social, streak, score,
  level, diagnosis, or personality-label features before cohort evidence;
- an attempt to declare public-release compliance complete without
  professional review;
- a reconstruction of previously discussed but undocumented requirements from
  memory.

The main risk is optimizing what is easy to count rather than learning whether
the reflective continuity loop is valuable and trusted.

### 3. Recommended abstract capability

**Privacy-preserving product evidence**: ZEROON can measure whether the bounded
core loop works, understand why invited adults return or stop, and make a
continue/reshape/stop decision without collecting the private content that
gives the product meaning.

### 4. Roadmap decision

Sprint 12 is accepted as **Closed Beta Evidence and Recruitment Readiness**.

This supersedes only the empty Sprint 12 reservation. It does not silently
approve any previously undocumented Sprint 10 idea. If that older proposal
still matters, it must be restated and reviewed against this plan.

Defer V1.2 Expression templates and memory-card Export until the first cohort
shows that users complete and revisit the existing record-memory-reflection
loop. Keep payment experiments in the documented Phase 4 sequence. Keep public
China release blocked by professional compliance review, and keep production
authentication blocked until the external verification-code provider has a
successful delivery smoke.

### 5. Planning acceptance criteria

The Sprint 12 plan is acceptable only if:

- every metric answers one documented 90-day product question;
- allowed event properties are typed and content-free;
- raw Record, goal, Memory, Profile, conversation, support, prompt, reply,
  mobile number, name, token, exact timestamp trail, and unrestricted error
  text are prohibited;
- event collection never blocks Record, Archive, Memory controls, support, or
  account deletion;
- retention, deletion, consent/notice, cohort identity, and operator access are
  decided before an event table or SDK is introduced;
- administrators see aggregates and operational health, not a general
  per-person activity browser;
- Simplified Chinese and English Beta notices state the same data-use boundary;
- the first cohort is adult-only and recruited for reflective continuity, not
  therapy, romance, crisis support, plush interest, or AI novelty;
- a named, access-tested backup support operator exists before invitations are
  sent;
- no wider cohort starts until the first 20 users are stable and blocking
  defects are addressed.

## Sprint Goal

Make ZEROON ready to invite and learn from the first 20 adult closed-Beta
participants with a privacy-reviewed evidence system, truthful bilingual
notice, reliable operational checklist, and no expansion of the product
promise.

## Proposed Implementation Sequence

| Item | Decision gate | Done when |
|---|---|---|
| S12-01 Evidence policy and lifecycle | Complete | ADR 007 fixes event purpose, allowed/prohibited properties, surrogate identity, consent/notice, retention, export/deletion, access, failure isolation, environment boundaries, and recruitment gates |
| S12-02 Typed event contract and persistence | Complete | Backend accepts only reviewed event names and bounded typed columns, uses client event ids for idempotency, and stores no private text or direct identity |
| S12-03 Core-loop instrumentation | Activation and trust behavior become measurable without content | Authentication, encounter, state, Reset, record save/failure, Archive/detail review, Memory control, Profile AI consent, export, deletion intent, and support entry emit only the reviewed contract |
| S12-04 Cohort and retention computation | Gate A and early Gate B can be calculated reproducibly | Activation, D1/D7, week-two record, Archive/reflection review, chat-only share, reliability, consent-control, and deletion/export demand are derived by documented queries with timezone and cohort rules |
| S12-05 Read-only evidence operations | Bruce Ann can review aggregate evidence without browsing private lives | ADMIN receives bounded aggregate cohort/reliability summaries; small-cell suppression and minimum cohort sizes prevent accidental individual disclosure |
| S12-06 Recruitment and runtime acceptance | The first invitation can be sent truthfully | Chinese/English notice, adult-only screen, interview consent/materials, backup support access, production-like auth/provider checks, cross-user isolation, event failure isolation, deletion behavior, full gates, and real runtime acceptance pass |

## Initial Event Boundary

Start from the already reviewed Beta event dictionary:

- `auth_completed`;
- `zeroon_encounter_viewed`;
- `zeroon_encounter_completed`;
- `state_started`;
- `reset_started`;
- `record_saved`;
- `record_save_failed`;
- `archive_viewed`;
- `record_detail_viewed`;
- `reflection_requested`;
- `reflection_completed`;
- `memory_control_changed`;
- `profile_ai_context_changed`;
- `data_export_requested`;
- `account_delete_requested`.

Do not implement subscription events in S12. They belong to the Phase 4 price
test and need their own package, refund, and billing decisions.

S12-01 does not approve support events. Support category, subject, body, reply,
diagnostic code, escalation, internal note, and audit reason must not become
analytics properties. Any future content-free support measurement requires a
new reviewed contract.

## Measurement Rules

- Activation requires authentication, encounter completion, a current state,
  one saved record, an Archive/detail review, and visibility of AI-context
  control. Chat alone is not activation.
- D1, D7, and D30 anchor on first completed activation, not registration.
- A calendar-day return uses the fixed `Asia/Shanghai` Sprint 12 policy; no
  timezone is inferred from locale, IP address, Profile, or private content.
- Archive/reflection review requires Archive, record detail, or source-linked
  reflection. Chat-only use remains separately visible and does not satisfy
  continuity.
- Buckets replace precise duration, count, latency, and age values where exact
  values are unnecessary.
- Cohort reports suppress cells below five distinct evidence subjects.
- Product metrics are evidence for decisions, never user-facing scores,
  streaks, rankings, or pressure.

## Operations Gates Before Recruitment

- Name and access-test one backup operator for `zeroon_ai@gmail.com` and the
  ADMIN support queue.
- Verify ownership and escalation routing for privacy, safety, complaint, and
  engineering cases.
- Complete a real verification-code delivery smoke in the intended Beta
  environment; local fixed codes are not recruitment evidence.
- Publish the adult-only Chinese and English Beta notice and interview consent.
- Prepare an incident stop rule: pause invitations when authentication,
  record durability, deletion, support reachability, or private-content
  boundaries fail.
- Invite at most 20 participants first. Expansion toward 50-100 requires a
  stability review.

## Out of Scope

- new Expression, Export, payment, subscription, or hardware features;
- public analytics, social proof, user rankings, streaks, levels, or badges;
- session replay, screen recording, unrestricted logs, clipboard collection,
  or third-party advertising identifiers;
- content classification, emotion scoring, personality inference, diagnosis,
  crisis prediction, or support-message analysis;
- per-user administrator timelines containing private product behavior;
- public launch, minors, guaranteed support SLA, or a claim of completed
  regulatory compliance.

## S12-01 Decision

`docs/02_Architecture/ADR_007_Beta_Evidence_Event_Lifecycle_V1.md` is accepted
and fixes:

- first-party, typed, content-free evidence events with no third-party
  analytics SDK;
- an internal random subject id, explicit Beta evidence notice and revocable
  collection choice, and an Asia/Shanghai calendar-day measurement policy;
- a 180-day maximum for user-linked event rows, export visibility, and hard
  deletion with the account;
- aggregate-only ADMIN evidence views with cells below five participants
  suppressed;
- failure isolation so evidence collection cannot block authentication,
  Record, Archive, Memory control, support, export, or deletion;
- development/test isolation from Beta evidence and no automatic promotion of
  local events into Beta metrics.

The first cohort is limited to at most 20 invited adults aged 25-45 from the
documented reflective knowledge-worker cohort. Bruce Ann remains the
accountable primary support operator. `chao.fan` is the named backup operator,
but the first invitation remains blocked until mailbox and ADMIN access are
actually tested and recorded. Naming a person is not evidence of access.

Approved by Bruce Ann on 2026-07-23, opening S12-02 implementation.

## S12-02 Verification

Completed on 2026-07-23:

- PostgreSQL V14 adds one owner-cascading `evidence_subjects` mapping and
  content-free `evidence_events`. Event rows contain only a subject foreign
  key, UUID client id, reviewed event enum, schema version, Asia/Shanghai date,
  fingerprint, typed property columns, and server receipt time; there is no
  arbitrary JSON, direct user id, exact client timestamp, or private text.
- Authenticated `GET/PUT /api/v1/me/preferences/beta-evidence` implements a
  default-off explicit choice tied to the current reviewed notice.
  `POST /api/v1/evidence/events` validates the exact property set for all 15
  approved event names, rejects unknown/free-text/event-inapplicable fields and
  stale dates, and stores nothing while collection or the environment is off.
- Subject-scoped locking and `(subject_id, client_event_id)` uniqueness make an
  identical retry idempotent. Conflicting reuse returns `409`; new-event
  throttling returns `429` with `Retry-After`, while an identical retry remains
  readable after the limit.
- Export V4 adds only the owned collection choice and retained content-free
  event name, schema, date, and reviewed properties. It excludes subject UUID,
  fingerprint, receipt time, and other users. Account deletion hard-deletes the
  mapping and events before returning success.
- An hourly UTC worker enforces a configurable 1-to-180-day maximum. It deletes
  expired events before stale event-free subjects; removing a stale subject
  returns collection to safe default-off rather than silently recreating
  consent.
- Focused evidence/data-control tests and all 122 backend tests pass. OpenAPI
  lint and whitespace validation pass.
- Real PostgreSQL 16.14 migrated from V13 to V14. A temporary account completed
  notice acceptance, first `RECORD_SAVED` persistence (`201`), identical retry
  (`200`, duplicate), export V4, and deletion (`204`). Database checks confirmed
  Flyway V14 success and zero remaining temporary user/evidence subject rows.

## S12-03 Verification

Completed on 2026-07-23:

- Flutter emits only the reviewed enum, boolean, bounded-version, context-class,
  and bucket properties for authentication, first encounter, manual state
  start, Reset entry, record save/failure, Archive/detail review, reflection,
  Memory controls, Profile AI-context consent, data export, and deletion
  intent. Record, Profile, Memory, conversation, support, prompt, and reply text
  never enter the event envelope.
- A process-local queue retains at most 50 events and drops entries older than
  seven days. Each event keeps one UUID across retries; invalid client events
  are dropped, transient network/429/5xx failures remain bounded, and every
  caller is best-effort so evidence failure cannot change a primary-flow
  result.
- Login responses distinguish only the account-creating login from existing
  account/refresh sessions. Companion responses provide reviewed outcome,
  latency bucket, prompt-family version, provider-path alias, and the enabled
  Profile/Memory context-class set without exposing raw provider ids or private
  context.
- Reflection transport failures produce a bounded `FAILED` outcome and keep the
  existing calm local fallback. Successful record, Memory, consent, export, and
  deletion paths do not await evidence availability.
- Support request/category/body/reply data remains uninstrumented. This is
  intentional: S12-01 explicitly approved no support-event contract, despite
  the broader table wording about the support entry.
- Flutter analyze, all 46 mobile tests, all 122 backend tests, OpenAPI lint, and
  whitespace validation pass.
- A PostgreSQL 16.14 runtime smoke returned `newAccount=true`, safely returned
  `stored=false` while evidence collection was off, exposed a refusal as
  `REFUSAL / SAFETY_V1 / SAFETY_BOUNDARY` with zero context classes, and
  deleted the temporary account with `204`. Runtime review also caught and
  corrected the built-in Companion prompt being mislabeled as a safety prompt;
  it now uses `COMPANION_REFLECTION_FALLBACK_V1`.

S12-04 cohort and retention computation is next.
