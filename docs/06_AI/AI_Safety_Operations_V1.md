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

## Cost Controls

- Configure model and token limits outside source code.
- Record daily token totals by environment and model.
- Alert when daily cost reaches 70%, 90%, and 100% of budget.
- Disable nonessential AI summaries before disabling the core record flow.

