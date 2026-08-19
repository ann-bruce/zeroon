# Sprint 14 Record Reliability And Ownership V1

Status: Proposed — next planning candidate; implementation not started
Prepared: 2026-08-19
Backlog sources: `ZPB-P0-01`, `ZPB-P0-02`

## Intake Decision

### 1. Mainline fit

Reliable private capture and complete user ownership are prerequisites for a
long-term companion and private memory system. A user should not lose an
unsaved moment after a recoverable interruption and should be able to remove
one owned Record without deleting the entire account.

### 2. Drift risk

This Sprint must not become a general offline-sync platform, document version
system, recycle bin, cross-device draft service, or broad Archive redesign.
Implementation convenience must not create hidden soft deletion or leave
private content available to AI after deletion.

### 3. Recommended abstract capability

**Reliable user-owned capture lifecycle**: preserve an account-scoped local
draft until a Record is saved or deliberately discarded, and hard-delete one
owned Record together with every explicitly accepted dependent lifecycle.

### 4. Roadmap decision

Accept Sprint 14 as the next bounded planning candidate. It is not active until
the owner approves its deletion and draft-storage contracts.

### 5. Planning acceptance criteria

- drafts survive route exit, locale change, app restart, and recoverable save
  failure;
- logout, account switch, shared-device behavior, backup inclusion, and local
  discard are explicit;
- save retry cannot create a duplicate Record;
- one Record can be deleted only by its owner;
- linked Memory, continuity cue, Archive, Growth, export, and AI context follow
  one reviewed deletion lifecycle;
- draft and deleted content never enter evidence, logs, admin, or support data.

## Sprint Goal

Make the core Record lifecycle trustworthy before public release: unfinished
input is recoverable, saved input is idempotent, and one owned Record can be
removed completely and predictably.

## Scope

### Durable Reset draft

- one account-scoped draft for the active Reset flow;
- local persistence of moment text, optional direction, expansion state, and
  only the minimum state reference required to explain restoration;
- save only after user input changes, with bounded failure handling;
- restore without silently submitting or changing the current state;
- explicit discard and deterministic clear after confirmed save;
- no private draft content in analytics, diagnostics, logs, or cloud backup
  unless a separate reviewed decision permits it.

### One-Record deletion

- owner-only delete contract and confirmation copy;
- hard deletion of user-authored Record text;
- reviewed linked-Memory lifecycle;
- exclusion from continuity-cue selection;
- consistent Archive, Growth, export, and AI-context results;
- idempotent retry and cross-user `404` behavior;
- no administrator browser for deleted private content.

## Planned Work

| ID | Task | Surfaces | Done when |
|---|---|---|---|
| `S14-01` | Freeze draft and deletion contracts | product, privacy, architecture, docs | Account scope, logout, backup, discard, linked Memory, export, and hard-delete rules are accepted |
| `S14-02` | Implement local durable draft | mobile, local storage, localization, tests | Draft restores after route exit and app restart without leaking across accounts |
| `S14-03` | Close save idempotency and retry | backend, OpenAPI, mobile, tests | Repeated save intent creates at most one Record and failure copy remains truthful |
| `S14-04` | Implement owner-only Record deletion | backend, database, OpenAPI, tests | Owned delete is idempotent; cross-user access fails without existence disclosure |
| `S14-05` | Implement deletion experience | mobile, Archive, Detail, Memory, localization, tests | User sees scope before confirm and all affected surfaces refresh consistently |
| `S14-06` | Verify lifecycle end to end | backend, mobile, PostgreSQL, export, AI context, docs | Automated and local runtime evidence covers recovery, retry, isolation, deletion, and zero private-content logs |

## Affected Surfaces

- backend: Record deletion, idempotency, linked lifecycle;
- database: migration only if required by the accepted contract;
- OpenAPI: delete and any idempotency contract;
- mobile: local draft store, Reset restoration/discard, Detail deletion;
- Memory and companion: deleted source exclusion and immediate AI-context stop;
- Growth, Archive, continuity cue, and export: consistent recalculation;
- evidence: content-free outcome only if separately approved;
- docs and tests: product lifecycle, ownership, recovery, and failure cases.

## Acceptance Criteria

- draft survives process restart and language change;
- account A never sees account B's draft on a shared device;
- logout behavior matches the approved contract;
- success clears only the saved draft;
- retry after timeout does not duplicate a Record;
- delete removes the Record from Detail, Archive, cue, Growth, export, Memory,
  and future AI context according to the accepted lifecycle;
- direct and cross-user reads after delete do not expose existence;
- full relevant quality gates and a PostgreSQL-backed lifecycle smoke pass.

## Non-Goals

- Archive search or filters;
- Record edit/version history;
- cross-device draft sync;
- new AI reflection;
- templates, media, notification, payment, physical delivery;
- production deployment or App Store submission.

## Stop Rules

Stop or reshape if draft protection can leak across accounts, if deletion
cannot reliably remove content from AI context, if idempotency changes existing
Record meaning, or if implementation requires a broad sync platform.
