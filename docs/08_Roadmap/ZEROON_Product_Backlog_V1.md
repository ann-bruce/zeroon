# ZEROON Product Optimization And Feature Backlog V1

Status: Proposed Backlog — no implementation Sprint assigned
Prepared: 2026-08-18
Owner: ZEROON

## 1. Purpose

This document converts ZEROON product review and competitor learning into one
independent, ordered candidate Backlog. It does not approve a new Sprint,
authorize production changes, or imply that every item should be built.

The next item must be selected by the owner and promoted into a separately
scoped Sprint with affected surfaces, acceptance evidence, and release gates.

## 2. Product Decision

### Mainline fit

The Backlog strengthens **user-controlled reflective continuity**:

```text
Leave one low-pressure moment
  -> preserve it reliably
  -> understand what ZEROON remembers
  -> find or revisit it across time
  -> receive a bounded, source-linked reflection
```

### Drift risks

Do not use this Backlog to turn ZEROON into:

- a scored emotion diary;
- a streak or habit-performance product;
- a task manager built from extracted goals;
- a therapy, diagnosis, or personality-classification product;
- a generic AI chat or paid-intimacy product;
- a public identity, social feed, or engagement-notification system.

### Recommended capability abstraction

Competitor-specific mechanisms are retained only at the capability level:

- Mubble's lightweight recording and time resurfacing become low-pressure
  capture and user-owned review, without mood scores or performance charts;
- Rosebud's cross-entry synthesis becomes source-linked, user-requested
  reflection, without diagnosis or fixed personality claims;
- Kin's visible memory becomes explainable, editable user-owned Memory,
  without hidden automatic profiling or streak pressure;
- Day One and Apple Journal's privacy model becomes stronger local protection,
  understandable export, and explicit user control over what leaves the device;
- Replika and Nomi's continuity informs consistent presence, not romance,
  proactive dependency, roleplay, or paid closeness.

## 3. Priority Rules

| Priority | Meaning | Entry rule |
|---|---|---|
| `P0` | Trust, ownership, and core-loop reliability | May be selected next after a bounded technical and experience review |
| `P1` | Findability, reflection, and user control after records accumulate | Select after its data and interaction boundary is accepted |
| `P2` | Evidence-dependent expansion | Do not schedule until the named prerequisite produces evidence |
| `Deferred` | Valuable but intentionally unscheduled | Requires a new explicit owner decision |
| `Rejected` | Product drift | Do not promote without a new durable decision and new evidence |

Priority does not override dependencies. A smaller `P1` item may be selected
before a larger `P0` item when the owner accepts the tradeoff and the selected
Sprint remains coherent.

### Accepted execution mapping

The current execution sequence is maintained separately in
`Sprint_14_19_Execution_Roadmap_V1.md`:

- Sprint 14 selects `ZPB-P0-01` and `ZPB-P0-02`;
- Sprint 15 selects `ZPB-P0-03` and `ZPB-P0-04`;
- Sprint 16 selects the release-bound portion of `ZPB-P1-04` and
  `ZPB-P1-05` together with production/App Store readiness;
- Sprint 17 validates acquisition, activation, return, and trust after an
  explicitly authorized release;
- Sprint 18 remains evidence-led rather than preselecting another feature;
- Sprint 19 is the separately gated physical ZEROON pilot.

Backlog identity remains `ZPB-*`; Sprint placement does not rename the item or
authorize implementation by itself.

The canonical Sprint 14-19 scope files are stored in `../07_Sprints/`; the
execution roadmap is an index and sequencing decision, not a substitute for
those Sprint records.

## 4. P0 — Trust And Core-Loop Reliability

| ID | Type | Backlog item | Main surfaces | Done when |
|---|---|---|---|---|
| `ZPB-P0-01` | Optimize | Durable Reset draft protection | mobile, local storage, tests, privacy copy | Unsaved moment and optional direction survive route exit, locale change, app restart, and recoverable save failure; success clears the correct draft; retry cannot create a duplicate Record; draft text never enters evidence or logs |
| `ZPB-P0-02` | New | Delete one owned Record | backend, database, OpenAPI, mobile, Memory, cue selection, export, tests | The owner can confirm deletion; cross-user access is impossible; linked Memory and continuity eligibility follow an explicit lifecycle; Archive, Growth, export, and AI context stop exposing the deleted content; retry is safe |
| `ZPB-P0-03` | Optimize | Reshape Growth away from performance | backend review, mobile, localization, tests, product copy | Continuous-day prominence and fixed-state implications are removed or subordinated; broken rhythm has no negative state; preserved moments and elapsed companionship are visible without score, rank, diagnosis, or personality claims |
| `ZPB-P0-04` | Optimize | Make Memory understandable and discoverable | Archive, Record Detail, Memory, Profile/Settings, localization, tests | A user can find Memory within two intentional actions, distinguish preservation from AI-use permission, see each source, and verify that pause/delete/revoke affects the next response immediately |

### P0 planning notes

- `ZPB-P0-01` must define whether drafts are account-scoped on shared devices,
  how logout handles them, and whether device backup includes them.
- `ZPB-P0-02` must decide linked-Memory behavior before implementation. Silent
  orphaning, hidden soft deletion, and continued AI use are unacceptable.
- `ZPB-P0-03` may retain truthful neutral counts, but no number may become a
  success grade or broken-streak warning.
- `ZPB-P0-04` should improve language and placement before adding new Memory
  automation.

## 5. P1 — Retrieval, Control, And Bounded Reflection

