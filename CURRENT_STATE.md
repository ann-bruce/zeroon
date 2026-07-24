# ZEROON Current State

Last updated: 2026-07-24

This file is the short handoff for new Codex threads. Read it before scanning long docs or old sessions.

## Project Path

```text
/Users/bruceann/codexspace/zeroon/ZEROON_PROJECT/10_TECH/zeroon
```

## Current Branch

```text
main
```

## Current Focus

90-day product validation: Sprint 11 is complete; Sprint 12 Closed Beta
Evidence and Recruitment Readiness is approved; S12-01 through S12-05 are
complete. S12-06 engineering and local runtime acceptance is complete, while
the real first invitation remains blocked by external launch gates.

Sprint 08 trust-foundation engineering, Sprint 09 controllable-memory
engineering, the approved real-provider success smoke, and the mobile latency
and consent-path audit are complete and integrated into `main` at `93b6a44`.
Sprint 10 has closed with a complete Simplified Chinese/English interaction
language foundation. Sprint 11 has closed with reachable, private, trackable
contact and feedback plus real operator handling. Sprint 12 is now explicitly
approved for privacy-preserving closed-Beta evidence and recruitment readiness;
previously undocumented Sprint 10 scope was not reconstructed or approved.

Immediate execution order:

- S10-01 locale architecture and string inventory are complete in ADR 005 and
  the accepted Sprint 10 inventory;
- S10-02 Flutter localization, deterministic locale resolution, pre-auth
  persistence, and no-flash startup behavior are complete;
- S10-03 explicit account preference, migration, API, export V2, and device
  synchronization are complete without mixing language with Profile AI consent;
- S10-04 discoverable Login/Settings controls and complete mobile copy
  localization are complete;
- S10-05 provider instruction, fallback, refusal, and safety-path localization
  is complete;
- S10-06 full regression and two-locale runtime acceptance are complete;
- original Record, Memory, Profile, and conversation content remains unchanged
  and is never used to infer identity or interaction language;
- S12-01 evidence policy and lifecycle are complete in ADR 007;
- S12-02 typed event contract and persistence are complete;
- S12-03 content-free core-loop instrumentation and failure isolation are
  complete;
- S12-04 cohort and retention computation is complete;
- S12-05 ADMIN-only, aggregate-only evidence operations is complete with a
  five-subject cohort minimum and backend-derived small-cell suppression;
- S12-06 adds the bilingual adult-only notice, default-off evidence choice,
  truthful fresh-login and existing-user re-introduction ordering, recoverable
  Settings control, export V5, PostgreSQL V16, recruitment/interview kit, and
  launch runbook. Engineering and local runtime acceptance are complete;
- do not send the first invitation until SMTP email delivery, one-time code
  consumption, spam placement, and outage behavior are tested in the intended
  environment; approved real-provider checks, Bruce Ann/Chao Fan mailbox and
  least-privilege ADMIN
  access tests, and production-like isolation/outage/deletion rehearsal are
  recorded.

Key product guardrails:

- Profile fields are optional and private by default.
- AI can use profile context only when the user enables it.
- Long-term memory must be visible, source-linked, deletable, and disableable.
- Paid value must come from continuity and control, not emotional closeness.
- Do not add public profile pages, social identity fields, AI-generated personality labels, diagnosis, scoring, or fixed user classification.
- Keep ZEROON positioned as long-term companionship and private memory, not a narrow emotional tool.

## Active Roadmap

- 90-day validation plan: `docs/08_Roadmap/ZEROON_90_Day_Product_Validation_Plan_V1.md`
- Validation baseline: `docs/08_Roadmap/Validation_Sprint_00_Baseline_V1.md`
- Beta brief: `docs/01_PRD/Beta_Validation_Brief_V1.md`
- Current engineering sprint: `docs/07_Sprints/Sprint_12_Closed_Beta_Evidence_Readiness_V1.md`
- Evidence decision: `docs/02_Architecture/ADR_007_Beta_Evidence_Event_Lifecycle_V1.md`
- Memory decision: `docs/02_Architecture/ADR_004_Memory_V1.md`
- Phase 2 target window: 2026-08-11 to 2026-08-31; engineering began early
  after Sprint 08 closure.
