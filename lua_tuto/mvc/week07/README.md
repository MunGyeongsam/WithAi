# 7주차 — [최종] 통합 템플릿 · 프로파일링 · 기능 추가 · ADR · 리뷰

> **소요:** 8시간
> **선행:** 3~6주차 전부 (특히 6주차 `galaga_replay`: 씬 + 진행 단계 + 입력 기록·리플레이)
> **이번 주 한 문장:** 6주 동안 만든 구조를 **템플릿 하나로 고정**하고, 그 위에서 **측정 → 최적화 → 기능 추가**를 테스트의 보호 아래 해 본 뒤, 내가 내린 구조 결정 하나를 **ADR** 로 남긴다.

---

## 🔗 지난주까지 남긴 숙제 (이번 주에 회수한다)

| 남긴 것 | 어디서 | 이번 주 결과 |
|--------|--------|-------------|
| 테스트가 주차마다 흩어져 있음 (4·5·6주차 tests/) | 4~6주차 | 템플릿 하나에 **10개 묶음**, `run_all.lua` 한 줄로 실행 |
| "전역 사용"을 눈으로만 확인 | 매 주 체크리스트 | `globals_check.lua` — 바이트코드(정적) + 잠근 `_G`(실행) |
| 리플레이를 저장하면 규칙이 바뀐 뒤 어떻게 되나? | 6주차 6절 | 규칙 버전 + 거부. ADR-000 예시 |
| "새 객체를 매 스텝 만들면 느리지 않나요?" | 6주차 강사노트 | **실측**: 시간은 프레임 예산의 0.2% 미만. 할당은 미사일이 90% → 고침 |
| AI 측정 T1→T2→T3 | 2·4주차 | **T4** (같은 프롬프트 P, 최종 템플릿) |

---

## 🎯 학습 목표

1. 템플릿의 **폴더·인터페이스 계약**을 표로 설명하고, 새 기능을 어느 파일에 넣을지 바로 말할 수 있다.
2. **측정하고 나서** 최적화한다: 벤치 → 프로파일러 → 원인 → 고침 → 다시 측정 → **동작 불변 증명**.
3. 테스트를 **명세**로 삼아 AI 와 기능을 추가하고, 번짐을 수치로 비교한다(T4).
4. **규칙 버전**이 무엇을 지키는지, 왜 최적화는 기능 추가 **전에** 해야 하는지 설명한다.
5. 구조 결정 하나를 **ADR** 로 쓴다(선택지·감수하는 것·검증 포함).
6. 자기 코드를 체크리스트로 리뷰하고, 루브릭으로 2→4→5→7주차 변화를 근거와 함께 채점한다.

---

## ⏱ 8시간 타임테이블

| 시간 | 블록 | 내용 | 산출물 |
|------|------|------|--------|
| 0.5h | 개관 | 6주 지도, 오늘 순서가 **프로파일링 → 기능**인 이유(4절) | — |
| 1.0h | 템플릿 | 폴더·인터페이스 계약표, `run_all`, `globals_check`, 템플릿에 새로 들어간 것 | 계약표 |
| 1.5h | 프로파일링 | `bench` → `-jp` → 원인 → 최적화 → `perf_test` + `equivalence_test` → F3 실기 확인 | 전후 수치 |
| 2.0h | 기능 (AI) | `combo_test` 를 명세로 AI 와 콤보 구현, 규칙 버전 올리기, 번짐 실측, T4 | 동작하는 콤보 |
| 1.5h | ADR | 템플릿 + 예시 읽기 → 내 `ADR-001.md` | ADR-001 |
| 1.5h | 리뷰·회고 | 체크리스트 리뷰, 루브릭 최종 채점, 과정 퀴즈 | 루브릭·회고 |

> 계획서 초안은 "템플릿 2.0h → 기능 2.0h → 프로파일링 1.5h" 순서였다. **프로파일링을 기능 앞으로** 옮겼다. 이유는 4-5절.

---

## 1. 템플릿 — 무엇이 고정되었나 (1.0h)

`examples/starter/` 가 **최종 템플릿**이다. 6주차 `galaga_replay` 에 다음만 더했다.

