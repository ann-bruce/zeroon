# Sprint 13 Return Loop Validation V1

Status: Closed — engineering and owner validation complete; S13-06/S13-07 in Backlog
Prepared: 2026-07-30
Last updated: 2026-08-18

## Intake Decision

### 1. Mainline fit

ZEROON's mainline is a long-term companion and private memory system. The
current product can save and review moments, but most value appears only after
the user has already decided to return.

Sprint 13 should make elapsed time create a new, user-visible reason to return:

```text
Leave one moment
  -> time passes
  -> ZEROON quietly resurfaces one user-owned moment
  -> the user revisits, updates, or leaves it alone
  -> continuity becomes more valuable
```

This strengthens private memory, reflective continuity, and companionship
without requiring public content, diagnosis, or high-frequency chat.

### 2. Drift risk

The sprint must not become:

- a daily check-in requirement or streak campaign;
- push-notification growth hacking;
- a generic AI chat tab;
- an emotional diagnosis, personality label, or prediction;
- an automatically inferred "unfinished issue";
- a task reminder or productivity inbox;
- a reason to expose private text on a lock screen;
- a broad analytics expansion or per-user administrator timeline.

The main risk is manufacturing opens before proving that the in-product return
experience is worth opening.

### 3. Recommended abstract capability

**User-owned continuity cue**: after enough time passes, ZEROON may quietly
resurface one eligible moment that the current user already owns. The user can
review it, leave a new moment, or ignore it. ZEROON does not claim why the
moment matters.

### 4. Roadmap decision

Accept Sprint 13 as **Return Loop Validation**, beginning with an in-app
continuity cue. Defer notification delivery until the cue itself demonstrates
value in owner testing and the first closed-Beta cohort.

Do not add payment, social, hardware, generic chat, scores, levels, or broader
AI inference in this sprint.

### 5. Planning acceptance criteria

The plan is acceptable only if:

- the returned item belongs to the authenticated user;
- the cue is derived from an existing user-owned Record, not AI inference;
- no private Record text enters evidence events, notification text, logs, or
  administrator views;
- the user can ignore the cue without penalty, repeated prompting, or a
  negative state;
- revisiting never changes or activates Memory or AI consent;
- any new reflection still uses current consent and Persona safety rules;
- a failed cue never blocks Now, Reset, Archive, or account controls;
- the first implementation can be removed or reshaped without changing stored
  Record meaning.

## Sprint Goal

Determine whether a quiet, private resurfacing of one older user-owned moment
creates a meaningful reason to reopen ZEROON and continue the
record-memory-reflection loop.

The sprint is successful only if users describe the return as useful or
personally meaningful. More opens alone are not success.

## Closure Decision — 2026-08-18

Sprint 13 is closed for engineering delivery and owner validation. The
owner-only continuity cue, optional continuation path, content-free evidence
boundary, Reset hierarchy refinement, and first-loop orientation were
implemented and passed their recorded owner checks.

This closure does **not** claim closed-Beta return value, retention lift, or
notification readiness. S13-06 was moved to Backlog without a target date, and
S13-07 remains blocked by that evidence gate. No participant invitation,
seven-day evidence collection, notification delivery, or public-release
expansion is authorized by closing this Sprint.

## Current Baseline

The 2026-07-30 production snapshot is directional only:

- active App users: fewer than the five-participant reporting threshold;
- all current active App users met ZEROON and saved at least one Record;
- total Records: `10`;
- multi-day recording exists but remains below the reporting threshold;
- evidence-enabled participation remains below the reporting threshold.

This is a team/test-sized sample and cannot establish D1 or D7 retention. It
does show that initial activation is possible while repeat value remains
unproven.

## Product Hypotheses

### H1: The current loop is front-loaded

Users must notice a state, enter Reset, write, and save before ZEROON provides
meaningful value. The first-week return reward is too weak relative to this
effort.

### H2: Continuity is promised but not visible on return

The encounter establishes ZEROON as a companion, but the normal home
experience waits for the user to act. It does not yet show how elapsed time
made an earlier moment newly useful.

### H3: A user-owned cue can create value without pressure

Showing one older Record after authentication may create curiosity and
continuity without notification pressure, AI guessing, or a new navigation
surface.

### H4: Notification is a delivery mechanism, not the value

An opt-in notification should be considered only if users value the in-app
cue. Otherwise notification would remind them to open an experience they
already do not miss.

## Minimum Product Experience

### Now card

Working label:

> 和 ZEROON 回看一个此刻

The card appears only when an eligible Record exists. It contains:

