# Companion Growth Metrics V1

## Product Intent

The companion growth page reflects time and memories shared with ZEROON. It
must not introduce rankings, levels, competitive streaks, or punishment for a
broken streak.

## Metrics

### Continuous Reset Days

The number of consecutive calendar dates, ending today or yesterday, on which
the user created at least one valid zero record. Multiple records on one date
count once.

### Cached Entries

The number of memory entries currently visible to the user in the Archive of
Mountains and Seas. Deleted or expired entries are excluded.

### First Record Date

The user's earliest non-deleted zero record date in the user's configured
timezone. It is `null` when no record exists.

### Companion Days

The inclusive number of calendar dates from the user's registration date to
the current date in the user's configured timezone:

`currentDate - registrationDate + 1`

Example: from 2025-06-11 through 2026-06-10 is 365 days.

## Edge Cases

- A new user has `continuousResetDays = 0`, `cachedEntries = 0`, and
  `firstRecordDate = null`; `companionDays = 1`.
- A broken streak resets only the streak metric and never removes history.
- Timezone changes apply to future reads and must not duplicate records.
- All calculations are scoped to the authenticated user.

