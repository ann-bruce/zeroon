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

### Confirmed Rules

- After a zero record is saved, the active state session is ended and Now
  returns to a neutral "choose current state" state.
- ZEROON does not auto-start the next state after reset completion.
- If the user changes state on Now, the previous active session is ended
  automatically and a new session starts.
- State duration is displayed softly on user-facing screens, for example
  `停留了约 18 分钟`.
- Exact duration remains available for backend calculation.
- Sessions shorter than 30 seconds are merged into the next session when the
  state changes without a zero record.
- Sessions shorter than 30 seconds are still saved when they end through a zero
  record, because the user intentionally created a memory.

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
- If the old session is shorter than 30 seconds and was not ended by a zero
  record, merge it away instead of preserving it as a meaningful interval.

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
- Leaves the user with no active state session after completion.

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
| S4-BE-01 | Backend | Add `state_sessions` migration and entity | Done |
| S4-BE-02 | Backend | Add one-active-session-per-user constraint | Done |
| S4-BE-03 | Backend | Add start/get active state session APIs | Done |
| S4-BE-04 | Backend | Update record creation to derive state from active session | Done |
| S4-BE-05 | Backend | Link zero record and ended state session | Done |
| S4-BE-06 | Backend | Update growth/state pattern calculations for duration | Pending |
| S4-BE-07 | Backend | Update OpenAPI and tests | Done |

## Mobile Tasks

| ID | Owner | Task | Status |
|---|---|---|
| S4-MO-01 | Mobile | Move six state choices to Now | Done |
| S4-MO-02 | Mobile | Show active state duration on Now | Done |
| S4-MO-03 | Mobile | Simplify Reset to one active state icon | Done |
| S4-MO-04 | Mobile | Save record through active state session | Done |
| S4-MO-05 | Mobile | Show duration on completion and Archive cards | Pending |
| S4-MO-06 | Mobile | Update widget tests | Done |

---

## Acceptance Criteria

- User can choose a current state on Now.
- Choosing a state starts a session with `startedAt`.
- Now displays the active state and elapsed duration.
- Reset does not allow choosing a different state.
- Saving a zero record ends the active session.
- After saving a zero record, Now asks the user to choose a current state again.
- Zero record is linked to the ended state session.
- Archive can show the state duration for a saved record.
- Growth can still calculate existing Sprint 03 metrics.
- State sessions under 30 seconds are merged unless they ended with a zero
  record.
- No diagnostic, ranking, or pressure language is introduced.

---

## Decisions From Open Questions

| Question | Decision |
|---|---|
| What happens after saving a zero record? | End the active session and return Now to "choose current state". |
| What happens when user chooses another state on Now? | End the old session automatically and start the new one. |
| Should duration be exact or soft? | User-facing UI uses soft wording; backend keeps exact seconds. |
| What about sessions under 30 seconds? | Merge when caused by quick state changes; keep when ended by zero record. |

---

## Development Sequence

1. Backend migration and `state_sessions` entity.
2. Backend active session service and API.
3. Backend record creation update.
4. OpenAPI and backend tests.
5. Mobile state session repository/controller.
6. Now page state selector and duration display.
7. Reset page locked active state.
8. Completion and Archive duration display.
9. Growth calculation compatibility check.
10. Full local validation.

---

## Risk Notes

- This is a core model change and should not be mixed with unrelated UI polish.
- Existing `state_history` should remain as event history.
- `state_sessions` should become the source for duration-based insights.
- Migration must preserve existing users by creating an initial active session
  only when the user explicitly chooses a state after the update.
