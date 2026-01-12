# Contributing

## Rules
- Do not import `modules/*` inside `core/*`.
- ViewModels never call HTTP directly.
- Repositories return `Result<T>` only.
- UI uses `AsyncState` + `UiMessage` patterns.

## Checks before PR
- dart format .
- flutter analyze
- flutter test
