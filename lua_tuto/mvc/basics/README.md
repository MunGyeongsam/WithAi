# MVC 기초 — LÖVE2D 없이 순수 Lua 콘솔로 배우기

> **대상:** Lua 문법·테이블·메타테이블(`09_oop_patterns`, `10_modules`)까지 배운 학습자
> **소요:** 약 3~4시간 (설명 30분 + 예제 6개 + 연습 과제)
> **준비물:** `lua` 또는 `luajit` 하나. **창(LÖVE2D)은 필요 없다.**
> **이 문서의 한 문장:** "데이터와 규칙(Model) · 보여주기(View) · 입력 해석(Controller)을 서로 다른 파일로 나누면, 하나를 바꿔도 나머지는 그대로다."

7주 과정([7주_MVC_아키텍처_집중_학습계획.md](../7주_MVC_아키텍처_집중_학습계획.md))에 들어가기 전에, 게임 루프·`dt`·그리기 같은 복잡한 요소 없이 **MVC 자체의 모양**만 먼저 익히는 입문편이다.

---

## 1. MVC 란?

MVC(Model–View–Controller)는 프로그램을 **세 가지 역할**로 나누는 구조다.

| 역할 | 한 줄 정의 | 콘솔 예 | 게임(LÖVE2D) 예 |
|------|-----------|---------|-----------------|
| **Model** | 데이터 + 규칙. "무엇이 사실인가" | 카운터 값, 할 일 목록 | 플레이어 위치, 점수, 충돌 규칙 |
| **View** | Model 을 읽어서 보여준다. "어떻게 보이는가" | `print` 로 출력 | `love.draw` 안의 그리기 |
| **Controller** | 입력을 해석해 Model 을 바꾼다. "사용자가 무엇을 원하는가" | `io.read` 로 받은 명령 처리 | `love.keypressed` 처리 |

### 비유: 식당

- **Model = 주방.** 재료(데이터)와 레시피(규칙)가 있다. 손님 얼굴도, 접시 모양도 모른다.
- **View = 플레이팅.** 같은 요리를 접시에 담을지 도시락에 담을지 정한다. 요리 자체는 바꾸지 않는다.
- **Controller = 웨이터.** 손님 말("덜 맵게요")을 주방이 이해하는 주문서로 바꿔 전달한다.

---

## 2. 왜 나누는가 — 나누지 않은 코드부터

```lua
-- ❌ 모든 것이 한 곳에: 카운터
local value = 0
while true do
  io.write("> ")
  local cmd = io.read("*l")
  if cmd == "+" then
    if value < 3 then value = value + 1 else print("최댓값!") end
  elseif cmd == "q" then
    break
  end
  print("값: " .. value)
end
```

짧을 때는 괜찮아 보인다. 하지만 다음 요구가 오면 곤란해진다.

| 요구 | 한 덩어리 코드의 문제 |
|------|----------------------|
| "규칙(최댓값 3)이 맞는지 **자동 테스트**하고 싶다" | `io.read` 가 섞여 있어 사람이 직접 입력해야만 확인 가능 |
| "출력을 **막대 그래프**로도 보여주고 싶다" | 규칙 코드 사이사이에 있는 `print` 를 전부 찾아 고쳐야 함 |
| "콘솔 대신 **LÖVE2D 창**에서 쓰고 싶다" | 처음부터 다시 작성 |
| "키보드 대신 **파일/네트워크**로 명령을 받고 싶다" | 입력 처리와 규칙이 붙어 있어 분리 불가 |

MVC 로 나누면 각각 **한 파일만** 바꾸면 된다.

---

## 3. 세 역할의 "해도 되는 것 / 하면 안 되는 것"

| | 해도 되는 것 | 하면 안 되는 것 |
|---|---|---|
| **Model** | 상태 저장, 규칙 검사, 결과/오류 **값을 반환** | `print`, `io.read`, `love.*` 호출 / View·Controller `require` |
| **View** | Model **읽기**, 문자열 만들기, 출력 | Model 값 **변경**, 게임 규칙 판단 |
| **Controller** | 입력 해석(파싱), Model 메서드 호출, View 에 갱신 요청 | 규칙을 직접 구현(예: `model.value = model.value + 1` 후 범위 검사) |