- a quiet time anchor such as `3 天前` or an exact user-local date;
- the Record's user-owned state and a short on-device/API response preview;
- one primary action: `回看这个此刻`;
- one quiet action: `先放着`.

It must not say:

- `你一直都是这样`;
- `这件事还困扰着你`;
- `ZEROON 发现你有某种模式`;
- `你已经连续几天没有回来`;
- anything implying urgency, diagnosis, surveillance, or disappointment.

### Confirmed implementation and release contract

The continuity cue belongs in the existing **Now** (`此刻`) surface. It does
not create a new tab, interaction surface, or additional home-page section.
When eligible, it **replaces the existing continuous Reset rhythm card in that
single card slot**; it must not be stacked above or below that card. When the
cue is unavailable, dismissed for the local day, loading, or recoverably
fails, the normal rhythm card remains in that same slot.

This keeps the primary Reset action and today's Archive entry unchanged while
preventing the Now surface from becoming denser or turning continuity into a
second daily task. The cue remains a quiet invitation, not a performance
metric.

### Review path

The primary action opens the existing Record detail. From there the user may:

- read the original Record;
- use the existing Memory controls;
- choose an optional `写下现在` action that starts a new, blank Reset flow;
- leave without changing anything.

The old Record is never silently edited, relabeled, activated as Memory, or
sent to AI.

### Empty behavior

When no Record is old enough, do not show a placeholder card or ask the user
to create data for the feature. The normal Now experience remains intact.

## Eligibility and Selection Contract

Initial rules:

- owner must be the authenticated current user;
- Record must be at least `72` hours old at the start of the user's local
  calendar day, keeping that day's eligible set stable;
- deleted or unavailable Records are excluded;
- selection is deterministic for the user's local calendar day using the
  device's current UTC offset or an equivalent IANA timezone;
- only one cue appears at a time;
- a cue dismissed with `先放着` stays hidden for the current local day;
- the selection algorithm must not inspect or classify Record text;
- no importance, emotion, risk, or engagement score is calculated.

For the first slice, notification delivery and cross-device dismissal sync are
not required. If deterministic selection creates excessive repetition, a
future content-free `lastPresentedAt` receipt may be proposed separately with
export and deletion behavior.

## Implementation Sequence

| Item | Decision gate | Done when |
|---|---|---|
| S13-01 Product contract and baseline | Product plan approved | Return value, boundaries, current baseline, hypotheses, and stop rules are explicit |
| S13-02 Owner-only continuity cue API | Technical contract accepted | Authenticated API returns zero or one eligible owned Record cue without AI, cross-user access, text classification, or analytics side effects |
| S13-03 Now continuity card | First owner test | Card is quiet, optional, localized, recoverable, and opens the existing Record detail |
| S13-04 Optional `写下现在` continuation | Continuity test | User can start a blank Reset from the reviewed Record without copying old text or pre-deciding the new state |
| S13-05 Content-free evidence | Measurement boundary accepted | Only cue availability/view/open/dismiss and optional continuation outcome are recorded under explicit Beta consent |
| S13-06 Owner and closed-Beta validation | Backlog — deferred by owner | No seven-day cohort or evidence collection is currently scheduled; resume only with a new explicit owner decision |
| S13-07 Optional return invitation | Backlog — blocked by S13-06 | Only after S13-06 is explicitly resumed and proves value may user-controlled local reminders be proposed, with no private lock-screen text |
| S13-08 Reset capture hierarchy refinement | Owner UX correction | Reset prioritizes one open moment field and reveals the non-required next direction only on request, without changing stored Record meaning |
| S13-09 First-loop orientation | Pre-cohort first-use correction | A user with no Records receives two contextual, non-blocking cues that connect Now, the first Reset, and Archive without a tutorial flow |

### S13-08 Reset capture hierarchy refinement

Owner production use found that `留下一句话` was narrower than the actual
free-form Record capability, while `今天想完成什么` made an optional continuity
field feel like a daily task. Equal visual weight also made Reset feel more
like a form than a quiet place to preserve one moment.

The accepted hierarchy is:

```text
这一刻，想留下什么
一句话、一个念头，或刚刚发生的事

＋ 留一个接下来的小方向（可选）
```

After the user asks for it, the second field becomes:

```text
接下来，想往哪里走一点
不一定要完成，留一个小方向就好
```

The stored API fields remain `content` and `goal`. Completion, Archive, and
Record Detail present `goal` as `接下来` / `Next`, not as a required target.
Either field may satisfy the existing Record-content requirement.

Acceptance requires:

