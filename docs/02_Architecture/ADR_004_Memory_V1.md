# ADR 004: User-Controlled Memory V1

Status: Accepted
Date: 2026-07-14

## Context

ZEROON promises reflective continuity without turning private records into a
hidden profile. The existing `memory_entries` table can be listed and read, but
it does not express whether an entry is active, whether AI may use it, or how
source deletion and user control should behave.

## Decision

Memory V1 is a private, user-owned, source-linked derived object.

- Every production-created entry belongs to exactly one user and points to a
  source owned by that same user.
- The first production source is `ZERO_RECORD`. Other source classes require a
  separate product and privacy decision before writers are added.
- `enabled` controls whether an entry participates in continuity features.
  Disabled entries remain visible so the user can understand and reverse the
  choice.
- `aiContextEnabled` is a separate per-entry permission and defaults to false.
  An entry can enter an AI request only when it is enabled, not expired, and AI
  context is enabled for that entry and at the applicable account-level gate.
- Disabling an entry immediately makes AI use ineffective even if its stored
  AI flag was previously true.
- Deleting an entry is an immediate hard delete. Its title and summary are not
  retained in analytics or audit payloads.
- Deleting a source must delete derived memory from that source. A user account
  deletion continues to cascade all memory.
- Expired entries are unavailable to list, detail, and AI context assembly.
- The API exposes source class and identifier, control flags, expiry, and
  timestamps. It does not expose an inferred personality label or confidence
  score.

The V9 migration adds the control and update fields without creating a writer.
The record-to-memory writer and user mutation endpoints are later Sprint 09
items so their ownership and idempotency behavior can be accepted separately.

## Invariants

1. A user cannot read, mutate, or delete another user's memory.
2. `enabled = false` means the entry is never supplied to an AI provider.
3. `ai_context_enabled = false` means the entry is never supplied to an AI
   provider.
4. New entries default to `enabled = true` and
   `ai_context_enabled = false`.
5. A source-derived entry is unique per user, source class, source identifier,
   and memory type.
6. Source text, memory summaries, and titles are prohibited from operational
   logs and analytics properties.

## Consequences

- Memory remains inspectable and reversible instead of becoming an invisible
  personalization store.
- AI continuity requires an explicit later user action; this is intentionally
  more conservative than automatically using every saved record.
- Disabled entries still appear in Memory management surfaces, while normal
  reflective surfaces may choose to show only active entries.
- Polymorphic source ownership cannot be enforced by a single foreign key.
  Writers and deletion services must enforce it transactionally and tests must
  cover cross-user and source-deletion behavior.

## Rejected Alternatives

- Automatically enabling AI use for every derived memory: rejected because
  saving a record is not consent to send its derived content to a provider.
- Treating disable as delete: rejected because the user needs a reversible
  control and a separate irreversible action.
- Storing fixed personality traits or scores: rejected because it narrows
  reflection into classification and is difficult for users to inspect.
- Adding embeddings in V1: deferred until source, control, deletion, and real
  user value are proven without semantic retrieval.