- Day-90 review: 2026-10-12
- Sprint 06 implementation exists in the worktree but must not be marked
  accepted until code, contract, tests, and local UI evidence are verified.
- Sprint 07 remains a draft; real-provider work follows trust and consent
  baseline decisions.
- Full local quality gate passed on 2026-07-14 after adding the missing admin
  ESLint flat configuration. Two non-blocking React Hook warnings remain.
- Sprint 08 S8-01 administrator authorization is implemented: roles are backed
  by `user_roles`, included in signed access tokens, and `/api/v1/admin/**`
  requires ADMIN. Automated USER/ADMIN tests pass and local USER access returns
  403. Production admin provisioning and future mutation audit remain
  operational follow-ups.
- Sprint 08 S8-02 production fail-fast is complete: the `prod` profile rejects
  missing, short, development, or example JWT and PostgreSQL password values
  before the Spring application context is created. Focused tests, an expected
  unsafe-prod startup failure, and the full quality gate passed.
- Sprint 08 S8-03 verification-code environment boundary is complete:
  development keeps fixed logged codes and in-memory state, while `prod` uses
  secure random codes, Redis-backed atomic one-time state, email/IP/device
  throttling, and a five-failure cap. On 2026-07-24 email verification replaced
  SMS as the first closed-Beta channel; SMTP is fail-fast and bounded by
  connection/read/write timeouts, while legacy SMS is disabled by default.
  Dependency outages return 503 and limits return 429 with `Retry-After`.
  Intended-environment email delivery and outage smoke remain operational
  release blockers.
- Sprint 08 S8-04 AI profile consent closure is complete: Companion rereads
  consent for every request and includes only the user's nickname, age range,
  occupation or identity, and self-description when enabled. Avatar presets,
  inferred traits, and personality labels are excluded. Capturing-provider
  tests prove off/on/off behavior and immediate disable without logging prompt
  content.
- Sprint 08 S8-05 data-control and contract alignment is complete. Implemented
  endpoints are `GET /api/v1/me`, `GET /api/v1/me/export`, and idempotent
  `DELETE /api/v1/me/deletion`; the obsolete planned `/users/me` and `202`
  deletion claim were removed. The mobile settings page now exposes JSON data
  copy, remote-backed logout, and confirmed account deletion. Hard deletion
  removes private content and sessions before returning while only explicitly
  documented deidentified AI/audit metadata may remain. Sprint 08 engineering
  scope is complete; compliance readiness and real email-delivery acceptance
  remain release blockers.
- Sprint 09 S9-01 Memory V1 foundation is complete. The accepted decision
  separates reversible memory activation from per-entry AI-use permission,
  defaults AI use off, requires source ownership, and hard-deletes memory
  content. V9 adds control/update fields and source idempotency, and passed a
  real PostgreSQL migration.
- Sprint 09 S9-02 record-to-memory production is complete. A committed record
  publishes a post-commit event; an independent transaction creates one
  private source-linked Memory from bounded user-authored text, with AI use
  still off. Duplicate saves are idempotent and repair a missing entry, while
  simulated Memory failures leave the record response and persistence intact.
- Sprint 09 S9-03 Memory management API is complete. Owner-only PATCH changes
  explicitly supplied activation and AI-use preferences; disable preserves the
  preference but makes it ineffective. DELETE hard-deletes Memory content.
  Empty updates return 400 and missing, expired, or cross-user resources return
  404.
- Sprint 09 S9-04 mobile Memory management is complete. Archive now has a
  restrained Memory entry; users can inspect source records, pause/re-enable a
  Memory with local feedback, and confirm hard deletion while keeping the
  source Zero Record.
