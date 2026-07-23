# ZEROON 90-Day Product Validation Plan V1

Status: Active  
Start date: 2026-07-14  
Target review date: 2026-10-12  
Owner: ZEROON  

## 1. Objective

Use the next 90 days to determine whether ZEROON can become a sustainable
long-term companion and private memory product.

The plan is not complete when more features exist. It is complete when ZEROON
has credible evidence that users:

1. are willing to leave meaningful private moments;
2. return to review and reflect on those moments over time;
3. trust ZEROON's memory and AI boundaries;
4. show real willingness to pay for continuity, control, and reflection.

## 2. Product Decision

### Mainline fit

ZEROON will remain a long-term companion and private memory system that helps
users understand themselves over time.

The primary loop is:

```text
Notice the present
  -> leave a low-pressure record
  -> preserve a user-owned memory
  -> receive a bounded reflection
  -> return across time
```

### Drift risks

During these 90 days, do not optimize ZEROON into:

- a generic AI chat app;
- an emotion diary or diagnosis system;
- a streak-driven habit tracker;
- a pet game, romance product, or social identity system;
- a crowdfunding promise that combines unfinished software, hardware, and
  supply-chain delivery.

### Capability abstraction

The core capability is **user-controlled reflective continuity**:

- the user decides what is saved;
- every derived memory has a visible source;
- saved context can be viewed, deleted, disabled, or excluded from AI use;
- AI helps the user reflect without assigning a fixed label;
- ZEROON's presence connects records across time without creating dependency.

### Roadmap decision

- Accept and strengthen: low-pressure record, private archive, controllable
  memory, contextual reflection, calm companion presence.
- Reshape: Growth should express preserved time and change, not performance.
- Defer: semantic RAG, public sharing, smart hardware, marketplace, user-owned
  API keys, and large crowdfunding commitments.
- Reject for this validation period: rankings, levels, paid intimacy, social
  feed, diagnosis, and engagement mechanics based on emotional dependency.

## 3. Success Gates

Metrics are decision gates, not promises. They must be calculated from real
cohorts and paired with qualitative evidence.

### Gate A: usable and trustworthy beta

- Core record flow completion rate: at least 70%.
- A saved record is never silently lost after a recoverable network failure.
- Memory and AI context permissions have explicit on/off behavior covered by
  tests.
- Users can view and delete saved long-term memory entries.
- Production-facing admin, secret, authentication, and data-control blockers
  have an owner and release decision.
- Safety, fallback, and provider-success paths are repeatably verifiable.

### Gate B: users return for continuity

Target cohort: 50-100 invited users.

- D1 retention: at least 35%.
- D7 retention: at least 18%; 20% or higher is the preferred signal.
- D30 retention: at least 8%; 10% or higher is the preferred signal.
- At least 30% of activated users create a valid record in week two.
- At least 25% of weekly active users review Archive, record detail, or a
  source-linked reflection; chat-only activity does not satisfy this gate.
- At least 10 completed interviews explain why users returned or stopped.

### Gate C: users show willingness to pay

- Test a real price with active users instead of asking only hypothetical
  willingness questions.
- Obtain the first 20 real payments or equivalent refundable paid commitments.
- Paid value is continuity, reflection, export, sync, or memory capacity; it is
  never emotional closeness or affection.
- Estimated AI and storage variable cost stays below 15% of net subscription
  revenue at the tested usage level.
- Refund, deletion, complaint, and support paths are operational before wider
  paid acquisition.

### Decision at day 90

| Evidence | Decision |
|---|---|
| Gates A, B, and C show credible signals | Continue toward public release and a larger paid cohort |
| Gate A passes, retention is weak | Reshape the core loop before adding features or hardware |
| Retention passes, payment is weak | Rework packaging and price without weakening privacy or emotional boundaries |
| Trust or safety gate fails | Stop expansion and fix the trust foundation |
| Plush interest is strong but app evidence is weak | Treat plush as a separate limited IP experiment, not proof of the app |

## 4. Workstreams

### Product and research

- Freeze the beta promise and target user definition.
- Create interview screening, consent, interview guide, and synthesis template.
- Define activation, retention, archive review, AI outcome, deletion, and paid
  conversion events.
- Maintain an evidence log that separates observed behavior from interpretation.

### Backend, database, and OpenAPI

- Close admin authorization and production secret blockers.
- Complete profile-to-AI consent behavior.
- Define and implement Memory V1 with source, ownership, visibility, deletion,
  AI-use permission, and lifecycle fields.
