# ZEROON Beta Validation Brief V1

Status: Accepted validation baseline
Date: 2026-07-14  

Sprint 12 event implementation is governed by
`docs/02_Architecture/ADR_007_Beta_Evidence_Event_Lifecycle_V1.md`. Where this
brief lists a broader future event or property, ADR 007 is authoritative for
the closed-Beta engineering boundary.

## 1. Beta Promise

Recommended promise:

> ZEROON helps you quietly leave the moments you want to keep, then return to
> them over time with a private, controllable reflection companion.

Chinese beta copy:

> 把想留下的此刻交给 ZEROON。它会替你安静保存，并在未来陪你一起回看。

This promise is intentionally not:

- therapy or emotional diagnosis;
- a general-purpose AI chat assistant;
- a daily discipline or streak promise;
- a public diary or social identity;
- a claim that ZEROON understands the user's fixed personality.

## 2. Target Cohort

Primary cohort:

- age 25-45 for the first adult-only operational beta;
- creators, developers, product people, designers, founders, independent
  workers, or reflective knowledge workers;
- already records thoughts irregularly or feels that meaningful daily moments
  are being lost;
- willing to use a private product at least three times in the first week;
- accepts a follow-up interview and beta data notice.

The beta should include, not filter out:

- users who are skeptical of AI memory;
- users who stop after the first record;
- users who disable AI context;
- users who request deletion.

They provide necessary trust evidence.

Exclude from the first operational cohort:

- minors, until minor-protection design and review are complete;
- users recruited with a therapy, diagnosis, crisis-support, romance, or
  dependency promise;
- users whose primary interest is only supplier, licensing, or plush business.

## 3. Activation Definition

An activated user must complete all of the following:

1. authenticate and meet ZEROON;
2. start or confirm a current state;
3. save one valid Zero Record;
4. see the saved record in Archive or record detail;
5. understand whether AI context is enabled.

Chat alone is not activation.

## 4. Core Questions

1. Does the user understand what ZEROON saves?
2. Is one valid record low-pressure enough to complete?
3. Does the user return because a memory is worth revisiting?
4. Does reflection improve continuity without feeling diagnostic or generic?
5. Can the user find and trust disable/delete controls?
6. What value, if any, is strong enough to pay for?

## 5. Event Dictionary

Events must use an internal surrogate user identifier. Do not send record text,
goals, conversation text, profile descriptions, phone numbers, names, model
prompts, or memory summaries as analytics properties.

| Event | Purpose | Allowed properties |
|---|---|---|
| `auth_completed` | Login funnel | new/existing, platform, app version |
| `zeroon_encounter_viewed` | Encounter exposure | entry source, app version |
| `zeroon_encounter_completed` | Companion activation step | duration bucket, retry count |
| `state_started` | Current-state use | state enum, source |
| `reset_started` | Record funnel | entry source, active-state present |
| `record_saved` | Core activation | state enum, has_goal boolean, has_content boolean, latency bucket, retry count |
| `record_save_failed` | Reliability | error class, retryable boolean, network status |
| `archive_viewed` | Continuity behavior | entry source, item-count bucket |
| `record_detail_viewed` | Memory review | age bucket of record, source type |
| `reflection_requested` | Reflective use | surface, context classes enabled |
| `reflection_completed` | AI reliability | outcome success/fallback/refusal, latency bucket, prompt version, model alias |
| `memory_control_changed` | Trust behavior | action enable/disable/delete, source type |
| `profile_ai_context_changed` | Consent behavior | enabled boolean, surface |
| `data_export_requested` | Data-control demand | surface, outcome |
| `account_delete_requested` | Exit and trust | surface, outcome; reason only from fixed optional categories |
| `subscription_offer_viewed` | Pricing exposure | package, price, cohort |
| `subscription_started` | Payment evidence | package, price, billing period, trial boolean |
| `subscription_refunded` | Payment quality | package, days-since-purchase, fixed reason category |

## 6. Cohort Metrics

- Activation rate: activated users / completed authentications.
- D1, D7, and D30 retention by first activation date.
- Week-two valid record rate.
- Weekly Archive/reflection review rate.
- Chat-only user share.
- AI success/fallback/refusal and latency distribution.
- Record-save failure and recovered-retry rate.
- AI-context disabled share and deletion-control use.
- Subscription exposure, purchase, refund, and variable cost.

Do not use total message count, longest session, emotional intensity, or
continuous conversation time as a success metric.

## 7. Interview Plan

Interview at least:

- 4 retained users;
- 3 users who stopped in the first week;
- 2 users who expressed privacy concern or disabled AI context;
- 1 user who requested deletion or export, when available.

Core prompts:

1. Tell us about the last moment you wanted to keep but normally would not.
2. What did you expect ZEROON to remember after saving it?
3. When did ZEROON feel useful, generic, intrusive, or unclear?
4. Did you return to record, to review, or to chat? Why?
5. What would make you stop trusting it?
6. Which capability would you miss enough to pay for?

Do not ask users to disclose sensitive record content during the interview.

## 8. Acceptance Criteria

This brief is ready for recruitment when:

- the beta promise appears consistently in recruitment, onboarding, and the
  first-use experience;
- the app can calculate activation without collecting private text;
- consent, deletion, fallback, and support paths are testable;
- a beta notice explains product stage, AI boundaries, data use, and contact;
- Sprint 11 contact acceptance proves users can reach the real team before
  login and during API outage, and signed-in requests are private, trackable,
  and handled without automatically attaching unrelated private content;
- the first cohort is recruited for product behavior, not plush interest.
