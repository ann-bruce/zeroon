# ZEROON Current State

Last updated: 2026-07-22

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

90-day product validation: Sprint 10 language and locale foundation.

Sprint 08 trust-foundation engineering, Sprint 09 controllable-memory
engineering, the approved real-provider success smoke, and the mobile latency
and consent-path audit are complete and integrated into `main` at `93b6a44`.
Sprint 10 now establishes a complete Simplified Chinese/English interaction
language foundation before further user-facing expansion. Sprint 11 separately
establishes reachable, private, trackable contact and feedback with real
operator handling. Previously discussed but undocumented Sprint 10 scope is
reserved as Sprint 12.

Immediate execution order:

- complete S10-01 locale architecture and string inventory before code edits;
- establish Flutter localization and deterministic locale resolution;
- add explicit account preference without mixing it with Profile AI consent;
- localize mobile, provider instruction, fallback, refusal, and safety paths;
- prove original Record, Memory, Profile, and conversation content is never
  translated or used to infer identity.
- after Sprint 10 acceptance, implement Sprint 11 contact paths that remain
  reachable before login and during API outage without automatic private-content
  attachment.

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
- Current engineering sprint: `docs/07_Sprints/Sprint_10_Language_Locale_Foundation_V1.md`
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
  secure random codes, Redis-backed atomic one-time state, an HTTPS sender,
  mobile/IP/device throttling, and a five-failure cap. Redis/sender safety is
  fail-fast, dependency outages return 503, and limits return 429 with
  `Retry-After`. SMS-provider onboarding and a real delivery smoke remain
  operational release blockers.
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
  scope is complete; compliance readiness and SMS-provider onboarding remain
  release blockers.
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
- Sprint 10 Language and Locale Foundation is planned. It supports Follow
  System, Simplified Chinese, and English across mobile and bounded companion
  behavior, while preserving all user-authored content in its original form.
  Sprint 11 Help, Contact, and Feedback Foundation follows as a separate Beta
  gate with real operator handling, receipt/status tracking, privacy-safe
  diagnostics, and pre-auth/outage fallback contact. Any previously discussed
  but undocumented Sprint 10 scope moves to Sprint 12.

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
- Sprint 11 plan: `docs/07_Sprints/Sprint_11_Help_Contact_Feedback_Foundation_V1.md`
- Roadmap IA: `docs/07_Sprints/Roadmap_Information_Architecture_V2.md`
- API contract: `docs/04_API/OpenAPI_V1.yaml`
- Engineering guide: `docs/05_Engineering/Development_Guide_V1.md`
- Done criteria: `docs/05_Engineering/Definition_of_Ready_Done.md`

## Handoff Notes

- Current workflow improvements are uncommitted unless `git status --short` says otherwise.
- Do not commit or push unless the user explicitly asks.
- Before implementing validation work, verify whether backend, OpenAPI, mobile model/repository, mobile UI, admin, database, docs, tests, and local services are affected.
- For product ideas, use the ZEROON guardrail flow: mainline fit, drift risk, abstraction, roadmap decision, acceptance criteria.
