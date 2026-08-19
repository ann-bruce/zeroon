# Sprint 13 Return Loop Foundation And Owner Acceptance V1

Status: Closed — engineering delivery and owner acceptance complete
Prepared: 2026-07-30
Last updated: 2026-08-19

## Intake Decision

### 1. Mainline fit

ZEROON is a long-term companion and private memory system. Sprint 13 makes
elapsed time visible inside the existing product loop:

```text
Leave one moment
  -> time passes
  -> ZEROON quietly resurfaces one user-owned moment
  -> the user reviews it, writes now, or leaves it alone
```

This strengthens reflective continuity without public content, diagnosis,
high-frequency chat, or engagement pressure.

### 2. Drift risk

Sprint 13 must not become:

- a daily check-in requirement or streak campaign;
- push-notification growth hacking;
- a generic AI chat tab;
- emotional diagnosis, personality labeling, or prediction;
- an automatically inferred unfinished issue;
- a task reminder or productivity inbox;
- a reason to expose private text on a lock screen;
- a broad analytics or per-user administrator timeline.

### 3. Recommended abstract capability

**User-owned continuity cue**: after enough time passes, ZEROON may quietly
resurface one eligible moment that the current user already owns. The user can
review it, leave a new moment, dismiss it for the local day, or ignore it.
ZEROON does not claim why the moment matters.

### 4. Roadmap decision

Sprint 13 establishes the in-app return-loop foundation and closes after
engineering verification and owner acceptance. It does not add notification,
payment, social, hardware, generic chat, scores, levels, or broader AI
inference.

## Sprint Goal

Deliver and owner-accept one quiet, private, removable continuity cue together
with the minimum Reset and first-use refinements required to keep the core loop
clear and low pressure.

## Closure Outcome — 2026-08-18

The following work is complete on `main` and passed recorded owner checks:

- owner-only deterministic continuity-cue API;
- one quiet Now-slot continuity card with local-day dismissal;
- existing Record Detail review and optional blank `写下现在` continuation;
- reviewed content-free evidence events and failure isolation;
- Reset capture hierarchy refinement;
- first-loop contextual orientation;
- Simplified Chinese and English coverage;
- owner and cross-user isolation verification recorded by the Sprint work.

Sprint 13 has no remaining task, deferred item, or downstream release
authorization.

## Minimum Product Experience

### Now card

Working label:

> 和 ZEROON 回看一个此刻

The card appears only when an eligible Record exists. It contains:

- a quiet time anchor such as `3 天前` or an exact user-local date;
- the Record's user-owned state and a bounded preview;
- one primary action: `回看这个此刻`;
- one quiet action: `先放着`.

It must not imply urgency, diagnosis, surveillance, importance, unfinished
work, or disappointment.

### Confirmed Now-slot contract

The cue belongs in the existing Now surface. It replaces the existing Reset
rhythm card in that single card slot and never creates a new tab or additional
home-page section. When unavailable, dismissed, loading, or recoverably
failed, the normal rhythm card remains in the same slot.

### Review path

The primary action opens the existing Record Detail. From there the user may:

- read the original Record;
- inspect existing Memory controls;
- start a new blank Reset through `写下现在`;
- leave without changing anything.

The old Record is never silently edited, relabeled, activated as Memory, or
sent to AI by opening the cue.

### Empty behavior

When no Record is old enough, no placeholder or data-creation prompt appears.
The normal Now experience remains intact.

## Eligibility And Selection Contract

- The Record belongs to the authenticated current user.
- The Record is at least `72` hours old at the start of the user's local day.
- Deleted or unavailable Records are excluded.
- Selection is deterministic for the user's local calendar day.
- Only one cue appears at a time.
- `先放着` hides that cue for the current local day.
- Selection never inspects or classifies Record text.
- No importance, emotion, risk, or engagement score is calculated.
- Cue availability or failure never blocks Now, Reset, Archive, or account
  controls.

## Completed Work

| Item | Scope | Completion contract |
|---|---|---|
| `S13-01` | Product contract and baseline | Return-loop capability, ownership, privacy, and stop boundaries were explicit before implementation |
| `S13-02` | Owner-only continuity cue API | Authenticated API returns zero or one eligible owned Record cue without AI, cross-user access, text classification, or analytics side effects |
| `S13-03` | Now continuity card | Card is quiet, optional, localized, recoverable, and opens existing Record Detail |
| `S13-04` | Optional `写下现在` continuation | A blank Reset starts without copying old text or pre-deciding a new state |
| `S13-05` | Content-free evidence | Only reviewed cue availability, open, dismiss, and continuation outcomes are recorded under explicit Beta consent |
| `S13-08` | Reset capture hierarchy | One open moment field is primary and the optional direction appears only on request |
| `S13-09` | First-loop orientation | Contextual cues connect Now, the first Reset, and Archive without tutorial state or pressure |

Historical item numbers remain stable; removed planning items are not reused.

## Reset Capture Hierarchy

Accepted primary capture:

```text
这一刻，想留下什么
一句话、一个念头，或刚刚发生的事

＋ 留一个接下来的小方向（可选）
```

Expanded optional direction:

```text
接下来，想往哪里走一点
不一定要完成，留一个小方向就好
```

Stored API fields remain `content` and `goal`. Either field may satisfy the
existing Record-content requirement. Older Records require no migration.

## First-Loop Orientation

A user with no Records receives one quiet Now cue: choose the state closest to
this moment, then begin a Reset when ready. After the first Record is saved,
the completion screen explains that the moment can later be revisited in
Archive. The cues disappear naturally once a Record exists.

This adds no tutorial-completion field, backend API, migration, modal,
spotlight, carousel, counter, reward, or mandatory action.

## Evidence Boundary

Implemented event names:

- `RETURN_CUE_AVAILABLE`;
- `RETURN_CUE_OPENED`;
- `RETURN_CUE_DISMISSED`;
- `RETURN_CUE_CONTINUED`.

Allowed properties remain fixed buckets, fixed surface/action values, and
already permitted app/platform metadata. Record id, date, state, goal, content,
preview, Memory status, identity, AI text, and exact event time are prohibited.
Evidence failure never affects cue display or navigation.

## Acceptance Criteria

- owner-only selection and cross-user isolation pass;
- no eligible cue restores the normal Now slot;
- dismissal restores the normal slot for the local day;
- review never changes Record, Memory, or AI consent;
- optional continuation starts blank;
- Reset drafts survive locale changes during the active route;
- first-loop cues appear only in their intended zero/first-Record states;
- Chinese and English remain readable at 390-pixel width;
- no private content enters evidence, logs, admin, or lock-screen surfaces;
- failures remain recoverable and do not block the core product.

## Non-Goals

- push or local return notifications;
- lock-screen Record previews;
- AI-selected important memories;
- unfinished-task reminders;
- automatic sensitive-content questions;
- generic companion chat navigation;
- streak rewards, badges, scores, levels, social sharing, or payment;
- weekly, monthly, or yearly automatic AI summaries.
