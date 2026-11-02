# 6주차 — 단방향 흐름(Flux): Snake 를 처음부터 + 겔러그에 리플레이

> **소요:** 8시간
> **선행:** 5주차(`galaga_states`: 씬 스택, 진행 단계 State, `equivalence_test`)
> **이번 주 한 문장:** 상태를 바꾸는 길을 **Action 하나로 좁히면**, "일어난 모든 일"이 기록되고 그 기록으로 **같은 판을 다시 돌릴 수 있다**. Snake 는 처음부터 그렇게 만들고, 겔러그는 **Model 을 한 줄도 고치지 않고** 리플레이를 붙인다.

---

## 🔗 지난주까지 남긴 숙제 (이번 주에 회수한다)

| 남긴 것 | 어디서 | 이번 주 결과 |
|--------|--------|-------------|
| "입력을 기록하면 리플레이가 된다" (예고만) | 3주차 결정성, 4주차 `[한계]` | 겔러그 `InputRecorder` + `ReplayScene`. 20fps 로 한 판을 60fps·4배속으로 재생해도 **매 스텝 같은 판** |
| `[한계]` 실시간 입력은 프레임 경계에서 양자화된다 | 4주차 `integration_test` | **그대로 남는다**(이번 주 테스트도 `[한계, 그대로]` 로 계속 통과). 기록은 "그 판"을 재현할 뿐, 실시간 양자화를 없애지 않는다 — 6절 |
| `InputController:read()` 가 같은 테이블을 재사용 | 4주차 1-4절 | 기록기에서 실제로 터지는 함정이 된다 → 복사 + 테스트 |
| main 의 루프를 테스트가 "흉내"만 냄 | 4주차 `integration_test` | Snake 는 `App.lua`(love 모름)로 조립 → 테스트가 **진짜 App** 을 돌린다 |

---

## 🎯 학습 목표

1. Flux 의 네 부품(Action·Dispatcher·Store·View)과 **한 방향** 흐름을 그림으로 설명할 수 있다.
2. **순수 리듀서**가 무엇이며, 왜 "받은 state 를 고치지 않는다"가 시간 여행·리플레이의 바탕인지 설명한다.
3. **시간도 Action 이다**(`tick`)의 의미와, 그 덕분에 재생이 프레임률과 무관해지는 이유를 설명한다.
4. 기존 MVC 겔러그에 Model 수정 없이 입력 기록·리플레이를 붙이고, **재사용 테이블 함정**을 테스트로 잡는다.
5. 리플레이가 **해결하는 것과 해결하지 못하는 것**(실시간 입력 양자화)을 구분해 말할 수 있다.
6. "고쳐서 좋은 구조로" vs "처음부터 좋은 구조로"의 비용 차이를 이번 주 실측으로 말할 수 있다.

---

## ⏱ 8시간 타임테이블

| 시간 | 블록 | 내용 | 산출물 |
|------|------|------|--------|
| 1.0h | 개념 | Flux 4부품, 순수 리듀서, 시간도 Action, MVC(Pull 갱신)와의 차이 | 흐름도 1장 |
| 0.5h | 설계 | Action 계약·state 계약·계층 규칙 읽기 | 계약표 |
| 2.0h | 실습 1 | `starter` 의 `snakeReducer` `turn`·`tick` → `reducer_test` | 순수 규칙 |
| 1.0h | 실습 2 | `Dispatcher:dispatch`, `ActionLog:record`·`replay` → `flux_test` | 동작하는 Snake + 리플레이 |
| 1.5h | 실습 3 | `starter_galaga` 의 `InputRecorder:record`, `ReplayScene:update` → `replay_test` | 겔러그 리플레이 |
| 0.5h | 실습 | 실행 확인 1회씩 (Snake 한 판 → V, 겔러그 한 판 → V) | 동작 확인 |
| 1.5h | 비교·회고 | 겔러그(직접 호출 MVC) vs Snake(Flux) 비교표, `[한계]` 토론, 퀴즈 | 비교 메모 |

---

## 1. Flux — 상태를 바꾸는 길을 하나로 (개념 1.0h)

### 1-1. 지금까지의 겔러그: 누가 상태를 바꾸나?

5주차 겔러그에서 `GameModel` 의 상태는 `update(dt, input)` 안에서 바뀐다. Controller 는 `input` 테이블을 만들어 넘기고, View 는 읽기만 한다. 이미 꽤 깨끗하다. 그런데 "이 판에서 **무슨 일이** 있었나?"를 묻으면 답이 없다. 남는 건 **결과**(점수·좌표)뿐이고 **원인**의 목록은 없다.