> 💡 **Model 합격 기준 하나만 기억하자:** Model 파일에 `print`, `io.`, `love.` 가 **한 글자도 없어야** 한다.
> 이 저장소의 테스트([tests/mvc_basics_test.lua](tests/mvc_basics_test.lua))가 실제로 이걸 검사한다.

---

## 4. 의존성 방향과 데이터 흐름

```
           (1) 입력 "+"
 사용자 ─────────────────▶ Controller
                              │ (2) model:increment()
                              ▼
                            Model   ← 아무도 모른다 (가장 안쪽)
                              ▲
                              │ (4) model.value 읽기
 사용자 ◀───────────────── View
           (5) 화면 출력       ▲
                              │ (3) view:render(model)
                          Controller
```

- **화살표는 "안다(require 한다)"는 뜻이다.** Controller 는 Model 과 View 를 알고, View 는 Model 을 읽는다.
- **Model 은 누구도 모른다.** 그래서 Model 만 떼어 테스트하거나 다른 프로그램(LÖVE2D)으로 옮길 수 있다.
- 세 조각을 만들고 연결하는 일은 `main.lua` 가 한다. 이것을 **조립(composition)** 이라고 한다.

### 화면 갱신을 누가 부르나? — 두 가지 방식

| 방식 | 흐름 | 예제 |
|------|------|------|
| **Controller 가 갱신 요청** (Pull — View 가 Model 을 읽어 감) | Controller → Model 변경 → Controller 가 `view:render(model)` 호출 → View 가 Model 을 읽음 | 예제 1, 2, 4, 5 |
| **Model 이 변경을 알림** (Observer, Push) | Controller → Model 변경 → Model 이 `notify()` → 구독한 View 들이 스스로 다시 그림 | 예제 3 |

게임에서는 매 프레임 `love.draw` 가 어차피 다시 그리므로 **Pull** 방식이 흔하다. 7주 과정이 다루는 구조도 이쪽이다 ([week03 1-3절](../week03/README.md) 참고).

> ⚠️ 이 Pull 방식을 "Passive View"라고 부르지 않는다. Passive View(Fowler)는 View 가 Model 을 **전혀 모르고** Presenter 가 값을 넣어 주는 방식이다. 여기서는 View 가 Model 을 직접 읽는다.

---

## 5. 예제 6개

예제 1~5는 모두 같은 모양이다.

```
0N_이름/
  *_model.lua        ← 데이터 + 규칙 (print/io/love 없음)
  *_view.lua         ← 출력만
  *_controller.lua   ← 입력 해석 → Model 호출
  main.lua           ← 조립 + 입력 루프
```

| # | 폴더 | 내용 | 이 예제에서 볼 것 |
|---|------|------|------------------|
| 1 | [01_counter/](01_counter/) | +, - 로 숫자 증감 (범위 0~3) | MVC 최소 형태. Model 은 실패 시 `false` 만 반환하고, 메시지는 View 가 보여준다 |
| 2 | [02_todo/](02_todo/) | `add 우유 사기`, `done 1`, `del 1` | **입력 파싱은 Controller**, **데이터 검증은 Model** — `(false, 이유)` 반환 패턴 |
| 3 | [03_temperature/](03_temperature/) | 섭씨/화씨 변환, 숫자 View + 막대 View | **Model 하나에 View 둘** (Observer). Controller 는 View 를 전혀 모른다. 실행 중 View 를 떼어내도 나머지는 그대로 |
| 4 | [04_guess_number/](04_guess_number/) | 1~100 숫자 맞히기 게임 | 게임 상태(`playing`/`won`/`lost`)는 Model. **난수 함수 주입**으로 결과 재현 가능. "숫자인가?"(입력 검증)와 "범위 안인가?"(규칙)의 구분 |
| 5 | [05_grid_robot/](05_grid_robot/) | ASCII 격자에서 w/a/s/d 로 로봇 이동 | 게임으로 가는 다리. **View 만 LÖVE2D 로 바꾸면 그대로 게임이 된다** (6절) |
| 6 | [06_dungeon/](06_dungeon/) | 턴제 던전 RPG (탐험·전투·가방·퀘스트) | **실제 게임 규모 맛보기.** Model 8개 · View 8개 · Controller 5개. Model 트리, 이벤트 버스, View 합성(레이아웃), 모드별 Controller 라우팅 → [06_dungeon/README.md](06_dungeon/README.md) |

