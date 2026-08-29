# 01. 환경 설정 & 첫 실행

## LÖVE2D란?

- Lua로 2D 게임을 만드는 **프레임워크** (Unity 같은 에디터 GUI 없음)
- C/SDL2 기반, LuaJIT으로 스크립팅
- 내장 기능: 그래픽, 오디오, 물리(Box2D), 입력, 파일시스템
- 코드만으로 모든 것을 제어하므로 구조를 이해하기 좋음

## 설치

### macOS

```bash
# Homebrew
brew install love

# 또는 이 저장소의 번들 사용
# love-11.5-mac/love.app
```

### Windows

```
# 이 저장소의 번들 사용
love-11.5-win64/love.exe

# 또는 공식 사이트에서 다운로드
# https://love2d.org/
```

### 설치 확인

```bash
love --version
# LOVE 11.5 (Mysterious Mysteries)
```

## 프로젝트 구조

LÖVE2D는 `main.lua` 파일이 있는 폴더를 프로젝트로 인식한다.

```
my_game/
├── main.lua      ← 필수 진입점
├── conf.lua      ← 선택 (창 설정 등)
└── assets/       ← 이미지, 사운드 등
```

## 첫 번째 프로그램

```lua
-- main.lua
function love.draw()
    love.graphics.print("Hello, LÖVE2D!", 320, 280)
end
```

```bash
# main.lua가 있는 폴더에서
love .
```

창이 열리고 "Hello, LÖVE2D!" 텍스트가 표시되면 성공이다.

## conf.lua — 설정 파일

`conf.lua`는 `main.lua`보다 먼저 실행된다. 창 크기, 제목, 모듈 on/off를 설정한다.

```lua
-- conf.lua
function love.conf(t)
    t.window.title  = "My First Game"
    t.window.width  = 800
    t.window.height = 600
    t.window.vsync  = 1

    t.identity = "my_first_game"
    t.version  = "11.5"

    -- 사용하지 않는 모듈 끄기 (로딩 시간 감소)
    t.modules.joystick = false
    t.modules.physics  = false
end
```

### 주요 설정 항목

| 설정 | 기본값 | 설명 |
|------|--------|------|
| `t.window.width` | 800 | 창 너비 (px) |
| `t.window.height` | 600 | 창 높이 (px) |
| `t.window.title` | "Untitled" | 창 제목 |
| `t.window.resizable` | false | 창 크기 조절 허용 |
| `t.window.vsync` | 1 | 수직 동기화 (0=off, 1=on) |
| `t.window.fullscreen` | false | 전체 화면 |
| `t.identity` | "love..." | 저장 폴더 이름 |

## VS Code에서 실행

이 저장소에서는 VS Code task를 사용할 수 있다:
- `Love2D: Run project` — `01_breakout/src` 실행
- `Lua: Run current file` — 현재 Lua 파일 단독 실행

챕터별 예제를 실행하려면 터미널에서 직접:
```bash
love exercises/ch01_setup/
```

## 디버깅 기본

```lua
-- print는 터미널(콘솔)에 출력된다
function love.load()
    print("게임 시작!")
    print("LÖVE version:", love.getVersion())
end
```

### 에러 화면

LÖVE2D는 에러 발생 시 파란 화면에 에러 메시지와 스택 트레이스를 표시한다.
`Esc`키로 종료, 콘솔에도 같은 정보가 출력된다.

```lua
-- 일부러 에러를 내보자
function love.update(dt)
    local x = nil
    x.y = 10   -- nil 인덱싱 에러 → 파란 화면
end
```

## 다음 챕터

게임 루프(load → update → draw)의 동작 원리를 배운다.