- the moment field is the only text field visible initially;
- the optional direction expands locally without clearing the moment draft;
- content-only, direction-only, and combined Records continue to save;
- locale changes preserve drafts and the expanded state;
- Chinese and English remain readable on a 390-pixel-wide device;
- older Records render under the new labels without migration;
- no task completion, streak, score, reminder, or negative state is added.

### S13-09 First-loop orientation

ZEROON should explain its first core loop without becoming instructional. A
user with no Records sees one quiet cue on Now: first choose the state closest
to this moment, then begin a Reset when ready. After the first Record is saved,
the completion screen explains that the moment can later be revisited in
Archive. The cues disappear naturally once a Record exists.

This orientation is derived from the existing Record count. It adds no
tutorial-completion field, backend API, database migration, analytics event,
modal, spotlight, carousel, step counter, reward, or mandatory action.

Acceptance requires:

- the Now cue appears only when the authenticated user has zero Records;
- both the no-state and active-state variants remain quiet and contextual;
- the completion cue appears only after the user's first saved Record;
- returning users retain the existing Now and completion experience;
- Record-list loading or failure never blocks state selection or Reset;
- Chinese and English remain readable on a 390-pixel-wide device;
- no private content or new behavioral evidence is collected.

## Affected Surfaces for Engineering

Expected only after S13-01 approval:

- backend: owner-only cue query, DTO, service, controller, tests;
- OpenAPI: optional continuity-cue response;
- mobile: Now card, Record-detail navigation, local-day dismissal, and Reset
  capture hierarchy;
- localization: Simplified Chinese and English;
- evidence: narrowly reviewed typed events and cohort calculation;
- database: no new table for the first slice unless selection or evidence
  review proves persistence necessary;
- admin: aggregate evidence only; no individual cue browser.

## Evidence Boundary

Proposed content-free events, subject to a separate contract review:

- `RETURN_CUE_AVAILABLE`;
- `RETURN_CUE_OPENED`;
- `RETURN_CUE_DISMISSED`;
- `RETURN_CUE_CONTINUED`.

Allowed properties should be limited to:

- fixed cue age bucket;
- fixed entry surface;
- action;
- app version and platform where already permitted.

Prohibited properties include Record id, date, state, mood, goal, content,
preview, Memory status, user identity, AI reply, and exact event time.

Availability should not be counted repeatedly on every rebuild. Evidence
failure must never affect cue display or navigation.

## Backlog: Seven-Day Validation

Deferred by owner on 2026-08-18. This is not a current Sprint gate, has no
target date, and must not trigger participant invitations, evidence collection,
or notification work. Resume only after a new explicit owner decision.

Run first with Bruce Ann, then no more than the existing closed-Beta limit.

Ask each participant:

1. What did you expect when you opened the returned moment?
2. Was it worth seeing now, or did it feel random?
3. Did ZEROON imply something about you that you did not say?
4. Did you want to leave a new moment after reading it?
5. Would a weekly invitation be useful, unnecessary, or intrusive?
6. What would have made you dismiss the feature permanently?

Do not ask participants to disclose the Record content.

## Release gate

Before any controlled deployment, verify and record all of the following:

- this confirmed Now-slot behavior, including restoration after `先放着`;
- owner-only API selection, no eligible-cue behavior, and cross-user
  isolation;
- OpenAPI, database migration, localized mobile behavior, and content-free
  evidence-contract tests;
- no production deployment, participant invitation, or notification change
  occurs without explicit owner authorization.

## Decision Gates

### Continue

- at least `5` participants have an eligible cue;
- at least `3` voluntarily open a cue on more than one day;
- at least `3` describe a concrete value beyond novelty;
- no participant reports diagnosis, pressure, surveillance, or consent
  confusion;
- owner and cross-user isolation tests pass;
- the normal Now screen remains useful when no cue exists.

### Reshape

- users open cues but describe them as random, repetitive, generic, or too
  old;
- users want a different time range or explicit topic choice;
- the cue is valued only after manual selection;
- `写下现在` is useful but automatic resurfacing is not.

### Stop

- users experience the cue as intrusive or emotionally unsafe;
- the feature requires content classification to appear relevant;
- private text appears outside the authenticated in-app surface;
- return behavior depends mainly on streak pressure or notification frequency;
- users cannot explain why the cue is more useful than opening Archive.

## Explicitly Deferred

- push notifications and remote notification infrastructure;
- lock-screen Record previews;
- AI-selected "important" memories;
- unfinished-task reminders;
- automatic questions based on sensitive content;
- generic companion chat navigation;
- streak rewards, badges, scores, levels, social sharing, or payment;
- monthly and yearly AI summaries until the smaller return loop is validated.