> 예제 6은 파일이 많아 `models/`, `views/`, `controllers/`, `data/` 폴더로 나뉜다. 예제 1~5를 먼저 보고 오는 것을 권장한다.

### 실행 방법

각 예제의 `main.lua` 를 열고 VS Code task **`Lua: Run current file`** 을 실행한다. 미리 정해 둔 명령으로 자동 시연한다.

터미널에서 직접 실행하려면(저장소 루트 기준, `lua` 대신 `luajit` 도 가능):

```sh
lua lua_tuto/mvc/basics/01_counter/main.lua        # 자동 시연
lua lua_tuto/mvc/basics/01_counter/main.lua -i     # 직접 입력 모드
```

> `main.lua` 는 자기 위치를 기준으로 모듈을 찾으므로 어느 폴더에서 실행해도 된다.

### 테스트 (화면 없이 검증)

```sh
lua lua_tuto/mvc/basics/tests/mvc_basics_test.lua   # 예제 1~5
lua lua_tuto/mvc/basics/tests/dungeon_test.lua      # 예제 6
```

테스트가 확인하는 것:

- **[0] 디커플링** — Model 파일(예제 6은 Controller 포함)에 `print`/`io.`/`love.` 가 없는지 스캔
- **Model 규칙** — 범위, 빈 입력, 절대영도, 벽 충돌, 전투·아이템·모드 전환 등
- **Controller** — 진짜 View 대신 호출만 기록하는 **가짜 View(spy)** 를 넣어 "어떤 입력에 어떤 View 메서드가 불렸는지" 확인
- **(예제 6) Model 간 연동** — GameModel 없이 이벤트만으로 퀘스트가 진행되는지, View 가 Model 을 바꾸지 않는지

> 👉 이것이 MVC 의 가장 큰 실익이다. **사람이 키보드를 치지 않아도 규칙이 맞는지 1초 만에 확인**할 수 있다.

---

## 6. 콘솔 → LÖVE2D: 무엇이 바뀌고 무엇이 그대로인가

예제 5의 `robot_model.lua` 와 `robot_controller.lua` 는 **한 글자도 고치지 않고** LÖVE2D 에서 쓸 수 있다. View 와 조립 코드만 바꾸면 된다.

```lua
-- love_view.lua (스케치) — console_view.lua 와 같은 메서드 이름을 가진다
local CELL = 32
local LoveView = {}
LoveView.__index = LoveView

function LoveView.new()
  return setmetatable({ message = "" }, LoveView)
end

function LoveView:render(model) -- 콘솔과 달리 실제 그리기는 draw() 에서
end

function LoveView:showMessage(message)
  self.message = message
end

function LoveView:draw(model)
  for y = 1, model.height do
    for x = 1, model.width do
      if model:isWall(x, y) then
        love.graphics.rectangle("fill", (x - 1) * CELL, (y - 1) * CELL, CELL, CELL)
      end
    end
  end
  love.graphics.circle("fill", (model.x - 0.5) * CELL, (model.y - 0.5) * CELL, CELL * 0.4)
  love.graphics.print(self.message, 8, model.height * CELL + 8)
end

return LoveView
```

```lua
-- main.lua (LÖVE2D 조립 스케치)
local model, view, controller

function love.load()
  model = RobotModel.new(MAP)
  view = LoveView.new()
  controller = RobotController.new(model, view)
end

function love.keypressed(key)      -- Controller 입구: io.read 대신 키 이벤트
  controller:handle(key)
end

function love.draw()               -- View 출구: print 대신 매 프레임 그리기
  view:draw(model)
end
```

