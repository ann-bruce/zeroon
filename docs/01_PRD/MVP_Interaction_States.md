# MVP Interaction States

## Global

- Loading: preserve layout and prevent duplicate submission.
- Empty: explain what will appear and provide one primary action.
- Offline: preserve unsent text locally and allow retry.
- Error: describe the recoverable action without exposing technical details.
- Authentication expired: attempt one token refresh, then return to login.

## SMS Login

- Request code is disabled for 60 seconds after success.
- Invalid mobile format is rejected before submission.
- Invalid or expired code keeps the mobile number and clears only the code.
- After five failed attempts, require a new code.
- The UI never reveals whether an unregistered mobile number exists.

## Zero Record

- State is required; goal and content are optional, but at least one
  descriptive field must be provided.
- Save is idempotent from the user's perspective and cannot create duplicates
  after repeated taps.
- A successful save immediately updates the home state.
- If AI feedback fails, the record remains saved and displays a retryable
  "feedback temporarily unavailable" state.

## Companion

- Show a non-diagnostic product disclaimer before the first conversation.
- Preserve the user's message when the model times out.
- Crisis or self-harm signals show an immediate safety notice and local
  emergency-resource guidance; the model response is not the only safeguard.
- Medical, legal, and financial requests receive a boundary response.

## Account Deletion

- Explain the 7-day recovery period and affected data before confirmation.
- Require fresh authentication.
- Revoke all sessions immediately after confirmation.
