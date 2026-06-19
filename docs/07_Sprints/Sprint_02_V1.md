# Sprint 02 Plan V2

## Sprint Goal

Deliver ZEROON AI Reflection MVP without expanding the primary navigation.

Duration:

2 Weeks

---

## Product Navigation

Primary navigation remains:

- Now
- Reset
- Archive

AI reflection appears as a supporting capability inside Archive and record
detail, not as a broad chatbot product surface.

---

## Scope

### Companion / Reflection

- State-aware response after a record is saved
- AI observation card in Archive
- Non-diagnostic reflection on recent records
- Conversation persistence for AI-generated replies only where needed
- Safety boundary copy

### Context Injection

Allowed context:

- Current state
- Recent zero records
- User-visible memory summaries

Not allowed:

- Hidden user profiling
- Cross-user data
- Unconfirmed sensitive inferences

---

## Backend Tasks

| ID | Owner | Task | Estimate | Dependency |
|---|---|---|---|---|
| S2-BE-01 | Backend | LLM provider interface and default provider adapter | 1d | Sprint 01 |
| S2-BE-02 | Backend | Companion message API with timeout and fallback | 2d | S2-BE-01 |
| S2-BE-03 | Backend | Prompt template loading and version selection | 1d | S2-BE-01 |
| S2-BE-04 | Backend | AI usage log without raw private content | 1d | S2-BE-02 |
| S2-BE-05 | Backend | Safety boundary and refusal response tests | 1d | S2-BE-02 |

## Mobile Tasks

| ID | Owner | Task | Estimate | Dependency |
|---|---|---|---|---|
| S2-MO-01 | Mobile | AI feedback state on record success | 1d | S2-BE-02 |
| S2-MO-02 | Mobile | AI observation card in Archive | 1d | S2-BE-02 |
| S2-MO-03 | Mobile | Loading, timeout, retry, and unavailable states | 1d | S2-BE-02 |

## Admin Tasks

| ID | Owner | Task | Estimate | Dependency |
|---|---|---|---|---|
| S2-AD-01 | Admin | Prompt template list and read-only detail | 1d | S2-BE-03 |

---

## Acceptance Criteria

- AI feedback can be requested after a zero record is saved.
- AI failure does not block record persistence.
- AI responses use current state and recent user-owned records only.
- Logs never store API keys or full private message content.
- Medical, legal, financial, and psychological-diagnosis requests hit boundary responses.
- User can continue using Now, Reset, and Archive when the LLM provider is unavailable.

---

## Out of Scope

- Full open-ended chatbot as a primary tab
- Permanent user insight profile
- Automatic state changes
- Memory summarization pipeline
- Custom model settings
- Expression templates
- Export cards
- Hardware or device link

---

## Sprint Exit Criteria

- AI reflection is useful but non-blocking.
- The product still feels like a long-term companion and memory system, not a generic chatbot.
- Ready for Growth and Memory enhancement in Sprint 03.
