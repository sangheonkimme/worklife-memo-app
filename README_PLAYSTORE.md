# 스마트메모 - Google Play Store 업로드 가이드

이 가이드는 스마트메모 앱을 Google Play Store에 업로드하는 전체 과정을 설명합니다.

## 목차

1. [앱 정보](#앱-정보)
2. [사전 준비사항](#사전-준비사항)
3. [앱 아이콘 생성](#앱-아이콘-생성)
4. [앱 서명 키 생성 (Keystore)](#앱-서명-키-생성)
5. [릴리스 빌드 생성](#릴리스-빌드-생성)
6. [Google Play Console 설정](#google-play-console-설정)
7. [앱 업로드 및 배포](#앱-업로드-및-배포)

---

## 앱 정보

- **앱 이름**: 스마트메모 (SmartMemo)
- **패키지명**: `com.sangheon.smartmemo`
- **버전**: 1.0.0+1

---

## 사전 준비사항

### 1. Google Play Console 계정

- [Google Play Console](https://play.google.com/console)에 가입
- 개발자 등록 비용: $25 (1회 결제)

### 2. 필요한 자료

- [ ] 앱 아이콘 (512x512 PNG, 1024x1024 PNG)
- [ ] 스크린샷 (최소 2개, 최대 8개)
  - 휴대전화: 16:9 또는 9:16 비율
  - 최소 크기: 320px
  - 최대 크기: 3840px
- [ ] 고해상도 아이콘 (512x512 PNG, 32비트)
- [ ] 기능 그래픽 (1024x500 PNG 또는 JPEG)
- [ ] 앱 설명 (짧은 설명: 최대 80자, 전체 설명: 최대 4000자)
- [ ] 개인정보처리방침 URL (필수)

---

## 앱 아이콘 생성

### 방법 1: 온라인 도구 사용 (추천)

1. **Icon Kitchen 사용**

   ```
   https://icon.kitchen/
   ```

   - 1024x1024 PNG 이미지 업로드
   - Android 옵션 선택
   - 다운로드 후 압축 해제

2. **생성된 아이콘 적용**
   ```bash
   # Icon Kitchen에서 다운로드한 파일을 android/app/src/main/res/에 복사
   cp -r path/to/downloaded/mipmap-* android/app/src/main/res/
   ```

### 방법 2: flutter_launcher_icons 패키지 사용

1. **pubspec.yaml에 추가**

   ```yaml
   dev_dependencies:
     flutter_launcher_icons: ^0.13.1

   flutter_launcher_icons:
     android: true
     ios: false
     image_path: "assets/icon/app_icon.png" # 1024x1024 PNG 준비
     adaptive_icon_background: "#FFFFFF"
     adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
   ```

2. **아이콘 생성 실행**
   ```bash
   flutter pub get
   dart run flutter_launcher_icons
   ```

### 임시 아이콘 생성 (테스트용)

간단한 텍스트 기반 아이콘이 필요하면:

```bash
# ImageMagick 사용 (설치 필요: brew install imagemagick)
convert -size 1024x1024 xc:#2196F3 -pointsize 200 -fill white -gravity center -annotate +0+0 "메모" app_icon.png
```

---

## 스플래시 아이콘 생성

```yaml
dev_dependencies:
  flutter_native_splash: ^2.4.1

flutter_native_splash:
  color: "#0A84FF" # 라이트 배경
  image: assets/splash/splash_light.png
  branding_mode: bottom
  android_12:
    color: "#0A84FF"
    image: assets/splash/splash_light.png

  color_dark: "#1C1C1E" # 다크 배경(그래파이트)
  image_dark: assets/splash/splash_dark.png
  android_12_dark:
    color: "#1C1C1E"
    image: assets/splash/splash_dark.png
```

```bash
flutter pub get
flutter pub run flutter_native_splash:create
```

---

## 앱 서명 키 생성

### 1. Keystore 파일 생성

```bash
cd android/app

keytool -genkey -v -keystore ~/smartmemo-upload-keystore.jks \
  -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 \
  -alias smartmemo

# 질문 답변 예시:
# Enter keystore password: [안전한 비밀번호 입력]
# Re-enter new password: [비밀번호 재입력]
# What is your first and last name? [이름 입력 또는 SmartMemo]
# What is the name of your organizational unit? [조직 단위 또는 개인]
# What is the name of your organization? [조직명 또는 개인]
# What is the name of your City or Locality? [도시명]
# What is the name of your State or Province? [시/도]
# What is the two-letter country code for this unit? [KR]
```

**⚠️ 중요**: 생성된 `smartmemo-upload-keystore.jks` 파일과 비밀번호를 안전하게 보관하세요!

### 2. key.properties 파일 생성

```bash
# android/key.properties 파일 생성
cat > android/key.properties << EOF
storePassword=[keystore 비밀번호]
keyPassword=[key 비밀번호]
keyAlias=smartmemo
storeFile=/Users/sangheon/smartmemo-upload-keystore.jks
EOF
```

**⚠️ 중요**: `key.properties` 파일은 절대 Git에 커밋하지 마세요!

### 3. .gitignore 확인

```bash
# android/.gitignore에 다음이 있는지 확인
echo "key.properties" >> android/.gitignore
```

### 4. build.gradle.kts 수정

`android/app/build.gradle.kts` 파일을 다음과 같이 수정:

```kotlin
// 파일 상단에 추가
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ... 기존 설정 ...

    // signingConfigs 추가 (buildTypes 위에)
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release  // 이 줄 추가
        }
    }
}
```

---

## 릴리스 빌드 생성

### 1. 앱 번들 (AAB) 생성 (추천)

Google Play는 AAB 형식을 권장합니다:

```bash
# 릴리스 빌드 생성
flutter build appbundle --release

# 생성 위치: build/app/outputs/bundle/release/app-release.aab
```

### 2. APK 생성 (옵션)

직접 배포용 APK가 필요한 경우:

```bash
flutter build apk --release

# 생성 위치: build/app/outputs/flutter-apk/app-release.apk
```

### 3. 빌드 확인

```bash
# AAB 파일 확인
ls -lh build/app/outputs/bundle/release/

# 파일 크기 확인 (일반적으로 20-30MB)
du -h build/app/outputs/bundle/release/app-release.aab
```

---

## Google Play Console 설정

### 1. 앱 등록

1. [Google Play Console](https://play.google.com/console) 접속
2. "앱 만들기" 클릭
3. 앱 정보 입력:
   - 앱 이름: **스마트메모**
   - 기본 언어: **한국어**
   - 앱 또는 게임: **앱**
   - 무료 또는 유료: **무료**
4. 선언 항목 체크 후 "앱 만들기" 클릭

### 2. 스토어 등록정보 작성

#### 앱 세부정보

**짧은 설명** (최대 80자):

```
업무와 일상의 메모를 스마트하게 관리하세요. 폴더 분류, 검색, 핀 고정 기능 제공.
```

**전체 설명** (최대 4000자):

```
스마트메모는 업무와 일상의 모든 메모를 효율적으로 관리할 수 있는 간편한 메모 앱입니다.

📝 주요 기능
• 빠른 메모 작성 및 편집
• 폴더별 메모 분류
• 중요한 메모 핀 고정
• 강력한 검색 기능
• 깔끔하고 직관적인 UI

🎯 이런 분들께 추천합니다
• 업무 메모를 체계적으로 관리하고 싶은 직장인
• 아이디어와 할 일을 기록하는 습관을 들이고 싶은 분
• 간단하고 빠른 메모 앱을 찾는 분

✨ 특징
• 오프라인 사용 가능
• 무료
• 광고 없음
• 개인정보 보호 (로컬 저장)

스마트메모와 함께 생산성을 높여보세요!
```

#### 앱 카테고리

- 카테고리: **생산성**
- 태그: 메모, 노트, 할 일, 업무

#### 연락처 정보

- 이메일 주소 입력 (필수)
- 전화번호 (선택)
- 웹사이트 (선택)

### 3. 스토어 설정

#### 개인정보처리방침

간단한 개인정보처리방침 URL이 필요합니다. 없다면:

1. GitHub Gist 또는 GitHub Pages 사용
2. 다음 내용으로 작성:

```markdown
# 스마트메모 개인정보처리방침

스마트메모("앱")는 사용자의 개인정보를 수집하지 않습니다.

## 데이터 저장

- 모든 메모는 기기 내부에 로컬로 저장됩니다
- 서버로 데이터를 전송하지 않습니다
- 사용자 계정이나 로그인이 필요하지 않습니다

## 데이터 공유

앱은 제3자와 어떠한 데이터도 공유하지 않습니다.

## 연락처

문의사항: [이메일 주소]

최종 수정일: 2025년 11월 2일
```

#### 앱 액세스 권한

- 특별한 액세스 권한 불필요 체크

### 4. 그래픽 자산

#### 고해상도 아이콘 (필수)

- 크기: 512 x 512 픽셀
- 형식: 32비트 PNG (알파 채널 포함)
- 파일 크기: 최대 1MB

#### 기능 그래픽 (필수)

- 크기: 1024 x 500 픽셀
- 형식: PNG 또는 JPEG
- 파일 크기: 최대 1MB

**임시 기능 그래픽 생성**:
ㅁ

```bash
# ImageMagick 사용
convert -size 1024x500 xc:#2196F3 \
  -pointsize 80 -fill white -gravity center \
  -annotate +0+0 "스마트메모\n간편한 메모 관리" \
  feature_graphic.png
```

#### 스크린샷 (최소 2개 필수)

앱을 에뮬레이터나 실기기에서 실행하고 스크린샷 촬영:

**Android 에뮬레이터에서 스크린샷**:

1. 에뮬레이터 실행
2. 앱 실행
3. 에뮬레이터 오른쪽 메뉴에서 카메라 아이콘 클릭

**추천 스크린샷**:

- 메모 목록 화면
- 메모 작성/편집 화면
- 폴더 선택 화면
- 검색 화면

### 5. 콘텐츠 등급

1. "콘텐츠 등급" 메뉴 선택
2. 설문 시작
3. 앱 카테고리 선택: **유틸리티, 생산성, 통신 또는 기타**
4. 모든 질문에 "아니요" 답변
5. 제출 후 등급 확인

### 6. 타겟층 및 콘텐츠

#### 타겟 연령층

- 13세 이상 선택

#### 광고 포함 여부

- 아니요 (광고 없음)

---

## 앱 업로드 및 배포

### 1. 프로덕션 트랙에 출시

1. "프로덕션" 메뉴 선택
2. "새 출시 만들기" 클릭
3. "앱 번들 업로드" 클릭
4. `build/app/outputs/bundle/release/app-release.aab` 파일 선택
5. 출시 이름: "1.0.0 - 첫 출시"
6. 출시 노트 작성:

   ```
   스마트메모 첫 출시입니다!

   주요 기능:
   • 빠른 메모 작성 및 편집
   • 폴더별 메모 분류
   • 중요한 메모 핀 고정
   • 강력한 검색 기능
   ```

### 2. 내부 테스트 (선택사항)

정식 출시 전에 내부 테스트를 권장합니다:

1. "내부 테스트" 트랙 선택
2. "새 출시 만들기" 클릭
3. AAB 파일 업로드
4. 테스터 이메일 추가
5. 출시 검토 후 "출시 검토" 클릭

### 3. 검토 제출

모든 필수 항목 완료 후:

1. 대시보드에서 완료되지 않은 항목 확인
2. 모든 항목 완료
3. "게시 개요" 페이지에서 "프로덕션으로 출시 검토" 클릭
4. Google 검토 대기 (일반적으로 3-7일)

---

## 체크리스트

출시 전 최종 확인사항:

- [ ] 앱 이름이 "스마트메모"로 올바르게 설정됨
- [ ] 패키지명이 `com.sangheon.smartmemo`로 설정됨
- [ ] Keystore 파일과 비밀번호를 안전하게 보관
- [ ] 릴리스 AAB 파일 생성 완료
- [ ] 앱 아이콘이 모든 해상도에서 올바르게 표시됨
- [ ] 스크린샷 최소 2개 준비
- [ ] 기능 그래픽 준비 (1024x500)
- [ ] 고해상도 아이콘 준비 (512x512)
- [ ] 앱 설명 작성 완료
- [ ] 개인정보처리방침 URL 준비
- [ ] 콘텐츠 등급 완료
- [ ] 타겟층 및 콘텐츠 설정 완료

---

## 추가 팁

### 버전 업데이트 시

1. `pubspec.yaml`에서 버전 업데이트:

   ```yaml
   version: 1.0.1+2 # version+build_number
   ```

2. 릴리스 빌드 재생성:

   ```bash
   flutter build appbundle --release
   ```

3. Play Console에서 새 출시 생성 및 업로드

### 문제 해결

**빌드 실패 시**:

```bash
# 캐시 정리 후 재빌드
flutter clean
flutter pub get
flutter build appbundle --release
```

**서명 오류 시**:

- `key.properties` 파일 경로 확인
- 비밀번호 확인
- keystore 파일 존재 여부 확인

**업로드 오류 시**:

- 패키지명이 고유한지 확인
- 버전 코드가 증가했는지 확인
- AAB 파일 크기 확인 (최대 150MB)

---

## 유용한 링크

- [Google Play Console](https://play.google.com/console)
- [Android 개발자 가이드](https://developer.android.com/studio/publish)
- [Flutter 배포 가이드](https://docs.flutter.dev/deployment/android)
- [Icon Kitchen](https://icon.kitchen/)
- [App Icon Generator](https://www.appicon.co/)

---

## 문의

문제가 발생하면 다음 정보와 함께 문의하세요:

- Flutter 버전: `flutter --version`
- 오류 메시지
- 진행 단계

---

**Good Luck! 🚀**