| 추가 | 파일 | 왜 |
|------|------|----|
| 규칙 버전 `GameModel.RULES_VERSION = 1` | `models/GameModel.lua` | 저장된 리플레이 호환성 (ADR-000) |
| 기록 헤더 `version N`, 깨진 파일 거부 | `controllers/InputRecorder.lua` | 파일은 시스템 경계 — 믿지 않고 검사 |
| 버전이 다르면 재생 거부 | `scenes/ReplayScene.lua`, `views/ReplayView.lua` | 조용히 틀린 재생보다 거부 |
| 결과 화면 **S** 저장, 타이틀 **L** 불러오기 | `ResultScene`·`TitleScene`·뷰 | 기록이 실행을 넘어 살아남는다 |
| `ctx.storage = { write, read }` | `main.lua` | 씬은 파일 시스템을 모른다(테스트는 표로 대신) |
| **F3** 성능 표시 (FPS·update·draw ms·Lua 메모리) | `main.lua` | 측정 코드는 love 를 아는 곳에만 |

`models/` 의 규칙 코드는 6주차와 **매 스텝 같다**(`equivalence_test` 8개).

### 1-1. 폴더·인터페이스 계약 (이 표가 템플릿이다)

| 폴더 | 아는 것 | 모르는 것 | 대표 인터페이스 |
|------|--------|----------|----------------|
| `models/` | 자기 상태, 규칙, 주입된 시드 | love, 파일, 시각(`os.time`), `math.random`, View·Controller | `GameModel({seed})`, `:update(dt, input)`, `:drainEvents()`, `RULES_VERSION` |
| `views/` | 주입된 `gfx`, Model(읽기만) | love, Controller | `View.draw(gfx, ...)`, `GameView:onEvent(ev)` |
| `controllers/` | 주입된 `isDown` | love, View, Scene | `InputController:read() → {move, fire, missile}` (재사용 테이블!), `InputRecorder` |
| `scenes/` | `ctx`, M·V·C 조립 | love, 다른 씬(`ctx.scenes` 로만) | `enter/exit/pause/resume/update/draw/keypressed`, `transparent` |
| `main.lua` | **love 전부** | — | `ctx = { width, height, isDown, seed, quit, storage, scenes }` |

이벤트 계약(Model → View)은 `GameModel.lua` 의 `update` 위 주석에 있다. 새 이벤트를 추가해도 모르는 View 는 무시한다(`feature_test` 가 확인).

### 1-2. 한 줄로 전부 검사

```sh
cd lua_tuto/mvc/week07/examples/tests
luajit run_all.lua            # 완성본(galaga_final)
luajit run_all.lua starter    # 템플릿 — 처음엔 perf_test·combo_test 두 묶음만 실패
```

| 묶음 | 개수 | 출신 | 지키는 것 |
|------|------|------|----------|
| `layer_check` | — | 4~6주차 | 계층 규칙(1-1 표의 "모르는 것") |
| `globals_check` | — | **7주차** | 암묵적 전역 0 (1-3절) |
| `view_test` | 9 | 4주차 | View 는 Model 을 바꾸지 않는다 등 |
| `feature_test` | 13 | 4주차 | 미사일·보스 (4주차 R 재시작 테스트는 5주차에 씬으로 옮겨져 뺐다) |
| `scene_test` | 16 | 5주차 | 씬 스택·일시정지·결과 |
| `phase_test` | 9 | 5주차 | 진행 단계 |
| `replay_test` | 14 | 6주차 + 7주차 5개 | 기록·재생·**버전·저장·불러오기** |
| `equivalence_test` | 8 (v1) / 1 (v2) | 5주차 → 7주차 | **규칙 버전 약속** (4-4절) |
| `perf_test` | 1 | **7주차** | 할당 회귀 (2절) |
| `combo_test` | 8 | **7주차** | 콤보 명세 (3절) |

### 1-3. `globals_check` — 두 겹인 이유

| 겹 | 방법 | 잡는 것 | 못 잡는 것 |
|----|------|--------|-----------|
| 정적 | `luajit -bl 파일` 의 바이트코드에서 `GSET`(전역 쓰기), 표준에 없는 이름의 `GGET`(오타·`love`) | **실행되지 않는 줄**까지 | `_G["x"] = 1` 같은 동적 접근 |
| 실행 | `_G` 에 메타테이블을 걸어 새 전역 쓰기·없는 전역 읽기를 즉시 에러로 만들고, 타이틀→플레이→결과→저장→리플레이→불러오기 한 바퀴 | 동적 접근 | 실행되지 않은 경로 |

