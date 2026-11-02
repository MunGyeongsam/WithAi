# 예제 6 — 던전 RPG: 다중 Model · 다중 View · 다중 Controller

> 예제 1~5는 Model 1개, View 1~2개, Controller 1개였다. 실제 게임은 **Model 수십 개, View(UI 패널) 수십 개, 모드(씬)별 Controller** 가 동시에 돌아간다.
> 이 예제는 그 "많아졌을 때의 모양"을 콘솔 턴제 던전 RPG로 축소해 보여준다.

```sh
lua lua_tuto/mvc/basics/06_dungeon/main.lua        # 자동 시연 (방 7개 → 승리)
lua lua_tuto/mvc/basics/06_dungeon/main.lua -i     # 직접 플레이
lua lua_tuto/mvc/basics/tests/dungeon_test.lua     # 헤드리스 테스트
```

VS Code 에서는 `main.lua` 를 열고 task **`Lua: Run current file`**.

---

## 1. 파일 구성 (23개)

```
06_dungeon/
  main.lua                     ← 조립만 (규칙·문구·키 해석 없음)
  data/
    dungeon_data.lua           ← 방 구성, 적 능력치, 퀘스트 (코드 아닌 데이터)
  models/                      ← 8개
    game_model.lua             ← 루트: 작은 모델 소유 + 여러 모델에 걸친 규칙
    player_model.lua           ← 체력·공격·장비·골드
    enemy_model.lua            ← 적 1마리 (전투 중에만 존재)
    inventory_model.lua        ← 아이템 목록·용량
    dungeon_model.lua          ← 방 목록·현재 위치
    quest_model.lua            ← 퀘스트 진행도 (이벤트 구독)
    log_model.lua              ← 최근 사건 원본 기록 (이벤트 구독)
    event_bus.lua              ← 모델 간 소통 통로
  views/                       ← 8개
    screen_view.lua            ← 합성 View: 모드별 레이아웃으로 위젯 배치
    status_view.lua            ← HUD (플레이어·위치)
    enemy_view.lua             ← 적 패널 (전투 중에만 표시)
    inventory_view.lua         ← 가방 패널 (모드에 따라 요약/선택 화면)
    quest_view.lua             ← 퀘스트 패널
    log_view.lua               ← 사건 → 문장 번역
    command_view.lua           ← 모드별 조작 안내
    widgets.lua                ← 공용 UI 부품 (체력 바)
  controllers/                 ← 5개
    input_router.lua           ← 현재 모드 담당 Controller 에게 입력 전달
    explore_controller.lua     ← 탐험 모드
    battle_controller.lua      ← 전투 모드
    inventory_controller.lua   ← 가방 모드
    end_controller.lua         ← 게임 오버 / 승리
```

---

## 2. 전체 구조

```
                         ┌──────────────── Controllers ────────────────┐
  입력 ──▶ InputRouter ──▶│ explore │ battle │ inventory │ end            │
           (mode 로 선택)  └────┬───────────────────────────────────────────┘
                              │ game:explore() / attack() / useItem(i) ...
                              ▼
  ┌──────────────────────── GameModel (루트) ────────────────────────┐
  │  Player   Inventory   Dungeon   Enemy        ← 직접 소유·호출      │
  │                                                                   │
  │  bus:emit("enemy_killed") ──▶ EventBus ──┬──▶ QuestModel (진행도+1)│
  │                                          └──▶ LogModel  (기록)    │
  └───────────────────────────────────────────────────────────────────┘
                              ▲ 읽기만
                              │
  출력 ◀── ScreenView ── layout[mode] ──▶ Status │ Enemy │ Inventory │ Quest │ Log │ Command
```

### 핵심 아이디어 4가지

| # | 아이디어 | 이 예제에서 | 실제 게임에서 |
|---|---------|------------|--------------|
| ① | **Model 트리** — 루트 Model 이 작은 Model 들을 소유한다 | `GameModel` → Player / Inventory / Dungeon / Enemy | `World` → 엔티티들, `Session` → 계정·재화·설정 |
| ② | **이벤트 버스** — 작은 Model 끼리는 서로를 모르고 사건으로만 소통한다 | `enemy_killed` → Quest, Log 가 각자 반응 | 업적, 통계, 튜토리얼, 사운드 트리거 |
| ③ | **View 합성** — 화면은 작은 위젯 여러 개를 레이아웃대로 쌓은 것 | `ScreenView` + 위젯 6개, 모드별 `layouts` | HUD, 미니맵, 인벤토리 창, 대화창 패널 |
| ④ | **모드별 Controller** — 같은 키도 상황마다 다른 담당자가 해석 | `i` = 탐험/전투에선 가방 열기, 가방에선 무시 | 필드/전투/메뉴/대화 씬별 입력 처리 |

---

## 3. 누가 누구를 아는가 (의존성 표)

| | 아는 것 (require/참조) | 모르는 것 |
|---|---|---|
| `PlayerModel`, `EnemyModel`, `InventoryModel`, `DungeonModel` | 자기 데이터만 | 다른 모델 전부, View, Controller |
| `QuestModel`, `LogModel` | `EventBus` | **GameModel**, 다른 모델, View |
| `GameModel` | 작은 모델 전부 + `EventBus` | **QuestModel·LogModel 의 내부**(emit 만 함), View, Controller |
| 각 위젯 View | 읽는 모델(읽기 전용), `widgets` | Controller, 다른 위젯 |
| `ScreenView` | 위젯 규약(`title`, `lines`) | 위젯이 어떤 모델을 읽는지 |
| 각 Controller | `GameModel` 의 행동 메서드 | View, 다른 Controller |
| `InputRouter` | Controller 규약(`handle`), View 의 `render`/`showNotice` | 각 Controller 가 무슨 키를 쓰는지 |
| `main.lua` | **전부** (조립 담당) | 규칙, 문구, 키 해석 |

