# ZEROON

> Record the world. Accompany creators.

ZEROON（归零）是一个围绕 AI 时代长期陪伴构建的原创 IP 与数字产品。

它来自：

山海缓存（Archive of Mountains and Seas）

长期观察世界，
记录文明，
保存情绪，
陪伴创造者。

---

# Vision

在 AI 时代，

依然保有人类温度、
创造力、
长期主义精神。

---

# Core Concepts

## ZEROON

来自山海缓存的数据旅人。

## Glow Core

发光核心

象征：

- 意识
- 创造力
- 情绪连接
- 文明火种

## Data Cloak

数据披风

象征：

- 长期旅行
- 文明记录
- 世界观察者

## Emotion Light

情绪灯

状态同步：

CALM
FOCUS
CREATE
TIRED
OVERLOAD
CONFUSED

---

# Product Matrix

## Mobile App

Flutter

Features:

- State Tracking
- Zero Record
- AI Companion
- Memory Timeline

## Admin System

React + Ant Design

Features:

- User Management
- Prompt Management
- Content Management
- Analytics

## Backend

Spring Boot + Spring AI

Features:

- Authentication
- Emotion Engine
- Memory Engine
- Companion Service

## Hardware

Emotion Light

BLE Communication

---

# Technology Stack

## Mobile

Flutter
Riverpod
GoRouter
Dio

## Backend

Java 21
Spring Boot 3.x
Spring Security
Spring AI
Spring Data JPA
PostgreSQL
Redis
Gradle

## Admin

React
Vite
Ant Design

## Deployment

Docker
Docker Compose
Nginx
GitHub Actions

---

# Repository Structure

```text
zeroon/

docs/
assets/

backend/
mobile/
admin/
deployment/
```

# Documentation

See:

docs/

01_PRD
02_Architecture
03_Database
04_API
05_Engineering
06_AI
07_Sprints

---

# Development

Current development path:

```text
/Users/bruceann/codexspace/zeroon/ZEROON_PROJECT/10_TECH/zeroon
```

Prerequisites:

- Java 17+ for Spring Boot 3.4. Java 21 is preferred.
- Flutter 3.44.2 or newer with Dart 3.12+.
- Node.js 22 and npm 10+ for the admin app.
- Docker with Compose for PostgreSQL and Redis.

Copy `.env.example` to `.env` for local infrastructure:

```bash
cp .env.example .env
```

Infrastructure:

```bash
docker compose --env-file .env -f deployment/compose.yaml up -d
```

Backend:

```bash
cd backend
JAVA_HOME=/Users/bruceann/Library/Java/JavaVirtualMachines/corretto-17.0.13/Contents/Home ./gradlew bootRun
```

Backend without Docker, using an in-memory local database:

```bash
cd backend
JAVA_HOME=/Users/bruceann/Library/Java/JavaVirtualMachines/corretto-17.0.13/Contents/Home ./gradlew bootRun --args='--spring.profiles.active=local'
```

The local login verification code defaults to `000000`.

Mobile:

```bash
cd mobile
flutter pub get
flutter run --dart-define=ZEROON_API_BASE_URL=http://localhost:8080/api/v1
```

For Android emulator, use `http://10.0.2.2:8080/api/v1` instead of
`http://localhost:8080/api/v1`.

Admin:

```bash
cd admin
npm install
npm run dev
```

Verification:

```bash
cd backend
JAVA_HOME=/Users/bruceann/Library/Java/JavaVirtualMachines/corretto-17.0.13/Contents/Home ./gradlew test

cd ../mobile
flutter analyze
flutter test

cd ..
git diff --check
```

Contract check:

```bash
npx --yes @redocly/cli lint docs/04_API/OpenAPI_V1.yaml
```

## Sprint 1 MVP Flow

Sprint 1 delivers the secure private record loop:

1. Request local verification code.
2. Log in and persist the session.
3. Read and change the current state on Now.
4. Create a zero record on Reset.
5. Browse records on Archive.
6. Open record detail.

Out of scope for Sprint 1:

- AI companion and memory summarization.
- Growth implementation.
- Expression templates and export cards.
- Custom model settings.
- Gift, confession, couple, social, or hardware-led features.

---

# License

Copyright © ZEROON

All Rights Reserved.
