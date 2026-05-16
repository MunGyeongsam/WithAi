# 01. Lua란? 왜 게임에서 쓰나?

## Lua 한 줄 요약

> **가볍고 빠른 임베딩 스크립팅 언어**

C/C#으로 만든 엔진 위에 Lua를 얹어서 게임 로직을 작성하는 구조가 업계 표준이다.

## 어디서 쓰이나?

| 게임/엔진 | Lua 활용 |
|-----------|----------|
| World of Warcraft | UI, 애드온 시스템 |
| Roblox | 게임 로직 전체 (Luau) |
| CryEngine | 게임 스크립팅 |
| Corona SDK | 모바일 게임 전체 |
| LÖVE2D | 게임 로직 전체 |
| Defold | 게임 로직 전체 |

## 왜 Lua인가? (C/C# 개발자 관점)

### 1. 가볍다
- 전체 인터프리터가 약 200KB
- C로 작성, ANSI C 호환 → 어디든 포팅 가능
- C# Unity 프로젝트의 Mono 런타임(수십 MB)과 비교

### 2. 빠르다
- 스크립팅 언어 중 최상위 성능
- LuaJIT: JIT 컴파일 → C에 근접한 속도
- LÖVE2D는 LuaJIT 기반

### 3. 임베딩이 쉽다
- C API가 단순 (스택 기반, ~100개 함수)
- C/C++ 엔진에 30줄이면 Lua 통합 가능
- C#의 `[DllImport]`보다 훨씬 자연스러움

### 4. 테이블 하나로 모든 자료구조
- 배열, 딕셔너리, 객체, 모듈 전부 테이블
- C의 struct + array + hashmap을 하나로

## Lua vs C vs C# 핵심 차이

```
특성              C              C#             Lua
──────────────────────────────────────────────────────────
타입 시스템       정적           정적            동적
메모리 관리       수동(malloc)   GC             GC
컴파일            AOT            AOT/JIT        인터프리터/JIT
클래스            없음(struct)   class          테이블+메타테이블
배열 인덱스       0부터          0부터          1부터 ⚠️
문자열            char*          string(불변)   string(불변)
에러 처리         반환값         try-catch      pcall
```

## LÖVE2D란?

- Lua로 2D 게임을 만드는 **프레임워크** (엔진이 아님)
- Unity처럼 에디터 GUI가 없음 → 코드로 모든 것을 제어
- 내장 기능: 그래픽, 오디오, 물리, 입력, 파일시스템
- C/SDL2 기반, Lua(LuaJIT)로 스크립팅

### LÖVE2D 최소 구조

```lua
-- main.lua (이 파일 하나면 게임이 실행된다)

function love.load()
    -- 게임 시작 시 1회 호출
    x = 400
    y = 300
end

function love.update(dt)
    -- 매 프레임 호출 (dt = 이전 프레임으로부터 경과 시간)
    if love.keyboard.isDown("right") then
        x = x + 200 * dt
    end
end

function love.draw()
    -- 매 프레임 화면 그리기
    love.graphics.circle("fill", x, y, 20)
end
```

```
-- C# Unity 비교:
-- love.load()   ≈ Start()
-- love.update() ≈ Update()  (dt ≈ Time.deltaTime)
-- love.draw()   ≈ OnRenderObject() 또는 Camera render
```

### 실행

```bash
# main.lua가 있는 폴더에서
love .
```

## 개발 환경 설정

### 1. LÖVE2D 설치

**macOS:**
```bash
brew install love
```

**Windows:**
- https://love2d.org/ 에서 zip 다운로드
- `love.exe`가 있는 폴더를 PATH에 추가

### 2. 에디터 설정 (VS Code)

1. VS Code 설치
2. 확장 설치: **Lua** (sumneko)
3. 확장 설치: **LÖVE2D Support** (pixelbyte-studios)
4. `.vscode/settings.json`:

```json
{
    "Lua.runtime.version": "Lua 5.1",
    "Lua.workspace.library": [
        "${3rd}/love2d/library"
    ]
}
```

### 3. 첫 프로젝트 만들기

```bash
mkdir my_first_game
cd my_first_game
# main.lua 파일 생성 (위의 최소 구조 코드 붙여넣기)
love .
```

## Hello World

```lua
function love.draw()
    love.graphics.print("Hello, World!", 400, 300)
end
```

이것이 LÖVE2D에서 가능한 가장 짧은 게임이다. `love.draw()` 하나만 정의하면 된다.

---

## 연습문제

### 연습 1-1: 환경 확인
LÖVE2D를 설치하고, 아래 코드를 `main.lua`에 저장한 뒤 실행하라.
화면에 Lua 버전이 표시되어야 한다.

```lua
function love.draw()
    love.graphics.print("Lua version: " .. _VERSION, 10, 10)
    love.graphics.print("LOVE version: " .. love._version, 10, 30)
end
```

### 연습 1-2: 움직이는 원
위의 "최소 구조" 예제를 수정하여:
- 상하좌우 화살표 키로 원을 이동시켜라
- 이동 속도는 `200 * dt`

### 연습 1-3: 색상 변경
`love.graphics.setColor(r, g, b)` 를 사용하여 원의 색상을 빨간색으로 바꿔라.
(힌트: LÖVE2D 11.x에서 색상 값은 0~1 범위)

---

[다음: 02. 타입 & 변수 & 스코프 →](02_types_and_variables.md)
