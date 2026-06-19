# System Architecture V1

## Technology Stack

### Mobile
- Flutter
- Riverpod
- Dio

### Backend
- Java 21
- Spring Boot 3
- Spring Security
- Spring AI
- JPA

### Infrastructure
- PostgreSQL
- Redis
- Docker

---

## Architecture

Mobile App
    ↓
Nginx / Cloud Load Balancer
    ↓
Spring Boot Modular Monolith

Modules:
- User
- State
- Record
- Companion
- Memory
- Admin

    ↓

PostgreSQL
Redis

    ↓

LLM Provider
(OpenAI / Claude / Gemini)

MVP does not deploy an independent API Gateway. See ADR-002.

---

## Module Boundaries

### User
- Login
- JWT
- Profile

### State
- Current State
- State History
- Emotion Mapping

### Record
- Zero Records

### Companion
- AI Chat

### Memory
- Archive of Mountains and Seas

### Admin
- Prompt Management
- Content Management
- User Management

---

## Hardware Roadmap

V1:
- No Hardware

V2:
- BLE Emotion Light

V3:
- Plush Companion Device
