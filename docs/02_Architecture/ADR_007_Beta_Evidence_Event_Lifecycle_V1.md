# ADR 007 Beta Evidence Event Policy and Lifecycle V1

Status: Accepted for engineering
Date: 2026-07-23
Scope: Sprint 12 Closed Beta Evidence and Recruitment Readiness

## Context

ZEROON needs evidence that invited adults can complete and return to its
private record-memory-reflection loop. Counting what is technically convenient
would create the wrong incentives and could expose the private content that
makes the product valuable.

This decision fixes the purpose, contract, identity, notice, lifecycle, access,
and failure boundaries before an event table, ingestion API, mobile
instrumentation, or evidence dashboard is introduced.

## Decision

ZEROON will use a first-party, typed, content-free evidence system for the
closed Beta. It measures whether the bounded core loop is usable, reliable,
revisited, and trusted. It is not an engagement-ranking system and does not
measure emotional intensity, dependency, personality, diagnosis, or the
meaning of private content.

No third-party analytics, advertising, session-replay, screen-recording, heat
map, or unrestricted logging SDK is permitted in Sprint 12.

### Product questions

Each event must answer at least one of these approved questions:

1. Can a participant complete the activation loop?
2. Does a participant return to Record, Archive, record detail, or a
   source-linked reflection across calendar days?
3. Do Record and companion operations succeed without silent loss?
4. Can participants find and use Memory, AI-context, export, and deletion
   controls?
5. Is use chat-only, or does it include user-controlled reflective continuity?

An event or property without a mapping to these questions is rejected until a
new decision is approved.

## Identity and Collection Choice

### Surrogate identity

S12-02 will create a server-generated random UUID evidence subject for an
account. The value:

- is not derived from user id, mobile number, name, email, token, device id, IP
  address, advertising id, or private content;
- is stored in a private account-to-subject mapping with account-deletion
  cascade;
- is the only subject identifier on event rows;
- is never returned in ADMIN aggregate responses or shown to operators;
- is never shared with an external analytics provider.

The mapping exists only so collection choice, export, and hard deletion can be
enforced. It is not a general pseudonymous user directory.

### Notice and control

Before the first Beta evidence event is accepted, the signed-in participant
must see the same material boundary in Simplified Chinese and English and make
an explicit choice. The notice states:

- which content-free product events are collected and why;
- that Record, Memory, Profile, conversation, support, prompt, reply, contact,
  and unrestricted error content are excluded;
- the 180-day maximum, export, deletion, operator-access, and aggregate-report
  boundary;
- that collection can be disabled without losing core Record, Archive, Memory,
  support, export, or account-deletion capabilities.

Collection defaults off until acceptance. Disabling it stops new event
collection immediately; it does not silently delete already collected rows.
Existing rows remain visible in data export and can be removed through account
deletion. A future separate event-data deletion control may be added only with
an explicit contract.

All reported denominators identify that they cover evidence-enabled
participants. Coverage is reported separately so opt-out is not hidden.

## Typed Event Contract

Every accepted event contains only:

- `clientEventId`: UUID, idempotent within the evidence subject;
- `eventName`: one reviewed enum below;
- `schemaVersion`: positive reviewed integer;
- `occurredDate`: calendar date resolved using the policy below;
- the exact typed properties allowed for that event.

The server sets receipt and retention timestamps. Arbitrary property maps,
unknown fields, unknown enum values, free text, nested objects, arrays, exact
coordinates, unrestricted URLs, and unrestricted exception or HTTP bodies are
rejected rather than stored.

### Global bounded enums

- platform: `IOS`, `ANDROID`, `WEB`, `UNKNOWN`;
- entry source: a reviewed product-surface enum, never a free-form route or URL;
- duration/latency/record-age/item-count: reviewed buckets, never exact values;
- retry count: `ZERO`, `ONE`, `TWO_OR_MORE`;
- network status: `ONLINE`, `OFFLINE`, `TIMEOUT`, `UNKNOWN`;
- app version: bounded release version, without build path or device identity;
- prompt version and model alias: server-owned bounded identifiers, never
  prompts, provider credentials, endpoint values, or user-selected text.

### Approved events and properties

