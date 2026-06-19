# ADR-001: Mobile Technology

Status: Accepted

Date: 2026-06-07

## Decision

ZEROON mobile uses Flutter with Dart, Riverpod, GoRouter, and Dio.

## Context

The product requires consistent visual rendering, custom state animations, and a future BLE hardware connection. The existing technical documents and sprint plans already use Flutter.

## Consequences

- Mobile and admin do not share UI or runtime code.
- OpenAPI is the contract shared by mobile, admin, and backend.
- The team must maintain Dart and TypeScript skills.
- BLE support can use the Flutter plugin ecosystem in a later phase.

## Review Trigger

Reconsider only if Flutter blocks a required native capability or staffing cannot support Dart before Beta.

