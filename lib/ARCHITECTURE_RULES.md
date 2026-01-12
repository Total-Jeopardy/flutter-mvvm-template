# Architecture Rules (Template Law)

## Core laws
- `core/` must never import from `modules/`
- `modules/<feature>/domain` must not import `data/` or `presentation/`
- `modules/<feature>/presentation` must not import `data/api` or HTTP clients directly

## Data flow
UI -> ViewModel -> Repository (domain interface) -> data repository impl -> ApiClient

## Result + errors
- All non-UI operations return `Result<T>`
- Failures are `AppError` (never raw exceptions)

## Networking
- Features never use http/dio directly.
- Only `ApiClient` uses `NetworkTransport`.

## Auth
- Auth UI is optional per app
- Auth *services* are reusable primitives
- Token storage is via `TokenStore` (default secure)

## Messages
- Persistent UI state: `AsyncState<T>`
- One-off UI events: `UiMessage` via `UiEvent`
