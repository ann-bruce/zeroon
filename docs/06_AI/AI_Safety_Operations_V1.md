# AI Safety and Operations V1

## Runtime Rules

- Companion provider timeout: 8 seconds.
- Automatic provider retry is disabled in the current adapter; an unavailable
  provider returns the calm fallback without exposing technical errors.
- Maximum user message: 4,000 characters.
- Store provider, model, latency, prompt version, character counts, optional
  provider-reported token usage, and outcome without logging raw private content.
- Apply per-user and per-device rate limits.
- If the provider is unavailable, preserve the user message and return the
  existing calm fallback response.

## Transaction Boundary

- User-message preparation, consent-aware context reads, and assistant/log
  completion use separate short transactions.
- `LlmProvider.generate` must run without an active Spring transaction.
- The user message is committed before the external call. Success, fallback,
  and refusal complete with an assistant message and matching usage row.
- Provider exceptions are represented only by bounded error codes; exception
  messages, request bodies, prompts, and replies never enter usage metadata.

## Safety Boundaries

- No diagnosis, therapy claims, legal decisions, or investment guarantees.
- High-risk self-harm language triggers deterministic safety guidance before
  or alongside model output.
- Prompt injection in user content cannot override system safety rules or
  expose memory belonging to another user.
- Admin prompt changes require the `ADMIN` role and an audit event.

## Profile Context Consent

- Profile context is off by default and is read again for every AI request.
- When enabled, only the user's nickname, age range, occupation or identity,
  and self-description may enter the provider request.
- Avatar presets, internal identifiers, inferred traits, personality labels,
  and fields belonging to another user are excluded.
- Disabling permission affects the next request immediately; no context cache
  may preserve an earlier consent decision.
- Profile values are treated as user data rather than prompt instructions.
- Usage logs store metadata, character counts, and optional provider-reported
  token counts, never profile, Memory, record, prompt, message, or reply text.

## Planned Cost Controls

- Configure model and token limits outside source code.
- Aggregate daily provider-reported token totals by environment and model.
- Alert when daily cost reaches 70%, 90%, and 100% of budget.
- Disable nonessential AI summaries before disabling the core record flow.
