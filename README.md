# 워크라이프 메모 (Worklife Memo)

워크라이프 메모는 일을 하며 떠오르는 아이디어와 일정을 빠르게 기록하고 관리하기 위한 멀티플랫폼 Flutter 애플리케이션입니다.  
Riverpod로 상태를 관리하고 Isar 데이터베이스를 사용해 로컬에 메모와 폴더를 저장합니다.

## 목차
- [주요 기능](#주요-기능)
- [아키텍처](#아키텍처)
- [개발 방법](#개발-방법)
- [테스트](#테스트)
- [문제 해결](#문제-해결)

## 주요 기능
- 메모 생성/수정/삭제, 제목과 본문을 분리하여 관리
- 중요 메모를 상단에 고정하는 핀 기능
- 폴더별 분류 및 메모 편집 화면에서 즉시 폴더 생성
- 메모 제목/본문 전체 텍스트 검색 지원
- Flutter Material 3 기반 반응형 UI

## 아키텍처
- **상태 관리:** `flutter_riverpod` 및 코드 생성 기반 프로바이더
- **로컬 저장소:** Isar 컬렉션 (`MemoEntity`, `FolderEntity`)
- **도메인 계층:** 유스케이스(`UpsertMemo`, `WatchMemos` 등)를 통한 비즈니스 로직 캡슐화
- **프레젠테이션:** 기능별 디렉터리 구조(`lib/features/...`)를 통한 데이터/도메인/프레젠테이션 분리
- **의존성 주입:** `lib/app/di/providers.dart`에서 ProviderScope 구성

## 개발 방법
```bash
flutter pub get
flutter run -d chrome    # macOS / iOS / Android 기기를 지정해도 됩니다.
```

자주 사용하는 스크립트:
- `dart run build_runner build --delete-conflicting-outputs` – freezed/isar/riverpod 생성 코드 동기화
- `flutter format .` – 프로젝트 전체 포매팅

## 테스트
```bash
flutter test
```
위젯 및 컨트롤러 테스트는 `test/features/...`에 위치해 있습니다.

정적 분석:
```bash
flutter analyze
```

## 문제 해결
- **Isar 스키마 불일치:** 스키마 ID 변경 시 기존 Isar DB(`Application Support/.../isar/`) 삭제 필요
- **macOS Pod 관련 문제:** `cd macos && pod install --repo-update`
- **Riverpod 캐시 문제:** 디버깅 시 `ref.invalidate(...)` 호출로 캐시 무효화 가능

추가 기획 및 백로그는 `prompts/init-plan.md`, `prompts/memo-app-plan.md`에서 확인할 수 있습니다.
