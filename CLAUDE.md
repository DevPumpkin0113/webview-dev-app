# Flutter WebView Dev App - Development Guidelines

## 프로젝트 개요

본 프로젝트는 **모바일 웹게임 및 웹콘텐츠 개발 중 실기기 테스트를 위한 개발자 전용 WebView 앱**입니다.

### 핵심 목적
- 로컬 개발 서버 URL을 모바일 기기에서 즉시 확인
- APK/IPA 포팅 없이 빠른 반복 테스트
- 전체화면 WebView 환경 제공
- **내부 개발/테스트 도구** (출시용 앱 아님)

### 기술 스택
- **Framework**: Flutter
- **WebView**: `webview_flutter`
- **Target Platform**: Android 우선, iOS 확장 가능
- **상태관리**: 필요 시 Provider/Riverpod (초기에는 최소화)

### 핵심 기능
1. **WebView 기능**: JavaScript 실행, HTTP/HTTPS 지원, 로컬 네트워크 접근
2. **URL 입력 UI**: 개발자용 입력 바, 최근 URL 히스토리
3. **전체화면 모드**: 상태바/시스템 UI 최소화, 토글 가능
4. **리로드 제어**: 새로고침, 강제 reload

### 화면 구성
```
┌────────────────────────────┐
│ URL 입력창  [ Load ] [ ↻ ] │  ← Dev Toolbar (토글 가능)
├────────────────────────────┤
│                            │
│        WebView 영역         │
│   (웹게임 / 웹콘텐츠)       │
│                            │
└────────────────────────────┘
```

---

## 코딩 규칙 및 가이드라인

### 구조 & 설계 원칙

#### 단일 책임 원칙 (SRP)
- **함수는 하나의 책임만** 수행
- 파일/클래스에 과도한 책임 부여 금지
- 복잡한 로직은 적절히 분리

**Good:**
```dart
// 각각의 책임이 명확히 분리됨
String validateUrl(String url) { ... }
Future<void> loadUrl(String url) { ... }
void saveUrlToHistory(String url) { ... }
```

**Bad:**
```dart
// 하나의 함수가 너무 많은 일을 수행
void handleUrlInput(String url) {
  // 유효성 검증
  // URL 로드
  // 히스토리 저장
  // UI 업데이트
  // 에러 처리
}
```

#### 재사용성
- 중복 로직은 별도 함수/유틸리티로 분리
- 공통 UI 컴포넌트는 재사용 가능하도록 설계

#### 하드코딩 금지
- magic number/string 대신 `enum` 또는 `config` 사용
- 상수는 명확한 이름으로 정의

**Good:**
```dart
enum WebViewLoadingState {
  idle,
  loading,
  loaded,
  error,
}

class AppConfig {
  static const int maxUrlHistoryCount = 10;
  static const Duration loadTimeout = Duration(seconds: 30);
}
```

**Bad:**
```dart
if (historyList.length > 10) { ... }  // 10이 무엇을 의미하는지 불명확
await Future.delayed(Duration(seconds: 30));  // 30초의 의도가 불명확
```

#### 확장 가능성 우선
- 추후 기능 추가를 고려한 구조 설계
- 인터페이스/추상 클래스 활용
- 의존성 주입 고려

---

### 코딩 스타일

#### 명시적 타입 선언
- 타입 추론에만 의존하지 말고 명시적으로 선언
- 함수 반환 타입 필수 명시

**Good:**
```dart
Future<bool> validateAndLoadUrl(String url) async {
  final Uri? parsedUri = Uri.tryParse(url);
  return parsedUri != null;
}
```

**Bad:**
```dart
validateAndLoadUrl(url) async {  // 반환 타입 불명확
  var parsedUri = Uri.tryParse(url);  // var 사용으로 타입 불명확
  return parsedUri != null;
}
```

#### Magic Number 사용 금지
- 숫자 리터럴은 명명된 상수로 선언

**Good:**
```dart
class WebViewConfig {
  static const double toolbarHeight = 56.0;
  static const int maxRetryCount = 3;
}

Container(height: WebViewConfig.toolbarHeight)
```

**Bad:**
```dart
Container(height: 56.0)  // 56.0의 의미를 파악하기 어려움
```

#### 의미 있는 변수명
- `flag`, `data`, `info`, `temp` 등 모호한 이름 사용 금지
- 축약 사용 금지 (루프 인덱스 `i`, `j` 제외)
- 변수명만으로 역할/의미가 명확해야 함

**Good:**
```dart
bool isWebViewLoading = false;
String currentLoadedUrl = '';
List<String> urlHistory = [];
int selectedHistoryIndex = -1;
```

**Bad:**
```dart
bool flag = false;  // 무엇의 플래그인지 불명확
String data = '';  // 어떤 데이터인지 불명확
List<String> list = [];  // 무엇의 리스트인지 불명확
int idx = -1;  // 축약 사용 (index로 작성)
String url = '';  // url이 현재/이전/입력중인 URL인지 불명확
```

---

### 미사용 코드 관련 규칙

#### 선언 금지 항목
- 사용하지 않는 **변수, 함수, 파라미터** 선언 금지
- 사용하지 않는 **import 문** 금지
- 사용하지 않는 **enum, type, interface** 정의 금지

