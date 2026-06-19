# Memory Design V1

## Purpose

Memory System is the long-term memory layer of ZEROON.

Responsibilities:

- Preserve user growth
- Build personal history
- Generate reflections
- Support AI companionship

---

## Memory Types

### Zero Record Memory

Source:

- User zero records

Purpose:

- Preserve daily thoughts

---

### State Memory

Source:

- Emotion Engine

Purpose:

- Track emotional evolution

---

### Conversation Memory

Source:

- AI chats

Purpose:

- Remember important topics

---

### Growth Memory

Source:

- Monthly summaries

Purpose:

- Record milestones

---

## Memory Levels

L1
Recent Memory

Retention:
30 Days

---

L2
Active Memory

Retention:
1 Year

---

L3
Long-term Memory

Retention:
Permanent

---

## Memory Entry

Fields:

- id
- user_id
- type
- title
- summary
- source_id
- importance
- created_at

---

## Importance Score

Range:

1 - 10

Criteria:

1-3
Normal

4-6
Useful

7-8
Important

9-10
Milestone

---

## AI Memory Usage

AI may access:

- Recent memories
- Repeated patterns
- Milestones

AI should not expose raw memory content unnecessarily.

---

## Memory Retrieval

Methods:

- Timeline
- Keyword Search
- State Filter
- AI Reflection

---

## Monthly Reflection

Generate:

- Most common state
- Most important memory
- Growth highlights
- Companion reflection

---

## Privacy Rules

All memories are private by default.

Users own all memory data.

Users can:

- View
- Export
- Delete

their memories.

---

## Future Roadmap

V1
Memory Storage

V2
AI Memory Retrieval

V3
Semantic Search

V4
Vector Memory (pgvector)

V5
Personal Knowledge Archive

---

## Success Criteria

Memory System can:

- Store memories
- Retrieve memories
- Generate reflections
- Support AI companionship
- Preserve long-term growth history