- Move external model calls out of long database transactions.
- Add bounded provider timeout, fallback, usage outcome, and cost metadata.
- Align implemented endpoints with OpenAPI and database migrations.

### Mobile experience

- Complete and accept the My ZEROON encounter flow without pet-game mechanics.
- Keep Reset recoverable when the network fails.
- Make AI loading, fallback, refusal, and retry states understandable.
- Make memory sources and delete/disable controls visible.
- Review Growth navigation and reduce streak pressure.
- Establish a complete Simplified Chinese/English locale foundation before a
  bilingual beta cohort; language choice must not translate private history or
  create mixed-language AI safety states.

### Admin and operations

- Establish administrator authorization and audit boundaries.
- Provide safe prompt/version inspection and AI outcome monitoring without
  exposing private record or conversation text.
- Add release checks for provider success, fallback, refusal, latency, and cost.
- Establish backup, restore, complaint, data export, and deletion procedures.

### Compliance and safety

Before a public China release, obtain professional review against applicable
personal-information, generative-AI, and anthropomorphic-interaction rules.
The implementation backlog must cover at least:

- clear disclosure that the user is interacting with AI;
- age and minor-protection decisions;
- overuse and dependency-risk reminders;
- extreme-risk response and escalation policy;
- convenient service exit and interaction-data copy/delete;
- separate consent for any sensitive interaction data used in training;
- launch safety assessment, algorithm filing, complaint, and incident process.

This plan is an engineering and product checklist, not legal advice.

### Commercial and IP

- Test subscription packaging only after a trustworthy beta exists.
- Keep the free layer useful; do not paywall basic data control.
- Obtain 3-5 plush sample quotations and one physical sample only as a separate
  demand experiment.
- Do not promise smart-device integration or mass delivery during this period.
- Keep advertising, social feed, paid affection, and large licensing deals out
  of scope.

## 5. Ninety-Day Sequence

### Phase 0: baseline and scope freeze (2026-07-14 to 2026-07-20)

Exit criteria:

- Current worktree changes are inventoried and preserved.
- Sprint 06 implementation is verified or its gaps are explicitly recorded.
- Product promise, target cohort, success gates, and event definitions are
  approved.
- The first implementation sprint has an ordered, testable backlog.

### Phase 1: trust foundation (2026-07-21 to 2026-08-10)

Priority:

1. Admin authorization.
2. Production configuration fail-fast.
3. OTP abuse boundary and environment separation.
4. Profile AI consent closure.
5. Data delete/export scope and OpenAPI alignment.
6. My ZEROON acceptance and recoverable entry behavior.

Exit criteria:

- Release-blocking security findings are closed or explicitly prevent release.
- Cross-surface tests and local validation pass.
- No control is presented to the user without corresponding behavior.

### Phase 2: controllable memory and real AI (2026-08-11 to 2026-08-31)

Priority:

1. Memory V1 ADR and data model.
2. Record-to-memory production path.
3. View, delete, disable, and AI-use controls.
4. Context assembler with explicit consent rules.
5. Real-provider success/fallback/refusal validation.
6. AI latency, outcome, version, and cost observation without private-content logs.

Exit criteria:

- A user can explain what ZEROON remembers and can remove it.
- AI can use allowed context, cannot use disabled context, and cites the source
  class of a reflection.
- Provider failure never blocks recording or archive access.

### Phase 3: closed beta (2026-09-01 to 2026-09-21)

Priority:

1. Complete Sprint 10 language and locale acceptance before inviting any
   English-language participants.
2. Complete Sprint 11 help, contact, feedback, complaint, and operator-response
   acceptance before inviting the first cohort.
3. Invite the first 20 users, observe activation, and fix blocking defects.
4. Expand toward 50-100 users only after the first cohort is stable.
5. Conduct interviews across retained, inactive, and privacy-concerned users.
6. Review metrics weekly without changing the core promise mid-cohort.

Exit criteria:

- Gate A passes.
- D1/D7 and week-two behavior are measurable.
- Top reasons for return, abandonment, and distrust are evidence-backed.

### Phase 4: payment and product decision (2026-09-22 to 2026-10-12)

Priority:

1. Test two simple subscription packages with a real price.
2. Measure payment, refund, usage, and variable AI cost.
3. Review one non-smart plush sample or quotations separately from app metrics.
4. Produce the day-90 continue, reshape, or stop decision.

Exit criteria:

- Gate B and Gate C have measured results.
- The next roadmap is based on cohort evidence rather than feature enthusiasm.
- No hardware, crowdfunding, or public-release commitment is made without its
  own readiness review.

## 6. Immediate Execution Backlog

### Validation Sprint 00

| ID | Task | Surfaces | Done when |
|---|---|---|---|
| V00-01 | Inventory current Sprint 06 worktree | backend, migration, OpenAPI, mobile, tests, docs | Implemented and missing items are recorded without reverting user work |
| V00-02 | Run current quality and service baseline | backend, mobile, admin, OpenAPI, local services | Commands, results, and stale-service state are recorded |
| V00-03 | Accept or correct My ZEROON | backend, OpenAPI, mobile, tests, UX | Sprint 06 acceptance criteria have evidence |
| V00-04 | Freeze beta promise and cohort | PRD, research, metrics | One promise, one target cohort, and recruitment criteria exist |
| V00-05 | Define event dictionary | backend/mobile analytics, privacy | Required events have purpose, properties, and prohibited private fields |
| V00-06 | Create release-blocker matrix | security, AI, data, compliance, operations | Every blocker has severity, owner, verification, and release consequence |
| V00-07 | Prepare Sprint 08 trust-foundation plan | all affected surfaces | Ordered implementation tasks and acceptance criteria are ready |

### Sprint 10 Language and Locale Foundation

The accepted plan is
`docs/07_Sprints/Sprint_10_Language_Locale_Foundation_V1.md`. It occupies
Sprint 10; previously discussed but undocumented Sprint 10 scope moves to
Sprint 12. Language work is complete only when mobile UI, companion behavior,
fallback, refusal, and safety paths are coherent while original private content
remains untranslated.

### Sprint 11 Help, Contact, and Feedback Foundation

The accepted plan is
`docs/07_Sprints/Sprint_11_Help_Contact_Feedback_Foundation_V1.md`. It is a
separate closed-beta gate after language foundation. Users must be able to find
a real-team contact path before login and during API outage; signed-in users
must receive a private, trackable request and real operator response without
automatically attaching unrelated private content.

Sprint 11 completed on 2026-07-23 with automated retention, privacy and abuse
boundaries, bilingual outage fallback, operator audit, zero companion-context
coupling, full quality gates, and real PostgreSQL end-to-end acceptance.

### Sprint 12 Closed Beta Evidence and Recruitment Readiness

The accepted plan is
`docs/07_Sprints/Sprint_12_Closed_Beta_Evidence_Readiness_V1.md`. S12-01
completed on 2026-07-23 with a first-party typed event boundary, explicit and
revocable collection, 180-day maximum, account-deletion hard deletion,
aggregate-only reporting, and small-cell suppression at five participants.
The first cohort remains capped at 20 invited adults. `chao.fan` is the named
backup support operator; mailbox and ADMIN access testing remains a blocker
before the first invitation.

S12-02 completed on 2026-07-23 with PostgreSQL V14, a default-off
notice-bound collection choice, typed first-party event persistence, export
V4, account-deletion cascade, 180-day retention, all-event contract and
rate-limit coverage, and real PostgreSQL runtime acceptance. S12-03 completed
on 2026-07-23 with content-free mobile instrumentation across the approved
core loop, a bounded seven-day/50-item retry queue, truthful
new/existing-account and companion execution metadata, and best-effort failure
isolation. Support content remains outside analytics because no support event
was approved. Full backend/mobile tests and OpenAPI lint pass. S12-04 cohort
and retention computation is next.

## 7. Operating Rhythm

### Weekly

- Monday: choose one user or trust outcome, not a feature count.
- During the week: implement, test, and keep the local app current.
- Friday: review evidence, regressions, service status, and next decision.

### Decision record

Every material product decision should record:

1. mainline fit;
2. drift risk;
3. abstract capability;
4. roadmap decision;
5. acceptance criteria.

### Change discipline

- Preserve existing user work and keep edits scoped.
- Update backend, migration, OpenAPI, mobile, admin, docs, and tests together
  when a behavior crosses surfaces.
- Do not commit or push without explicit instruction.
- Do not claim completion without validation evidence.

## 8. Day-90 Deliverables

- Product and cohort evidence report.
- Retention and archive/reflection behavior report.
- Paid experiment and unit-economics report.
- Safety, privacy, compliance, and release-readiness matrix.
- Memory V1 and real-AI technical acceptance evidence.
- Decision: continue, reshape, separate the IP experiment, or stop expansion.