### 1-2. Flux 의 흐름

```text
 키 입력 ─┐
 시간 ────┼─▶ Action ──▶ Dispatcher ──▶ Store ──(getState)──▶ View
          │   (평범한     (단 하나의 문:   (state 보관,
          │    테이블)     검증·기록·전달)  reducer 로만 변경)
          └─────────────────── 한 방향 ───────────────────────────┘
```

| 부품 | 이번 주 파일 | 한 가지 책임 |
|------|-------------|-------------|
| **Action** | `game/actions.lua` | "무슨 일이 일어났는가"를 담은 **데이터**. 함수·참조 없음 → 문자열로 저장 가능 |
| **Dispatcher** | `flux/Dispatcher.lua` | 모든 Action 이 지나가는 **유일한 문**. 검증 → tap(기록기) → Store |
| **Store** | `flux/Store.lua` | 지금 state 를 **들고만** 있다. 규칙은 주입받은 리듀서가 갖는다 |
| **Reducer** | `game/snakeReducer.lua` | `reduce(state, action) → 새 state`. **순수 함수** |
| **View** | `views/SnakeView.lua` | state 를 읽어 그린다. dispatch 금지 |

### 1-3. 순수 리듀서 — 이번 주의 핵심 한 줄

```lua
-- ❌ 받은 state 를 고친다 → "어제의 state" 가 사라진다
local function turn(state, dir) state.nextDir = dir; return state end

-- ✅ 바뀐 부분만 새 테이블, 나머지는 공유
local function turn(state, dir)
  local s = copy(state)   -- 얕은 복사: snake 배열·각 칸 테이블은 공유
  s.nextDir = dir
  return s
end
```

- **옛 state 가 그대로 남는다** → 보관만 하면 그게 "과거"다(시간 여행). `flux_test` "옛 상태는 그대로 남아 있다".
- **같은 입력 → 같은 출력** → 기록을 다시 계산하면 같은 결과(리플레이).
- **변화 없으면 같은 테이블** → `old == new` 한 번으로 변경 감지(Store 구독자가 쓸데없이 불리지 않음).
- 공유가 안전한 이유: 리듀서는 **어떤 테이블도 만든 뒤에 고치지 않는다**. 그래서 `snake` 의 칸 테이블은 여러 state 가 함께 써도 된다.

> ⚠️ 난수도 state 안에 있다(`state.rng`). `math.random` 을 리듀서에서 부르면 "같은 입력 → 같은 출력" 이 깨진다. `layer_check` 가 `game/` 의 `math.random`·`os.time` 을 금지한다.

### 1-4. 시간도 Action 이다

```lua
{ type = "tick" }   -- "시간이 한 칸 흘렀다" 도 일어난 일이다
```

`Ticker`(0.12초마다 tick dispatch)는 **실시간을 Action 으로 바꾸는 곳**이다. 일단 Action 으로 바뀌면 리듀서는 실시간을 모른다. 그래서 기록을 **초당 7개로 천천히** 재생하든 **초당 300개로 빨리** 재생하든 결과가 같다(`flux_test` 확인).

겔러그는 이걸 이미 다른 모양으로 하고 있었다: **고정 스텝**. 1/60초 한 스텝 = tick 하나, 그 스텝의 `input` = 그 스텝의 Action. 그래서 7절의 비교가 성립한다.

### 1-5. MVC(Pull 갱신)와 무엇이 다른가

| | 4~5주차 겔러그 | 6주차 Snake |
|---|---|---|
| 상태 변경 경로 | `GameModel:update(dt, input)` 내부 여러 메서드 | `reduce(state, action)` 하나 |
| 상태 변경 방식 | 객체 필드를 **제자리에서 수정** | **새 state** 를 만듦 (옛 state 보존) |
| 입력 전달 | 매 스텝 `input` 테이블 (누르고 있는 키) | 눌린 **순간**을 Action 으로 |
| 시간 | 고정 스텝 루프(`acc`) | `tick` Action |
| View | 매 프레임 Model 을 읽음(Pull) | 매 프레임 `getState()` 를 읽음(Pull) — **같다** |
| "무슨 일이 있었나" | 남지 않음 → 이번 주에 기록기를 덧붙임 | Dispatcher 에서 **저절로** 남음 |