- Sprint 09 S9-05 consent-aware Memory context assembly is complete. Companion
  prompts include only owned, enabled, AI-permitted, unexpired Memory within
  count and character bounds, with source class and source id and without
  personality labels, diagnoses, or scores. Raw recent Zero Record goal/content
  is no longer injected outside that path, so pause, AI-permission revoke, and
  Memory deletion keep source text out of the next provider request. Profile AI
  consent remains a separate gate for profile fields. Capturing fake-provider
  tests cover default-off, allow, pause, revoke, expiry, cross-user isolation,
  bounds, and Record→Memory control bypass regression. Private Memory text is
  excluded from usage metadata. Mobile exposes an editable `aiContextEnabled`
  switch with honest paused-state copy and local success/failure feedback.
  Mobile completion and Archive observation prompts also stay abstract instead
  of rebuilding Record state/goal/content; Widget tests cover both request paths
  plus the Archive loading and recoverable retry states.
- Sprint 09 S9-06 provider transaction and observability is complete.
  Companion now commits user-message preparation, performs consent-aware reads,
  calls `LlmProvider.generate` with no active Spring transaction, then persists
  the assistant message and usage row in a short completion transaction.
  Transaction-aware tests cover success and fallback, refusal still bypasses
  the provider, and V10 adds optional provider-reported input/output token
  counts without storing prompt, Memory, record, message, reply, or exception
  body text. Sprint 09 engineering and the approved real-provider credential
  smoke are complete and integrated into `main` at `93b6a44`.
- Sprint 10 Language and Locale Foundation is complete. It supports Follow
  System, Simplified Chinese, and English across mobile and bounded companion
  behavior, while preserving all user-authored content in its original form.
  Sprint 11 Help, Contact, and Feedback Foundation follows as a separate Beta
  gate with real operator handling, receipt/status tracking, privacy-safe
  diagnostics, and pre-auth/outage fallback contact. Any previously discussed
  but undocumented Sprint 10 scope moves to Sprint 12.
- S10-01 is complete. ADR 005 fixes the canonical preferences, device/account
  synchronization, `Accept-Language` request boundary, `users` persistence,
  dedicated `/me/preferences/language` contract, export V2 decision, and
  original-content boundary. The accepted string inventory maps every current
  mobile, formatter, error, accessibility, prompt, fallback, refusal, and safety
  surface before localization implementation begins.
- S10-02 is complete. Flutter now generates typed `zh`, `zh_CN`, and `en`
  resources, restores the non-sensitive device preference before `runApp`,
  resolves only effective `zh-CN` or `en`, exposes immediate Riverpod locale
  state, persists pending account synchronization through SharedPreferences,
  and keeps the selected session locale when device persistence fails. Focused
  first-frame, resolution, persistence, and failure tests pass with the full
  mobile suite.
- S10-03 is complete. PostgreSQL V11 adds the constrained account preference;
  login, refresh, `GET /me`, owned `GET/PUT /me/preferences/language`, and export
  V2 expose the same enum. Mobile applies pending-device-wins/account-wins
  synchronization with stale-response protection and sends only resolved
  `zh-CN` or `en` in `Accept-Language`. Full backend/mobile tests, OpenAPI lint,
  real PostgreSQL migration, and a temporary-account update/read/export/delete
  runtime smoke pass.
- S10-04 is complete. A language-neutral Login globe and independent
  Profile/Settings preference switch the device immediately while preserving
  pending account synchronization. All shipped mobile screens, shared states,
  privacy controls, AI boundary copy, dates, times, durations, and dynamic
  values now use typed Simplified Chinese and English resources; raw technical
  errors are mapped to recoverable product copy. Flutter analyze and all 28
  mobile tests pass, and desktop plus 390×844 runtime review confirms the
  Chinese picker and English Login layout do not clip or overlap. User-authored
  content remains unmodified.
