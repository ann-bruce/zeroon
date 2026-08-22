# ZEROON Sprint 14-19 Execution Roadmap V1

Status: Accepted sequence — Sprint 14 closed; Sprint 15 active after bounded intake
Prepared: 2026-08-19
Last updated: 2026-08-22
Owner: ZEROON

## 1. Decision

ZEROON will complete a bounded set of meaningful trust and experience
improvements before production release and App Store launch validation.

This sequence responds to the current acquisition constraint: there are too
few real users for useful retention conclusions. It does not treat more
features as evidence. Scope freezes at release readiness, after which
promotion, acquisition, activation, return behavior, and trust are measured as
separate questions.

## 2. Mainline Fit

The sequence strengthens:

```text
Reliable private capture
  -> user ownership and control
  -> understandable Memory and Growth
  -> trustworthy production release
  -> real-user value evidence
  -> evidence-led iteration
  -> optional physical-companion extension
```

It does not add therapy, diagnosis, scores, streak pressure, generic chat,
social identity, or paid intimacy.

## 3. Ordered Sequence

| Sprint | Theme | Candidate scope | Exit decision |
|---|---|---|---|
| `14` | Record Reliability And Ownership | `ZPB-P0-01` durable Reset drafts; `ZPB-P0-02` delete one owned Record and close linked Memory/cue/export/AI lifecycle | Private capture survives recoverable interruption and the user can remove one Record completely |
| `15` | Growth And Memory Clarity | `ZPB-P0-03` remove performance pressure; `ZPB-P0-04` make Memory source and AI-use controls understandable | A user can explain what ZEROON preserves and Growth does not grade behavior |
| `16` | Privacy And Release Readiness | `ZPB-P1-05` app access/background protection; bounded `ZPB-P1-04` readable export; production, support, AI-safety, privacy, and App Store package acceptance | One production candidate is trustworthy, supportable, reviewable, and ready for explicit release authorization |
| `17` | Production Launch And User Validation | Approved production/App Store release, promotion, acquisition funnel, activation, return, trust, and interview evidence | Record Continue, Reshape, or Stop separately for acquisition, activation, return value, and trust |
| `18` | Evidence-Led Iteration | Select only evidence-backed items from `ZEROON_Product_Backlog_V1.md`; exact scope remains intentionally unset | One measured problem is improved without changing the core promise mid-cohort |
| `19` | Physical ZEROON Entitlement Pilot | Gated small physical-companion and fulfillment experiment | Run only if digital value, supply, budget, privacy, operator, and owner gates pass |

### Canonical Sprint plans

- Sprint 14: `../07_Sprints/Sprint_14_Record_Reliability_And_Ownership_V1.md`
- Sprint 15: `../07_Sprints/Sprint_15_Growth_And_Memory_Clarity_V1.md`
- Sprint 16: `../07_Sprints/Sprint_16_Privacy_And_Release_Readiness_V1.md`
- Sprint 17: `../07_Sprints/Sprint_17_Production_Launch_And_User_Validation_V1.md`
- Sprint 18: `../07_Sprints/Sprint_18_Evidence_Led_Iteration_V1.md`
- Sprint 19: `../07_Sprints/Sprint_19_Physical_ZEROON_Entitlement_Pilot_V1.md`

The roadmap defines sequence and dependencies. These six files are the
canonical Sprint-level scope records; a planned file does not make its Sprint
active or authorize implementation, release, recruitment, or fulfillment.

## 4. Sprint 14 Closure And Boundary

Sprint 14 closed on 2026-08-22 after engineering, automated,
PostgreSQL-backed, and owner-confirmed real iOS acceptance. It delivered
`ZPB-P0-01` and `ZPB-P0-02`; its accepted intake boundary defined:

- account-scoped local draft behavior across logout, restart, locale change,
  shared devices, and backup;
- idempotent save and duplicate prevention;
- owner-only Record deletion;
- linked Memory deletion or lifecycle behavior;
- removal from cue selection, Archive, Growth, export, and AI context;
- migration, OpenAPI, mobile, evidence, and test surfaces;
- failure, retry, cross-user, and recovery acceptance.