> 💡 Flux 는 MVC 를 버리는 것이 아니다. View 가 상태를 읽어 그리는 건 똑같다. 바뀐 건 **"쓰기" 쪽**: 쓰는 길을 하나로 좁히고, 쓰기를 데이터(Action)로 만든 것이다.

---

## 2. 설계 — 계약 읽기 (0.5h)

### 2-1. Action 계약 (`game/actions.lua`)

```lua
{ type = "restart", seed = 정수 }                  -- 새 판 (시드도 Action 에 담는다!)
{ type = "turn",    dir = "up"|"down"|"left"|"right" }
{ type = "tick" }
```

- `restart` 가 **시드를 들고 온다**. 시드를 리듀서가 `os.time` 으로 정하면 기록을 재생해도 다른 판이 나온다. 비결정 요소(시각)는 **조립부(`main.lua`)** 에서 한 번만 정하고 Action 으로 들여보낸다(5주차 `ctx.seed` 와 같은 생각).
- `actions.validate` 가 계약을 검사한다. 잘못된 Action 은 Dispatcher 에서 **에러**, 기록도 state 도 그대로.

### 2-2. Dispatcher 규칙

1. 검증 실패 → 에러 (조용히 무시하지 않는다)
2. **dispatch 도중 dispatch 금지** → 에러. 처리 순서가 꼬이는 것을 막는 Flux 의 핵심 규칙
3. Store 가 에러를 내도 `dispatching` 플래그가 풀린다(`pcall`) → 다음 dispatch 가 영원히 막히지 않는다

### 2-3. 조립은 `App.lua` — love 를 모른다

```text
main.lua (love 를 아는 유일한 파일) ──▶ App.lua (조립: Store·Dispatcher·Log·Controller·View)
                                          ▲
                        tests/flux_test.lua 가 똑같이 만든다
```

4주차 `integration_test` 는 `main.lua` 의 루프를 **흉내** 냈다. 흉내와 진짜가 다르면 테스트는 거짓말을 한다. 이번에는 `main.lua` 가 쓰는 **바로 그 `App`** 을 테스트가 돌린다.

### 2-4. 계층 규칙 (`layer_check.lua`)

| 폴더 | 금지 | 이유 |
|------|------|------|
| `game/` | `print`·`io`·`love`, `os.time`·`math.random`, Store·Dispatcher require | 순수·결정적 규칙. 저장소를 모른다 |
| `flux/` | `love` | 범용 부품 |
| `views/` | `love`, `dispatch` | View 는 읽기만 |
| `controllers/` | `love`, `state.x = …` 직접 대입 | 상태는 Action 으로만 |
| `App.lua` | `love` | 테스트가 돌릴 수 있게 |

겔러그(`galaga_replay`·`starter_galaga`)는 5주차 규칙(씬은 love 금지·씬끼리 require 금지 등)에 **`models/` 의 `os.time`·`math.random` 금지**를 더해 같은 스크립트로 검사한다(`luajit layer_check.lua galaga_replay`). 리플레이가 생기면서 Model 안의 숨은 난수는 "언젠가 깨질 수 있다"가 아니라 **바로 깨지는** 버그가 됐다.

> ⚠️ 문자열 검사는 **근사치**다. `local st = state; st["score"] = 0` 은 못 잡는다. 그래서 `flux_test` 에 **실행 중 검사**("어떤 키를 눌러도 이전 state 테이블은 그대로")를 따로 두었다. 정적 검사 + 실행 검사 둘 다 있어야 한다.

---

## 3. [실습 1] 순수 리듀서 (2.0h)

`examples/starter/` 는 완성본(`snake_flux`)에서 다음만 비웠다.

| 파일 | 비운 것 | 검사 |
|------|--------|------|
| `game/snakeReducer.lua` | `turn`, `tick` | `reducer_test` |
| `flux/Dispatcher.lua` | `dispatch` 안의 tap·store 전달 루프 | `flux_test` |
| `flux/ActionLog.lua` | `record`(복사), `replay` | `flux_test` |

```sh
cd lua_tuto/mvc/week06/examples/tests
luajit layer_check.lua starter     # 항상 OK
luajit reducer_test.lua starter    # 처음: 통과 11 / 실패 7
luajit flux_test.lua starter       # 처음: 통과 2 / 실패 16
```

