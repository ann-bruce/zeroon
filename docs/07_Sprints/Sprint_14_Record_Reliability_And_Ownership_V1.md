# Sprint 14 Record Reliability And Ownership V1

Status: Active — `S14-06` automated and PostgreSQL runtime gates complete;
real iOS process-restart acceptance pending
Prepared: 2026-08-19
Started: 2026-08-19
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

Sprint 14 entered active execution on 2026-08-19. `S14-01` reconciled the
current Record, Memory, AI-context, export, evidence, and mobile behavior and
accepted the lifecycle contract below.

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

## S14-01 Accepted Lifecycle Contract

Accepted on 2026-08-19 after repository baseline reconciliation.

### Verified baseline

- Reset text currently exists only in widget memory. It survives the current
  locale rebuild but not route disposal or process restart.
- Record creation currently suppresses matching content within ten seconds.
  It has no client intent key or database uniqueness boundary, so it can merge
  two intentional matching Records and cannot safely resolve a late retry.
- Record detail, backend, mobile repository, and OpenAPI currently have no
  single-Record deletion operation.
- Each produced `ZERO_RECORD` Memory has exactly one Record source under a
  unique `(user_id, source_type, source_id, type)` boundary. The current model
  has no multi-source Memory.
- continuity cue, Growth, Archive, export, and Memory AI context read live
  Record or Memory state; they do not require preserved Record text after
  deletion.
- state-session references already use `ON DELETE SET NULL`. Content-free
  evidence has no approved Record content field.

### Draft contract

- Keep at most one device-local Reset draft per authenticated user UID.
- Persist moment text, optional direction, whether the direction field is
  expanded, and the minimum state-session reference needed to explain restore.
- Restore across route exit, locale change, recoverable save failure, and app
  process restart. Never submit, start/end state, or emit product evidence on
  restore.
- Exclude the draft from device/cloud backup and cross-device sync. App removal
  may remove the draft and the UI must not promise recovery after uninstall.
- Explicit discard, logout, account deletion, or terminal session expiry clears
  the affected account draft. Account A can never read account B's draft.
- A confirmed save clears only the matching draft. Failed or ambiguous save
  keeps it until the idempotent retry resolves.
- Draft text never enters analytics, logs, diagnostics, admin, support, or an
  API request other than the user's explicit Record save.

### Save-idempotency contract

- Create one stable opaque intent key when a new draft begins and retain it
  through retries and process restart.
- Send that key as `Idempotency-Key`; persist a user-scoped unique key with the
  Record. The same key and same normalized payload returns the original Record
  regardless of elapsed time and does not republish commit side effects.
- Reusing a key with a different normalized payload returns conflict. Two
  deliberate saves with identical text but different keys create two Records.
- Resolve an existing key before reading or ending an active state session so
  a late retry cannot close a newer session.

### Record-deletion contract

- Add owner-authenticated `DELETE /api/v1/records/{recordId}`. The first
  successful deletion returns `204`; absent, already deleted, and cross-user
  targets expose no private data and use the common not-found boundary.
- Hard-delete the owned Record and its current single-source `ZERO_RECORD`
  Memory in one transaction. Do not retain a soft-deleted content copy.
- Database `ON DELETE SET NULL` detaches the historical state session without
  deleting the state interval itself.
- Archive, Record Detail, continuity cue, Growth, export, Memory, and future AI
  context reflect deletion on their next read. Cached mobile providers are
  invalidated after success.
- Existing content-free aggregate evidence may remain, but Record id, text,
  state, goal, preview, Memory text, and deletion target never enter a deletion
  event, log, audit payload, or admin surface.
- Existing encrypted database backups age out under the separately approved
  retention policy; deletion does not make an untruthful instantaneous-backup
  erasure promise, and deleted live data must not be restored as active data.

### Implementation boundary

`S14-02` through `S14-06` may now implement this contract. Any need for
cross-device sync, recycle bin, Record editing, multi-source Memory, or content
retention requires a new owner decision rather than an implementation shortcut.

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

## Progress Evidence

### S14-02 Durable local Reset draft — engineering complete 2026-08-19

- Added one encrypted, account-keyed device-local draft containing only moment
  text, optional direction, expansion state, state-session reference, and an
  opaque future idempotency key.
- iOS storage is non-synchronizing and uses `first_unlock_this_device`;
  Android application backup is disabled so encrypted preferences are not
  copied into Google backup. No draft API, evidence property, log, admin, or
  support surface was added.
- Reset restores after widget/route recreation, preserves edits with a bounded
  debounce, gives a quiet recovery receipt, and offers explicit confirmed
  clearing without adding a modal tutorial or performance mechanic.
- Logout, remote-revocation failure, account deletion, and terminal session
  expiry attempt account-specific draft cleanup without blocking safe exit.
- `flutter analyze` passed with no issue and the full `flutter test` suite
  passed 80 tests, including restore, persistence, cross-account isolation,
  discard, logout, failed remote logout, and account-deletion cleanup.
- Real iOS process-restart, uninstall expectation, and device logout checks
  remain part of `S14-06`; no runtime acceptance is claimed yet.

