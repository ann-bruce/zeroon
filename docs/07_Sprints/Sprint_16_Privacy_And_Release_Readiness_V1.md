# Sprint 16 Privacy And Release Readiness V1

Status: Planned sequence — blocked by Sprint 14 and Sprint 15 acceptance
Prepared: 2026-08-19
Backlog sources: release-bound `ZPB-P1-04`, `ZPB-P1-05`

## Intake Decision

### 1. Mainline fit

A private memory companion must be trustworthy before asking unknown App Store
users to leave sensitive moments. App access protection, understandable data
portability, production reliability, safety, support, and honest store claims
strengthen the core promise without expanding product scope.

### 2. Drift risk

Release work can become an excuse for new features, unreviewed marketing
claims, rushed compliance conclusions, or production changes without rollback.
App lock must not create unrecoverable account loss, and readable export must
not become a public-sharing feature.

### 3. Recommended abstract capability

**Trustworthy public-release boundary**: one frozen production candidate whose
private data, authentication, AI, support, export, deletion, device privacy,
observability, rollback, and store representation are coherent.

### 4. Roadmap decision

Plan Sprint 16 as a release-readiness Sprint with a feature freeze. Completion
means ready for an explicit owner release decision, not automatically deployed,
submitted, reviewed, or publicly available.

### 5. Planning acceptance criteria

- optional platform authentication protects app entry;
- background/app-switcher previews hide private text;
- portable machine-readable and readable export scopes are clear;
- production authentication, AI, support, deletion, and rollback paths pass;
- privacy, AI identity, age, support, and App Store statements are honest;
- no production or external action occurs without explicit authorization.

## Sprint Goal

Freeze expansion and produce one iOS/production candidate that is safe,
supportable, observable, reversible, and ready for App Store review materials.

## Planned Work

| ID | Task | Surfaces | Done when |
|---|---|---|---|
| `S16-01` | Freeze release scope and blocker matrix | product, engineering, operations, safety, docs | Every blocker has owner, evidence, consequence, and explicit release decision |
| `S16-02` | Add private app access protection | mobile, iOS, localization, tests | Optional system authentication, recovery, disable, and hidden background preview work without exposing private content |
| `S16-03` | Add bounded readable export | backend, OpenAPI, mobile, docs, tests | User can obtain portable machine-readable and readable copies with previewed scope and no social default |
| `S16-04` | Reverify production trust paths | auth, support, AI, consent, deletion, export, observability | Intended-environment success, outage, refusal, revoke, deletion, operator, and rollback evidence is current |
| `S16-05` | Prepare privacy and App Store package | product copy, privacy, support, assets, metadata | Store claims, screenshots, AI disclosure, privacy answers, contact, and age boundary match shipped behavior |
| `S16-06` | Build and verify production candidate | mobile iOS, backend, deployment, tests | Full gates, real-device regression, monitoring, rollback, and version evidence pass |
| `S16-07` | Record owner release decision | release docs, current state | Owner explicitly approves, defers, or rejects production deployment and App Store submission separately |

## Affected Surfaces

- iOS application security and lifecycle privacy;
- backend export and production configuration;
- email authentication, Redis, PostgreSQL, AI provider, support, and admin;
- consent, Memory/Profile context, account deletion, backup, and rollback;
- App Store metadata, screenshots, privacy answers, support URLs, and copy;
- release runbook, observability, incident ownership, tests, and evidence.

## Acceptance Criteria

- app lock is optional, recoverable, and covered on supported iOS devices;
- background previews contain no Record, Memory, profile, or AI text;
- exports preserve original text and exclude unrelated internal data;
- production email one-time, throttle, spam/outage, and recovery paths pass;
- AI success, fallback, refusal, safety, timeout, usage, and rollback pass;
- Memory/Profile consent disable affects the next response;
- support and account deletion are reachable and truthful;
- store assets make no therapy, diagnosis, guaranteed outcome, or paid-intimacy
  claim;
- full quality gates and production-candidate evidence pass;
- release and submission remain separately owner-authorized.

## Non-Goals

- Archive search, new reflection, templates, media, notification, or payment;
- public social sharing;
- production release merely because local tests pass;
- legal or professional-review claims without actual review;
- physical ZEROON implementation or fulfillment.

## Stop Rules

Stop release readiness if private content appears in previews or logs, account
exit/control is not operational, production dependencies cannot fail safely,
store claims exceed behavior, or rollback and support ownership are unclear.
