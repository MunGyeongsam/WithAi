# 1주차 — Lua 핵심 & LÖVE2D 게임 루프 (소재: Pong 처음부터)

> **소요:** 8시간 (오전 4h 이론·설계 / 오후 4h 실습·검증)
> **선행:** 없음. LÖVE 11.x(LuaJIT) 설치만 되어 있으면 된다.
> **이번 주 한 문장:** "클래스 흉내 내는 메타테이블"과 "프레임률과 무관한 결정적 루프"를 이해하고, 아주 작은 게임(Pong)으로 몸에 익힌다.

---

## 🎯 학습 목표

1. 메타테이블(`setmetatable`, `__index`, `__call`)로 **클래스·상속을 모방**할 수 있다.
2. LÖVE2D의 **수명주기**(`load`/`update(dt)`/`draw`)와 역할 분리를 설명할 수 있다.
3. **고정 타임스텝(fixed timestep)**이 왜 필요한지 설명하고 accumulator 패턴을 구현할 수 있다.
4. 위 세 가지를 합쳐 **결정적인 Pong**을 처음부터 작성할 수 있다.

---

## ⏱ 8시간 타임테이블

| 시간 | 블록 | 내용 | 산출물 |
|------|------|------|--------|
| 1.5h | 이론 | 메타테이블 OOP (`__index`, `__call`) | `class.lua` |
| 1.0h | 이론 | LÖVE 수명주기 + LuaJIT GC | 개념 노트 |
| 1.0h | 이론 | 고정 타임스텝 vs 가변 dt | `02_fixed_timestep_demo.lua` 이해 |
| 2.0h | 실습 | Pong 처음부터 구현 | `pong/` |
| 1.5h | 실습 | 공 반사를 고정 스텝으로 처리 | `pong/main.lua` |
| 1.0h | 검증 | 프레임률 독립성 확인 | 검증 메모 |

---

## 1. 메타테이블로 클래스 흉내 내기 (1.5h)

Lua에는 `class` 키워드가 없다. 대신 **테이블 + 메타테이블**로 OOP를 "흉내" 낸다. 핵심은 딱 두 개의 메타메서드다.

### 1-1. `__index` — 메서드 탐색의 비밀

테이블에서 어떤 키를 찾지 못하면, Lua는 메타테이블의 `__index`를 본다.

```lua
local methods = {}
function methods.greet(self)
  return "hello, " .. self.name
end

local obj = setmetatable({ name = "Lua" }, { __index = methods })
print(obj.greet(obj))   -- obj엔 greet가 없지만 __index를 타고 methods.greet를 찾음
print(obj:greet())      -- obj:greet()는 obj.greet(obj)의 축약 (콜론 문법)
```

> **핵심:** `__index`에 "메서드 모음 테이블"을 꽂으면, 모든 인스턴스가 같은 메서드를 **공유**한다(메모리 절약). 이것이 클래스의 본질이다.

### 1-2. `__call` — 테이블을 함수처럼 호출

메타테이블에 `__call`을 넣으면 테이블을 `Animal("dog")`처럼 호출할 수 있다. 생성자(`new`)를 깔끔하게 만들 때 쓴다.

```lua
local Animal = setmetatable({}, {
  __call = function(cls, name)
    local self = setmetatable({}, { __index = cls })
    self.name = name
    return self
  end,
})
function Animal:speak() return self.name .. " makes a sound" end

local a = Animal("Generic")   -- __call이 생성자처럼 동작
print(a:speak())
```

### 1-3. 상속 — 메타테이블의 체인

자식 클래스의 `__index`를 부모로 향하게 하면 메서드 탐색이 부모까지 이어진다.

```
인스턴스  --__index-->  Dog(클래스)  --__index-->  Animal(부모)
```

→ 이 패턴을 재사용하려고 **`class.lua` 유틸**을 만든다. (예제 파일 참고)

> ⚠️ **주의 (워크스페이스 규칙):** 암묵적 전역 금지. 모든 클래스/변수는 `local`로 선언하고 모듈은 `return`으로 내보낸다.

### 실습 A (30분)
`class.lua`를 읽고, `Animal`→`Dog` 상속을 직접 작성해 `d:speak()`가 오버라이드되고 `d.name`은 상속되는지 확인한다. → `01_class_demo.lua`

---

## 2. LÖVE2D 수명주기 & LuaJIT GC (1.0h)

### 2-1. 세 개의 콜백

```lua
function love.load()            -- 1회: 리소스 로드·초기 상태
function love.update(dt)        -- 매 프레임: 상태 갱신 (dt = 직전 프레임과의 시간차, 초 단위)
function love.draw()            -- 매 프레임: 화면 그리기 (상태를 바꾸지 말 것!)
```

**철칙(이 과정 내내 지킴):**
- `update`는 **상태를 바꾸는 곳**, `draw`는 **상태를 읽어 그리기만 하는 곳**.
- `draw` 안에서 좌표를 바꾸거나 점수를 더하면 안 된다. (프레임률에 따라 게임이 달라짐)

### 2-2. `dt`가 핵심인 이유

모니터마다 프레임률이 다르다(60/120/144Hz…). 이동을 `x = x + 5`로 하면 빠른 모니터에서 공이 더 빨리 날아간다. 그래서 **`x = x + speed * dt`**(초당 speed 픽셀)로 쓴다.

### 2-3. LuaJIT GC 한 줄 요약

LÖVE 11.x는 LuaJIT 위에서 돈다. **매 프레임 반복되는 코드에서 테이블을 새로 만들면** GC 부담이 커진다.
- 루프 안 `{}` 생성 최소화, 값은 재사용.
- 자주 쓰는 전역 접근(`love.graphics`)은 지역 변수로 캐싱(`local lg = love.graphics`).