- S10-05 is complete. Companion now resolves weighted supported
  `Accept-Language` ranges before concrete account preference and Simplified
  Chinese fallback, without inspecting message or private context. The
  resolved language composes a reviewed Provider instruction and selects
  server-owned fallback, refusal, and safety copy. Chinese and English terms
  retain the same safety categories and deterministic refusals still bypass
  the Provider. Full backend tests, OpenAPI lint, and a PostgreSQL-backed
  temporary-account runtime smoke for account-English/header-Chinese
  precedence pass; the temporary account was deleted.
- S10-06 is complete. Logout retains the selected device language and an
  in-progress Reset preserves its route and unsaved text during immediate
  switching. All 29 mobile tests and the full backend/mobile/admin/OpenAPI
  quality gate pass. A real provider success smoke returned language-coherent
  English and Chinese replies and safety notices; a 390×844 runtime review
  covered signed-out and authenticated switching plus post-logout retention
  without clipping, overlap, or mixed-language product state. PostgreSQL
  remains current at migration V11, the temporary account was deleted, and
  Sprint 11 is now the next engineering focus.
- Sprint 11 S11-01 through S11-06 are complete. ADR 006 accepts the human-operated
  support lifecycle: authenticated private requests, an immutable packaged
  pre-auth/outage fallback, explicit categories and owner roles, constrained
  status transitions, human response language, bounded opt-in diagnostics,
  opaque owner-scoped idempotency, export, account-deletion hard deletion, and
  a 180-day maximum after closure. `zeroon_ai@outlook.com` is the packaged
  fallback and Bruce Ann is the accountable primary for the closed Beta. There
  is no SLA or continuous-coverage claim. Chao Fan is now the named backup,
  but mailbox and ADMIN access testing remains required before recruitment.
- S11-02 implements the private support-request foundation. PostgreSQL V12,
  test schema, JPA, OpenAPI, and export V3 align on opaque references,
  owner-scoped idempotency, bounded categories/text, opt-in allowlisted
  diagnostics, five-per-hour creation and twenty-per-hour follow-up limits,
  owned list/detail/follow-up, visible status history, and deletion cascade.
  Automated tests cover authentication, cross-user isolation, identical and
  conflicting retries, unknown diagnostics, rate limiting, closed follow-up,
  export visibility, and hard deletion. Full quality gates and a two-account
  PostgreSQL runtime smoke pass; both temporary accounts were deleted. Next is
  S11-03 adds bilingual Login and Settings contact entry, a category and
  description form with exact draft preservation and stable retry identity,
  opt-in previewed diagnostics, a packaged outage fallback to
  `zeroon_ai@outlook.com`, and an honest copyable receipt. Focused tests and the
  full 34-test mobile suite pass. A real 390x844 Chinese/English runtime flow
  created one opaque support reference and then deleted the temporary account
  and its support data.
- S11-04 adds the owner-scoped My support requests list, request detail,
  user-visible human messages, status history, waiting-for-user guidance, and
  exact-content follow-up with local retry and closed-state boundaries.
  Simplified Chinese and English empty, loading, error, status, reply,
  progress, and follow-up copy is complete. All 42 mobile tests pass. A real
  390x844 PostgreSQL-backed temporary-account flow covered empty list, create,
  receipt, detail, follow-up, list refresh, and Chinese/English rendering
  before account deletion cascaded the support data.
- S11-05 adds PostgreSQL V13, ADMIN-only support queue/detail/mutations,
  self-assignment, reviewed escalation, constrained human reply transitions,
  strictly separated internal notes, and content-free request-scoped audit.
  Owner APIs and export continue to exclude internal handling data. Automated
  authorization, lifecycle, isolation, audit, and deletion tests plus the full
  backend/mobile/admin/OpenAPI gate pass. A temporary owner and ADMIN completed
  the real PostgreSQL queue-to-`WAITING_FOR_USER` flow with six audited
  mutations and full cleanup, and the Admin workbench passed visual review.
  S11-06 follows with final privacy, abuse, and runtime acceptance.