일부러 망가뜨려 확인함: 안 도는 분기의 `leaked = 1`, 안 도는 분기의 `print(scroe)`, 실행 중 `_G["lastInput"] = …`, 씬 안의 `love.event.quit()` → 모두 잡힘. 정적 겹은 LuaJIT 에서만 돈다(`lua5.1` 로 실행하면 안내만 하고 실행 겹만 한다).

---

## 2. [실습] 측정하고 나서 최적화한다 (1.5h)

### 2-1. 벤치마크

```sh
luajit bench.lua starter          # 10분 분량(36000 스텝) 자동 조종
luajit -joff bench.lua starter    # JIT 끔: 할당 숫자가 실행마다 같아진다
```

`bench.lua` 는 GC 를 멈추고 구간별 **시간(µs)** 과 **할당(바이트)** 을 잰다. 그리기는 아무것도 안 하는 `gfx` 로 하므로 실제 GPU 비용은 빠진다(2-4절).

작성자 기계(macOS, LuaJIT 2.1) 실측, 스텝당:

| 구간 | 시간 (JIT 켬) | 시간 (JIT 끔) | 할당 (JIT 끔) |
|------|--------------|--------------|--------------|
| `Model:update` | 약 4~7 µs | 약 23 µs | **1244 B** |
| `InputRecorder:record` | 약 0.5 µs | 약 0.6 µs | 171 B |
| drain + View 이벤트·연출 | 약 0.7~1 µs | 약 1.3 µs | 137 B |
| `View:draw` (가짜 gfx) | 약 1~1.5 µs | 약 3.6 µs | 0.3 B |
| **합계 / 프레임 예산 16667µs** | **0.04~0.06%** | 0.17% | |

> ⚠️ **첫 번째 결론: 이 게임은 느리지 않다.** 시간만 보면 최적화할 이유가 없다. 측정 없이 "Flux 는 매번 새 테이블이라 느리다", "객체가 많으면 느리다"고 짐작했다면 틀렸다.
> 시간 숫자는 실행마다 흔들린다(JIT 켬 기준 4µs~7µs). **같은 기계에서 전후 비교에만** 쓴다.

### 2-2. 할당은 어디서? — 하나씩 꺼 본다

`Model:update` 할당 1244 B/스텝이 눈에 띈다(초당 약 75KB → GC 가 자주 돈다). 미사일을 끄고 다시 재면:

| 조건 (JIT 끔) | Model 할당/스텝 |
|--------------|----------------|
| 미사일 켬 | 1244 B |
| 미사일 끔 | 94 B |

→ **약 92%가 유도 미사일**에서 나온다. `luajit -jp=f bench.lua` 로 함수별 시간도 볼 수 있다(LuaJIT 내장 샘플링 프로파일러). 다만 이 게임에선 `bench.lua` 자신의 측정 함수가 70%를 차지해 큰 도움이 안 된다 — **프로파일러 결과도 해석해야 한다**는 사례다.

### 2-3. 원인과 고침

```lua
-- 템플릿: 미사일이 있으면 스텝마다 목표 목록을 새로 만든다 (적 32기면 테이블 33개)
targets = {}
for _, e in ipairs(self.enemies) do
  if e.alive then targets[#targets + 1] = { x = e:centerX(), y = e:centerY() } end
end
local tx, ty = homing.nearest(targets, b.x, b.y)
```

고친 것(`galaga_final`): 목록 없이 바로 가장 가까운 목표를 고르는 `_nearestTarget(x, y)`. **거리식(`dx*dx+dy*dy`)과 순서(적 → 보스, 더 작을 때만 교체)를 `homing.nearest` 와 똑같이** 맞췄다.

| | 전 | 후 |
|---|---|---|
| Model 할당/스텝 (JIT 끔) | 1244 B | **104 B** |
| 미사일 켬/끔 비율 (`perf_test`) | 9.47 | **1.07** |
| Model 시간/스텝 (JIT 끔) | 약 23 µs | 약 23 µs (차이 없음) |
| 6주차와 동작 | — | **매 스텝 동일** (`equivalence_test` 8개) |

