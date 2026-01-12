Flutter Modular Monolith Template (MVVM + Riverpod)

A production-ready Flutter template designed to start any app with minimal setup.
The goal of this template is simple:

Solve infrastructure once. Build apps fast.

This template standardizes networking, authentication, state management, error handling, routing, and project structure so future apps focus almost entirely on UI and business logic.

Table of Contents

Philosophy

Architecture Overview

Project Structure

Data Flow

Core Concepts

Result & Errors

Networking

Authentication & Session

State Management (MVVM)

UI Messages & One-off Events

Routing & Guards

Environment & Configuration

How to Start a New App

What You Change Per App

What You Must NOT Change

Commands

Testing

Extending the Template

Versioning & Maintenance

Philosophy

This template follows a few strict principles:

Modular Monolith
One app, one codebase, clear feature boundaries. No premature microservices thinking.

MVVM with Riverpod
UI is dumb. ViewModels coordinate state. Business logic is testable.

Infrastructure First
Networking, auth, error handling, logging, routing, and configuration are solved once.

Configuration over Rewriting
New apps should require changing base URL, endpoints, and UI only.

If a new app requires rewriting core infrastructure, the template has failed.

Architecture Overview

High-level layers:

UI (Widgets)
   ↓
ViewModels (MVVM, Riverpod)
   ↓
Repositories / Services
   ↓
ApiClient (core/network)
   ↓
HTTP Transport


Cross-cutting concerns (auth, logging, errors, env config) live in core/.

Project Structure
lib/
├── app/
│   ├── app.dart
│   ├── bootstrap.dart
│   └── router.dart
│
├── core/
│   ├── config/           # env, flavors, app config
│   ├── errors/           # AppError hierarchy
│   ├── network/          # ApiClient, transport, interceptors, auth plumbing
│   ├── presentation/     # AsyncState, ViewModel base, UiMessage
│   └── utils/            # logger, helpers
│
├── modules/
│   └── <feature>/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
└── main.dart

Key rule

core/ must never depend on modules/

modules/ may depend on core/

Data Flow

Standard flow for all features:

Widget
 → ViewModel (StateNotifierVm)
   → Service / Repository
     → ApiClient
       → NetworkTransport


UI never talks to HTTP

ViewModels never parse JSON

Services never emit UI state

Core Concepts
Result & Errors

All non-UI operations return:

Result<T> = Success<T> | Failure<AppError>


Error types are explicit:

NetworkError

AuthError

ValidationError

Custom domain errors (extend AppError)

This avoids exception-driven flow and keeps ViewModels predictable.

Networking

Located in core/network.

Key components:

ApiClient – single entry point for all requests

ApiRequest – pure request data

NetworkTransport – HTTP implementation (swappable)

Interceptors – auth headers, logging, retry

Environment-controlled logging

Features never use http or dio directly.

Switching HTTP clients requires changing one place.

Authentication & Session

Auth is treated as infrastructure, not UI.

Includes:

Secure token storage (Keychain / EncryptedSharedPreferences)

Refresh token flow with single-flight concurrency protection

Retry-once logic on 401

Central AuthSessionController (no polling)

Routing reacts instantly to login/logout without timers.

State Management (MVVM)

Located in core/presentation/viewmodel.

AsyncState<T> – persistent UI state

UiIdle

UiLoading

UiData<T>

UiError

StateNotifierVm<T> – base ViewModel with helpers:

run()

applyResult()

setLoading / setData / setError

UI simply reacts to state.

UI Messages & One-off Events

Persistent state ≠ one-off UI events.

Handled via:

UiMessage (success, error, warning, info)

UiEvent<T> (consume once)

ErrorToUiMessage mapper (AppError → human-safe message)

Prevents snackbars/dialogs from reappearing on rebuilds.

Routing & Guards

Routing is centralized in app/router.dart using go_router.

Features:

Splash → Login → Home flow

Auth-aware redirects

Refresh tied to AuthSessionController

No redirect loops

RBAC / role checks are not forced but can be layered later.

Environment & Configuration

Environment is controlled via --dart-define.

Supported flavors

dev

staging

prod

Example:

flutter run \
  --dart-define=FLAVOR=dev \
  --dart-define=API_BASE_URL=https://dev.api.com


Env flags control:

Base URL

Network logging

Body logging (disabled by default in prod)

How to Start a New App

Click “Use this template” on GitHub

Rename package / app identifiers

Set base URL via --dart-define

Create feature modules under modules/

Build UI + ViewModels

You should not touch core infrastructure.

What You Change Per App

Base URL (API_BASE_URL)

Flavor (FLAVOR)

Feature modules inside modules/

Endpoints, DTOs, mappers

UI and navigation destinations

What You Must NOT Change

These are template primitives:

core/result

core/errors

core/network

core/presentation (AsyncState, ViewModel base, UiMessage)

If you feel the need to change these, it’s a signal to:

either extend them

or evolve the template version

Commands
Run (dev)
flutter run \
  --dart-define=FLAVOR=dev \
  --dart-define=API_BASE_URL=https://dev.api.com

Analyze
flutter analyze

Format
dart format .

Test
flutter test

Testing

The template includes:

Fake network transport for tests

Provider overrides for dependency injection

Recommended testing focus:

ViewModels

Services / repositories

Auth session transitions

UI tests are optional and app-specific.

Extending the Template

Only extend the template when:

You hit the same problem in 2+ real apps

You can extract a reusable primitive

Examples of valid future extensions:

Pagination helper

Caching layer

Feature flags

Role/permission guards

Avoid speculative additions.

Versioning & Maintenance

Template versions are tagged (e.g. v1.0.0-template)

Apps are created from a tag, not from main

Template evolves based on real usage

Final Note

This template is intentionally opinionated.

It trades flexibility for speed, safety, and consistency.
If you follow the rules, new apps become configuration + UI work, not infrastructure rewrites.

Happy building.