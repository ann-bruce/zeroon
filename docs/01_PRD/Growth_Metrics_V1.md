# Companion Growth Metrics V1

## Product Intent

The companion growth page reflects time and memories shared with ZEROON. It
must not introduce rankings, levels, competitive streaks, or punishment for a
broken streak.

## Metrics

### Preserved Moments

The number of owned Zero Records the authenticated user can still revisit.
Deleted records are excluded.

### First Record Date

The user's earliest remaining Zero Record date in the requested IANA
timezone. It is `null` when no record exists.

### Companion Days

The inclusive number of calendar dates from the user's registration/meeting
date to the current date in the requested timezone:

`currentDate - registrationDate + 1`

Example: from 2025-06-11 through 2026-06-10 is 365 days.

### Recent State Confirmations

`GET /growth/state-pattern` returns only a window length (`days`) and the
count of visible state-history rows in that window (`sampleSize`). It does
not return a dominant state, distribution, or generated observation text.
Client copy may describe the count; it must not turn the count into identity,
diagnosis, or a performance grade.

## Removed From The Contract

Consecutive Reset days, Reset rhythm, dominant state, state distribution, and
server-authored observation strings are not part of the Growth API.

## Edge Cases

- A new user has `preservedMoments = 0` and `firstRecordDate = null`;
  `companionDays = 1`.
- Absence never produces a zero consecutive-day field, because that field is
  not exposed.
- Timezone changes apply to future reads and must not duplicate records.
- All calculations are scoped to the authenticated user.