- S11-06 closes Sprint 11 with hourly automated 180-day support retention,
  dependent-row cascade tests, follow-up throttling evidence, and explicit
  LLM/Memory/Profile isolation. The support page discloses the in-app and
  external-email retention boundary in Chinese and English. Full quality gates
  pass. A real PostgreSQL three-account flow proved cross-user isolation,
  human operator handling, eight audit rows, export isolation, zero AI usage,
  scheduled purge, and complete cleanup; 390x844 English/Chinese and
  backend-outage review also pass. Public release remains subject to the
  existing professional compliance gates.
- Sprint 12 Closed Beta Evidence and Recruitment Readiness is approved. S12-01
  fixes first-party typed content-free events, explicit and revocable Beta
  evidence collection, an Asia/Shanghai calendar policy, a 180-day maximum,
  account-deletion hard deletion, aggregate-only ADMIN access, and suppression
  below five participants. Chao Fan is the named backup support operator;
  mailbox and ADMIN access testing still blocks the first invitation.
- S12-02 typed event contract and persistence is complete. PostgreSQL V14 adds
  owner-cascading evidence subjects and typed content-free event columns with
  default-off notice-bound collection, subject-scoped idempotency/conflict,
  event throttling, and a seven-day queued-date window. Export V4 exposes only
  owned reviewed evidence, account deletion hard-deletes it, and the hourly UTC
  worker enforces the 180-day maximum. All 15 approved event shapes, unknown
  field rejection, disable/no-backfill, cross-user isolation, rate limiting,
  export, deletion, and retention are covered. All 122 backend tests, OpenAPI
  lint, real PostgreSQL V14 migration, and a temporary-account runtime smoke
  pass with full cleanup.
- S12-03 core-loop instrumentation is complete. Flutter emits the reviewed
  content-free events for authentication, first encounter, manual state
  selection, Reset and record save/failure, Archive/detail review, reflection,
  Memory controls, Profile AI-context consent, export, and deletion intent.
  Events use an in-memory 50-item/seven-day queue, stable UUID retries,
  Asia/Shanghai dates, enums/booleans/buckets only, and best-effort failure
  isolation. Companion responses expose only reviewed outcome, latency,
  prompt-family version, provider-path alias, and enabled context-class names;
  no prompt, Profile, Memory, Record, message, or reply content is added.
  Login now truthfully distinguishes the account-creation response from an
  existing account. Support content remains deliberately uninstrumented
  because S12-01 approved no support-event contract. Flutter analyze, all 46
  mobile tests, all 122 backend tests, OpenAPI lint, and whitespace checks pass.
  PostgreSQL runtime acceptance covered the new-account flag, collection-off
  no-store behavior, bounded refusal metadata, and temporary-account deletion;
  it also caught and corrected a fallback-prompt alias mismatch.
- S12-04 adds a pure aggregate calculator for activation, D1/D7/D30,
  week-two Record, continuity/chat-only, reliability, AI outcome/latency,
  consent control, export, and deletion demand. Every metric preserves its
  numerator and denominator and returns null for immature/empty rates. The
  reviewed Profile AI-context-control visibility event closes the original
  activation gap without screen dwell, identity, or private content; V15 only
  extends the event constraint. All 126 backend and 46 mobile tests, Flutter
  analyze, OpenAPI lint, whitespace validation, and a PostgreSQL
  store/export/delete runtime smoke pass with zero temporary rows.
- S12-05 adds `GET /api/v1/admin/evidence/cohorts` and a read-only React Beta
  Evidence view. Cohorts below five expose neither actual size nor metrics;
  eligible reports independently suppress non-zero groups, event counts, and
  distribution cells contributed by fewer than five subjects. ADMIN/USER
  boundaries, invalid windows, safe zeroes, and suppression are automated.
  Local runtime acceptance verified the whole-report suppression state and
  responsive admin layout.
