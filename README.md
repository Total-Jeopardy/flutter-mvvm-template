# Flutter Modular Monolith Template (MVVM + Riverpod)

## What you change per app
- Base URL: `--dart-define=API_BASE_URL=...`
- Flavor: `--dart-define=FLAVOR=dev|staging|prod`
- Endpoints + DTOs + mappers inside `modules/`

## What you should NOT change
- `core/result`
- `core/errors`
- `core/network`
- `core/presentation` primitives

## Commands
### Dev
flutter run --dart-define=FLAVOR=dev --dart-define=API_BASE_URL=https://dev.api.com

### Analyze
flutter analyze

### Format
dart format .

### Test
flutter test
