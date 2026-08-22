# Sprint 15 Growth And Memory Clarity V1

Status: Active — `S15-01` and `S15-02` complete; `S15-03` next
Prepared: 2026-08-19
Unblocked: 2026-08-22
Started: 2026-08-22
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

Sprint 15 entered active execution on 2026-08-22. `S15-01` reconciled the
current Growth metrics, state-pattern copy, Memory discovery paths, Record
Detail surface, and control language, then accepted the clarity contract
below.

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

## S15-01 Accepted Clarity Contract

Accepted on 2026-08-22 after repository baseline reconciliation.

### Verified baseline

- Bottom navigation is Now, Archive, and Growth. Growth is a primary tab.
  Memory is not a tab.
- `GET /api/v1/growth/summary` returns `continuousResetDays`, `cachedEntries`,
  `firstRecordDate`, and `companionDays`. Mobile shows consecutive days as the
  first metric card, titled `连续归零` / `Reset rhythm`, with helper copy
  `最近一次连续记录` / `Recent continuous`.
- `continuousResetDays` counts consecutive local calendar days that contain at
  least one owned Record, ending today or yesterday. If neither day has a
  Record, the value is `0` and is still shown. Absence therefore already has a
  numeric zero state, even without explicit "broken streak" copy.
- The Growth orbit's large number is `companionDays`, which is account age
  including the meeting day, not time since the first Record. The serif title
  also uses that number.
- `firstRecordDate` exists as a smaller card. `cachedEntries` is a neutral
  owned-Record count labeled `累计缓存` / archive metric.
- `GET /api/v1/growth/state-pattern` returns `dominantState`, `distribution`,
  `sampleSize`, and a backend `observation` string hardcoded in Chinese.
  Mobile does not render `observation`. It writes `你最常回到「{state}」` /
  `You return most often to “{state}”`, with extra FOCUS coaching. Empty
  samples use waiting copy without a penalty state.
- The Growth info sheet already says ZEROON does not diagnose or apply a
  fixed label. Growth load failure stays on the Growth tab and does not block
  Archive, Record Detail, or account controls.
- Memory is reached only from the Archive header button `记忆` / `Memory`.
  Profile/Settings and Record Detail have no Memory navigation. From Now this
  is two actions (Archive tab, then Memory). From Profile there is no path.
- Each Memory card shows title, summary, source, keep/pause, AI-use
  permission, and delete. Paused entries remain listed. Source
  `ZERO_RECORD` can open Record Detail; other sources show unavailable copy.
- Keep-control helper copy says a paused Memory "will not join future
  responses", mixing preservation with AI-use. Introduction copy mentions
  pause and delete but not the separate AI permission.
- Record Detail always shows decorative `Archive 记忆` / `Archive memory`.
  The Record DTO has no Memory id, presence, or control state, so the screen
  cannot tell whether this Record currently has source-linked Memory.
- `importance` remains on the Memory API and mobile model and is not shown.
  OpenAPI already states that a disabled entry cannot join AI context even
  when `aiContextEnabled` stays true, and that control changes apply on the
  next companion request. Profile AI consent remains a separate gate.

### Growth presentation contract

- Do not lead Growth with consecutive-day count, rhythm, or any zero-as-loss
  treatment of absence.
- If a consecutive-day count remains at all, it is subordinate, non-goal, and
  absence-neutral. `0` must not read as failure, broken rhythm, or a reason to
  record today.
- Lead with preserved moments, the first moment, and elapsed companionship.
  Neutral counts may remain; they must not become grades, ranks, or targets.
- Do not describe a dominant state as who the user is, what they are
  learning, or a yearly identity. Optional observation must stay reversible,
  non-diagnostic, and explicitly bounded to visible recent state history.
- Do not display the unused backend `observation` string until `S15-03`
  accepts a language-safe replacement or removal.
- Do not add scores, levels, badges, streak rewards, or shame for absence.

### Memory control and discovery contract

- Keep preservation (`enabled`) and AI-use (`aiContextEnabled`) as separate
  reversible controls. Copy must let a new user distinguish keep/pause,
  allow-in-response, and delete without reading technical documentation.
- Memory must be reachable within two intentional actions from Archive and
  from Profile/Settings.
- Record Detail must show whether this owned Record currently has
  source-linked Memory and offer a path to that Memory's controls. Missing
  Memory is not an error. This screen must not create Memory.