| Event | Allowed properties |
|---|---|
| `auth_completed` | new/existing enum, platform, app version |
| `zeroon_encounter_viewed` | entry source, app version |
| `zeroon_encounter_completed` | duration bucket, retry-count bucket |
| `state_started` | reviewed state enum, source enum |
| `reset_started` | entry source, active-state-present boolean |
| `record_saved` | reviewed state enum, has-goal boolean, has-content boolean, latency bucket, retry-count bucket |
| `record_save_failed` | bounded error class, retryable boolean, network status |
| `archive_viewed` | entry source, item-count bucket |
| `record_detail_viewed` | record-age bucket, source-type enum |
| `reflection_requested` | surface enum, enabled-context-class bit set |
| `reflection_completed` | outcome enum, latency bucket, prompt version, model alias |
| `memory_control_changed` | action enum, source-type enum |
| `profile_ai_context_changed` | enabled boolean, surface enum |
| `data_export_requested` | surface enum, outcome enum |
| `account_delete_requested` | surface enum, outcome enum, optional fixed reason category |

Subscription events remain outside Sprint 12. Support request category,
subject, body, reply, diagnostic code, escalation, internal note, and audit
reason are not evidence properties. Support operations already have their own
private lifecycle and audit; Sprint 12 adds no support-content analytics.

### Prohibited data

Evidence events must never contain or derive properties from:

- Record goal, content, summary, current-state notes, or exact timestamps;
- Memory title, summary, source text, or source identifier;
- Profile nickname, age, age range, occupation, identity, self-description,
  avatar, inferred trait, or AI label;
- conversation, support request, human reply, internal note, provider prompt,
  provider reply, refusal text, or safety-notice text;
- mobile number, email, name, token, verification code, IP address, device
  identifier, advertising identifier, precise location, contacts, clipboard,
  screenshot, file, or unrestricted application log;
- emotion score, sentiment, diagnosis, crisis prediction, personality,
  relationship, or dependency classification.

Boolean fields such as `hasContent` describe only the presence required for a
funnel step. They are never derived into a content category.

## Time and Cohort Rules

- All Sprint 12 calendar-day metrics use `Asia/Shanghai`.
- The client sends only the resolved calendar date for an occurrence; it does
  not send a timezone, coordinate, or exact event timestamp.
- The server stores a receipt time for idempotency, retention, and operational
  diagnosis, but aggregate product reports use the resolved date and never
  expose a per-person timestamp trail.
- D1, D7, and D30 anchor on first completed activation, not registration.
- Activation requires authentication, encounter completion, a current state,
  one saved record, an Archive or record-detail review, and visibility of the
  AI-context control. Chat alone is not activation.
- Archive/reflection continuity requires Archive, record detail, or a
  source-linked reflection. Chat-only use remains a separate aggregate.
- The first cohort is at most 20 invited adults aged 25-45 from the approved
  reflective knowledge-worker cohort.

A timezone change or multinational cohort requires a new versioned policy; it
must not be inferred from locale, IP address, private text, or Profile.

## Retention, Export, and Deletion

### Retention

- User-linked evidence subjects and event rows have a maximum retention of 180
  days from server receipt.
- An automated UTC purge is required in S12-02. A missing schedule or unsafe
  retention value must fail startup in a Beta/production-like environment.
- No legal-hold, complaint, research, or incident exception exists in V1.
  Adding one requires professional review, user disclosure, and a new decision.
- Cohort metrics are recomputed from current rows. The system does not keep a
  hidden personally linkable historical snapshot after source rows expire.
- A manually approved decision record may retain only aggregate cells that
  satisfy the suppression rule and contain no subject id or private content.

### Export

Account data export includes:

- whether Beta evidence collection is enabled and when the choice changed;
- each retained event's name, schema version, occurred date, and allowed
  properties;
- no internal subject id, server mapping id, operator metadata, or unrelated
  participants' aggregates.

S12-02 must version the existing export schema when this section is added.

### Deletion

Account deletion hard-deletes the evidence subject mapping and every linked
event before returning success. No deidentified per-person event row remains.
Aggregate metrics must be recomputed and may not preserve a linkable deleted
contribution. Deletion failure fails the account-deletion operation visibly; it
must never report success while evidence rows remain.

