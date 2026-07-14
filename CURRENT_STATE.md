# ZEROON Current State

Last updated: 2026-07-14

This file is the short handoff for new Codex threads. Read it before scanning long docs or old sessions.

## Project Path

```text
/Users/bruceann/codexspace/zeroon/ZEROON_PROJECT/10_TECH/zeroon
```

## Current Branch

```text
feature/s9-05-consent-aware-memory-context
```

## Current Focus

90-day product validation: Phase 2 controllable memory and real AI.

Sprint 08 trust-foundation engineering is complete. Sprint 09 now turns the
existing read-only Memory placeholder into user-controlled reflective
continuity before a real provider is expanded.

Immediate execution order:

- accept the Memory V1 source, ownership, activation, AI-use, and deletion model;
- create an idempotent record-to-memory production path;
- add owner-only enable, AI-use, and hard-delete controls;
- expose those controls in mobile without pressure or personality labels;
- assemble only explicitly allowed memory into AI context;
- move provider calls out of long database transactions and verify observability.

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
- Current engineering sprint: `docs/07_Sprints/Sprint_09_Controllable_Memory_V1.md`
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
  personality labels, diagnoses, or scores. Profile AI consent remains a
  separate gate for profile fields. Capturing fake-provider tests cover
  default-off, allow, pause, revoke, expiry, cross-user isolation, and bounds.
  Private Memory text is excluded from usage metadata. Mobile now exposes an
  editable `aiContextEnabled` switch with local success and failure feedback.
  S9-06 provider transaction and observability is next.

## Recent Completed Work

Recent commits on `main`:

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
- Roadmap IA: `docs/07_Sprints/Roadmap_Information_Architecture_V2.md`
- API contract: `docs/04_API/OpenAPI_V1.yaml`
- Engineering guide: `docs/05_Engineering/Development_Guide_V1.md`
- Done criteria: `docs/05_Engineering/Definition_of_Ready_Done.md`

## Handoff Notes

- Current workflow improvements are uncommitted unless `git status --short` says otherwise.
- Do not commit or push unless the user explicitly asks.
- Before implementing validation work, verify whether backend, OpenAPI, mobile model/repository, mobile UI, admin, database, docs, tests, and local services are affected.
- For product ideas, use the ZEROON guardrail flow: mainline fit, drift risk, abstraction, roadmap decision, acceptance criteria.
