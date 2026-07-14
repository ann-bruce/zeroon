# Sprint 06 Plan V1

Status: Draft

## Sprint Goal

Add "My ZEROON" as a calm companion presence that the user can meet and keep.

Sprint 06 lets each user establish a private ZEROON companion before entering
the main app for the first time. The feature does not turn the product into a
pet game, social identity page, or generic avatar system. It gives ZEROON a
clearer presence before real-model AI replies are expanded in Sprint 07.

---

## Product Decision

Confirmed direction:

- Add a private "My ZEROON" companion foundation.
- Use "meet ZEROON" or "my ZEROON" language instead of game-like claiming.
- Route first-time authenticated users to `与 ZEROON 相遇` before enabling main
  app functions.
- Assign a stable private nameplate serial at the first meeting.
- Keep the first version light, quiet, and identity-building.
- Let the user's ZEROON appear in selected product moments.
- Store only minimal companion configuration.

Do not add:

- Levels, feeding, coins, tasks, or growth pressure.
- Public profiles or social sharing.
- Marketplace, skins, or paid decoration.
- Emotional dependency mechanics.
- AI-generated fixed personality labels.

---

## Mainline Fit

This sprint supports ZEROON's mainline as a long-term companion and private
memory system by giving the companion a stable product presence.

The companion is not a separate game object. It is the user's quiet ZEROON
presence across recording, reflection, archive, and growth.

Allowed use:

- First meeting moment.
- Private companion identity.
- Calm visual presence on My, Now, Reset Complete, and Growth surfaces.
- Future AI reply continuity.

Disallowed use:

- Pet-care loops.
- Streak pressure.
- Romance or confession framing.
- Social comparison.
- User scoring or ranking.

---

## Experience Scope

### Entry

Recommended MVP entry:

- Primary entry immediately after first registration/login.
- The main app is enabled only after the user meets ZEROON.
- `我与 ZEROON` shows the already-met ZEROON and nameplate. It is not the
  creation entry.

### First Meeting

Recommended flow:

1. User logs in or registers.
2. App checks `GET /api/v1/me/zeroon-companion`.
3. If `met=false`, user sees `与 ZEROON 相遇`.
4. ZEROON appears with calm copy.
5. User confirms: `确认相遇`.
6. Backend creates the companion and assigns a private nameplate serial.
7. User sees the nameplate and taps `进入 ZEROON`.
8. Main app features become available.

Recommended copy:

- Title: `与 ZEROON 相遇`
- Body: `在开始记录之前，先确认这个会陪你回看此刻的 ZEROON。`
- Action: `确认相遇`
- Completion: `我在这里。以后你留下的此刻，我都会陪你一起回看。`
- Enter action: `进入 ZEROON`

### Persistent Surfaces

After meeting ZEROON:

- `我与 ZEROON`: show the user's ZEROON companion card.
- `此刻`: use a small calm ZEROON presence when appropriate.
- `归零完成`: let ZEROON confirm the saved memory.
- `陪伴成长`: reflect that ZEROON has been present across time.

Avoid overuse. ZEROON should feel present, not noisy.

---

## Data Model

Recommended table: `user_zeroon_companions`

| Field | Type | Required | Notes |
|---|---|---|---|
| `id` | BIGSERIAL | yes | Primary key |
| `user_id` | BIGINT | yes | Unique owner |
| `companion_key` | VARCHAR(30) | yes | Initial value such as `ZEROON_DEFAULT` |
| `display_name` | VARCHAR(30) | no | Reserved for later, not required in MVP |
| `nameplate_serial` | VARCHAR(20) | yes | Stable private serial such as `ZR-20260703-A8K2` |
| `met_at` | TIMESTAMPTZ | yes | First meeting time |
| `created_at` | TIMESTAMPTZ | yes | Audit timestamp |
| `updated_at` | TIMESTAMPTZ | yes | Audit timestamp |

Rules:

- One companion per user.
- Companion belongs only to the authenticated user.
- Nameplate serial is assigned once and does not imply rank, rarity, or social
  status.