> 정직한 해석: 시간은 거의 그대로다. 얻은 것은 **GC 압박 감소**(초당 75KB → 6KB)다. 지금 PC 에선 체감되지 않지만, 모바일·적 수백 기·긴 세션에서는 GC 멈춤(끊김)으로 나타난다. "최적화했다"가 아니라 **"무엇을 얼마나 줄였고, 그게 언제 의미가 있는지"** 를 쓴다.

### 2-4. 실기 확인 — F3

게임을 실행하고 **F3** 을 누르면 FPS·update ms·draw ms·Lua 메모리가 보인다. 측정은 `main.lua` 에만 있다(씬·Model 에 측정 코드를 섞지 않는다).
- `draw ms` 는 **그리기 명령을 쌓는 시간**이다. GPU 가 실제로 그리는 시간은 화면을 내보낼 때(present) 따로 든다. 그래서 `bench` 의 가짜 gfx 수치와 F3 의 수치는 서로 다른 것을 잰다.
- Lua 메모리가 톱니 모양으로 오르내리면 GC 가 도는 것이다. 최적화 전후로 톱니의 **기울기**를 비교해 본다.

### 2-5. 왜 최적화를 기능 추가 **앞에** 하나

`equivalence_test` 는 **규칙 버전이 1 인 동안만** "6주차와 매 스텝 같다"를 검사한다. 콤보를 넣어 버전이 2 가 되면 이 그물이 사라진다(이제는 "달라야 한다"만 검사).

일부러 망가뜨려 확인함 (템플릿에 최적화를 넣으면서):
- 보스를 목표에서 빠뜨림 → **543번째 스텝**에서 달라짐, 8개 실패
- `e.alive` 검사를 빠뜨림 → **107번째 스텝**에서 달라짐, 8개 실패
- `<` 를 `<=` 로 (동률일 때 뒤의 목표) → **못 잡음.** 실수 좌표에서 거리가 정확히 같은 경우가 거의 없어 실제 동작도 같다. 테스트가 못 잡는 차이는 "관찰되지 않는 차이"일 수도 있다.

→ **리팩터링·최적화(동작 불변)와 기능 추가(동작 변경)는 섞지 않는다.** 순서를 나누고, 가능하면 커밋도 나눈다.

---

## 3. [실습] 기능 추가 — 테스트를 명세로, AI 와 함께 (2.0h)

### 3-1. 기능: 콤보

| 규칙 | 값 |
|------|----|
| 적을 격추한 뒤 `WINDOW` 초 안에 다음 적을 격추하면 콤보가 이어진다 | `WINDOW = 1.0` |
| 격추 점수 = 100 × 배율, 배율 = min(콤보 수, `MAX_MULT`) | `MAX_MULT = 4` |
| 플레이어가 맞으면 콤보가 끊긴다. 보스 피격은 콤보와 무관 | |
| 콤보 2 이상이 되는 격추마다 이벤트 `{ type="combo", count, mult }` — `enemy_destroyed` **바로 뒤** | |
| HUD 가운데 위에 `COMBO n  xm` (콤보 2 이상일 때만) | |
| 점수가 바뀌면 보스 등장 시점이 바뀐다 → **`RULES_VERSION = 2`** | |

`tests/combo_test.lua` 맨 위 주석이 위 표와 같은 **명세**다. 인터페이스(`ComboModel` 의 함수 이름 등)도 여기서 정한다.

### 3-2. AI 에게 주는 프롬프트 (예)

```text
lua_tuto/mvc/week07/examples/starter 에 "콤보" 기능을 추가해줘.
명세와 검사: tests/combo_test.lua (맨 위 주석 + 테스트). 이 테스트를 모두 통과해야 한다.
규칙: models/ 는 love·print·os.time·math.random 금지, views/ 는 gfx 로만 그린다.
새 Model 은 models/ComboModel.lua 로 만들고, GameModel·HudView 는 필요한 곳만 고쳐.
다른 파일은 고치지 마. 끝나면 tests/run_all.lua starter 가 전부 통과해야 한다.
```