| ID | Type | Backlog item | Main surfaces | Done when |
|---|---|---|---|---|
| `ZPB-P1-01` | New | Archive search and composable filters | backend query/OpenAPI or bounded local search, mobile, tests | The owner can search original text and filter by date, user-selected state, content shape, Memory presence, or reflection presence; cross-user isolation holds; search terms never enter analytics, logs, or profile inference |
| `ZPB-P1-02` | New | User-owned review marker | backend, database, OpenAPI, Archive/Detail, cue selection, export | A user can mark a Record to keep, revisit, or exclude from resurfacing; the marker is private, reversible, exported, deleted with the Record, and never treated as an AI importance score |
| `ZPB-P1-03` | New | Source-linked bounded reflection | companion, Memory, OpenAPI, Archive/Growth, prompt governance, tests | The user explicitly selects a period or records; every observation exposes its sources; uncertain language is used; the user can reject an observation; no personality label, diagnosis, score, or silent Memory creation occurs |
| `ZPB-P1-04` | Optimize | Human-readable data export | backend, export contract, mobile, documentation, tests | Users can download a portable machine-readable copy and a readable format; scope and included content are previewed; original text is preserved; export failure is recoverable; basic data control remains free |
| `ZPB-P1-05` | New | Private app access protection | mobile, platform integration, privacy UX, tests | Optional system authentication protects app entry; background previews hide private text; recovery and disable behavior are clear; notifications and widgets reveal no private content by default |
| `ZPB-P1-06` | New | Correct or explicitly create Memory | backend, database, OpenAPI, mobile, context assembler, export, tests | The owner can correct an inaccurate Memory or deliberately create one from an owned source; provenance remains visible; changes are immediately reflected in AI context; no hidden personality store is created |
| `ZPB-P1-07` | Evaluate | Record correction without rewriting history | product contract, backend, database, OpenAPI, mobile, Memory, tests | Product review decides between correction note, versioned edit, or no edit; old AI replies are not silently redefined; source provenance and export history remain understandable |

## 6. P2 — Evidence-Dependent Expansion

| ID | Type | Backlog item | Prerequisite | Decision gate |
|---|---|---|---|---|
| `ZPB-P2-01` | Experiment | `那年今日` or user-invoked random review | Existing in-app continuity and retrieval behaviors demonstrate user value | Test one resurfacing variant at a time; user can exclude an item; no AI importance ranking or private lock-screen text |
| `ZPB-P2-02` | New | General Record templates | Core capture remains low pressure after P0 validation | Templates stay optional and abstract, such as a moment, an idea, something not to forget, or words for the future; no confession, therapy, couple, or task-specific product mode |
| `ZPB-P2-03` | New | Voice capture, then optional image attachment | Draft lifecycle, storage, export, deletion, and AI-consent boundaries accepted | User confirms transcription before save; media upload and AI use are separately understandable; deletion and export cover originals; private previews remain protected |
| `ZPB-P2-04` | Experiment | User-controlled return invitation | The in-app return experience demonstrates user value and the owner approves a separate scope | Opt-in frequency control, easy disable, no private notification text, no absence pressure, and no implication that ZEROON is disappointed |
| `ZPB-P2-05` | Experiment | Paid continuity and control | Trust gates pass and an active cohort demonstrates return value | Test real prices for sync, capacity, export, recovery, or bounded reflection; basic deletion/export remain available; no affection, intimacy, or relationship status is sold |

## 7. Rejected Or Reshape-Required Ideas

Do not promote the following mechanisms as currently framed:

- mood scores, emotional rankings, improvement grades, or diagnostic curves;
- streak rewards, shame for absence, badges, levels, or pressure reminders;
- AI-selected "important" memories without user confirmation;
- fixed personality, attachment, mental-health, or risk labels;
- romance roles, multiple partners, paid intimacy, or affection tiers;
- generic AI chat as the primary product loop;
- automatic task extraction or unfinished-work reminders;
- social feed, public profile, likes, comments, or public Record sharing;
- private Record text in notifications, widgets, analytics, logs, or admin;
- automatic weekly/monthly AI summaries before a smaller source-linked
  reflection demonstrates value.

The useful abstraction behind a rejected idea may be proposed again. For
example, a mood chart may become a user-controlled time view of preserved
moments, and a proactive reminder may become an opt-in invitation only after
the in-app return experience proves valuable.

## 8. Promotion Checklist

Before any item becomes a Sprint, its intake must record:

1. Mainline fit and the user problem supported by evidence.
2. Drift and privacy risks, including what the item explicitly will not do.
3. Affected surfaces: backend, OpenAPI, mobile, admin, database, AI prompts,
   evidence, docs, tests, and local/runtime services.
4. Ownership, deletion, export, consent, failure, retry, and cross-user rules.
5. Content-free success evidence and qualitative interview questions.
6. Continue, reshape, and stop criteria.
7. Release authority, with production, cohort, prompt, notification, payment,
   and external communication remaining separately controlled.

## 9. Recommended Selection Order

Recommended default order, subject to owner selection:

```text
Sprint 14: ZPB-P0-01 Durable Reset drafts + ZPB-P0-02 Record deletion
  -> Sprint 15: ZPB-P0-03 Growth reshape + ZPB-P0-04 Memory discoverability
  -> Sprint 16: release-bound ZPB-P1-04 Export + ZPB-P1-05 App protection
  -> Sprint 17: production/App Store launch and user validation
  -> Sprint 18: choose one evidence-backed Backlog item
  -> Sprint 19: gated physical ZEROON pilot
```

This order closes trust and ownership gaps, freezes expansion for a production
release, and resumes feature selection only after real acquisition, activation,
return, and trust evidence exists.
