# Sprint 04 Plan V1

Status: Draft

## Sprint Goal

Move ZEROON from "state as a record label" to "state as a lived interval".

The Now page starts and displays the user's current state. The Reset page
records what helped the user leave or settle that state. Archive and Growth can
then show how long each state lasted and what was saved with it.

---

## Product Decision

Current implementation:

- Now shows the current state.
- Reset asks the user to choose a state again.
- The zero record stores the selected state as a label.

Target implementation:

- Now shows all six state icons and lets the user choose the current state.
- Choosing a state starts a state session.
- Now shows the active state and its elapsed duration.
- Reset no longer shows six state choices.
- Reset shows only the active state icon.
- Saving a zero record ends the active state session.
- The zero record is linked to the ended state session.
- Archive can show state duration next to the saved record.
- Growth can aggregate state duration and reset patterns.

---

## User Flow

1. User opens Now.
2. User chooses one of six states.
3. System starts a state session with `startedAt`.
4. Now displays the active state and elapsed time.
5. User taps `开始一次归零`.
6. Reset opens with the active state already selected and locked.
7. User enters:
   - `留下一句话`
   - `今天想完成什么`
8. User taps `保存这次归零`.
9. System saves the zero record.
10. System ends the active state session with `endedAt`.
11. System links the zero record to the state session.
12. Completion page confirms the state has been saved.

---

## Data Model

### New Table: `state_sessions`

Recommended instead of overloading `state_history`.

Reason:

- `state_history` is an event log.
- `state_sessions` is an interval model.
- Duration, ending reason, and record linkage belong to an interval model.

Fields:

| Field | Type | Required | Notes |
|---|---|---|---|
| `id` | BIGSERIAL | yes | Primary key |
| `user_id` | BIGINT | yes | Owner |
| `state` | VARCHAR(20) | yes | CALM / FOCUS / CREATE / TIRED / OVERLOAD / CONFUSED |
| `source` | VARCHAR(20) | yes | MANUAL / RECORD / AI / SYSTEM |
| `started_at` | TIMESTAMPTZ | yes | State start time |
| `ended_at` | TIMESTAMPTZ | no | Null means active |
| `ended_by_record_id` | BIGINT | no | Zero record that ended the session |
| `created_at` | TIMESTAMPTZ | yes | Audit timestamp |
| `updated_at` | TIMESTAMPTZ | yes | Audit timestamp |

Constraints:

- Only one active state session per user.
- `ended_at` must be null or greater than `started_at`.
- `ended_by_record_id` must belong to the same user.

### Zero Record Link

Add to `zero_records`:

| Field | Type | Required | Notes |
|---|---|---|---|
| `state_session_id` | BIGINT | no | Session ended by this record |

Keep `zero_records.state` for denormalized display and historical resilience.

---

## API Changes

### Current State

`GET /api/v1/state/current`

Response adds active session fields:

- `state`
- `source`
- `changedAt`
- `sessionId`
- `startedAt`
- `elapsedSeconds`

### Start State Session

`POST /api/v1/state/sessions`

Request:

- `state`

Behavior:

- If no active session exists, create one.
- If active session has the same state, return it idempotently.
- If active session has a different state, end the old session and start a new
  one.

### Save Zero Record

`POST /api/v1/records`

Request no longer needs `state`; backend derives it from the active session.

Request:

- `goal`
- `content`

Behavior:

- Requires an active state session.
- Creates zero record with active state.
- Ends active session.
- Links `zero_records.state_session_id` and
  `state_sessions.ended_by_record_id`.

Fallback rule:

- If no active session exists, return a clear 409 response asking the user to
  choose a state on Now first.

---

## Mobile UI Changes

### Now

- Show all six state icons as selectable.
- Active state is visually highlighted.
- Show elapsed duration, for example: `已停留 18 分钟`.
- `开始一次归零` opens Reset with the active state.

### Reset

- Remove the six-state grid.
- Show one current state icon only.
- Show state duration.
- Keep:
  - `留下一句话`
  - `今天想完成什么`
  - `保存这次归零`

### Record Complete

- Show:
  - `本次状态 · 专注`
  - `持续 18 分钟`
  - ZEROON quote
  - Today record summary

### Archive

- Record card can show:
  - state label
  - saved time
  - state duration

### Growth

- Add future-ready metrics:
  - most common active state by duration
  - average time before reset
  - states most often ended by a zero record

Do not add rankings, scores, or pressure-based streak language.

---

## Backend Tasks

| ID | Owner | Task | Status |
|---|---|---|
| S4-BE-01 | Backend | Add `state_sessions` migration and entity | Draft |
| S4-BE-02 | Backend | Add one-active-session-per-user constraint | Draft |
| S4-BE-03 | Backend | Add start/get active state session APIs | Draft |
| S4-BE-04 | Backend | Update record creation to derive state from active session | Draft |
| S4-BE-05 | Backend | Link zero record and ended state session | Draft |
| S4-BE-06 | Backend | Update growth/state pattern calculations for duration | Draft |
| S4-BE-07 | Backend | Update OpenAPI and tests | Draft |

## Mobile Tasks

| ID | Owner | Task | Status |
|---|---|---|
| S4-MO-01 | Mobile | Move six state choices to Now | Draft |
| S4-MO-02 | Mobile | Show active state duration on Now | Draft |
| S4-MO-03 | Mobile | Simplify Reset to one active state icon | Draft |
| S4-MO-04 | Mobile | Save record through active state session | Draft |
| S4-MO-05 | Mobile | Show duration on completion and Archive cards | Draft |
| S4-MO-06 | Mobile | Update widget tests | Draft |

---

## Acceptance Criteria

- User can choose a current state on Now.
- Choosing a state starts a session with `startedAt`.
- Now displays the active state and elapsed duration.
- Reset does not allow choosing a different state.
- Saving a zero record ends the active session.
- Zero record is linked to the ended state session.
- Archive can show the state duration for a saved record.
- Growth can still calculate existing Sprint 03 metrics.
- No diagnostic, ranking, or pressure language is introduced.

---

## Open Questions

- After saving a zero record, should the user return to no active state, or
  should ZEROON ask the user to choose the next state?
- Should changing state on Now automatically end the previous session, or ask
  for confirmation when the previous session lasted long enough?
- Should state duration be shown exactly (`18 分钟`) or softly (`停留了一会儿`)?
- Should a very short state session under 30 seconds be saved, merged, or
  ignored?

---

## Risk Notes

- This is a core model change and should not be mixed with unrelated UI polish.
- Existing `state_history` should remain as event history.
- `state_sessions` should become the source for duration-based insights.
- Migration must preserve existing users by creating an initial active session
  only when the user explicitly chooses a state after the update.
