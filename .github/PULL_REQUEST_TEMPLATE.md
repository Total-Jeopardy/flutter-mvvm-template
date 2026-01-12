## Checklist
- [ ] No `core/*` imports from `modules/*`
- [ ] ViewModels return `AsyncState` and emit `UiMessage` for one-offs

- [ ] Repositories return `Result<T>` only
- [ ] No direct http/dio usage outside `core/network`

- [ ] `dart format` passed
- [ ] `flutter analyze` passed
- [ ] `flutter test` passed
