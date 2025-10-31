# Repository Guidelines

## Project Structure & Module Organization
- `lib/` holds the Flutter application entrypoint and feature widgets; split new features into subdirectories per domain (e.g. `lib/memos/`).
- `test/` mirrors `lib/` widgets and logic with `*_test.dart` files.
- Platform folders (`android/`, `ios/`, `macos/`, `linux/`, `windows/`, `web/`) contain generated build scaffolding; avoid manual edits unless targeting platform-specific APIs.
- `prompts/` stores product planning notes useful for context but not shipped code.
- Keep assets under `assets/` (create if needed) and register them in `pubspec.yaml`.

## Build, Test, and Development Commands
- `flutter pub get` installs package dependencies after editing `pubspec.yaml`.
- `flutter analyze` runs static analysis with the configured `flutter_lints`.
- `flutter test` executes widget and unit tests headlessly.
- `flutter run -d chrome` launches the app for local web debugging; swap the device id for mobile targets.
- `flutter build apk --release` produces a release Android package; add `--split-per-abi` for store-ready uploads.

## Coding Style & Naming Conventions
- Follow Flutter's defaults: 2-space indentation, trailing commas to enable formatter-friendly diffs, and `dart format .` before committing.
- Classes and widgets use UpperCamelCase, methods and variables use lowerCamelCase, files stay snake_case (e.g. `memo_card.dart`).
- Treat analyzer warnings as build blockers; adjust `analysis_options.yaml` only with team consensus.

## Testing Guidelines
- Use the `flutter_test` package; structure tests with `group`/`test` and prefer `WidgetTester` when rendering UI.
- Name files `<feature>_test.dart` and mirror the production file tree inside `test/`.
- Ensure new features ship with happy-path and regression coverage; run `flutter test --coverage` to audit metrics before merges.

## Commit & Pull Request Guidelines
- Adopt Conventional Commits (`feat:`, `fix:`, `chore:`) to clarify intent in the absence of historical git guidance.
- Keep commits focused and runnable; include `flutter analyze` and `flutter test` output in the PR description.
- Reference Jira/GitHub issue ids when available and attach UI screenshots or screen recordings for visible changes.
- Request at least one peer review and wait for CI to pass before merging.