- **파일 지정이 가능하다**는 것 자체가 4주차 이후 구조의 효과다(바이브 코딩 1원칙).
- AI 가 `RULES_VERSION` 을 안 올리면 `combo_test` 1개 + **`equivalence_test` 8개**가 실패한다(확인함). 메시지가 "동작을 바꿨다면 RULES_VERSION 을 올려라"라고 알려 준다.

### 3-3. 번짐 실측 (참고 구현)

| 변경 | 위치 |
|------|------|
| 새 파일 | `models/ComboModel.lua` (47줄) |
| `GameModel.lua` | require 1, 버전 1, `reset` 1, 이벤트 계약 주석 1, `tick` 1, 격추 처리 1, 피격 1 → **7곳** |
| `HudView.lua` | 1곳 |
| 씬·Controller·다른 View | **0** |

2주차 모놀리식(기능 추가 41 hunk, 전부 `main.lua`)과 4주차 MVC(25 hunk, GameModel 12)의 표에 이 줄을 이어 적는다. 콤보는 "점수 규칙"이라 GameModel 을 피할 수 없다 — **어떤 축의 변경이냐**에 따라 닿는 파일이 정해진다(5주차 "못 지운 3줄"과 같은 이야기).

### 3-4. AI 측정 T4 (2주차 1-4 이어서)

같은 프롬프트 P 를 **템플릿(starter, 콤보 전)** 의 복사본에 던진다.

> P: `"적 총알 속도를 1.5배로 하고, 플레이어가 맞으면 0.5초 무적이 되게 해줘"` (문구 그대로)

`monolith_pain.md` 측정표 **T4 행**에 수정 위치 수·오수정 수·손 수정 횟수를 적고, 이번에는 한 칸 더 적는다:
- **테스트가 알려 준 것:** `run_all` 에서 무엇이 실패했나? P 는 규칙을 바꾸므로 `equivalence_test` 가 실패해야 정상이다. AI 가 버전을 올렸나? 무적 판정이 `feature_test`·`scene_test` 의 기존 기대를 깨뜨렸나?
- 끝나면 **되돌린다**(측정이 템플릿을 바꾸지 않게).
- 학생 간 비교는 하지 않는다. 내 T1 → T2 → T3 → T4 추세만 본다.

---

## 4. 규칙 버전 — 리플레이 시대의 계약

### 4-1. 무엇이 "규칙 변경"인가

| 변경 | 같은 시드·입력의 결과 | 버전 |
|------|----------------------|------|
| 미사일 조준 최적화 (2절) | 같다 | **그대로** |
| 콤보 (점수 배율) | 다르다 (1.1초 만에 갈림) | **올린다** |
| 파티클 개수·색 (View) | Model 은 같다 | 그대로 |
| 키 배치 변경 (Controller) | 기록은 "Model 에 넣은 입력"이라 같다 | 그대로 |

### 4-2. 테스트가 지키는 약속

```text
RULES_VERSION == 1 → 6주차와 매 스텝 같아야 한다    (안 바꿨다고 했으면 정말 안 바꿨나)
RULES_VERSION  > 1 → 6주차와 어딘가 달라야 한다    (바꿨다고 했으면 정말 바꿨나)
```

두 번째 줄이 없으면 "혹시 몰라서" 버전을 올리는 습관이 생기고, 그때마다 멀쩡한 저장 리플레이가 버려진다.

### 4-3. 직접 해 보기
1. 템플릿에서 게임 한 판 → 결과 화면 **S** (저장).
2. 콤보를 넣은 버전(`galaga_final`)을 실행해 타이틀에서 **L** → `REPLAY VERSION MISMATCH recorded v1 / game v2`.
   - 두 앱은 저장 폴더가 같다(`conf.lua` 의 `t.identity`). 그래서 서로의 파일이 보인다.

---

## 5. ADR — 결정을 남긴다 (1.5h)

ADR(Architecture Decision Record): **무엇을 왜 골랐고, 무엇을 감수했는지**를 짧게 남기는 문서. 코드는 "어떻게"를 보여 주지만 "왜 다른 방법이 아닌가"는 보여 주지 못한다.

- 템플릿: [examples/adr/ADR-템플릿.md](examples/adr/ADR-템플릿.md)
- 예시: [examples/adr/ADR-000-예시-리플레이-규칙-버전.md](examples/adr/ADR-000-예시-리플레이-규칙-버전.md)

