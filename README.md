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

Prerequisites:

- Java 21 (the Gradle toolchain can provision it automatically)
- Flutter stable with Dart 3.6+
- Node.js 22 and npm 10+
- Docker with Compose

Copy `.env.example` to `.env` and replace all non-development secrets.

Infrastructure

```bash
docker compose --env-file .env -f deployment/compose.yaml up -d
```

Backend

```bash
cd backend
./gradlew bootRun
```

Mobile

```bash
flutter run
```

Admin

```bash
cd admin
npm install
npm run dev
```

Contract check

```bash
npx --yes @redocly/cli lint docs/04_API/OpenAPI_V1.yaml
```

The CI workflow is the authoritative build environment until local Java 21,
Gradle, and Flutter are installed.

---

# License

Copyright © ZEROON

All Rights Reserved.
