# Sprint 09 Controllable Memory V1

Status: In progress
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
| S9-03 Memory management API | Pending | Owner can enable, disable, change AI permission, and hard-delete; cross-user requests return 404 |
| S9-04 Mobile Memory controls | Pending | User can inspect source and control or delete memory with calm feedback and confirmation |
| S9-05 Consent-aware context assembly | Pending | Only active, unexpired, explicitly allowed entries enter provider context with bounded size and source class |
| S9-06 Provider transaction and observability | Pending | External calls do not hold long DB transactions; success/fallback/refusal, latency, version, and cost metadata are verified without private text logs |

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

## Sprint Exit

- A saved record can produce one inspectable memory.
- Users can view its source, disable it, exclude it from AI, or delete it.
- Provider failure never blocks record saving or Archive access.
- Full quality gate and current-code local service verification pass.
