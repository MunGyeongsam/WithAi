# 21. 빌드 & 배포

## .love 파일 생성

`.love` 파일 = 게임 폴더를 ZIP으로 압축한 것 (확장자만 변경).
LÖVE가 설치된 환경에서 바로 실행 가능하다.

```bash
# macOS / Linux
cd my_game/
zip -9 -r ../my_game.love . -x "*.DS_Store"

# Windows (PowerShell)
Compress-Archive -Path .\* -DestinationPath ..\my_game.zip
Rename-Item ..\my_game.zip my_game.love
```

> `main.lua`가 ZIP의 **루트**에 있어야 한다 (폴더 안에 들어가면 안 됨).

### 실행

```bash
love my_game.love
```

## Windows 실행 파일 (.exe)

```bash
# 1. love.exe와 .love 파일 결합
copy /b love.exe+my_game.love my_game.exe

# 2. 필요한 DLL과 함께 배포
#    love.dll, lua51.dll, SDL2.dll, OpenAL32.dll 등
#    love-11.5-win64/ 폴더의 DLL 전부 포함
```

### 배포 폴더 구조

```
my_game_windows/
├── my_game.exe
├── love.dll
├── lua51.dll
├── SDL2.dll
├── OpenAL32.dll
├── mpg123.dll
├── msvcp120.dll
└── msvcr120.dll
```

## macOS 앱 번들 (.app)

```bash
# 1. love.app 복사
cp -r /Applications/love.app MyGame.app

# 2. .love 파일을 Resources에 넣기
cp my_game.love MyGame.app/Contents/Resources/

# 3. Info.plist 수정 (번들 이름, 아이콘 등)
```

### Info.plist 수정 항목

```xml
<key>CFBundleName</key>
<string>MyGame</string>
<key>CFBundleIdentifier</key>
<string>com.yourname.mygame</string>
```

## Linux AppImage

```bash
# love-squashfs 방식 또는 AppImage 도구 사용
# 공식 위키 참조: https://love2d.org/wiki/Game_Distribution
```

## Android (love-android)

LÖVE 공식 Android 포트를 사용한다.

1. https://github.com/love2d/love-android 클론
2. `app/src/main/assets/` 에 게임 파일 배치
3. Android Studio에서 빌드

### 주의사항

- `conf.lua`에서 `t.window.fullscreen = true`
- 세로/가로 고정: `AndroidManifest.xml`에서 `screenOrientation` 설정
- 터치 입력 필수 (`love.touchpressed` 등)
- `love.filesystem`의 save directory가 내부 저장소로 변경됨

## iOS

LÖVE 공식 iOS 포트 (Xcode 프로젝트).

1. https://github.com/love2d/love-ios 클론
2. Xcode에서 프로젝트 열기
3. 게임 파일을 프로젝트에 추가
4. 빌드 & 실행

## 웹 (love.js — 비공식)

```bash
# love.js: Emscripten 기반 웹 포팅
# https://github.com/Davidobot/love.js

npx love.js my_game.love output_folder -t "My Game"
# output_folder/index.html을 웹서버에서 호스팅
```

> 주의: 모든 LÖVE 기능이 지원되지는 않는다 (스레드, 일부 셰이더 등).

## 배포 체크리스트

| 항목 | 확인 |
|------|:----:|
| `conf.lua`에 `t.identity` 설정 | □ |
| `t.version = "11.5"` 명시 | □ |
| 미사용 모듈 비활성화 | □ |
| 디버그 출력(print) 제거 또는 비활성화 | □ |
| 에러 핸들러 커스터마이즈 | □ |
| 모든 에셋이 ZIP 루트에서 접근 가능 | □ |
| 외부 파일 경로 하드코딩 없음 | □ |
| Windows: DLL 전부 포함 | □ |
| macOS: .app 번들 코드 사인 (배포 시) | □ |

## 커스텀 에러 핸들러

배포 시 파란 에러 화면 대신 우아한 처리를 한다.

```lua
function love.errhand(msg)
    -- 에러 로그 저장
    local trace = debug.traceback(msg, 2)
    pcall(love.filesystem.write, "crash.log", trace)

    -- 간단한 에러 화면
    love.graphics.reset()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1)

    return function()
        love.event.pump()
        for name in love.event.poll() do
            if name == "quit" or name == "keypressed" then
                return 1
            end
        end
        love.graphics.clear()
        love.graphics.setColor(1, 0.3, 0.3)
        love.graphics.printf("An error occurred", 0, 200, 800, "center")
        love.graphics.setColor(0.7, 0.7, 0.7)
        love.graphics.printf("The error has been logged to crash.log", 0, 260, 800, "center")
        love.graphics.present()
    end
end
```

## 다음 챕터

전체 강좌 내용을 통합한 미니 프로젝트를 만든다.