> 💡 "모두를 아는" 파일은 `main.lua` 하나뿐이다. 나머지는 자기 이웃만 안다. 파일이 100개가 되어도 이 원칙이 유지되면 한 파일을 고칠 때 볼 범위가 작게 유지된다.

---

## 4. 한 번의 입력이 흐르는 길 — `a`(공격)로 오크를 처치할 때

1. `main` 이 입력 `"a"` 를 `InputRouter:handle` 에 넘긴다.
2. 현재 `game.mode == "battle"` → `BattleController:handle(game, "a")` → `game:attack()`.
3. `GameModel` 이 `player:getAttack()` 만큼 `enemy:takeDamage()` → `bus:emit("player_attacked")`.
4. 적이 죽음 → `player:addGold()`, `mode = "explore"`, `bus:emit("enemy_killed")`.
5. `EventBus` → `LogModel` 이 기록, `QuestModel` 이 진행도 +1 → 3/3 이면 `bus:emit("quest_completed")` → `LogModel` 이 또 기록.
6. `InputRouter` 가 `screen:render(game)` 호출.
7. `ScreenView` 가 `layouts.explore` 순서대로 위젯 `lines(game)` 를 모아 출력. 전투가 끝났으므로 `EnemyView` 는 레이아웃에서 빠진다.

**GameModel 은 5단계(퀘스트 완료)를 전혀 모른다.** 퀘스트 시스템을 통째로 빼도 GameModel 은 한 줄도 바뀌지 않는다.

---

## 5. 확장해 보기 — "무엇을 추가할 때 어떤 파일을 고치나"

규모가 커질 때 MVC 의 가치는 **"추가가 기존 코드 수정 없이 끝나는가"** 로 드러난다.

| 추가하려는 것 | 새 파일 | 고칠 파일 | 고치지 않는 파일 |
|--------------|--------|----------|-----------------|
| 새 퀘스트 "아이템 3번 사용" | 없음 | `data/dungeon_data.lua` 1줄 (`event = "item_used"`) | 모든 코드 |
| 새 적 / 새 방 | 없음 | `data/dungeon_data.lua` | 모든 코드 |
| 업적 시스템 | `models/achievement_model.lua` (버스 구독) + `views/achievement_view.lua` | `game_model.lua` 생성 1줄, `main.lua` 위젯·레이아웃 등록 | Player, Quest, Log, Controller 전부 |
| 미니맵 패널 | `views/minimap_view.lua` | `main.lua` 위젯·레이아웃 등록 | Model, Controller 전부 |
| 상점 모드 | `controllers/shop_controller.lua` (+ `GameModel` 에 `buy`) | `main.lua` 라우터 등록, `command_view.lua` 안내 1줄 | 다른 Controller, 다른 View |
| 로그 문구 영어화 | `views/log_view_en.lua` | `main.lua` 에서 교체 | Model, Controller 전부 |
| LÖVE2D 로 이식 | 위젯마다 `draw(game, x, y)` 를 가진 View | `main.lua` → `love.load/keypressed/draw` | **Model 8개, Controller 5개 전부** |

---

## 6. 실제 게임과 다른 점 (정직하게)

| 이 예제 | 실제 실시간 게임 |
|--------|----------------|
| 턴제: 입력이 있을 때만 상태가 바뀐다 | 매 프레임 `update(dt)` 로 상태가 스스로 바뀐다 (적 이동, 쿨다운) |
| 입력 1회 → 화면 1회 출력 | 입력과 무관하게 매 프레임 `draw` |
| 모드 전환이 `game.mode` 문자열 | 씬마다 `enter/exit/update/draw` 를 가진 State 객체 (FSM) |
| 이벤트 버스가 즉시 동기 호출 | 큐에 쌓았다가 프레임 끝에 처리하기도 함 (순서·재진입 제어) |

이 차이는 7주 과정의 [week01](../../week01/README.md)(게임 루프), [week03](../../week03/README.md)(Model 분리), 5주차(State 패턴)에서 다룬다.

---

## 7. 연습 과제

1. **(데이터만)** "아이템 2번 사용" 퀘스트를 추가하라. 코드를 한 줄도 고치지 않았는지 확인하라.
2. **(View 추가)** 지금까지 처치한 적 목록을 보여주는 `KillListView` 를 만들어라. 필요한 데이터는 어디에 저장해야 할까? (힌트: 이벤트를 구독하는 작은 Model)
3. **(Model + View)** 업적 시스템: "골드 15 이상 모으기" 달성 시 로그에 표시. GameModel 의 기존 메서드는 고치지 마라.
4. **(Controller 추가)** 출구 직전에 상점 방(`kind = "shop"`)을 추가하고 `ShopController` 를 만들어라. 물약 1개 = 골드 5.
5. **(테스트 먼저)** 위 과제마다 [tests/dungeon_test.lua](../tests/dungeon_test.lua) 에 테스트를 먼저 쓰고 구현하라.