> 💡 처음부터 11개가 통과하는 이유: 빈 `turn`·`tick` 은 `return state` 라서 "dead 이후 아무것도 안 바뀜", "순수성", "반대 방향 무시", "벽 바로 앞 칸에서는 살아 있음" 같은 **"안 바뀌어야 / 안 죽어야 한다"** 테스트는 저절로 통과한다(`restart` 는 비우지 않았다). 4주차에서 본 것과 같다 — **빈 코드가 통과하는 테스트는 그 혼자서는 아무것도 증명하지 않는다.** 실패하던 7개가 모두 통과해야 의미가 있다. "벽 바로 앞 칸" 테스트는 "벽이면 dead" 테스트와 **짝**일 때만 off-by-one 을 잡는다.

### 3-1. `turn` (20분)
- 죽었음 / 현재 방향의 반대 / 이미 같은 `nextDir` → **같은 테이블** 반환
- 그 외 → 복사 + `nextDir` 만 변경
- 왜 `dir` 이 아니라 `nextDir` 인가? 한 tick 안에 ↑ → ← 를 빠르게 누르면, `dir` 기준으로 반대 검사를 해야 "제자리 역주행 사망"이 안 생긴다(`reducer_test` 가 검사).

### 3-2. `tick` (1h 30m)
1. 죽었으면 그대로
2. 복사, `dir = nextDir`, `ticks + 1`
3. 새 머리 좌표, 먹는가?
4. 벽·몸 충돌 → `dead`. **먹지 않을 때 꼬리 칸은 충돌이 아니다**(같은 tick 에 비켜남) → 검사 범위 `#body - 1`
5. 새 `snake` 배열 = 새 머리 + 기존 칸들(공유)
6. 먹었으면 점수 +1, `placeFood(..., state.rng)` → 새 먹이와 **새 rng** 를 둘 다 받는다

> ⚠️ 가장 흔한 실수: `table.insert(state.snake, 1, head)` — 받은 배열을 고친다. 순수성 테스트가 바로 잡는다.

---

## 4. [실습 2] Dispatcher 와 ActionLog (1.0h)

### 4-1. `Dispatcher:dispatch`
검증·중첩 검사·`pcall` 은 이미 있다. 비운 것은 가운데 두 루프: **모든 tap 에 action → 모든 store 에 `handle(action)`**. 순서가 중요하다: tap(기록)이 먼저여야 Store(리듀서)가 에러를 내더라도 그 Action 이 기록에 남는다 → 기록을 재생하면 **같은 자리에서 같은 에러가 재현**된다(버그 제보에 기록만 첨부하면 된다). `flux_test` "Store 가 에러를 내도 그 Action 은 이미 기록돼 있다"가 이 순서를 고정한다.

### 4-2. `ActionLog:record` — 왜 복사하나
```lua
local reused = A.restart(5); d:dispatch(reused)
reused.seed = 999   -- 보낸 쪽이 테이블을 재사용
-- 복사하지 않으면 기록의 seed 도 999 가 된다
```
"보낸 쪽이 테이블을 다시 쓰지 않겠지"라는 가정은 4주차 `InputController:read()` 에서 이미 깨졌다. **기록기는 받은 것을 믿지 않고 값을 복사한다.**

### 4-3. `ActionLog:replay(reduce, initial, n)`
`initial` 에서 시작해 `entries[1..n]` 을 차례로 `reduce`. 이게 **시간 여행** 전부다. n 을 바꾸면 그 시점의 state 가 나온다.

### 4-4. 실행해 보기 (Snake)
- 방향키/WASD 로 조작, 죽으면 **V** → 방금 판이 처음부터 재생, **Esc** → 실시간 화면
- **R** → 새 시드로 새 판(`restart` Action)
- 리플레이는 **별도 Store** 에서 돈다. 실시간 Store 는 건드리지 않는다(`flux_test` 가 확인).

---

## 5. [실습 3] 겔러그에 리플레이 붙이기 (1.5h)

### 5-1. 무엇을 고쳤나 — Model 은 0줄

5주차 `galaga_states` 를 복사해 `galaga_replay` 를 만들었다. 실측:

| 구분 | 파일 | 변경 |
|------|------|------|
| 새 파일 | `controllers/InputRecorder.lua` | 49줄 |
| 새 파일 | `scenes/ReplayScene.lua` | 61줄 |
| 새 파일 | `views/ReplayView.lua` | 17줄 |
| 수정 | `scenes/PlayScene.lua` | 기능 4줄 (시드 보관, 기록기 생성, `record(input)`, Result 에 넘기기) |
| 수정 | `scenes/ResultScene.lua` | V 키 → Replay |
| 수정 | `main.lua` | `ctx.scenes` 에 `Replay` **1줄** |
| 수정 | `views/ResultView.lua` | V 안내 문구 |
| **수정** | **`models/` 전체** | **0줄** (`diff` 로 확인) |

