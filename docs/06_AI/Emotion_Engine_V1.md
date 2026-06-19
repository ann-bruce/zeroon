# Emotion Engine V1

## Purpose

Emotion Engine is the core state processing system of ZEROON.

Responsibilities:

- State Detection
- State Transition
- Emotion Mapping
- Companion Context
- Emotion Light Mapping

---

## State Model

Supported States:

CALM
FOCUS
CREATE
TIRED
OVERLOAD
CONFUSED

---

## State Sources

Priority:

1. User Manual Selection
2. Zero Record Analysis
3. Conversation Analysis
4. Historical Pattern Analysis

MVP:

Use Manual Selection First.

---

## State Transition

Example:

CALM
 -> FOCUS
 -> CREATE
 -> TIRED
 -> CALM

All transitions are stored.

---

## State History

Each state change creates:

state_history

Fields:

- user_id
- previous_state
- current_state
- source
- created_at

---

## Emotion Score

Range:

0 ~ 100

Dimensions:

Energy
Focus
Creativity
Stress

Example:

Energy: 80
Focus: 90
Creativity: 65
Stress: 30

---

## Companion Context

Emotion Engine provides context to AI.

Example:

Current State:
FOCUS

Recent Trend:
Improving

Stress:
Low

The AI should respond based on this context.

---

## Emotion Light Mapping

CALM
 -> White

FOCUS
 -> Cyan

CREATE
 -> Gold

TIRED
 -> Soft Gray

OVERLOAD
 -> Red

CONFUSED
 -> Deep Blue

---

## Monthly Analysis

Generate:

- State Distribution
- Emotion Trend
- Growth Summary

Output:

Monthly Reflection

---

## Future Roadmap

V1:
Manual State

V2:
AI State Analysis

V3:
Emotion Light Feedback

V4:
Hardware Sensor Feedback

---

## Success Criteria

The Emotion Engine can:

- Track states
- Record transitions
- Drive AI context
- Drive emotion light
- Generate trend reports