내 `ADR-001.md` 주제 (하나 고른다, 예시와 겹치지 않게):
1. 왜 Pull 갱신 MVC 를 택했나 (Observer/Push 대신) — 3·4주차
2. 왜 씬은 스택 FSM 인가 (단순 FSM / 플래그 대신) — 5주차
3. 왜 진행 단계를 Model 안의 State 로 두었나 (씬으로 두지 않고) — 5주차
4. 왜 겔러그는 Flux 로 바꾸지 않았나 (Snake 는 Flux 인데) — 6주차
5. 이벤트 큐(`drainEvents`) vs 콜백 — 3·4주차

채점 포인트: **숫자·파일명 근거**, "아무것도 안 함" 선택지, **감수하는 것**이 비어 있지 않음, 결정을 지키는 **자동 검사**가 적혀 있음.

---

## 6. 자기 코드 리뷰 체크리스트 (1.5h 중 0.5h)

| # | 항목 | 자동 검사 | 사람이 볼 것 |
|---|------|----------|-------------|
| 1 | `main.lua` 밖에 love 가 없다 | `layer_check`, `globals_check` | — |
| 2 | 암묵적 전역이 없다 | `globals_check` | 모듈 끝의 `return` 누락 |
| 3 | Model 은 결정적이다 (`os.time`·`math.random`·시각 없음) | `layer_check`, `replay_test` | 반복 순서가 `pairs` 에 의존하지 않는가 |
| 4 | View 는 Model 을 바꾸지 않는다 | `view_test`, `combo_test` HUD | draw 안에서 상태(난수·타이머)를 바꾸지 않는가 |
| 5 | 받은 테이블을 보관할 때 복사한다 | `replay_test` 복사 | Controller 가 재사용하는 테이블 |
| 6 | 동작을 바꿨으면 규칙 버전을 올렸다 | `equivalence_test` | — |
| 7 | 파일 하나 = 책임 하나 | — | 파일 이름만 보고 위치를 아는가 (루브릭 1) |
| 8 | 경계 입력(파일·사용자)을 검사한다 | `replay_test` 깨진 파일 | 에러 메시지가 원인을 말하는가 |
| 9 | 새 기능에 테스트가 있고, **일부러 망가뜨리면 실패한다** | — | 6주차 8-2·8-3 |
| 10 | 측정 없이 최적화하지 않았다 | `perf_test` | 전후 수치를 기록했는가 |

---

## 7. 루브릭 최종 채점 (1.5h 중 0.5h)

4주차 8절의 4항목을 **2·4·5·7주차** 네 번 채점하고 근거를 적는다.

| 항목 | 2주차 | 4주차 | 5주차 | 7주차 | 근거 (숫자·파일명) |
|------|------|------|------|------|-------------------|
| 가독성·유지보수 | | | | | 기능 추가 hunk·파일 분포 |
| 디버깅 | | | | | 실패 메시지가 지목하는 것 (스텝 번호, 경로) |
| 테스트 | | | | | 묶음 수·테스트 수·실행 시간 |
| AI 컨텍스트 밀도 | | | | | T1~T4 |

---

## 8. ⚠️ 흔한 실수

1. 최적화와 기능을 한 번에 → 동작이 바뀌었을 때 어느 쪽 탓인지 모른다 (2-5절)
2. 시간 숫자 하나로 결론 → 다시 재면 4µs 가 7µs 가 된다. 할당·비율·여러 번
3. 측정 함수를 프로파일러 결과에서 못 걸러냄 (`-jp` 의 `measure` 70%)
4. 콤보 점수를 View 에서 계산 → Model 은 모르는 점수, 리플레이·테스트에서 사라진다
5. `RULES_VERSION` 안 올림 / 연출만 바꾸고 올림 (4-1절)
6. 저장 파일을 그대로 믿음 → `parse` 가 nil 을 돌려줄 수 있다
7. 씬에서 `love.filesystem` 직접 호출 → `ctx.storage` 로
8. F3 의 draw ms 를 GPU 시간으로 오해 (2-4절)

---

## 9. 과정 마무리 퀴즈