- When a Memory source is `ZERO_RECORD`, the source Record remains visible
  and reachable from Memory.
- Do not surface `importance` as a user-facing score or ranking.
- Pause, revoke, and delete continue to exclude the entry from the next
  companion request. This Sprint must not weaken `D-004`.

### Implementation boundary

`S15-02` through `S15-07` may now implement this contract. Any need for
Memory correction or manual creation, Archive search, automatic
weekly/monthly summaries, new Memory extraction, or exposing `importance`
requires a new owner decision rather than an implementation shortcut.

## S15-02 Accepted Growth Content Hierarchy

Accepted on 2026-08-22. This freezes presentation order, visual roles, and
copy intent for Growth. `S15-03` aligns the data contract; `S15-04`
implements the bilingual UI.

### Decision

The current 2x2 metric grid leads with consecutive Reset days and repeats
companion days. That performance emphasis is rejected. Consecutive-day count
is removed from the Growth surface, not demoted. A visible `0` after absence
still reads as a broken rhythm even without "streak" wording.

Growth now has three primary facts and one optional observation:

1. Elapsed companionship — days since the user met ZEROON, including that
   first day. This is time together, not a target.
2. First moment — the date of the first owned Record, or a quiet "not yet"
   if none exists.
3. Preserved moments — the count of owned Records the user can still revisit.
4. Optional recent-state note — a count inside a time window, or waiting
   copy. It never names a dominant state, personality, lesson, or yearly
   identity.

### Page order

1. Header `陪伴成长` / `Companion growth`, with the existing info control.
2. Elapsed-companionship presence: the orbit may keep the large
   `companionDays` number, labeled as days together. It must not show
   consecutive days, progress toward a goal, or a filled/broken ring.
3. Caption: companionship is counted from the meeting day, not from a
   check-in streak.
4. Title: time-together copy using elapsed companionship. Do not use
   "time begins with the first record" as a substitute title when the user
   has already met ZEROON but has no Record yet.
5. Intro: keep the current calm line that not every day needs to leave
   something behind.
6. Supporting pair, equal weight, after the presence block:
   - First moment
   - Preserved moments
7. Optional observation card.
8. Info sheet: explain the three facts and the observation boundary; do not
   mention Reset rhythm or consecutive recording.

### Empty, loading, and error

- `0` preserved moments is a quiet count, not a prompt to record today.
- Missing first moment uses `还没有` / `Not yet`. It is not a failed start.
- Observation with `sampleSize == 0` keeps waiting copy with no hurry.
- Observation failure stays local: unavailable copy plus retry. It must not
  hide the three primary facts.
- Growth summary failure stays on this tab with retry. Archive, Record
  Detail, Memory, and account controls remain usable.

### Copy intent

Replace, do not reuse, these meanings:

- `连续归零` / `Reset rhythm` and `最近一次连续记录` / `Recent continuous`
- `你最常回到「{state}」` / `You return most often to “{state}”`
- FOCUS extra coaching that the user is learning to place unclear thoughts
- Backend `observation` text, until `S15-03` accepts a language-safe field
  or removal

Required meanings:

- Elapsed companionship: counted from the meeting day, not consecutive
  check-ins.
- First moment: when preserved time began, if it exists.
- Preserved moments: owned Records that can be revisited, not an archive
  score.
- Observation, when present: `最近 N 天，你确认过 M 次状态变化。这只是次数，不是对你的判断。` /
  `In the last N days, you confirmed M state changes. This is a count, not a
  judgment about you.`
- Info boundary: ZEROON does not diagnose, grade, or apply a fixed label.

Exact ARB keys and 390-pixel layout belong to `S15-04`. This task accepts
the hierarchy and meaning, not pixel implementation.

### Data consequences for `S15-03`

The accepted presentation needs:

- `companionDays`
- `firstRecordDate`
- preserved-moment count (today's `cachedEntries`)
- observation window length and `sampleSize`

It does not need on the Growth surface:

- `continuousResetDays`
- `dominantState`
- `distribution`
- the current hardcoded `observation` string

`S15-03` may keep unused fields internally only if removing them is riskier
than ignoring them. It must not require the UI to keep reading them.

### Implementation boundary

`S15-04` may restyle the orbit and supporting cards to match this hierarchy,
but must not restore consecutive days, dominant-state identity, or a fourth
performance metric. New Growth charts, weekly summaries, or levels still
require a new owner decision.

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