#### "나중에 사용할 수도" 코드 금지
- 향후 사용 예정이라는 이유로 미사용 코드 남기지 말 것
- 필요할 때 추가하는 것이 원칙
- 주석 처리된 코드도 커밋하지 말 것

**Bad:**
```dart
// 나중에 사용할 수도 있어서 남겨둠
// void handleHistoryDelete(int index) {
//   urlHistory.removeAt(index);
// }

import 'package:flutter/services.dart';  // 현재 사용하지 않음

class WebViewController {
  String currentUrl = '';
  // String? previousUrl;  // 나중에 사용할 예정
}
```

#### 미사용 파라미터 처리
- 미사용 파라미터는 `_` prefix 사용
- 콜백 시그니처 맞추기 위해 필요한 경우에만 사용

**Good:**
```dart
onTap: (_event) {  // event를 사용하지 않지만 시그니처상 필요
  handleTap();
}

void onWebViewCreated(WebViewController controller, [Duration? _timeout]) {
  // timeout은 사용하지 않지만 시그니처 유지를 위해 필요
  _controller = controller;
}
```

#### 구조 분해 할당 최소화
- 실제 사용하는 속성만 추출
- 사용하지 않는 필드는 가져오지 말 것

**Good:**
```dart
final String url = webViewState.currentUrl;
```

**Bad:**
```dart
final (currentUrl, isLoading, error) = webViewState;
// isLoading, error는 사용하지 않음
```

#### 타입 전용 Import
- 타입으로만 사용하는 import는 반드시 `import type` 사용 (Dart 3.0+)
- 런타임에 필요 없는 import 최소화

**Good:**
```dart
import 'package:webview_flutter/webview_flutter.dart' show WebViewController;
```

#### 빌드 기준
- **프로젝트는 `noUnusedLocals` / `noUnusedParameters` 기준으로 빌드 통과해야 함**
- 정적 분석(lint) 경고 없이 커밋

---

## Flutter 프로젝트 구조

```
lib/
├── main.dart                 # 앱 진입점
├── config/                   # 설정 및 상수
│   ├── app_config.dart
│   └── webview_config.dart
├── models/                   # 데이터 모델
│   └── url_history_item.dart
├── screens/                  # 화면 위젯
│   └── webview_screen.dart
├── widgets/                  # 재사용 UI 컴포넌트
│   ├── url_input_bar.dart
│   └── dev_toolbar.dart
├── services/                 # 비즈니스 로직
│   ├── url_validator.dart
│   └── url_history_service.dart
└── utils/                    # 유틸리티 함수
    └── platform_utils.dart
```

---

## 플랫폼별 고려사항

### Android
- `android/app/src/main/AndroidManifest.xml`에서 `cleartextTraffic` 허용
- Immersive mode로 전체화면 구현
- 최소 API Level: 21 (Android 5.0)

### iOS
- `Info.plist`에서 ATS(App Transport Security) 설정
- Safe Area 처리 필수
- 최소 iOS 버전: 12.0

---

## Git Commit 가이드라인

### Commit Message 형식
```
<type>: <subject>

<body (optional)>
```

### Type 종류
- `feat`: 새로운 기능 추가
- `fix`: 버그 수정
- `refactor`: 코드 리팩토링
- `style`: 코드 포맷팅, 세미콜론 누락 등
- `docs`: 문서 수정
- `chore`: 빌드 설정, 패키지 매니저 수정 등
- `test`: 테스트 코드 추가/수정

### 예시
```
feat: add URL history dropdown

- Implement UrlHistoryService for persistent storage
- Add dropdown UI component
- Limit history to 10 items

fix: prevent crash on invalid URL input

- Add null check for Uri.tryParse result
- Show error message on invalid URL
```

---

## 성능 고려사항

### WebView 최적화
- 불필요한 WebView 재생성 방지
- JavaScript channel 최소화
- 메모리 누수 방지 (dispose 철저히)

### 반응성
- 앱 실행 → URL 로드까지 최소 단계
- UI 블로킹 작업은 async/await 처리
- 로딩 인디케이터 명확히 표시

---

## 테스트 전략

### 필수 테스트 항목
1. URL 유효성 검증 로직
2. URL 히스토리 저장/불러오기
3. WebView 로드 성공/실패 시나리오
4. 전체화면 모드 전환

### 실기기 테스트
- Android 다양한 화면 크기
- iOS Safe Area 동작
- 로컬 네트워크 접근 (HTTP)
- WebView JavaScript 실행

---

## 범위 외 (Out of Scope)

이 프로젝트는 개발 도구이므로 다음 항목은 구현하지 **않음**:
- 앱스토어 배포
- 사용자 계정 관리
- 푸시 알림
- 보안 인증/암호화
- 다국어 지원 (영어/한글만 지원)

---

## 참고 문서

- [APP_SPEC.md](docs/APP_SPEC.md): 상세 기획서
- [Flutter WebView 공식 문서](https://pub.dev/packages/webview_flutter)
- [Flutter 전체화면 가이드](https://docs.flutter.dev/development/ui/advanced/gestures)