1. 이 과정의 "MVC" 를 한 문장으로 정의하라. Passive View 와 무엇이 다른가?
2. 고정 타임스텝이 없었다면 6주차 리플레이는 가능했나? 무엇이 깨지나?
3. `drainEvents` 를 프레임당 한 번만 부르는 이유는?
4. 스택 FSM 에서 일시정지가 "공짜"인 이유는?
5. 순수 리듀서와 이 템플릿의 `GameModel` 은 무엇이 같고 무엇이 다른가?
6. `bench` 에서 시간 대신 할당을 기준으로 삼은 이유 두 가지는?
7. 최적화 후 `equivalence_test` 가 통과했다. 이것이 증명하는 것과 증명하지 못하는 것은?
8. `RULES_VERSION` 을 올렸는데 결과가 6주차와 같다면 무엇이 문제인가?
9. `globals_check` 의 정적 겹과 실행 겹이 각각 못 잡는 것은?
10. 내 ADR-001 의 "감수하는 것"을 한 문장으로.

---

## 10. 과제 & 체크리스트

### 과제
- [ ] 템플릿(`starter`)에 최적화 → `perf_test` 통과, `equivalence_test` **v1 그대로 통과** (커밋 1)
- [ ] 콤보 → `run_all starter` 전부 통과 (커밋 2)
- [ ] 전후 `bench` 수치 표 (JIT 끔 할당 + JIT 켬 시간)
- [ ] 번짐 실측 표 + `monolith_pain.md` T4 행
- [ ] `ADR-001.md`
- [ ] 체크리스트 10항목 + 루브릭 최종 채점
- [ ] 실행 확인 1회: 한 판 → S → 타이틀 L → 끝까지 → F3 켜고 한 판

### 체크리스트
- [ ] `luajit run_all.lua starter` 전부 통과 (10묶음)
- [ ] `lua5.1 run_all.lua starter` 도 통과 (정적 전역 검사는 생략됨)
- [ ] 2-5절 "왜 최적화가 먼저인가"를 한 문장으로 말할 수 있다
- [ ] 실행 확인은 1회만

---

## 📁 예제 파일 안내

```text
week07/examples/
├── galaga_final/            완성본 = 템플릿 + 미사일 조준 최적화 + 콤보 (RULES_VERSION 2)
│   ├── main.lua             love 를 아는 유일한 파일: ctx(storage 포함), F3 성능 표시
│   ├── models/              GameModel(RULES_VERSION, _nearestTarget) · ComboModel(신규) · …
│   ├── views/               HudView(콤보) · ReplayView(버전 불일치) · ResultView/TitleView(저장·불러오기 안내)
│   ├── controllers/         InputController · InputRecorder(버전 헤더, parse 검증)
│   └── scenes/              Title(L) · Play · Pause · Result(S) · Replay(버전 거부) · SceneStack
├── starter/                 최종 템플릿 (6주차 + 버전·저장·F3, RULES_VERSION 1) — 실습 출발점
├── adr/                     ADR-템플릿.md · ADR-000-예시-리플레이-규칙-버전.md
└── tests/
    ├── run_all.lua          전부 실행 + 요약
    ├── layer_check · globals_check
    ├── view_test · feature_test (4주차) · scene_test · phase_test (5주차) · replay_test (6·7주차)
    ├── equivalence_test     규칙 버전 약속 (6주차 galaga_replay 와 비교 — 폴더를 옮기면 경로 확인)
    ├── perf_test · combo_test
    └── bench.lua            프로파일링 (테스트 아님, 수치 출력)
```

실행 (저장소 루트에서, 환경에 맞는 `love` 사용):

```sh
love lua_tuto/mvc/week07/examples/galaga_final
love lua_tuto/mvc/week07/examples/starter
```

| 화면 | 키 |
|------|----|
| 타이틀 | Enter/Space 시작, **L 저장된 리플레이**, Esc 종료 |
| 플레이 | ←/→(A/D) 이동, Space 발사, X 미사일, P/Esc 일시정지 |
| 결과 | R 재도전, V 리플레이, **S 저장**, Enter 타이틀 |
| 리플레이 | Space 1/4배속, Esc/Enter 타이틀 |
| 어디서나 | **F3 성능 표시** |

---

> 📎 **선택 심화:** MVC 의 장단점과 단점을 메우는 구조(MVP·MVVM·TEA·ECS·Hexagonal)는 [week08_more](../week08_more/README.md) 에서 같은 게임 여섯 개로 비교한다.
