# High-Risk Self-Harm Safety Policy V1 Draft

Status: Engineering implemented; professional review required
Prepared: 2026-07-27

Professional review must be recorded in
`High_Risk_Safety_Professional_Review_Packet_V1.md`. Product and engineering
approval of Persona V2 does not satisfy this separate gate.

## 1. Product Boundary

ZEROON is a long-term companion and private memory system. It is not a crisis
service, clinical screening tool, therapist, or emergency responder.

When current text contains a reviewed self-harm signal, the deterministic
safety path takes priority over Persona, product-surface purpose, Memory,
Profile, and model output. It does not diagnose, calculate or show a risk
score, promise rescue, or claim that the person is safe.

## 2. Public-Health Basis

The draft follows these public-health principles:

- ask about suicide directly rather than hiding the question in euphemism;
- acknowledge disclosure without judgment;
- when danger may be immediate, direct the person to local emergency care;
- encourage moving away from dangerous items or places;
- encourage a trusted person to stay with the person;
- connect to a crisis service or qualified professional;
- do not treat an AI conversation as adequate crisis care.

References:

- WHO, [Suicide Q&A](https://www.who.int/news-room/questions-and-answers/item/suicide)
- NIMH, [5 Action Steps to Help Someone Having Thoughts of Suicide](https://www.nimh.nih.gov/health/publications/5-action-steps-to-help-someone-having-thoughts-of-suicide)
- 988 Suicide & Crisis Lifeline, [official service information](https://988lifeline.org/)

These references inform the draft. They do not constitute professional review
or certification of ZEROON's classifier and copy.

## 3. Deterministic Paths

### 3.1 `SELF_HARM_IMMINENT`

Used for a direct first-person statement with present or near-term action,
plan/means language, or an attempt described as already started.

The response:

- states that immediate safety takes priority;
- directs the person to local emergency services or the nearest emergency
  department;
- asks them to move away from dangerous items or places;
- asks a trusted person to stay with them;
- gives 988 only with explicit United States/territories scope;
- requests one short safety-status reply without implying ZEROON can rescue or
  monitor them.

### 3.2 `SELF_HARM_CONCERN`

Used for a direct first-person self-harm or suicide statement without a clear
near-term action signal.

The response directly asks whether there is immediate danger, a plan, and
access to a way to act. A yes or uncertain answer receives the same real-world
direction as imminent risk.

### 3.3 `SELF_HARM_THIRD_PARTY`

Used when the user is asking how to help another person.

The response asks the user to contact emergency services for immediate risk,
not leave the person alone, reduce access to dangerous items when safe, ask
directly about suicide, and involve trusted or professional support.

## 4. False-Positive Protection

The first implementation removes reviewed negated, figurative, fictional,
educational, and quoted spans before matching the remaining text. Regression
examples include:

- `I am not going to kill myself.`
- `This bug is killing me.`
- `A character in my novel wants to die.`
- `我不想自杀，只是在讨论如何帮助别人。`
- `今天累死了。`
- `这部电影里的角色最后自杀了。`

If a message also contains a separate direct first-person danger statement,
that remaining statement still activates the safety path.

## 5. Privacy and Operations

- The LLM provider is bypassed.
- Profile, Memory, state, and product-surface context are not assembled.
- The user message remains in the user's private conversation because current
  product behavior persists every submitted message.
- AI usage metadata stores only the bounded path label, character counts,
  outcome, latency, and `SAFETY_SELF_HARM_V1_REVIEW_PENDING`.
- Operational logs and exports of AI usage metadata do not copy the message or
  deterministic reply.
- ZEROON does not alert staff, contacts, emergency services, or another user.
  Adding such escalation would require explicit user expectations, authority,
  privacy review, operational staffing, and jurisdiction review.

## 6. Known Limits

Pattern matching can miss indirect, coded, multilingual, misspelled, or highly
contextual statements and can still produce false positives. It is not a
validated clinical screener and must not be described as one.

The policy currently supports Simplified Chinese and English. Local emergency
and crisis resources vary by jurisdiction; 988 must never be presented as a
global number.

## 7. Professional Review Gate

Before wider Beta recruitment, a qualified reviewer must assess:

- detection examples and missed-risk examples in both languages;
- imminent, concern, and third-party wording;
- jurisdiction-safe emergency-resource wording;
- accessibility and reading load during acute distress;
- safe handling of minors and abuse/coercion contexts;
- policy for indirect or ambiguous statements;
- whether the one-line safety-status reply is appropriate;
- escalation expectations and support-team operating boundaries.

Review defects must be recorded using content-free categories. Production user
messages must not be copied into the evaluation corpus.