| | 콘솔 | LÖVE2D |
|---|---|---|
| Model | `robot_model.lua` | **그대로** |
| Controller | `robot_controller.lua` | **그대로** (`love.keypressed` 에서 호출) |
| View | `console_view.lua` (`print`) | `love_view.lua` (`love.graphics`) |
| 입력 루프 | `while` + `io.read` | LÖVE 가 대신 돌려줌 |

> ⚠️ 실제 게임은 여기에 **시간(`update(dt)`)** 이 더해진다. 적이 스스로 움직이고 총알이 날아가므로 Model 에 `update(dt, input)` 이 생긴다. 이 부분은 7주 과정의 [week01](../week01/README.md)(게임 루프) → [week03](../week03/README.md)(Model 분리)에서 다룬다.

---

## 7. 흔한 실수

| 실수 | 왜 문제인가 | 고치는 법 |
|------|------------|----------|
| Model 안에서 `print("최댓값!")` | Model 이 콘솔에 묶여 LÖVE2D·테스트에서 재사용 불가 | `return false` 또는 `return nil, "이유"` 로 돌려주고 View 가 출력 |
| View 에서 `model.value = 0` | 보여주기만 해야 할 곳에서 상태가 바뀌어 버그 추적이 어려움 | 값 변경은 반드시 Controller → Model 메서드로 |
| Controller 에서 `model.value = model.value + 1` 후 범위 검사 | 규칙이 Controller 에 새어 나가 다른 Controller 에서 중복·누락 | 규칙은 `model:increment()` 안에 |
| Model 안에서 `math.random()` 직접 호출 | 테스트할 때마다 결과가 달라 검증 불가 | 난수 함수를 **주입**(예제 4) |
| "파일을 3개로 나눴으니 MVC 다" | 파일만 나뉘고 서로 `print`/`io` 를 섞어 쓰면 의미 없음 | 3절 표와 테스트의 디커플링 검사로 확인 |

---

## 8. 연습 과제

쉬운 순서다. 각 과제 후 `tests/mvc_basics_test.lua` 에 테스트를 1개 이상 추가해 보자.

1. **(예제 1)** 카운터에 `*` 명령(값 2배, 최댓값 초과 시 최댓값으로)을 추가하라. 어느 파일을 고쳐야 하는가?
2. **(예제 1)** 숫자 대신 `■■■□□` 처럼 보여주는 `BoxCounterView` 를 만들어 `main.lua` 에서 바꿔 끼워라. **Model/Controller 를 고치지 않았는지** 확인하라.
3. **(예제 2)** `clear` 명령(완료된 항목 일괄 삭제)을 추가하라. 삭제 규칙은 어디에 두어야 하는가?
4. **(예제 3)** 켈빈(K)으로 보여주는 세 번째 View 를 추가하라. Controller 는 몇 줄 고쳐야 하는가? (정답: 0줄)
5. **(예제 4)** 시도 기록을 "50(↓) 25(↑) 40(↑)" 처럼 보여주도록 바꿔라. Model 에 저장해야 할 것과 View 에서 만들 것을 구분하라.
6. **(예제 5)** 맵에 열쇠 `K` 와 문 `D` 를 추가하라(열쇠를 먹어야 문 통과). 테스트를 먼저 쓰고 Model 을 고쳐라.
7. **(예제 6)** [06_dungeon/README.md 7절](06_dungeon/README.md)의 확장 과제(퀘스트·업적·상점 추가)에 도전하라.

---

## 9. 다음 단계

| 다음 | 내용 |
|------|------|
| [7주 학습 계획](../7주_MVC_아키텍처_집중_학습계획.md) | 겔러그를 모놀리식 → MVC 로 두 번 만드는 전체 로드맵 |
| [week01](../week01/README.md) | 메타테이블 클래스 + 결정적 게임 루프(Pong) |
| [week02](../week02/README.md) | 일부러 한 파일에 몰아넣은 겔러그 — "나누지 않으면" 체감 |
| [week03](../week03/README.md) | 웹 MVC vs 게임 MVC, `love` 없는 순수 Model 추출 |
| [design_patterns/](../../design_patterns/) | MVC 안에서 쓰이는 패턴들 — 예제 3의 [Observer](../../design_patterns/behavioral/observer/) 등 |
