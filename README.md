🚀 Flutter Modular Monolith Template
MVVM • Riverpod • Production-Ready

A production-ready Flutter template designed to start any app with minimal setup.

Goal: solve infrastructure once, so future apps are mostly configuration + UI work.

📌 Key Features

✅ Modular Monolith architecture

✅ MVVM with Riverpod

✅ Reusable networking layer

✅ Secure authentication & token lifecycle

✅ Centralized routing with guards

✅ Global error handling & logging

✅ Environment-based configuration

✅ Built for scale, not demos

🧠 Philosophy

This template is opinionated by design.

It prioritizes:

Consistency over flexibility

Predictability over cleverness

Speed of delivery over rewrites

If a new app requires rewriting auth, networking, or state management, the template has failed.

🏗 Architecture Overview
UI (Widgets)
   ↓
ViewModels (MVVM)
   ↓
Services / Repositories
   ↓
ApiClient (core/network)
   ↓
HTTP Transport


Cross-cutting concerns (auth, errors, logging, env config) live in core/.

📂 Project Structure
lib/
├── app/
│   ├── app.dart
│   ├── bootstrap.dart
│   └── router.dart
│
├── core/
│   ├── config/           # Env, flavors
│   ├── errors/           # AppError hierarchy
│   ├── network/          # ApiClient, auth, interceptors
│   ├── presentation/     # AsyncState, ViewModel base, UiMessage
│   └── utils/            # Logger, helpers
│
├── modules/
│   └── <feature>/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
└── main.dart

🔒 Architecture Rules

core/ must never import from modules/

modules/ may import from core/

UI never talks to HTTP directly

🔁 Data Flow
Widget
 → ViewModel (StateNotifierVm)
   → Service / Repository
     → ApiClient
       → NetworkTransport

🧩 Core Concepts
1️⃣ Result & Error Handling

All non-UI operations return:

Result<T> = Success<T> | Failure<AppError>


Error types are explicit:

NetworkError

AuthError

ValidationError

Custom domain errors

No exception-driven UI logic.

2️⃣ Networking

Located in core/network.

Key rules:

Features never use http or dio

All requests go through ApiClient

Transport is swappable

Logging is environment-controlled

3️⃣ Authentication & Session

Auth is infrastructure, not UI.

Includes:

Secure token storage (Keychain / EncryptedSharedPreferences)

Refresh token flow (single-flight, retry-once)

Central AuthSessionController

Routing reacts instantly to login/logout

❌ No polling, ❌ no battery drain

4️⃣ State Management (MVVM)

Persistent UI state uses:

AsyncState<T>
 ├── UiIdle
 ├── UiLoading
 ├── UiData<T>
 └── UiError


ViewModels extend:

StateNotifierVm<T>


With helpers like:

run()

applyResult()

setLoading / setData / setError

5️⃣ UI Messages (One-off Events)

Snackbars, dialogs, and toasts use:

UiMessage

UiEvent<T> (consume once)

ErrorToUiMessage mapper

Prevents duplicate UI events on rebuilds.

6️⃣ Routing & Guards

Routing lives in app/router.dart using go_router.

Features:

Splash → Login → Home flow

Auth-aware redirects

No redirect loops

Centralized navigation logic

RBAC is optional, not forced.

🌍 Environment & Configuration

Configured via --dart-define.

Supported Flavors

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

Body logging (off by default in prod)

🚀 Starting a New App

Click Use this template on GitHub

Rename app/package identifiers

Set base URL via --dart-define

Add features under modules/

Build UI + ViewModels

👉 You should not touch core infrastructure.

✏️ What You Change Per App

API_BASE_URL

FLAVOR

Feature modules (modules/*)

Endpoints, DTOs, mappers

UI & navigation destinations

🚫 What You Must NOT Change

These are template primitives:

core/result

core/errors

core/network

core/presentation primitives

If you feel the need to change these, evolve the template version instead.

🧪 Commands
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

🧪 Testing Support

Included:

Fake network transport

Provider overrides

Recommended focus:

ViewModels

Services / repositories

Auth session transitions

🔧 Extending the Template

Only extend when:

You hit the same problem in 2+ real apps

You can extract a reusable primitive

Good future candidates:

Pagination

Caching

Feature flags

Role-based guards

Avoid speculative additions.

🏷 Versioning & Maintenance

Template versions are tagged (e.g. v1.0.0-template)

Apps should be created from tags

Template evolves based on real usage

✅ Final Note

This template trades flexibility for speed, safety, and consistency.

If followed correctly, new apps become:

configuration + UI work

—not infrastructure rewrites.

Happy building 🚀
