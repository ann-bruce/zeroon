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
- High-risk self-harm handling uses the deterministic
  `SELF_HARM_IMMINENT`, `SELF_HARM_CONCERN`, or
  `SELF_HARM_THIRD_PARTY` path and bypasses the provider. Engineering and
  regression tests are complete, but professional review remains a blocker
  before wider Beta recruitment.
- Prompt injection in user content cannot override system safety rules or
  expose memory belonging to another user.
- Admin prompt changes require the `ADMIN` role and an audit event.

The high-risk response is identified as
`SAFETY_SELF_HARM_V1_REVIEW_PENDING`. It directs immediate danger to local
emergency care, encourages a trusted person and distance from dangerous means,
and scopes 988 to the United States and its territories. It does not diagnose,
show a risk score, contact another person, or promise monitoring or rescue.
See `High_Risk_Safety_Policy_V1_Draft.md`.

## Prompt Governance

- Prompt content versions are immutable.
- A new version begins in `PENDING` and is not eligible for runtime use.
- The creator cannot review the same version; another authenticated
  administrator must approve or reject it.
- Runtime selection uses the explicit `prompt_activations` pointer rather than
  the numerically highest enabled version.
- Activating an older approved version is an audited rollback.
- A forward activation requires the latest immutable evaluation record to pass
  all release thresholds. A failed re-evaluation blocks forward activation.
- Evaluation rows contain only corpus/model aliases, bounded scores, reviewer
  identifiers, content-free defect categories, and the decision. Synthetic
  inputs and model replies stay outside operational tables and logs.
- Prompt audit rows contain only code, versions, actor, bounded reason code,
  action, and timestamp; they never duplicate Prompt or private context text.
- Persona V2 content is not production-active until its behavioral evaluation
  gate passes.

## Runtime Prompt Layers

1. Code-owned safety and privacy instruction.
2. Explicitly active, versioned ZEROON Persona.
3. Server-owned product-surface task selected by `purpose`.
4. Server-resolved language instruction.
5. Consented Profile and Memory in an untrusted data envelope.
6. Current state and current user message in that same data envelope.

Lower layers cannot override higher layers. `purpose` does not grant new data
access and mobile prompt prose is never the authority for surface behavior.

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
