# Sprint 15 Growth And Memory Clarity V1

Status: Ready for bounded intake — Sprint 14 acceptance complete; not active
Prepared: 2026-08-19
Unblocked: 2026-08-22
Backlog sources: `ZPB-P0-03`, `ZPB-P0-04`

## Intake Decision

### 1. Mainline fit

Growth should express preserved time and continuity, while Memory should make
ZEROON's remembered context visible, source-linked, and controllable. Clearer
presentation strengthens companionship and trust without adding more private
data or more AI inference.

### 2. Drift risk

Growth can drift into streak pressure, performance ranking, mood scoring, or a
fixed claim about who the user is. Memory can drift into a technical settings
page or hidden automatic profile. Neither surface may diagnose, grade, shame,
or imply that frequent use is better behavior.

### 3. Recommended abstract capability

**Understandable continuity and memory control**: show time preserved with
ZEROON without performance pressure, and let users answer what is remembered,
where it came from, and whether it may join future AI responses.

### 4. Roadmap decision

Plan Sprint 15 after Sprint 14. Improve hierarchy, copy, and control discovery
before adding Memory automation, new reflection, or historical scoring.

### 5. Planning acceptance criteria

- no broken-streak or negative absence state;
- no dominant state is presented as a personality or fixed pattern;
- a user can find Memory in two intentional actions;
- preservation and AI-use permission remain separate controls;
- every Memory source is visible and reachable;
- pause, revoke, and delete affect the next response immediately.

## Sprint Goal

Make Growth calm and non-evaluative, and make Memory understandable enough for
a new user to control without reading technical documentation.

## Planned Work

| ID | Task | Surfaces | Done when |
|---|---|---|---|
| `S15-01` | Audit Growth and Memory baseline | product, mobile, backend, copy, tests | Existing metrics, narratives, entries, controls, and confusing states are inventoried |
| `S15-02` | Accept Growth content hierarchy | product, UX, localization | Preserved moments, first moment, elapsed companionship, and optional observations replace performance emphasis |
| `S15-03` | Align Growth data contract | backend, OpenAPI, mobile, tests | API exposes only data required by the accepted neutral presentation |
| `S15-04` | Implement calm Growth experience | mobile, localization, tests | No streak pressure, score, rank, loss state, or fixed user label remains |
| `S15-05` | Improve Memory discovery and language | Archive, Memory, Profile/Settings, localization, tests | Users can distinguish keep, pause, delete, and allow-in-response behavior |
| `S15-06` | Surface source and Memory state from Record Detail | mobile, backend/OpenAPI review, tests | Record Detail shows whether an owned source has Memory and links to its controls without exposing hidden inference |
| `S15-07` | Verify owner understanding and control | tests, runtime review, docs | Chinese/English, empty/error/loading, source, revoke, delete, and next-response behavior pass |

## Affected Surfaces

- Growth backend summary and recent-state observation review;
- OpenAPI only if response fields change;
- Growth, Archive, Record Detail, Memory, and Profile/Settings mobile screens;
- Simplified Chinese and English copy;
- Memory context assembler and immediate revoke/delete verification;
- product docs, widget tests, backend isolation tests, and runtime review.

## Acceptance Criteria

- absence or a broken rhythm never produces penalty copy;
- neutral counts do not become grades or goals;
- state frequency is not described as identity, diagnosis, or prediction;
- Memory is reachable within two intentional actions from a relevant surface;
- source Record is visible when it exists;
- keep/pause and allow-in-response are separately understandable;
- revoke, pause, and delete prevent next-response use as specified;
- failures do not block Archive, Record Detail, or account controls;
- bilingual 390-pixel-width review and relevant automated tests pass.

## Non-Goals

- new Memory extraction or semantic RAG;
- personality reports, mood charts, scores, streak rewards, or levels;
- Archive search;
- automatic weekly/monthly summaries;
- notification, payment, public sharing, or physical ZEROON;
- production release or App Store submission.

## Stop Rules

Stop or reshape if a proposed Growth metric requires pressure to feel useful,
if Memory controls become less reversible, or if clarity depends on exposing
private content outside the authenticated owner surface.