> 💡 Model 을 안 고치고 리플레이가 붙은 이유는 3~5주차에 이미 해 둔 세 가지다: **시드 주입**(3주차), **고정 스텝 + 스텝마다 input 하나**(3~4주차), **씬 레지스트리 `ctx.scenes`**(5주차). 이번 주에 한 일은 그 위에 "기록"을 얹은 것뿐이다.

### 5-2. 기록 = 시드 + 스텝마다 입력 하나

```lua
-- PlayScene:update (고정 스텝 루프 안)
local input = self.controller:read()
self.recording:record(input)        -- Model 에 "실제로 넣은" 입력을
self.game:update(FIXED_DT, input)
```

- **프레임마다**가 아니라 **스텝마다**다. 20fps 면 한 프레임에 3스텝 → 기록 3줄. 프레임마다 기록하면 재생 시 스텝 수가 안 맞는다(`replay_test` 첫 테스트가 잡는다 — 확인함).
- 저장 형식: 첫 줄 `seed 42`, 이후 스텝당 3글자(`L10` = 왼쪽·발사·미사일 없음).

### 5-3. ⚠️ 재사용 테이블 함정

`InputController:read()` 는 매번 **같은 테이블**을 돌려준다(4주차에 성능 때문에 그렇게 만들었다). 그대로 `steps[#steps+1] = input` 하면 모든 칸이 **같은 테이블**을 가리키고, 판이 끝나면 전부 "마지막 입력"이 된다. 화면에는 아무 이상이 없다가 **리플레이에서만** 엉뚱하게 움직인다 — 원인과 증상이 멀리 떨어진 전형적인 버그다.

`replay_test` "기록은 입력의 복사본이다"는 기록에 왼쪽·정지·오른쪽이 **모두** 있는지 본다. 앨리어싱이면 한 값만 남아 실패한다(확인함).

### 5-4. `ReplayScene:update` (starter 에서 비운 곳)

`PlayScene` 의 고정 스텝 루프와 같은데, 입력원이 키보드가 아니라 `recording.steps[cursor]` 다. 그리고:
- `acc` 에 `dt * speed` 를 더한다(Space 로 1배속/4배속)
- 기록이 끝나면(`done()`) 더 진행하지 않는다

```sh
luajit replay_test.lua starter_galaga   # 처음: 통과 1 / 실패 8
```

### 5-5. 배속을 바꿔도 같은 이유
4배속 = 프레임당 스텝 **수**만 늘어난다. 스텝 하나하나의 `dt`(1/60)와 입력은 그대로 → 같은 판. 반대로 "4배속이니 `dt` 를 4/60 으로" 했다면 Model 이 다른 계산을 하므로 **다른 판**이 된다.

---

## 6. ⚖️ 리플레이가 해결하지 못하는 것 — `[한계, 그대로]`

이번 주 테스트에는 이름이 `[한계, 그대로]` 로 시작하는 것이 둘 있다. **통과한다 = 한계가 여전히 있다**는 뜻이다.

| 테스트 | 무엇을 보이나 |
|--------|--------------|
| `flux_test` `[한계, 그대로]` | Snake 에서 0.46초에 ↑ 를 누르면 60fps 는 0.48초 tick 에, 20fps 는 0.60초 tick 에 꺾는다 → 머리 위치가 다르다 |
| `replay_test` `[한계, 그대로]` | 겔러그에서 같은 "시각 기반" 키 조작이라도 60fps 와 20fps 의 실시간 결과가 다르다 |

이유는 4주차와 같다: 키는 **프레임 단위로만** 읽히고, 그 프레임이 어느 tick/스텝 앞에 오느냐가 fps 에 따라 다르다. **기록은 이 차이를 없애지 않는다.** 기록이 보장하는 것은 하나다:

> **"이미 일어난 그 판"** 은, 몇 fps·몇 배속으로 다시 돌려도 똑같다.

그리고 대조 테스트가 하나 더 있다:

| 입력 종류 | fps 가 달라지면 |
|----------|----------------|
| 사람처럼 **시각**에 반응 ("0.46초에 ↑") | 결과가 달라질 수 있다 (`[한계]`) |
| **상태**에 반응 ("먹이가 위에 있으면 ↑", 봇) | 결과가 같다. 기록에 같은 방향 `turn` 이 더 많이 쌓일 뿐 |

