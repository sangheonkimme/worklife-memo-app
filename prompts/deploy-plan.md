## Phase 1. 내부 품질 점검
- [ ] QA 시나리오 문서화 및 기능별 체크리스트 확정
- [ ] `flutter analyze`, `flutter test`, `flutter run -d chrome` 일일 자동화
- [ ] 테스터 계정으로 사내 배포 채널(TestFlight, Firebase App Distribution) 확보
- [ ] 주요 화면 스크린샷/동영상 캡처 후 문서화

## Phase 2. 베타 배포 준비
- [ ] 환경별 설정 값 정리(.env, firebase options 등) 및 암호화 저장
- [ ] 스토어용 아이콘/스플래시/메타데이터 검수
- [ ] Crashlytics, Analytics, 로그 정책 점검
- [ ] 베타 디플로이 파이프라인 구성(CI/CD에서 QA 채널까지)

## Phase 3. 공개 스토어 론칭
- [ ] 앱 스토어/플레이 스토어 계정 세팅 및 심사 체크리스트 작성
- [ ] 개인정보처리방침·서비스 이용약관 페이지 준비
- [ ] 출시 노트, 스토어 키워드, 카테고리 확정
- [ ] 버전명/빌드넘버 정책 확립 및 태깅 프로세스 문서화

## Phase 4. 론칭 후 운영
- [ ] 모니터링 대시보드(Analytics, Crashlytics, Isar backup 등) 주간 점검
- [ ] 사용자 피드백 수집 루프 구성(In-app, 이메일, 설문)
- [ ] 릴리즈 노트/업데이트 주기 정책 수립(예: 2주 배포)
- [ ] 차기 마일스톤 backlog 검토 및 우선순위 조정
