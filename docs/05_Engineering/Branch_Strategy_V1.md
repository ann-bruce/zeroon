# Branch Strategy V1

## Main Branches

main
develop

---

## Feature Branch

feature/user-login

feature/state-module

feature/zero-record

feature/companion-chat

feature/memory-system

feature/admin-system

---

## Release Branch

release/v1.0.0

release/v1.1.0

---

## Hotfix Branch

hotfix/login-bug

hotfix/jwt-expire

---

## Workflow

feature/*
    ↓

develop
    ↓

release/*
    ↓

main

---

## Rules

main

Production Only

No Direct Commit

---

develop

Integration Branch

Daily Development

---

feature/*

Single Feature Only

Must Create PR

---

release/*

Bug Fix Only

No New Features

---

hotfix/*

Emergency Fix

Merge Back To:

main
develop

---

## Pull Request Rules

Required:

1. Build Success

2. Unit Test Pass

3. Code Review Pass

4. Documentation Updated

---

## Commit Convention

feat:

fix:

docs:

refactor:

test:

chore:

---

Examples

feat(user): support sms login

feat(record): create zero record

fix(state): fix state query

docs(api): update openapi

---

## Versioning

v1.0.0

MVP Release

v1.1.0

Emotion Engine Upgrade

v2.0.0

Emotion Light Support

v3.0.0

Companion Plush Support

---

## Protection Rules

main

Protected

Require PR

Require Review

Require CI

develop

Protected

Require PR

Require CI
