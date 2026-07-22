# Sprint 09 Controllable Memory V1

Status: Completed
Prepared: 2026-07-14

## Sprint Goal

Turn Memory from a read-only placeholder into a private, source-linked and
user-controlled continuity capability before it is used by a real AI provider.

## Product Decision

### Mainline fit

Controllable memory is the core of ZEROON's long-term companion promise: the
user can see what is remembered, where it came from, and whether it remains
active or may be used by AI.

### Drift risk

- Do not infer fixed traits, diagnoses, emotional scores, or personality labels.
- Do not hide memory creation or AI use behind generic chat consent.
- Do not make memory count, importance, or streaks a performance mechanic.
- Do not add embeddings before source and deletion semantics are proven.

### Abstract capability

**User-controlled reflective continuity**: source-linked derived memory with
separate reversible activation and AI-use controls.

### Roadmap decision

Accept now as Phase 2. Real-provider expansion follows the control path rather
than preceding it.

## Implementation Sequence

| Item | Status | Done when |
|---|---|---|
| S9-01 Memory ADR and data foundation | Completed | ADR accepted; migration, entity, export, and OpenAPI expose enabled and AI-use controls with privacy-safe defaults; focused and full gates plus PostgreSQL v9 migration pass |
| S9-02 Record-to-memory production | Completed | Post-commit event creates one deterministic, owned and source-linked memory in an independent transaction; repeat save is idempotent and repairs a missing entry; failures do not alter record success |
| S9-03 Memory management API | Completed | Owner-only PATCH updates supplied activation/AI-use controls and DELETE hard-deletes content; empty input is 400 and missing, expired, or cross-user entries are 404 |
| S9-04 Mobile Memory controls | Completed | Archive exposes a quiet Memory management page with source navigation, local activation, editable AI-use permission after S9-05, recoverable errors, and confirmed hard deletion |
| S9-05 Consent-aware context assembly | Completed | Only owned, active, unexpired, explicitly allowed Memory enters companion context with count/character bounds and source class; neither backend assembly nor mobile-generated companion messages inject raw Zero Record text outside that path; capturing-provider and Widget tests cover default-off, allow, pause, revoke, expiry, cross-user isolation, bounds, Record→Memory bypass regression, and mobile completion/Archive prompts; mobile AI switch uses honest paused-state copy with local success/failure feedback |
| S9-06 Provider transaction and observability | Completed | Provider calls run with no active Spring transaction; short preparation/context/completion transactions preserve messages and metadata; success/fallback/refusal, latency, prompt version, character counts, and optional provider token counts are verified without private text logs |

## S9-01 Acceptance

- New memory rows default to active but excluded from AI context.
- API and data export expose `enabled`, `aiContextEnabled`, `expiresAt`, and
  `updatedAt`.
- Existing list/detail ownership and expiry behavior remains intact.
- Data shape changes have Flyway and test-schema parity.
- No mobile control is displayed before mutation behavior exists.

## Out of Scope for S9-01

- memory generation or summarization;
- mutation and deletion endpoints;
- mobile Memory UI;
- AI context consumption;
- embeddings, vector databases, RAG, scoring, or inferred traits.

## S9-05 Acceptance

- Companion requests include Memory only when the entry is owned by the caller,
  `enabled=true`, `aiContextEnabled=true`, and unexpired.
- Companion continuity does not append raw recent Zero Record `goal`/`content`
  outside consent-aware Memory assembly; pausing, revoking AI permission, or
  deleting Memory must keep source text out of the next provider request.
- Mobile completion and Archive observation prompts must not reconstruct Zero
  Record state, goal, or content as a user message. Archive observation relies
  on server-side consent-aware Memory context and tells the model not to guess
  when no allowed Memory is available.
- Account-level Profile AI context consent remains independently enforced for
  profile fields; any closed Memory control immediately excludes that Memory.
- Memory context is bounded by maximum entry count and character length, and
  includes source class plus source id without personality labels, diagnoses,
  or scores.
- AI usage metadata, logs, and exception messages never store Memory titles or
  summaries.
- Capturing fake-provider tests cover default-off, allow-in, pause-out,
  permission-off-out, expired exclusion, cross-user isolation,
  count/length bounds, and a real Record → Memory production path regression
  that asserts source goal/content stay out after controls close. Widget tests
  separately assert Record state/goal/content stay out of both mobile-generated
  companion requests.
- Mobile exposes an editable `aiContextEnabled` switch with local success and
  failure feedback; when `enabled=false`, copy states the preference is stored
  but will not affect the next response until Memory is re-enabled.
- OpenAPI, ADR 004, and engineering docs describe the assembly rules.

## S9-06 Acceptance

- `LlmProvider.generate` executes with no active Spring transaction; provider
  timeout cannot hold database locks or an open persistence context.
- The user message is committed before provider execution. Success, calm
  fallback, and deterministic refusal each persist an assistant message and one
  matching AI usage row in a short completion transaction.
- Usage metadata records outcome, provider, model when known, duration, prompt
  template code/version, input/output character counts, provider-reported input
  and output token counts when available, and a bounded technical error code.
- Missing provider token usage remains null rather than being estimated or
  fabricated. V10, test schema, data export, and OpenAPI stay aligned.
- Transaction-aware fake providers prove success and fallback run outside a
  transaction; safety tests prove refusal never calls the provider.
- Logs, exports, and exception metadata never contain prompt, Memory, Profile,
  Zero Record, user-message, or assistant-reply body text.
- Operational verification on 2026-07-22 used the exact case-sensitive model
  identifier `deepseek-v4-flash`: the authenticated request completed in 1495
  ms with `SUCCESS`, no fallback, provider-reported 80 input / 81 output tokens,
  an exact content-free usage schema, and HTTP 204 temporary-account cleanup.

## Sprint Exit

- A saved record can produce one inspectable memory.
- Users can view its source, disable it, exclude it from AI, or delete it.
- Explicitly allowed Memory can enter AI context under consent and bounds.
- Provider failure never blocks record saving or Archive access.
- Full quality gate and current-code local service verification pass.
