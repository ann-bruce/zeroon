# ZEROON Durable Decision Index

Last reviewed: 2026-08-18

This file indexes accepted decisions that a new project chat must not
re-litigate without new evidence. Detailed rationale and acceptance criteria
remain in the linked source. Add a new entry when a durable decision is made;
do not paste chat transcripts here.

| ID | Durable decision | Canonical source | Status |
|---|---|---|---|
| D-001 | ZEROON remains a long-term companion and private memory system, not a narrow emotional tool, diary, therapy product, task manager, public social product, or generic AI chat. | `docs/07_Sprints/Roadmap_Information_Architecture_V2.md` | Active |
| D-002 | Mobile uses Flutter and the backend remains a Spring Boot modular monolith unless a separately accepted architecture decision supersedes them. | `docs/02_Architecture/ADR_001_Mobile_Flutter.md`; `docs/02_Architecture/ADR_002_Modular_Monolith.md` | Active |
| D-003 | Closed-Beta authentication uses production email verification; App users and administrator identities have separate authorization paths. | `docs/02_Architecture/ADR_003_Authentication.md`; `docs/05_Engineering/Development_Guide_V1.md` | Active |
| D-004 | Long-term Memory is user-owned, source-linked, visible, disableable, deletable, and excluded from AI context by default until explicitly permitted. | `docs/02_Architecture/ADR_004_Memory_V1.md` | Active |
| D-005 | Interaction language supports Follow System, Simplified Chinese, and English without translating or inferring from user-authored content. | `docs/02_Architecture/ADR_005_Language_Locale_V1.md` | Active |
| D-006 | Help and feedback use a private, trackable, human-operated support lifecycle with an honest email fallback and no continuous-coverage claim. | `docs/02_Architecture/ADR_006_Support_Request_Lifecycle_V1.md` | Active |
| D-007 | Closed-Beta evidence is explicit-consent, content-free, aggregate-only for administrators, and must never block core product actions. | `docs/02_Architecture/ADR_007_Beta_Evidence_Event_Lifecycle_V1.md` | Active |
| D-008 | Persona V2 is production-active through a recorded owner-risk exception; professional safety review is still required and rollback remains available. | `docs/06_AI/evaluation/Persona_V2_V1_1_Review_Summary.md` | Active with open gate |
| D-009 | Sprint 13 established an owner-validated, in-app, user-owned continuity cue; broader return value and any notification mechanism still require separate evidence and explicit approval. | `docs/07_Sprints/Sprint_13_Return_Loop_Validation_V1.md` | Implemented; cohort gate deferred |

## Change Rules

- Use a new ID when a new durable product, architecture, privacy, AI, release,
  or operating decision is accepted.
- Mark an old row `Superseded by D-xxx` instead of silently rewriting history.
- Keep implementation progress in the active Sprint, not in this index.
- Never record passwords, tokens, verification codes, private user content, or
  unreviewed production data.