---

## 3. 고정 타임스텝 vs 가변 dt (1.0h)

### 3-1. 문제 상황

`update(dt)`의 `dt`는 프레임마다 들쭉날쭉하다. 로딩 끊김으로 `dt`가 갑자기 커지면:
- 공이 한 프레임에 너무 멀리 이동해 **벽/패들을 통과**(터널링)한다.
- 같은 입력이라도 결과가 **재현되지 않는다**(비결정적).

### 3-2. 해결 — accumulator 패턴

"프레임 시간"을 모아 두고, **일정한 크기(`FIXED_DT = 1/60`)**로 잘라서 물리를 여러 번 돌린다.

```lua
local FIXED_DT = 1/60
local acc = 0

function love.update(dt)
  acc = acc + dt
  while acc >= FIXED_DT do
    step(FIXED_DT)     -- 항상 같은 간격으로 물리 1스텝
    acc = acc - FIXED_DT
  end
end
```

**효과:** 프레임률이 달라도 물리 스텝 수가 일정 → **결정적**. 이 과정의 "결정적 루프" 규칙의 토대다.

### 실습 B (이론 확인)
`02_fixed_timestep_demo.lua`를 `lua`로 실행해, **부드러운 프레임**과 **끊기는 프레임**이 같은 총 시간이면 **같은 스텝 수·같은 위치**를 내는지 확인한다.

---

## 4. [실습] Pong 처음부터 만들기 (2.0h + 1.5h)

### 4-1. 설계 (단순하게 — 아직 MVC 아님)

이번 주 Pong은 **일부러 단순 구조**다. (2주차 모놀리식 겔러그 전에 루프 감각부터 잡는 게 목적)

- `Paddle`, `Ball` — `class.lua` 기반의 작은 클래스
- 입력: `update` 안에서 `love.keyboard.isDown` 폴링 (W/S, ↑/↓)
- 물리/충돌: **고정 스텝 `step(FIXED_DT)`** 안에서 처리
- 그리기: `draw`는 읽기 전용

### 4-2. 구현 순서 (권장)

1. 창 설정(`conf.lua`) + 검정 배경에 흰 사각형 2개, 공 1개 그리기
2. 패들 상하 이동(키 입력 → 속도 → 위치)
3. 공 등속 이동 + 상/하 벽 반사
4. 공 ↔ 패들 충돌 시 x 방향 반전
5. 공이 좌/우로 빠지면 점수 + 가운데 리셋
6. 위 2~5를 전부 `step()` 안에 넣고 accumulator로 호출

### 4-3. 충돌 규칙(간단 버전)

- 벽: `y < 0` 또는 `y > HEIGHT` → `vy = -vy`
- 패들: 공의 AABB와 패들 AABB가 겹치면 `vx = -vx` (+ 약간의 속도 증가 선택)

> **코드 전체는 `examples/pong/` 참고.** 강의에서는 비워 두고 직접 채워 보게 한 뒤, 막히면 예제와 대조한다.

---

## 5. 검증 — 프레임률 독립성 (1.0h)

이 과정의 핵심 습관: **"실행해서 눈으로" 전에 "하네스로 수치 확인"**.

1. **헤드리스 확인(우선):** `lua examples/02_fixed_timestep_demo.lua` →
   부드러운/끊기는 프레임이 **동일한 스텝 수·위치**를 출력하는지 본다.
2. **최소 실행 확인(필요 시 1회):** task `Love2D: Run project` 경로로 Pong을 띄워
   공이 터널링 없이 반사되는지 본다.

> 검증 메모 양식: "무엇을 바꿨고, 하네스 결과는 무엇이며, 실행 확인이 필요했는지" 한두 줄.

---

## 6. 과제 & 체크리스트

### 과제
- [ ] `class.lua`로 `Animal`→`Dog` 상속을 작성하고 오버라이드/상속을 확인한다.
- [ ] Pong을 완성한다(2인 플레이, 점수 표시).
- [ ] **(도전)** `FIXED_DT`를 `1/30`으로 바꿔도 공 궤적이 "비율적으로" 동일한지 관찰하고 메모한다.

### 자기 점검 체크리스트
- [ ] `draw` 안에서 상태(좌표·점수)를 바꾸지 않았다.
- [ ] 암묵적 전역이 없다(`local` 사용, 모듈은 `return`).
- [ ] 이동은 전부 `* dt` 또는 고정 스텝 기반이다.
- [ ] 루프 안에서 불필요한 테이블 생성을 하지 않았다.

---

## 📁 예제 파일 안내

```
week01/
  README.md                       ← (이 문서)
  examples/
    class.lua                     ← 메타테이블 클래스 유틸 (공용)
    01_class_demo.lua             ← lua로 실행: 상속/오버라이드 데모
    02_fixed_timestep_demo.lua    ← lua로 실행: 고정 타임스텝 결정성 증명(헤드리스)
    pong/
      conf.lua                    ← 창 설정
      class.lua                   ← 클래스 유틸 (pong 내부용 사본)
      main.lua                    ← Pong 본체 (update/draw 분리, 고정 스텝)
```

### 실행 방법
- 순수 Lua 데모: `cd lua_tuto/mvc/week01/examples && lua 01_class_demo.lua`
- 고정 스텝 데모: `cd lua_tuto/mvc/week01/examples && lua 02_fixed_timestep_demo.lua`
- Pong 실행: `love lua_tuto/mvc/week01/examples/pong`
  - 조작: 왼쪽 패들 `W`/`S`, 오른쪽 패들 `↑`/`↓`, 종료 `Esc`

> 환경에 따라 `lua` 대신 `luajit`, `love` 경로 차이가 있을 수 있다. task `Lua: Run current file` / `Love2D: Run project`를 우선 사용한다.