## Access and Reporting

- Normal users can see their own retained evidence only through account data
  export in V1.
- ADMIN APIs expose only reviewed aggregate cohort, activation, continuity,
  trust-control, and reliability cells.
- Any cell representing fewer than five distinct evidence subjects is
  suppressed and returned as suppressed, not zero.
- Filters may use reviewed cohort and calendar windows only. Combining filters
  to reconstruct an individual timeline is prohibited.
- There is no per-subject ADMIN event list, search, export, drill-down, or
  timeline.
- Direct database access is limited to named engineering incident responders,
  uses existing secret controls, and must not become normal product analysis.
- Logs contain event name, schema version, outcome, and bounded correlation
  identifiers only. They exclude subject id, properties that could identify a
  person, private content, and raw rejected payloads.

## Failure Isolation and Abuse Boundary

- Event submission is best-effort and cannot block or roll back authentication,
  Record, Archive, record detail, Memory controls, Profile AI consent, support,
  export, or account deletion.
- Mobile queues are bounded, contain only accepted typed fields, expire, and
  drop safely when full. They do not retry forever or delay primary UI success.
- Backend event persistence uses an independent transaction and idempotent
  client event id.
- Invalid or oversized events are rejected without echoing raw payloads.
- Per-account and per-device-request rate limits protect ingestion without
  introducing a persistent device identifier.
- Evidence-system outage is visible to operators through content-free health
  signals but does not change the user's primary-flow success copy.

## Environment Boundary

- Development and automated-test events never enter Beta evidence storage or
  reports.
- Beta/production-like collection requires explicit environment configuration,
  the accepted notice version, retention schedule, and secure database.
- Environment is assigned by trusted server configuration, never a client
  property.
- Local fixed-code authentication, fake-provider execution, seeded users, and
  synthetic acceptance events are excluded from participant metrics.
- Synthetic runtime verification uses a separately marked test environment and
  is deleted after acceptance.

## Operations Gate

Bruce Ann is the accountable primary support operator. `chao.fan` is the named
backup. Before the first invitation is sent, both of the following must be
tested and recorded:

1. `chao.fan` can access and respond through `zeroon_ai@gmail.com`;
2. `chao.fan` can authenticate to the ADMIN support queue with only the
   required role.

The test must not use or expose real participant content. Until both checks
pass, the recruitment gate is **blocked**, even though Sprint 12 engineering
may continue. No SLA or continuous-coverage claim is introduced.

## Consequences

- ZEROON can evaluate activation, continuity, reliability, and trust controls
  without turning private lives into an administrator browser.
- Explicit choice and aggregate suppression reduce measurable sample size; all
  reports must state coverage and suppressed cells honestly.
- Fixed event schemas and export/deletion behavior add engineering work but
  prevent arbitrary analytics JSON from becoming shadow personal data.
- The first cohort remains deliberately small. Expansion requires stable core
  flows, completed access gates, and a reviewed first-cohort evidence check.

## Verification Obligations

S12-02 and later items must prove:

- unknown events, fields, enum values, free text, and oversized inputs are
  rejected without persistence or raw-payload logs;
- duplicate client event ids are idempotent per evidence subject;
- disabled collection creates no event and re-enabling does not backfill;
- event failure does not change primary-flow success or persistence;
- export includes only owned retained evidence and deletion removes all linked
  rows;
- retention purges expired rows and fails safely under invalid configuration;
- cross-user access and per-person ADMIN browsing are absent;
- aggregate cells below five subjects are suppressed;
- development, test, synthetic, and Beta participant evidence remain isolated.

## Approval Record

Approved by Bruce Ann on 2026-07-23:

- Sprint 12 focus: Closed Beta Evidence and Recruitment Readiness;
- cohort: at most 20 invited adults aged 25-45 from the documented reflective
  knowledge-worker cohort;
- measurement: first-party typed events only, with no third-party analytics
  SDK;
- lifecycle: 180-day maximum and account-deletion hard deletion;
- aggregate privacy: small-cell suppression at five distinct subjects;
- support: Bruce Ann primary and `chao.fan` named backup, with mailbox and ADMIN
  access testing still required before recruitment.