- S12-06 engineering and local runtime acceptance adds a bilingual adult-only
  notice before the measured encounter, optional default-off evidence choice,
  separate interview consent, real existing-user re-introduction, recoverable
  Settings control, export V5, PostgreSQL V16, and the recruitment/launch
  materials. Runtime proved notice enforcement, ordered fresh-login events,
  disable/no-store, deletion, and cleanup. The combined S12-05/S12-06 gate
  passes with 142 backend and 51 mobile tests plus Flutter, Admin, OpenAPI, and
  whitespace checks. Email verification now replaces SMS; legacy SMS is
  disabled and fails closed. Review added normalized unique email identity,
  Redis-backed one-time/rate boundaries, a stable per-install device id,
  bounded SMTP timeouts, bilingual delivery copy, owned `/me` and export email,
  and a production login page with no development prefill. Local PostgreSQL
  acceptance proved email login, Export V5, SMS `503`, deletion `204`, revoked
  refresh, consumed code, and zero temporary users. Real invitations remain
  blocked by intended-environment SMTP delivery/one-time/spam/outage
  acceptance, operator access, and the isolation/outage/deletion gates.

## Recent Completed Work

Recent commits on `main`:

- `93b6a44 Harden companion provider boundaries and observability`
- `b823660 Add mobile profile settings screen`
- `0285d59 Add user profile API foundation`
- `3b1b82f Decide sprint five settings entry`
- `ea6361f Detail sprint five profile settings plan`
- `4ee1729 Close sprint four MVP scope`

## Local Services

Standard ports:

- backend: `http://127.0.0.1:8080`
- mobile web: `http://127.0.0.1:4173`
- admin: `http://127.0.0.1:5173`

Standard scripts:

```bash
scripts/zeroon-service.sh status all
scripts/zeroon-service.sh start all
scripts/zeroon-service.sh restart mobile
scripts/zeroon-verify.sh quick
scripts/zeroon-snapshot.sh
```

Default API base URL for local web verification:

```text
http://127.0.0.1:8080/api/v1
```

## Validation Shortcuts

Use focused checks when possible:

```bash
scripts/zeroon-verify.sh quick
scripts/zeroon-verify.sh backend
scripts/zeroon-verify.sh mobile
scripts/zeroon-verify.sh admin
scripts/zeroon-verify.sh all
```

`quick` checks OpenAPI lint, backend health if running, and `git diff --check`.

## Documentation Anchors

- 90-day validation plan: `docs/08_Roadmap/ZEROON_90_Day_Product_Validation_Plan_V1.md`
- Sprint 06 plan: `docs/07_Sprints/Sprint_06_My_ZEROON_Companion_V1.md`
- Sprint 07 draft: `docs/07_Sprints/Sprint_07_AI_Provider_Integration_V1.md`
- Sprint 10 plan: `docs/07_Sprints/Sprint_10_Language_Locale_Foundation_V1.md`
- Sprint 10 locale ADR: `docs/02_Architecture/ADR_005_Language_Locale_V1.md`
- Sprint 10 string inventory: `docs/07_Sprints/Sprint_10_String_Inventory_V1.md`
- Sprint 11 plan: `docs/07_Sprints/Sprint_11_Help_Contact_Feedback_Foundation_V1.md`
- Sprint 11 support lifecycle ADR: `docs/02_Architecture/ADR_006_Support_Request_Lifecycle_V1.md`
- Roadmap IA: `docs/07_Sprints/Roadmap_Information_Architecture_V2.md`
- API contract: `docs/04_API/OpenAPI_V1.yaml`
- Engineering guide: `docs/05_Engineering/Development_Guide_V1.md`
- Done criteria: `docs/05_Engineering/Definition_of_Ready_Done.md`

## Handoff Notes

- Current workflow improvements are uncommitted unless `git status --short` says otherwise.
- Do not commit or push unless the user explicitly asks.
- Before implementing validation work, verify whether backend, OpenAPI, mobile model/repository, mobile UI, admin, database, docs, tests, and local services are affected.
- For product ideas, use the ZEROON guardrail flow: mainline fit, drift risk, abstraction, roadmap decision, acceptance criteria.