→ 결정성은 "같은 **Action 열**이면 같은 결과"다. 사람의 손은 Action 열을 fps 에 따라 다르게 만든다. 네트워크 동기화(lockstep)에서 입력을 "몇 번째 스텝의 입력"으로 맞추는 이유가 여기 있다(이번 과정 범위 밖).

> 📏 실측: 봇이 20초 동안 Snake 를 하면 기록이 **1367개**(tick 166, turn 1200, restart 1), 약 12.6KB. 봇이 매 프레임 키를 누르기 때문에 대부분이 **변화 없는 turn** 이다. 결과에는 영향이 없지만 기록은 커진다. 사람이 하면 turn 은 훨씬 적다. 겔러그 기록은 입력과 무관하게 **스텝당 1줄**(20초 = 1200줄, 약 4.8KB)이다.

---

## 7. 비교 — "고쳐서" vs "처음부터" (1.5h 중 0.5h)

| | 겔러그 (고쳐서: 2→5주차 + 이번 주) | Snake (처음부터 Flux) |
|---|---|---|
| 리플레이 비용 | 새 파일 3개(127줄) + 기존 4파일 소폭 수정. **3~5주 구조 작업이 선행 조건** | `ActionLog` 는 원래 있음. 리플레이 = 별도 Store 에 기록 다시 dispatch |
| 무엇을 기록하나 | 스텝마다 **입력** (원인의 일부) | **Action** 전부 (원인 그 자체) |
| 시간 여행(n번째 시점) | 처음부터 n스텝 다시 돌려야 함 (옛 상태가 없음 — Model 이 제자리 수정) | `replay(reduce, nil, n)`, 또는 옛 state 를 보관만 하면 끝 |
| 상태 변경 추적 | 디버거로 메서드 따라가기 | Dispatcher 에 tap 하나 → 모든 변경의 원인 목록 |
| 비용 | 객체 제자리 수정 — 할당 적음 | 매 Action 마다 새 테이블 (Snake 규모에선 무시 가능, 7주차 프로파일링에서 확인) |
| 언제 맞나 | 엔티티 수백 개가 매 프레임 움직이는 게임 | 턴·격자·카드·퍼즐처럼 **상태 변경이 띄엄띄엄**인 게임, UI 상태 |

토론 질문 (메모로 남긴다):
1. 2주차 모놀리식 겔러그에 리플레이를 붙이려면 무엇부터 고쳐야 하나? (힌트: `math.random`, raw `dt`)
2. 겔러그 전체를 리듀서로 바꾸면 무엇을 얻고 무엇을 잃나?
3. 우리 겔러그의 "Action" 은 무엇인가? (힌트: 스텝마다의 `input` + 시드)

---

## 8. 테스트 지도

| 파일 | 개수 | 무엇을 지키나 |
|------|------|--------------|
| `layer_check.lua` | — | 계층 규칙(2-4절). 앱 이름으로 Snake·겔러그 모두 |
| `reducer_test.lua` | 18 | 이동·회전·**네 벽 + 경계 한 칸**·몸 충돌·먹기·판 가득 참·`restart` 시드·**순수성**·변화 없으면 같은 테이블 |
| `flux_test.lua` | 18 | Dispatcher 검증·중첩 금지·**tap 이 Store 보다 먼저**, 구독, 기록 복사·직렬화·재계산·시간 여행, 재생 속도 무관, `[한계]` vs 봇, **진짜 App** 6개(dt 상한 포함) |
| `replay_test.lua` | 9 | 스텝당 기록, 복사, 3가지 fps 재현, `[한계]`, 배속 재생, 직렬화, 씬 흐름 |

```sh
cd lua_tuto/mvc/week06/examples/tests
luajit layer_check.lua      && luajit reducer_test.lua && luajit flux_test.lua && luajit replay_test.lua
luajit layer_check.lua galaga_replay
# starter 는 인자로: reducer_test.lua starter / flux_test.lua starter / replay_test.lua starter_galaga
```

### 8-1. 테스트가 정말 잡는가 (일부러 망가뜨려 확인함)

