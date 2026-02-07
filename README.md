# Phaser Local Viewer

**Phaser Local Viewer**는 모바일 웹게임 및 웹콘텐츠 개발 시 실기기 테스트를 위한 개발자 전용 WebView 앱입니다.

## 주요 기능

- **로컬 개발 서버 접속**: 로컬 네트워크의 개발 서버 URL을 모바일 기기에서 즉시 확인
- **전체화면 WebView**: 상태바/시스템 UI를 최소화한 전체화면 모드 지원
- **URL 관리**: 북마크 기능으로 자주 사용하는 URL을 저장하고 빠르게 접근
- **개발자 도구바**: 토글 가능한 도구바로 URL 입력, 새로고침, 전체화면 전환 등 제공
- **플로팅 컨트롤**: 도구바 숨김 시 우상단에 표시되는 반투명 컨트롤 버튼

## 기술 스택

- **Framework**: Flutter
- **WebView**: `webview_flutter`
- **Storage**: `shared_preferences` (북마크 저장)
- **Target Platform**: Android 우선, iOS 확장 가능

## 설치 및 실행

### 사전 요구사항

- Flutter SDK 설치 ([설치 가이드](https://docs.flutter.dev/get-started/install))
- Android Studio 또는 Xcode (플랫폼별)
- 실기기 또는 에뮬레이터

### 빌드 및 실행

```bash
# 의존성 설치
flutter pub get

# 개발 모드 실행
flutter run

# APK 빌드 (Android)
flutter build apk --split-per-abi

# APK 설치
adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

## 사용 방법

### UI 구성

```
┌────────────────────────────┐
│  🔖  [ URL 입력창 ] ⭐ ➤   │  ← URL 입력 바
│  ↻  📱 🔍                  │  ← 액션 바
├────────────────────────────┤
│                            │
│        WebView 영역         │
│   (웹게임 / 웹콘텐츠)       │
│                            │
└────────────────────────────┘
```

### 주요 조작법

#### URL 로드
1. 상단 URL 입력창에 주소 입력 (예: `http://192.168.0.10:8080`)
2. 전송 버튼(➤) 클릭 또는 키보드 Enter

#### 북마크 관리
- **북마크 추가**: 별 아이콘(⭐) 클릭 → 이름 입력
- **북마크 목록**: 북마크 아이콘(🔖) 클릭
- **북마크 삭제**: 목록에서 삭제 버튼 클릭

#### 전체화면 모드
- 전체화면 아이콘(📱) 클릭으로 토글
- 전체화면 시 시스템 UI 최소화

#### 도구바 숨기기
- 숨김 아이콘(🔍) 클릭으로 도구바 토글
- 도구바 숨김 시 우상단에 플로팅 컨트롤 표시:
  - 👁️ 도구바 보이기
  - ↻ 새로고침
  - 📱 전체화면 토글

#### 앱 종료
- 뒤로가기 버튼 → 종료 확인 다이얼로그 → "Exit" 선택

## 설정

### WebView 설정

[lib/config/webview_config.dart](lib/config/webview_config.dart)에서 UI 관련 상수를 조정할 수 있습니다:

```dart
class WebViewConfig {
  static const double toolbarHeight = 56.0;         // 도구바 높이
  static const double urlInputBarHeight = 52.0;     // URL 입력바 높이
  static const double toolbarPadding = 8.0;         // 도구바 패딩
  static const double toolbarIconSize = 24.0;       // 도구바 아이콘 크기
  static const int maxRetryCount = 3;               // 최대 재시도 횟수
}
```

### 앱 설정

[lib/config/app_config.dart](lib/config/app_config.dart)에서 앱 전반 설정을 조정할 수 있습니다:

```dart
class AppConfig {
  static const String appName = 'Phaser Local Viewer';
  static const int maxBookmarkCount = 20;           // 최대 북마크 개수
  static const String bookmarkedUrlsKey = 'bookmarked_urls';
}
```

### 플로팅 컨트롤 설정

[lib/screens/webview_screen.dart](lib/screens/webview_screen.dart)에서 플로팅 컨트롤 위치와 스타일을 조정할 수 있습니다:

```dart
// 플로팅 컨트롤 위치 및 스타일 상수
static const double _floatingControlsTopPosition = 42.0;
static const double _floatingControlsRightPosition = 16.0;
static const double _floatingControlsHorizontalPadding = 12.0;
static const double _floatingControlsVerticalPadding = 8.0;
static const double _floatingControlsBackgroundAlpha = 0.5;
static const double _floatingControlsBorderRadius = 8.0;
static const double _floatingControlsIconSize = 18.0;
static const double _floatingControlsButtonSize = 18.0;
```

## 프로젝트 구조

```
lib/
├── main.dart                      # 앱 진입점
├── config/                        # 설정 파일
│   ├── app_config.dart           # 앱 전역 설정
│   └── webview_config.dart       # WebView 관련 설정
├── models/                        # 데이터 모델
│   └── bookmark_item.dart        # 북마크 아이템 모델
├── screens/                       # 화면 위젯
│   └── webview_screen.dart       # 메인 WebView 화면
├── widgets/                       # 재사용 UI 컴포넌트
│   ├── url_input_bar.dart        # URL 입력 바
│   └── dev_toolbar.dart          # 개발자 도구바
└── services/                      # 비즈니스 로직
    ├── url_validator.dart        # URL 유효성 검증
    └── bookmark_service.dart     # 북마크 관리 서비스
```

## 개발 가이드라인

본 프로젝트는 개발 도구로 설계되었으며, 상세한 개발 가이드라인은 [CLAUDE.md](CLAUDE.md)를 참고하세요.

### 주요 원칙

- **단일 책임 원칙**: 함수/클래스는 하나의 책임만 수행
- **명시적 타입 선언**: 타입 추론보다 명시적 선언 선호
- **Magic Number 금지**: 숫자 리터럴은 명명된 상수로 선언
- **미사용 코드 금지**: 사용하지 않는 변수/함수/import 선언 금지

### Commit 메시지 형식

```
<type>: <subject>

<body (optional)>
```

**Type 종류**: `feat`, `fix`, `refactor`, `style`, `docs`, `chore`, `test`

## 플랫폼별 고려사항

### Android

- **Cleartext Traffic 허용**: HTTP 로컬 서버 접속을 위해 AndroidManifest.xml에서 설정됨
- **Immersive Mode**: 전체화면 모드 지원
- **최소 API Level**: 21 (Android 5.0)

### iOS

- **ATS (App Transport Security)**: Info.plist에서 HTTP 접속 허용 설정됨
- **Safe Area**: 상태바 영역 처리
- **최소 iOS 버전**: 12.0

## 문제 해결

### URL이 로드되지 않는 경우

1. **로컬 네트워크 확인**: 모바일 기기와 개발 서버가 같은 네트워크에 있는지 확인
2. **방화벽 설정**: 개발 서버의 방화벽이 외부 접속을 허용하는지 확인
3. **URL 형식**: `http://` 또는 `https://` 프로토콜이 포함되었는지 확인

### WebView가 제대로 표시되지 않는 경우

1. **JavaScript 활성화**: WebView에서 JavaScript가 활성화되어 있는지 확인
2. **User Agent**: 필요 시 [webview_screen.dart](lib/screens/webview_screen.dart)의 User Agent 설정 조정
3. **Zoom 설정**: `enableZoom(true)`가 설정되어 있는지 확인

### 앱 종료 시 검은 화면이 표시되는 경우

- 종료 다이얼로그에서 "Exit" 버튼 선택 시 `SystemNavigator.pop()`이 호출되어 정상적으로 앱이 종료됩니다
- 검은 화면이 보이는 것은 정상적인 앱 종료 과정입니다

## 라이선스

이 프로젝트는 개발 도구로 제작되었으며 내부 사용 목적입니다.

## 참고 문서

- [Flutter WebView 공식 문서](https://pub.dev/packages/webview_flutter)
- [Flutter 공식 문서](https://docs.flutter.dev/)
- [CLAUDE.md](CLAUDE.md) - 상세 개발 가이드라인
