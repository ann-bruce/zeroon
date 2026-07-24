# Beta Evidence Cohort Computation V1

Status: Accepted S12-04 implementation reference.

## Purpose and boundary

This document fixes the reproducible calendar-day computations used by the
closed-Beta evidence service. It operates only on retained, content-free
`evidence_events` rows. It does not inspect users, Records, Memory, Profile,
conversations, support requests, prompts, replies, exact timestamps, or direct
identity.

`EvidenceCohortService` returns aggregate counts, denominators, and four-decimal
rates. It has no controller in S12-04. ADMIN exposure, minimum cohort rules, and
small-cell suppression belong to S12-05.

All dates are the stored `occurred_date`, which is already fixed to the
`Asia/Shanghai` calendar policy. No locale, IP, device timezone, or
`received_at` value changes cohort membership or retention day.

## Report window

Inputs:

- `cohortStart`: inclusive first-authentication date;
- `cohortEnd`: inclusive last-authentication date;
- `asOfDate`: inclusive observation cutoff.

The window is valid only when
`cohortStart <= cohortEnd <= asOfDate`. A subject enters the cohort when its
first retained `AUTH_COMPLETED` falls inside the cohort window. Reports must be
limited to windows for which the full required event history remains inside the
180-day retention boundary.

Because collection is default-off and has no backfill, a stored authentication
event is a measurement prerequisite. S12-06 must make the notice/choice
sequence capable of storing the cohort's first measured authentication; a
report must not treat an unobserved login as a completed authentication.

## Rate representation

Every rate is returned as:

```text
numerator / denominator, rounded half-up to four decimal places
```

When the denominator is zero, the rate is `null`, not zero. Zero would
incorrectly claim a measured failure where the cohort has not matured or no
eligible subject exists.

## Activation

The activation date is the latest of the first occurrence dates for:

1. `AUTH_COMPLETED`;
2. `ZEROON_ENCOUNTER_COMPLETED`;
3. `STATE_STARTED`;
4. `RECORD_SAVED`;
5. either `ARCHIVE_VIEWED` or `RECORD_DETAIL_VIEWED`;
6. `PROFILE_AI_CONTEXT_CONTROL_VIEWED`.

The activation numerator is the number of cohort subjects with all six
milestones. The denominator is distinct cohort subjects.

This is labeled `FULL_REVIEWED_EVENT_COVERAGE`. A control change, reflection
context-class bit, or screen implementation alone is not treated as visibility.
The dedicated event emits only after the authenticated Profile control is
actually rendered and contains only the current enabled boolean and fixed
Profile surface.

## Retention

Retention anchors on the calculated activation date, never registration.

- D1 checks for a return event on `activationDate + 1`;
- D7 checks `activationDate + 7`;
- D30 checks `activationDate + 30`.

The denominator for each day contains only activated subjects whose target day
is on or before `asOfDate`. A return is any of:

- `STATE_STARTED`;
- `RESET_STARTED`;
- `RECORD_SAVED` or `RECORD_SAVE_FAILED`;
- `ARCHIVE_VIEWED` or `RECORD_DETAIL_VIEWED`;
- `REFLECTION_REQUESTED` or `REFLECTION_COMPLETED`;
- `MEMORY_CONTROL_CHANGED`;
- `PROFILE_AI_CONTEXT_CHANGED`;
- `PROFILE_AI_CONTEXT_CONTROL_VIEWED`.

Authentication by itself is not a continuity return.

## Week-two record

The denominator contains activated subjects for whom
`activationDate + 13 <= asOfDate`. The numerator contains those with at least
one `RECORD_SAVED` from activation day +7 through day +13 inclusive.

## Current-week continuity and chat-only share

The current week is the rolling seven-calendar-day window
`asOfDate - 6` through `asOfDate`, inclusive.

A weekly active subject has at least one return event from the retention list.
A continuity reviewer has at least one:

- `ARCHIVE_VIEWED`;
- `RECORD_DETAIL_VIEWED`;
- `REFLECTION_REQUESTED` with surface `ARCHIVE` or `RECORD_DETAIL`.

A chat-only subject has `REFLECTION_REQUESTED` with surface `COMPANION` and no
state, Reset, saved Record, Archive, detail, or continuity-review event in the
same window. A Reset completion reflection does not become an Archive review.

Both rates use weekly active subjects as the denominator.

## Record funnel and reliability

- Record-flow completion is distinct cohort subjects with both
  `RESET_STARTED` and `RECORD_SAVED`, divided by distinct cohort subjects with
  `RESET_STARTED`.
- Record-save success is the number of `RECORD_SAVED` events divided by
  `RECORD_SAVED + RECORD_SAVE_FAILED`.
- Recovered retry is saved events whose `retryCountBucket` is `ONE` or
  `TWO_OR_MORE`, divided by all saved events.

The event contract has no attempt correlation id, so S12-04 does not claim that
a specific failure row was recovered by a specific success row.

Reflection reliability is returned as bounded distributions of reviewed
`outcome` and `latencyBucket` values. Prompt or reply content is never grouped.

## Trust and data-control demand

Each numerator is distinct cohort subjects; the denominator is all cohort
subjects:

- AI-context disabled: Profile context changed to false, or Memory action
  `DISABLE`/`DISALLOW_AI`;
- Memory deletion: Memory action `DELETE`;
- export demand: `DATA_EXPORT_REQUESTED` with outcome `STARTED`;
- deletion demand: `ACCOUNT_DELETE_REQUESTED` with outcome `STARTED`.

Completed account deletion removes the subject and its events by design.
Therefore deletion demand is best-effort and must not be interpreted as a
complete historical deletion ledger.

## S12-05 operator release boundary

The calculator returns unsuppressed aggregate counts only to server code.
`GET /api/v1/admin/evidence/cohorts` is the only operator release path and:

- require ADMIN authorization;
- returns a suppression envelope with no actual cohort size or metric when
  fewer than five distinct authenticated subjects qualify;
- independently suppresses a metric when its distinct-subject denominator is
  below five or its non-zero numerator is below five;
- suppresses event counts and bounded outcome/latency cells when fewer than
  five distinct subjects contributed to that cell;
- expose no subject id, event row, per-person timeline, exact receipt time, or
  private product content;
- document that retained-event loss, disabled collection, and incomplete
  maturity constrain interpretation.

Suppression is enforced in the backend DTO mapping, not only in the React
admin. The UI presents a calm read-only evidence view, labels immature rates,
and never uses participant behavior as a score, ranking, or user-facing claim.
