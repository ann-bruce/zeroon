# Validation Sprint 00 Baseline V1

Date: 2026-07-14  
Status: Completed

## 1. Baseline Decision

ZEROON has a working local MVP and a verified My ZEROON core path. It is not
ready for public production release.

The next implementation sprint will focus on trust foundations before Memory
V1, real-provider expansion, closed beta, payment, hardware, or crowdfunding.

## 2. Affected Surfaces

The 90-day validation program can affect:

- backend authentication, authorization, profile consent, companion, memory,
  AI, prompt, user, and operations modules;
- OpenAPI and Flyway migrations;
- Flutter authentication entry, My ZEROON, Reset, Archive, Growth, Profile,
  AI states, and privacy controls;
- React admin authentication, prompt operations, audit, and monitoring;
- tests, local services, release documentation, and beta measurement.

## 3. Current Worktree Inventory

The worktree contained user changes before Validation Sprint 00. They were
preserved.

Main uncommitted scope observed:

- Sprint 06 My ZEROON backend, migrations, tests, OpenAPI, mobile flow, and UI;
- Sprint 07 real-provider plan;
- profile and mobile integration changes;
- local workflow scripts and current-state documentation;
- project deep-analysis report.

No commit or push was performed.

## 4. My ZEROON Evidence

### Automated

- Backend tests cover unauthenticated access, initial `met=false`, creation,
  idempotency, ownership isolation, invalid companion key, and nameplate shape.
- Flutter test covers authenticated encounter before app entry.
- Full backend and mobile test suites pass.

### Runtime

An isolated local verification user was used.

- First `GET /me/zeroon-companion`: `met=false`.
- First meet request: `met=true`, `companionKey=ZEROON_DEFAULT`.
- Assigned nameplate matched `ZR-YYYYMMDD-XXXX`.
- Repeated meet request returned the same nameplate.

### Remaining acceptance gaps

- Visual review of the live encounter page is still required.
- First-load failure, meet failure, retry, and slow-network behavior need live
  experience verification beyond widget coverage.
- The requirement that ZEROON appear on selected later surfaces should be
  reviewed against visual-noise guardrails rather than treated as a quantity
  target.
- Sprint 06 plan status should not be changed to accepted until these gaps are
  resolved and recorded.

## 5. Quality Baseline

Command:

```bash
JAVA_HOME=/Users/bruceann/Library/Java/JavaVirtualMachines/corretto-17.0.13/Contents/Home \
  scripts/zeroon-verify.sh all
```

Result: passed.

| Gate | Result | Notes |
|---|---|---|
| Backend Gradle tests | Passed | Includes My ZEROON controller coverage |
| Flutter analyze | Passed | No issues |
| Flutter tests | Passed | 9 tests |
| Admin lint | Passed with warnings | Two React Hook dependency warnings remain |
| Admin production build | Passed with warning | Main JS chunk is about 1 MB before gzip |
| OpenAPI lint | Passed | Contract is syntactically valid |
| Backend health | Passed | Local service returned `UP` |
| `git diff --check` | Passed | No whitespace errors |

The first full run exposed a missing ESLint 9 flat configuration. Validation
Sprint 00 added `admin/eslint.config.js`; lint and build then passed.

## 6. Local Service Status

At baseline collection:

- backend: running on `127.0.0.1:8080`;
- mobile web: running on `127.0.0.1:4173`;
- admin: running on `127.0.0.1:5173`.

The backend served the current My ZEROON API during runtime verification.
No product behavior changed during the ESLint configuration fix, so no service
restart was required for that tooling-only change.

## 7. Release-Blocker Matrix

| ID | Severity | Finding | Evidence | Release consequence | Verification needed |
|---|---|---|---|---|---|
| RB-01 | Closed in S8-01 | Normal app tokens could access `/admin/**` | Database roles now enter signed tokens; `/admin/**` requires ADMIN | Automated USER 403 and ADMIN success pass; local USER 403 confirmed | Add mutation audit when admin write APIs are introduced |
| RB-02 | Closed in S8-02 | Production could start with development JWT and database defaults | Prod environment post-processor rejects unsafe JWT and PostgreSQL values; S8-03 extends checks to shared Redis and sender configuration | Public release remains blocked by compliance work and provider onboarding | Focused tests, unsafe prod boot failure, and full local/test regression passed |
| RB-03 | Engineering closed in S8-03 | Verification code path was local-only and abuse-prone | Prod now uses random one-time codes, Redis atomic state, HTTPS sender boundary, mobile/IP/device throttling, and five-attempt deletion; local-only beans are profile-isolated | Public authentication remains blocked until an SMS provider is onboarded and production delivery smoke passes | Controller/service/store tests, real Redis cross-instance test, safe prod-profile startup, and full quality gate passed |
| RB-04 | P0 | Public anthropomorphic-service compliance path is incomplete | No complete age/minor, overuse, escalation, complaint, filing, or assessment workflow; Sprint 11 now plans the reachable contact, complaint intake, operator audit, and escalation engineering subset | Public China release remains blocked pending professional review; Sprint 11 does not by itself close this blocker | Product, engineering, operations, and legal readiness checklist signed off |
| RB-05 | Closed in S8-04 | AI profile permission was stored but not applied to companion context | Companion now reads consent on every request and assembles only nickname, age range, occupation/identity, and self-description; avatar and inferred traits are excluded | AI-context beta claim is supported for the documented Profile fields | Capturing fake-provider test proves off/on/off behavior, immediate disable, whitelist inclusion, and excluded fields; full quality gate passed |
| RB-06 | Closed in S9-06 | Long-term memory control loop was incomplete | S9-01 through S9-05 establish visible, source-linked, owner-controlled Memory and consent-aware context; S9-06 closes provider transaction and observability boundaries | The engineering and configured-provider control loop, including mobile latency and consent-path review, is complete | Full quality gate, PostgreSQL V10 migration, fallback/refusal smoke, authenticated DeepSeek success smoke with exported content-free token metadata, and mobile runtime review |
| RB-07 | Closed in S9-06 | External LLM call occurred inside companion transaction | Companion orchestration now commits preparation, calls the provider with no active Spring transaction, then persists assistant/log completion in a short transaction | Provider timeout no longer holds a database transaction | Transaction-aware success/fallback tests, persisted fallback, metadata assertions, and full regression pass |
| RB-08 | Closed in S8-05 | Data export/account deletion contract and implementation were not aligned | `/me`, versioned JSON export, synchronous idempotent hard deletion, session revocation, mobile controls, and explicit deidentified-retention rules are implemented | Data-control engineering blocker is closed; jurisdiction-specific compliance review remains separate | Ownership isolation, credential exclusion, cascade deletion, retained-metadata deidentification, repeated deletion, logout ownership, mobile controller, Widget, OpenAPI, and full quality-gate tests pass |
| RB-09 | P2 | Admin Hook warnings and large bundle remain | Lint warnings and Vite chunk warning | Does not block private beta | Warnings resolved; route-based code split evaluated |

## 8. Next Action

Sprint 09 controllable-memory engineering, operational provider verification,
and mobile latency/consent-path review are complete. The next bounded sequence
is Sprint 10 Language and Locale Foundation followed by the independent Sprint
11 Help, Contact, and Feedback Foundation. Sprint 11 provides reachable,
private, trackable support engineering before wider Beta recruitment while
keeping professional compliance review separate.

Public release remains blocked by RB-03 provider onboarding and RB-04
professional compliance review; neither blocker authorizes widening Memory
scope into hidden profiling or diagnosis.