| 망가뜨린 것 | 잡은 테스트 |
|------------|------------|
| 리듀서가 받은 state 를 고침 (`state.nextDir = dir`) | `reducer_test` 순수성 |
| `ActionLog:record` 가 복사하지 않음 | `flux_test` 기록 복사 |
| View 에서 dispatch | `layer_check` |
| Controller 에서 `state.score = 0` | `layer_check` + `flux_test` 실행 중 검사 |
| 왼·위·아래 벽 검사 하나 삭제 / 오른벽 `>` → `>=` | `reducer_test` 네 벽·경계 한 칸 |
| `restart` 가 Action 의 시드를 무시 | `reducer_test` restart 시드 |
| Dispatcher 가 tap 을 빼먹음 | `flux_test` 9개 |
| Dispatcher 가 Store 먼저, tap 나중 | `flux_test` "에러를 내도 이미 기록" (초판에는 못 잡았음) |
| 기록기에 게임과 다른 시드(`ctx.seed()` 를 두 번 호출) | `replay_test` 7개 |
| 겔러그 씬에서 `love` / Model 에서 `math.random` | `layer_check galaga_replay` |
| `InputRecorder` 가 입력 테이블을 그대로 저장 | `replay_test` 복사 |
| 스텝마다가 아니라 프레임마다 기록 | `replay_test` 스텝당 기록 |

### 8-2. ⚠️ 이번 주에 고친 테스트 러너 버그 (3~6주차 공통)

테스트 러너가 `res ~= false` 를 "통과"로 봤다. 그래서 테스트 함수가 **아무것도 반환하지 않으면(`nil`) 통과**였다. 실수로 `return` 을 빠뜨린 테스트는 무엇을 검사하든 항상 초록불이다. `res == true` 로 고치고 3~6주차 전체를 다시 돌렸다(결과 변화 없음 — 숨어 있던 버그였다). 그 뒤 "기록 복사" 테스트는 앨리어싱 변경을 넣으면 제대로 실패한다.

> 교훈: **테스트를 테스트하라.** 일부러 망가뜨렸을 때 빨간불이 들어오는지 확인하지 않은 테스트는 믿을 수 없다.

### 8-3. 재검토에서 찾은 빈틈 (고침)

초판 테스트는 전부 통과했지만, 일부러 망가뜨려 보니 **아무것도 못 잡는 변경**이 있었다.

| 빈틈 | 왜 못 잡았나 | 고친 것 |
|------|-----------|--------|
| 벽 3개 검사를 지워도 통과 | 벽 테스트가 **오른쪽 벽 하나**뿐. 봇은 벽을 피해 다니므로 통합 테스트도 못 잡음 | 네 벽 + "끝 칸은 살아 있음" 짝 테스트 |
| `restart` 가 시드를 무시해도 통과 | 실시간과 리플레이가 **같은 리듀서**를 쓰므로 둘 다 틀려도 "같다" | `reduce(restart(7))` 을 `initial(7)` 과 직접 비교 |
| 겔러그 기록 시드가 달라도 통과 | 가짜 `ctx.seed` 가 **항상 같은 값** → 두 번 읽어도 같음. 실제 `newSeed` 는 부를 때마다 다르다 | 가짜도 부를 때마다 다른 값 |
| 겔러그 계층 규칙 미검사 | 6주차 `layer_check` 가 Snake 전용이었음 | 겔러그 규칙 추가 |
| tap→Store 순서를 바꿔도 통과 | 문서는 "순서가 중요"라고 했지만 테스트가 없었음 | 리듀서 에러 시에도 기록이 남는지 검사 |

> 교훈 두 가지. ① **"실시간 = 리플레이"는 일관성만 보인다.** 규칙 자체가 틀려도 양쪽이 똑같이 틀리면 통과한다. 규칙은 규칙대로 단위 테스트가 필요하다. ② **가짜(fake)는 진짜의 성질을 닮아야 한다.** 항상 같은 값을 주는 가짜는 "두 번 읽기" 버그를 숨긴다.

---

## 9. ⚠️ 흔한 실수

1. 리듀서에서 `table.insert(state.snake, ...)` — 받은 배열 수정
2. `placeFood` 가 돌려준 새 rng 를 버림 → 다음 먹이도 **같은 난수**로 뽑힌다. 리플레이는 맞으니 눈치채기 어렵다. `reducer_test` "난수 상태가 바뀐다"가 잡는다
3. 리듀서에서 `math.random` / `os.time` → 리플레이 불일치
4. `restart` 시드를 리듀서가 정함 → 재생하면 다른 판
5. 기록기가 입력 테이블을 그대로 저장 (5-3절)
6. 프레임마다 기록 (5-2절)
7. 4배속을 `dt * 4` 로 구현 (5-5절)
8. 리플레이를 실시간 Store 에 재생 → 실시간 판이 덮어써짐
9. dispatch 중 Store 구독자에서 또 dispatch → 에러(의도된 규칙)

