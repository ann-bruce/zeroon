# Sprint 07 Plan V1

Status: Draft

## Sprint Goal

Turn ZEROON's AI path from fallback-capable to real-model verified.

Sprint 07 connects and validates a system-level OpenAI-compatible provider for
ZEROON companion replies and observations, while preserving privacy, fallback
resilience, and the long-term companion product direction.

This sprint does not turn ZEROON into a generic AI chat app. AI remains a quiet
supporting layer for reflection, memory continuity, and self-understanding.

---

## Product Decision

Current state:

- Backend has `LlmProvider` and an OpenAI-compatible HTTP adapter.
- Companion chat calls the LLM provider when configured.
- Local verification has intentionally used empty AI credentials and fallback
  replies.
- Sprint and architecture documents still mention Spring AI in some places,
  while current code uses a lightweight provider adapter.

Sprint 07 decision:

- Keep the current OpenAI-compatible adapter as the MVP integration path.
- Validate real model calls through system-level configuration first.
- Run this after Sprint 06 establishes the user's own ZEROON companion
  presence, so AI replies have a clearer product container.
- Do not add user-owned API keys in this sprint.
- Do not migrate to Spring AI unless a concrete capability gap appears.
- Add clear operational verification so the team can tell whether AI is really
  connected or using fallback.

---

## Mainline Fit

The sprint supports ZEROON as a long-term companion and private memory system by
making AI observations and replies genuinely contextual.

Allowed use:

- Companion replies based on the user's current state and recent records.
- Archive or growth observations that help the user understand patterns.
- Profile context only when the user has enabled AI profile context.
- Calm, non-diagnostic reflection.

Disallowed use:

- Generic open-ended chatbot behavior unrelated to ZEROON memory.
- Medical, legal, financial, or psychological diagnosis.
- Fixed personality labels.
- User-level API key collection before the security and consent model is ready.
- Provider branding or model details exposed as the center of the product.

---

## Scope

### Backend

- Verify `LLM_BASE_URL`, `LLM_API_KEY`, and `ZEROON_LLM_MODEL` configuration
  against a real OpenAI-compatible provider.
- Add a safe AI provider verification path for local and release checks.
- Ensure fallback remains available when the provider is unavailable.
- Ensure AI usage logs distinguish success, fallback, and refusal.
- Confirm profile context is included only when
  `ai_profile_context_enabled=true`.
- Document the actual adapter-based architecture.

### Mobile

- Verify companion and observation flows display real AI replies correctly.
- Keep fallback copy calm and product-consistent.
- Avoid showing raw technical provider errors to users.
- Add or adjust user feedback only if real provider latency makes the current
  UI unclear.

### Admin / Operations

- Document environment variables required for local AI verification.
- Defer a full admin provider settings UI unless needed for release operation.

---

## Out of Scope

- User-entered API keys.
- Per-user model selection.
- Spring AI migration.
- RAG, vector database, semantic search, or embedding storage.
- Long-term inferred personality profile.
- AI-generated diagnosis, scoring, or classification.
- Public sharing of AI observations.

---

## Backend Tasks

| ID | Owner | Task | Status |
|---|---|---|
| S6-BE-01 | Backend | Add documented local configuration example for `LLM_BASE_URL`, `LLM_API_KEY`, and `ZEROON_LLM_MODEL` | Pending |
| S6-BE-02 | Backend | Add or confirm a safe AI provider verification path without storing prompt content in logs | Pending |
| S6-BE-03 | Backend | Run real OpenAI-compatible provider smoke test through `POST /api/v1/companion/messages` | Pending |
| S6-BE-04 | Backend | Verify `AiUsageOutcome.SUCCESS`, `FALLBACK`, and `REFUSAL` logging with real and unavailable provider states | Pending |
| S6-BE-05 | Backend | Confirm profile context prompt inclusion only when user permission is enabled | Pending |
| S6-BE-06 | Backend | Add focused tests if any integration behavior changes | Pending |

## Mobile Tasks

| ID | Owner | Task | Status |
|---|---|---|
| S6-MO-01 | Mobile | Verify real AI companion reply renders correctly in the current mobile web flow | Pending |
| S6-MO-02 | Mobile | Verify fallback reply remains calm and does not look like a crash state | Pending |
| S6-MO-03 | Mobile | Review loading and retry behavior for AI response latency | Pending |
| S6-MO-04 | Mobile | Keep AI reply copy aligned with ZEROON voice and non-diagnostic boundaries | Pending |

## Documentation Tasks

| ID | Owner | Task | Status |
|---|---|---|
| S6-DOC-01 | Architect | Update architecture notes to reflect adapter-based OpenAI-compatible integration | Pending |
| S6-DOC-02 | Architect | Record decision to defer Spring AI migration | Pending |
| S6-DOC-03 | PM | Add local AI verification checklist to release verification notes | Pending |

---

## Development Sequence

1. Confirm target real provider and local environment variable names.
2. Add local AI configuration documentation.
3. Start backend with real provider configuration.
4. Call `POST /api/v1/companion/messages` through an authenticated user flow.
5. Confirm the response is not the static fallback reply.
6. Confirm AI usage logs record `SUCCESS`.
7. Temporarily remove or break provider configuration and confirm fallback.
8. Confirm safety-boundary requests still produce `REFUSAL` without calling the
   provider.
9. Verify mobile web displays success, fallback, and loading states acceptably.
10. Update Sprint or architecture documentation with the verified result.

---

## Acceptance Criteria

- A real OpenAI-compatible provider can be configured without code changes.
- Companion message API returns a real model response when provider credentials
  are valid.
- Companion message API returns the existing calm fallback when provider
  credentials are missing or invalid.
- AI usage logs correctly distinguish `SUCCESS`, `FALLBACK`, and `REFUSAL`.
- User-facing screens do not expose raw provider errors.
- Profile context is not included in prompts unless the user enabled it.
- Documentation no longer implies Spring AI is already implemented.
- ZEROON remains a private memory and companion product, not a generic chatbot.

---

## Verification Commands

Recommended gates:

```bash
cd backend
JAVA_HOME=/Users/bruceann/Library/Java/JavaVirtualMachines/corretto-17.0.13/Contents/Home ./gradlew test

cd ../mobile
flutter analyze
flutter test

cd ..
git diff --check
```

Runtime checks:

```bash
curl -sS http://localhost:8080/actuator/health
```

Authenticated API smoke test should verify:

- `POST /api/v1/companion/messages`
- response body contains a non-empty `reply`
- real-provider case does not equal the static fallback reply
- unavailable-provider case returns fallback without breaking record flows

---

## Risks

- Different providers may claim OpenAI compatibility but vary in endpoint,
  request, or response behavior.
- Real provider latency may require better mobile loading feedback.
- API keys must not be committed, logged, or exposed to the mobile client.
- Prompt context can drift into labeling if future changes are not reviewed
  against ZEROON product guardrails.