- MVP does not support deletion or public sharing.
- MVP does not support file upload.

---

## API Draft

### Get My ZEROON

`GET /api/v1/me/zeroon-companion`

Behavior:

- Return the current user's companion if it exists.
- Return `met=false` if the user has not met ZEROON yet.

### Meet My ZEROON

`POST /api/v1/me/zeroon-companion`

Request:

- `companionKey`

Behavior:

- Create the companion if none exists.
- Return existing companion idempotently if already created.
- Reject invalid companion keys.

Response:

- `met`
- `companionKey`
- `displayName`
- `nameplateSerial`
- `metAt`

Error behavior:

- `400` for invalid companion key.
- `401` for unauthenticated access.

---

## Backend Tasks

| ID | Owner | Task | Status |
|---|---|---|
| S6-BE-01 | Backend | Add `user_zeroon_companions` migration and entity | Pending |
| S6-BE-02 | Backend | Add companion repository and service | Pending |
| S6-BE-03 | Backend | Add get/create companion API | Pending |
| S6-BE-04 | Backend | Add nameplate serial generation and persistence | Pending |
| S6-BE-05 | Backend | Update OpenAPI documentation | Pending |
| S6-BE-06 | Backend | Add owner-scoped, idempotency, and nameplate tests | Pending |

## Mobile Tasks

| ID | Owner | Task | Status |
|---|---|---|
| S6-MO-01 | Mobile | Add My ZEROON model, repository, and controller | Pending |
| S6-MO-02 | Mobile | Add first-login `与 ZEROON 相遇` gate | Pending |
| S6-MO-03 | Mobile | Show assigned nameplate before entering main app | Pending |
| S6-MO-04 | Mobile | Add light companion presence on selected screens | Pending |
| S6-MO-05 | Mobile | Add loading, empty, saved, and failure states | Pending |
| S6-MO-06 | Mobile | Add widget tests for the meeting flow | Pending |
| S6-MO-07 | Mobile | Remove creation entry from `我与 ZEROON` | Pending |

## Design Tasks

| ID | Owner | Task | Status |
|---|---|---|
| S6-UX-01 | Design | Confirm ZEROON companion visual treatment | Pending |
| S6-UX-02 | Design | Confirm first meeting copy and card layout | Pending |
| S6-UX-03 | Design | Review selected surface appearances for visual noise | Pending |

---

## Development Sequence

1. Confirm MVP copy and visual state for the first meeting.
2. Add backend migration, entity, repository, nameplate serial, and service.
3. Add get/create API and OpenAPI contract.
4. Add backend tests for unauthenticated access, creation, idempotency, and
   ownership.
5. Add mobile repository and state controller.
6. Add first-login encounter gate and nameplate confirmation UI.
7. Change `我与 ZEROON` to show the existing companion and nameplate only.
8. Add restrained companion presence to selected surfaces.
9. Run backend, mobile, OpenAPI, and whitespace validation.
10. Restart local services for UI verification.

---

## Acceptance Criteria

- A new authenticated user meets ZEROON before entering the main app.
- Once met, the user's ZEROON remains visible as a private companion card.
- The user sees a stable private nameplate serial before entering ZEROON.
- Repeating the meet action is idempotent and does not create duplicates.
- Another user cannot access or modify the companion.
- ZEROON appears in selected places without adding visual noise.
- `我与 ZEROON` does not contain the creation/meet entry after this flow change.
- The feature does not include pet-care, game, social, ranking, or reward loops.
- The copy reinforces companionship, memory, and reflection.
- OpenAPI, backend tests, and mobile tests are updated.

---

## Risks

- The word "领取" can make the feature feel like a game reward. Product copy
  should use `见一面`, `我的 ZEROON`, or similar calmer language.
- Too much visual presence can make ZEROON feel noisy. The first release should
  be restrained.
- Adding customization too early can turn the feature into an avatar system.
  MVP should keep only one default companion option unless design confirms a
  very small preset set.
