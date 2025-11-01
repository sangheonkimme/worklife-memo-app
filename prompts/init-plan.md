# 초기 개발 플랜

## Phase 1. 기반 구조 정비
- [x] 기존 `notes` 기반 구조를 `features/memos`와 `features/folders`로 리팩터링
- [x] `app/di/providers.dart`를 메모/폴더 도메인에 맞게 재구성
- [x] `pubspec.yaml` 의존성 확인 후 `flutter pub get` 실행

## Phase 2. 데이터 모델 설계
- [x] `MemoEntity`/`FolderEntity` Isar 컬렉션 정의 및 Freezed 모델 작성
- [x] 도메인 모델(`Memo`, `Folder`)과 Entity 변환 로직 구현
- [x] `dart run build_runner build --delete-conflicting-outputs` 실행으로 코드 생성

## Phase 3. 리포지토리 & 유스케이스
- [x] `MemoRepository`/`FolderRepository` 인터페이스와 구현 추가
- [x] `SearchMemos`, `WatchPinnedMemos`, `UpsertMemo`, `CreateFolder` 등 유스케이스 정의
- [x] Result/Failure 패턴을 활용한 에러 처리 흐름 정비

## Phase 4. 상태 관리 레이어
- [x] `MemoListController`, `PinnedMemoController`, `MemoEditorController` Riverpod 생성
- [x] 검색어/필터 전용 프로바이더 및 디바운스 로직 준비
- [x] 폴더 목록 관리를 위한 `FolderListController` 구현

## Phase 5. UI 플로우 구현
- [x] 홈 화면(검색바, 핀 섹션, 메모 리스트, FAB) 위젯 구성
- [x] 메모 편집 화면에 폴더 선택·생성 UI와 핀 토글 반영
- [x] 폴더 생성 BottomSheet 및 라우팅/네비게이션 흐름 연결

## Phase 6. 테스트 & 검증
- [x] 리포지토리/유스케이스 단위 테스트로 CRUD, 검색, 핀 토글 검증
- [ ] 홈·편집 위젯 테스트 작성 및 상태 변동 시나리오 확인
- [ ] `flutter analyze`, `flutter test`, `flutter run -d chrome`으로 품질 점검
