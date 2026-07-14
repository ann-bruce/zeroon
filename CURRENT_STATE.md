# ZEROON Current State

Last updated: 2026-07-14

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

90-day product validation: Phase 0 baseline and scope freeze.

Goal: determine whether ZEROON can become a sustainable long-term companion
and private memory product by validating trust, retained use, reflective
continuity, and real willingness to pay.

Immediate execution scope is Validation Sprint 00:

- inventory and verify the current uncommitted Sprint 06 / My ZEROON work;
- establish the current backend, mobile, admin, OpenAPI, and service baseline;
- freeze one beta promise and target cohort;
- define the beta event dictionary without collecting private record or message content;
- create a release-blocker matrix;
- prepare the trust-foundation implementation sprint.

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
- Next engineering sprint: `docs/07_Sprints/Sprint_08_Trust_Foundation_V1.md`
- Phase 0 dates: 2026-07-14 to 2026-07-20
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
  content. S8-05 data-control and contract alignment is next.

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
