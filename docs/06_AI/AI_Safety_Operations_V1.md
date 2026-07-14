# AI Safety and Operations V1

## Runtime Rules

- Request timeout: 20 seconds.
- Retry: one retry only for transient upstream failures.
- Maximum user message: 4,000 characters.
- Store provider, model, latency, token usage, and outcome without logging raw
  private content.
- Apply per-user and per-device rate limits.
- If the provider is unavailable, preserve the user message and return a
  retryable response.

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
- Usage logs store metadata and character counts, never profile or prompt text.

## Cost Controls

- Configure model and token limits outside source code.
- Record daily token totals by environment and model.
- Alert when daily cost reaches 70%, 90%, and 100% of budget.
- Disable nonessential AI summaries before disabling the core record flow.