### S14-03 Save idempotency and retry — engineering complete 2026-08-20

- Added PostgreSQL migration V20 with a nullable user-scoped idempotency key,
  normalized-request fingerprint, pair constraint, and partial unique index.
- Current Flutter clients send the draft's stable opaque intent key through
  `Idempotency-Key`; failed and late retries retain the same key.
- Record creation locks the owning user row, resolves an existing key before
  reading or ending an active state session, and returns the original Record
  without replaying Memory or other commit side effects.
- Reusing one key with a different normalized payload returns `409`. Matching
  text with different intent keys remains two deliberate Records; the former
  ten-second content heuristic was removed.
- OpenAPI and the database model document the boundary. The key and fingerprint
  are not returned, exported, logged, or exposed to evidence/admin surfaces.
- Concurrent same-intent requests, conflicting reuse, separate matching
  intents, and non-replayed side effects pass backend integration coverage.
- The complete backend test suite, `flutter analyze`, all 80 Flutter tests,
  OpenAPI lint, and whitespace checks pass. PostgreSQL runtime migration and
  timeout/retry smoke remain part of `S14-06`.

### S14-04 Owner-only Record deletion — engineering complete 2026-08-20

- Added authenticated `DELETE /api/v1/records/{recordId}` with `204` only for
  the first successful owner deletion. Missing, already deleted, and
  cross-user targets share the same `404` boundary.
- The service hard-deletes the owner Record and every Memory entry with its
  owned `ZERO_RECORD` source in one transaction; no content tombstone, audit
  payload, evidence event, or admin surface was added.
- Historical state-session duration remains, while `ended_by_record_id` is
  explicitly detached before Record deletion. This matches the production
  foreign-key behavior and keeps test/production lifecycle semantics aligned.
- Integration coverage verifies Record and Memory removal, preserved session
  timing, detached Record reference, post-delete reads, repeated deletion,
  authentication, cross-user isolation, and preservation of the other user's
  data.
- Focused and complete backend tests pass. OpenAPI lint remains valid with the
  same 24 existing warnings; PostgreSQL/export/Growth/AI-context runtime
  closure remains part of `S14-06`.

### S14-05 Mobile deletion experience — engineering complete 2026-08-20

- Added a quiet destructive action at the end of Record Detail, keeping the
  Record itself and the continuation action visually primary.
- Confirmation copy states before deletion that both the Record and ZEROON's
  source-linked Memory will be permanently removed and cannot be recovered.
- A successful deletion returns from the now-invalid Detail and invalidates
  Archive, Memory, Growth, state-pattern, continuity-cue, and Detail providers
  so every affected surface uses fresh live data on its next read.
- A failed deletion stays on the intact Detail, confirms that the Record still
  exists, and leaves a direct retry path. No deletion evidence or private
  target property was introduced.
- Chinese and English copy are generated through the existing localization
  pipeline. Widget coverage verifies scope disclosure, success navigation,
  and recoverable failure behavior.
- `flutter analyze` passed with no issue and the complete `flutter test` suite
  passed 82 tests. Real service, PostgreSQL, export, cue, Growth, Memory, and AI
  context lifecycle acceptance remains consolidated in `S14-06`.

### S14-06 Lifecycle verification — runtime gate partially complete 2026-08-20

- PostgreSQL 16.14 accepted a clean Flyway migration from V1 through V20 and a
  second startup validated the schema at V20 without further migration.
- A real local Tomcat/PostgreSQL API smoke used two isolated placeholder
  accounts and verified same-intent replay, different-payload conflict,
  deliberate identical content under a different key, and owner isolation.
- The smoke exposed a runtime-only error boundary defect: the idempotency
  conflict passed MockMvc as `409` but became an empty `401` after Tomcat error
  dispatch. `ApiExceptionHandler` now handles `ResponseStatusException`
  directly; focused coverage asserts the stable `409 conflict` response and
  the repeated real request passed.
- Before deletion, the source-linked Memory was visible and explicitly enabled
  for AI context; the companion response reported `MEMORY` context. After
  owner deletion, Record Detail/read, Archive list, Memory, continuity cue,
  Growth count and state sample, export, and AI `MEMORY` context all reflected
  removal. Cross-user read/delete and repeated owner delete returned the
  accepted not-found boundary.
- The live database retained the state interval with its Record reference
  detached, contained no Record or source-linked Memory tombstone, and emitted
  no evidence event. Runtime request logs contained no Record, goal, Memory,
  deletion target, or chat placeholder content.
- Both placeholder accounts were deleted after the smoke. Final temporary
  database counts were zero for users, Records, Memory, evidence, and
  conversations.
- The complete backend suite passed, `flutter analyze` passed, all 82 Flutter
  tests passed, OpenAPI remained valid with the same 24 existing warnings, and
  whitespace validation is clean.
- Draft recovery, account isolation, discard, logout, failed remote logout,
  and deletion cleanup remain covered by automated mobile tests. A truthful
  real iOS process-restart acceptance cannot run yet: no iOS device or
  simulator is currently available, and this uncommitted build is not
  installed. Sprint 14 remains active until that final device check passes or
  the owner explicitly accepts automated recovery evidence instead.

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