---

## 10. 개념 퀴즈

1. Flux 에서 상태를 바꾸는 방법은 몇 가지인가? 그것이 하나라서 얻는 것 두 가지는?
2. 리듀서가 받은 state 를 고치면 시간 여행이 왜 깨지는가? 테스트로는 어떻게 드러나나?
3. 얕은 복사만 하는데 `snake` 의 칸 테이블을 여러 state 가 공유해도 안전한 이유는?
4. `tick` 을 Action 으로 만들면 재생 속도와 결과가 무관해지는 이유는?
5. 겔러그 기록을 "프레임마다" 하면 무엇이 틀어지나? 20fps 에서 구체적으로.
6. `InputRecorder` 에서 복사를 빼먹으면 게임 중에는 왜 아무 이상이 없나?
7. 리플레이가 있는데도 `[한계, 그대로]` 테스트가 계속 통과하는 이유를 한 문장으로.
8. 봇 입력은 fps 가 달라도 결과가 같은데 사람 입력은 아닌 이유는?
9. `layer_check` 만으로 "Controller 는 state 를 직접 바꾸지 않는다"를 보장할 수 없는 이유와 보완책은?
10. 겔러그 Model 을 한 줄도 안 고치고 리플레이를 붙일 수 있었던 3~5주차의 선행 작업 세 가지는?

---

## 11. 과제 & 체크리스트

### 과제
- [ ] `starter` 3파일, `starter_galaga` 2파일 완성 → 테스트 전부 통과
- [ ] 실행 확인 1회씩: Snake 한 판 → V → 끝까지 → Esc / 겔러그 한 판 → V → Space(4배속) → 끝까지 → Esc
- [ ] **비교 메모** (7절 표 + 토론 질문 3개에 대한 내 답, A4 반 장)
- [ ] (선택) Snake 에 `pause` Action 추가 — 어떤 파일을 몇 줄 고쳤는지 기록
- [ ] (선택) Snake 리플레이에 "한 Action 씩 앞/뒤로" 키 추가 (`replay(reduce, nil, n)` 활용)

### 체크리스트
- [ ] `layer_check` OK (Snake·starter·galaga_replay·starter_galaga)
- [ ] `reducer_test` 18/18, `flux_test` 18/18, `replay_test` 9/9
- [ ] `[한계, 그대로]` 두 개가 **왜 통과하는지** 말할 수 있다
- [ ] 일부러 리듀서를 비순수하게 바꿔 보고 어떤 테스트가 실패하는지 확인했다
- [ ] 실행 확인은 각 1회만 (검증은 테스트가 한다)

---

## 📁 예제 파일 안내

```text
week06/examples/
├── snake_flux/              완성본 (Snake, Flux)
│   ├── main.lua             love 를 아는 유일한 파일 (시드·키·그리기 연결)
│   ├── App.lua              조립 — 테스트도 이것을 그대로 돌린다
│   ├── core/class.lua
│   ├── flux/                Store · Dispatcher · ActionLog   (게임을 모르는 범용 부품)
│   ├── game/                prng · actions · snakeReducer    (순수 규칙)
│   ├── controllers/         InputController(키→Action) · Ticker(시간→Action) · ReplayPlayer(기록→Action)
│   └── views/SnakeView.lua
├── galaga_replay/           완성본 (5주차 galaga_states + 리플레이, models/ 는 5주차와 동일)
│   ├── controllers/InputRecorder.lua
│   ├── scenes/ReplayScene.lua
│   └── views/ReplayView.lua
├── starter/                 Snake 실습용 (turn·tick, dispatch 루프, record·replay 비움)
├── starter_galaga/          겔러그 실습용 (InputRecorder:record, ReplayScene:update 비움)
└── tests/                   helper · layer_check · reducer_test · flux_test · replay_test
```

실행 (저장소 루트에서, 환경에 맞는 `love` 사용):

```sh
love lua_tuto/mvc/week06/examples/snake_flux
love lua_tuto/mvc/week06/examples/galaga_replay
```

| 앱 | 키 |
|----|----|
| Snake | 방향키/WASD 이동, R 새 판, 죽은 뒤 V 리플레이, 리플레이 중 Esc/V 복귀, Esc 종료 |
| 겔러그 | 5주차와 같음 + 결과 화면에서 V 리플레이, 리플레이 중 Space 1/4배속, Esc/Enter 타이틀 |
