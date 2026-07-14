# Validation Sprint 00 Baseline V1

Date: 2026-07-14  
Status: In progress  

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
| RB-02 | P0 | Production can start with development JWT and database defaults | `application.yml` contains usable fallback values | Production release is blocked | Production profile fails fast on unsafe or missing secrets |
| RB-03 | P0 | Verification code path is local-only and abuse-prone | Static code, in-memory storage, code logged, no rate or attempt limit | Public authentication is blocked | Environment separation, sender, random code, TTL, throttling, attempt tests |
| RB-04 | P0 | Public anthropomorphic-service compliance path is incomplete | No complete age/minor, overuse, escalation, complaint, filing, or assessment workflow | Public China release is blocked pending professional review | Product, engineering, operations, and legal readiness checklist signed off |
| RB-05 | P1 | AI profile permission is stored but not applied to companion context | Profile module has the switch; Companion does not assemble profile context | AI-context beta claim is blocked | On/off tests prove disallowed context never reaches provider |
| RB-06 | P1 | Long-term memory has no production write/control loop | Memory query exists; record-to-memory flow and controls do not | Long-term-memory value claim is blocked | Source-linked memory can be created, viewed, deleted, disabled, and excluded from AI |
| RB-07 | P1 | External LLM call occurs inside companion transaction | `CompanionService.send` is transactional and calls provider | Real-provider scale is blocked | Provider timeout does not hold a long DB transaction; fallback persists correctly |
| RB-08 | P1 | Data export/account deletion contract and implementation are not aligned | Planned OpenAPI and actual endpoints differ | Wider paid beta is blocked | Contract reflects reality; minimum export/delete path is tested |
| RB-09 | P2 | Admin Hook warnings and large bundle remain | Lint warnings and Vite chunk warning | Does not block private beta | Warnings resolved; route-based code split evaluated |

## 8. Next Action

Start Sprint 08 Trust Foundation in this order:

1. administrator authorization and tests;
2. production configuration fail-fast;
3. verification-code environment and abuse boundary;
4. profile AI consent closure;
5. data-control and OpenAPI alignment.

Memory V1 design begins after these trust decisions are explicit, and can run
in the same 90-day Phase 1 only when it does not weaken the P0 sequence.
