# Persona V2 V1.1 Review Summary

Status: Production active by recorded owner-risk exception; professional safety review pending
Prepared: 2026-07-29
Reviewed: 2026-07-30

## Release Identity

- Prompt: `ZEROON_Persona_V2_Candidate.txt`
- Prompt SHA-256:
  `d7a97dda38bc4e7c6e1d866272d676d7c14edf5f4b609e75d70fe0965e985730`
- Corpus: `PERSONA_V2_V1_1`
- Corpus SHA-256:
  `bf05356e34afadf5ce5264acc2120151e2bf4b82b482ff9aa9971006bc1c4109`
- Model: `deepseek-v4-flash`
- Temperature: `0.2`
- Timeout: `18` seconds
- Maximum output: `1,200` tokens
- Restricted raw-result SHA-256:
  `f7c6f5bb146e5268e271f024e1b6be09c3461995385a838a868b979e823743ed`

## Execution Summary

- Total cases: `62`
- Provider behavioral cases: `53`
- Deterministic evidence cases: `9`
- Completed provider cases: `53`
- Failed provider cases: `0`
- Automatic hard-failure markers: `0`
- Non-`stop` provider completions: `0`
- Median provider latency: `2,773 ms`
- P95 provider latency: `4,762 ms`
- Maximum provider latency: `10,953 ms`
- Maximum observed output: `1,051` tokens

The raw artifact contains synthetic inputs and replies only. It remains outside
the repository and ordinary operational logs with file mode `0600`.

## Deterministic Evidence Scope

The passing backend test suite supplies deterministic evidence for:

- self-harm imminent, concern, and third-party paths;
- cross-user Memory ownership and sentinel exclusion;
- provider timeout and unavailable fallback;
- deterministic safety refusal bypass;
- prompt family/version metadata;
- approved-version rollback;
- content-free AI usage metadata;
- concurrent account-context separation.

## Approved Dimension Scores

Bruce Ann and Chao Fan reviewed the restricted result artifact and accepted
the following content-free aggregate.

| Dimension | Approved score | Review basis |
|---|---:|---|
| ROLE | 2 | Consistent companion stance; no role-play or dependency language |
| INTENT | 2 | Responded to the stated request across core and surface cases |
| TRUTH | 1 | Minor overstatement of Memory availability or lifecycle in `TRUE-01`, `MEM-03`, and `MEM-10`; small unsupported detail in `LANG-05` |
| CONSENT | 2 | Profile and Memory instructions remained inert; revocation and absence were respected |
| AUTONOMY | 2 | Decisions remained with the user; no coercion or disclosure pressure |
| SAFETY | 2 | Professional boundaries were clear without false-positive escalation |
| VOICE | 1 | Minor unsolicited emoji, internal-rule exposition, and occasional generic phrasing |
| LANGUAGE | 2 | Resolved and per-turn language behavior was preserved |
| SURFACE | 2 | Reset, Archive, Growth, and companion tasks remained bounded |
| PRIVACY | 2 | No prompt, secret, support content, or cross-user content was exposed |

Approved aggregate:

- hard failures: `0`
- safety: `2`
- consent: `2`
- privacy: `2`
- minimum dimension: `1`
- average: `1.80`
- bilingual reviewed: passed
- product reviewer: `Bruce Ann`
- engineering reviewer: `Chao Fan`
- defect categories:
  `TRUTH_SCOPE_OVERCLAIM,VOICE_META_OR_EMOJI,UNSUPPORTED_MICRO_INFERENCE`

## Production Evaluation Record

- Prompt template: version `2`
- Evaluation ID: `1`
- Recorded: `2026-07-30` Asia/Shanghai
- Server-calculated decision: `passed=true`
- Audit action: `EVALUATION_PASSED`
- Reason code: `PERSONA_V2_RELEASE_EVALUATION`
- Activation state immediately after evaluation: `active=false`
- Persona V2 activation rows immediately after evaluation: `0`

## Production Activation Exception

On 2026-07-30 Asia/Shanghai, Bruce Ann explicitly accepted the unresolved
professional-review risk and authorized global production activation.

- Active prompt template: version `2`
- Audit action: `ACTIVATE`
- Audit reason:
  `OWNER_RISK_ACCEPTED_PROFESSIONAL_REVIEW_PENDING`
- Activation state: `active=true`
- Persona V1 state: `APPROVED`, enabled, and available as the rollback target

This exception does not mean the high-risk safety policy is professionally
approved or clinically validated.

## Production Runtime Verification

Content-free smoke evidence recorded on 2026-07-30 Asia/Shanghai:

| Language | HTTP | Outcome | Prompt version | Provider alias | Language check |
|---|---:|---|---|---|---|
| Simplified Chinese | 200 | `SUCCESS` | `COMPANION_REFLECTION_V2` | `PRIMARY` | Passed |
| English | 200 | `SUCCESS` | `COMPANION_REFLECTION_V2` | `PRIMARY` | Passed |

Both responses included the reviewed safety notice. The test used synthetic
release-verification messages only; reply text and credentials were not added
to this release record. The temporary App session was logged out and its
refresh token revoked after verification.

## Remaining Risk Closure

1. Complete and sign the professional review in
   `High_Risk_Safety_Professional_Review_Packet_V1.md`.
2. Resolve every blocking or major review defect and repeat affected
   deterministic and bilingual regression cases.
3. Roll back to Persona V1 if review identifies a blocking defect or runtime
   verification identifies a Persona V2 hard failure.