Sprint 14 excluded Archive search, new reflection, templates, media,
notification, payment, physical delivery, and public release.

## 5. Sprint 16 Release Boundary

Sprint 16 freezes product expansion and prepares one production candidate. At
minimum it must reverify:

- real production email authentication and one-time behavior;
- account deletion and portable export;
- Memory/Profile consent and immediate revoke behavior;
- AI success, fallback, refusal, timeout, safety, and rollback;
- support reachability and operator access;
- privacy policy, terms, AI disclosure, age boundary, and store data answers;
- app access protection and background privacy;
- iOS device regression, production observability, rollback, and support owner;
- App Store name, subtitle, screenshots, description, and claims without
  therapy or guaranteed-outcome language.

Release, App Store submission, prompt activation, and production changes still
require explicit owner authorization.

## 6. Sprint 17 Evidence Model

App Store availability is distribution, not proof of value. Sprint 17 keeps
four evidence layers separate:

### Acquisition

- product-page impressions and views;
- downloads;
- download-to-authentication conversion;
- channel and message learning without private-content tracking.

### Activation

- authentication and encounter completion;
- state selection;
- first valid Record;
- Archive or Record Detail review;
- understanding of Memory and AI-context control.

### Return value

- D1 and D7 for mature cohorts;
- week-two valid Record behavior when mature;
- Archive, Record Detail, Memory, and continuity-cue review;
- user-described reasons for returning or stopping.

### Trust

- ability to find and use Memory, delete, export, support, and app protection;
- privacy concern, consent confusion, deletion demand, and complaint themes;
- no private Record content in research notes or analytics.

The first approximately 20 adults establish production and activation
stability. Expansion toward 50-100 occurs only after blocking failures are
contained. Very small or immature cohorts produce directional observations,
not retention claims.

## 7. Sprint 18 Selection Rule

Sprint 18 has no preselected feature. Select the smallest Backlog item that
addresses the strongest Sprint 17 evidence:

| Evidence | Candidate response |
|---|---|
| Low product-page conversion | Store promise, screenshots, positioning, or audience—not private product behavior |
| Downloads but weak activation | First loop, reliability, or product explanation |
| Activation but weak return | Archive retrieval, user-owned review markers, or bounded resurfacing |
| Return without reflective value | Source-linked bounded reflection |
| Trust confusion | Memory correction, export, access protection, or clearer controls |
| Credible return but weak payment | Later pricing/package experiment without paid intimacy |

Do not change positioning, Persona, onboarding, notification, and core loop at
the same time during a measured cohort.

## 8. Physical ZEROON Parallel Preparation

During Sprints 14-18, only reversible non-production preparation may proceed:

- one physical sample;
- 3-5 supplier quotations;
- material, packaging, quality, and safety review;
- quantity, budget, region, replacement, and accountable operator decisions;
- minimal delivery-data, encryption, retention, deletion, and access policy.

No entitlement implementation, address collection, participant promise,
fulfillment, sale, crowdfunding, or smart-device claim is authorized before
Sprint 19 entry gates pass.

## 9. Backlog Relationship

- `ZEROON_Product_Backlog_V1.md` remains the independent candidate inventory.
- Sprint numbers are execution packages, not Backlog identities.
- An item leaves Backlog only after its Sprint evidence is recorded.
- P2 items remain unnumbered until their prerequisite evidence exists.
- Sprint 19 retains a separate detailed candidate plan because it includes
  supply, delivery, operator, and privacy work beyond a normal app feature.

## 10. Promotion Checklist

Before each Sprint becomes active:

1. confirm the user problem and current evidence;
2. accept mainline fit, drift risk, and explicit non-goals;
3. enumerate backend, OpenAPI, mobile, admin, database, AI, evidence, docs,
   tests, and service surfaces;
4. define ownership, consent, deletion, export, failure, retry, and isolation;
5. define continue, reshape, and stop criteria;
6. preserve separate authority for production, App Store, cohort, prompt,
   notification, payment, fulfillment, and external communication actions.
