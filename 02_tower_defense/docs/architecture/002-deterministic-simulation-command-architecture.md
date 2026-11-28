# 결정적 Simulation Core + Command 아키텍처

> 상태: 확정
> 결정 문서: [ADR-001](001-gameplay-architecture-review.md)
> 작성일: 2026-11-28
> 적용 범위: `02_tower_defense` 게임플레이 구현
> 목적: 향후 구현과 코드 리뷰에서 사용할 구조적 기준과 계약

## 1. 문서 목적

이 문서는 **결정적 Simulation Core와 원자적 Command/Transaction을 중심으로,
최소 MVC와 제한적 Layered/Hexagonal 경계, ViewData, Render Event를 조합한
게임플레이 구조**를 정의한다.

이 문서가 정하는 것은 다음과 같다.

- 게임 상태의 단일 소유자
- 입력에서 상태 변경까지의 실행 흐름
- 모듈과 폴더의 책임 경계
- Simulation, Command, Transaction, ViewData, Render Event 계약
- 고정 타임스텝과 결정성 제약
- 기존 구현을 이동하는 순서와 검증 기준
- 도입하지 않아야 하는 패턴과 추상화

적 수치, 타워 위력, 웨이브 수량, UI 배치와 같은 기획 내용은 이 문서의
범위가 아니다. 해당 값은 GDD와 데이터 문서를 따른다.

## 2. 최종 선택

```text
결정적 Simulation Core
+ 원자적 Command/Transaction
+ 최소 MVC
+ 제한적 Layered/Hexagonal 경계
+ ViewData와 Render Event
```

Simulation Core는 게임 상태와 규칙을 소유한다. 플레이어 입력은 명령으로
변환되고, 원자성이 필요한 명령은 `preview -> commit 또는 reject` 계약으로
처리된다. View는 Simulation 상태를 직접 변경하지 않고 ViewData와 Render Event
로부터 화면과 효과를 만든다.

이 구조는 여러 패턴의 이름을 동시에 구현하기 위한 것이 아니다. 각 패턴은
하나의 구체적인 문제를 해결할 때만 사용한다.

| 차용 요소 | 해결하는 문제 |
|---|---|
| 결정적 Simulation | 같은 입력과 스텝에서 같은 게임 결과 생성 |
| Command | 플레이어 행동과 상태 변경을 명시적으로 연결 |
| Transaction | 맵·골드·적 경로의 부분 적용 방지 |
| 최소 MVC | 입력, 상태, 표시 책임의 기본 분리 |
| Layered 경계 | 도메인이 LÖVE/입력/UI 기술에 의존하지 않도록 제한 |
| Hexagonal 경계 | LÖVE 입력·렌더링을 어댑터로 교체 가능하게 유지 |
| ViewData | 읽기와 쓰기의 계약 분리 |
| Render Event | 시각·청각 효과가 게임 상태를 다시 변경하지 않도록 분리 |

## 3. 비목표

다음은 이 아키텍처의 목표가 아니다.

- 모든 입력에 Command 객체와 폴더를 만드는 것
- 모든 도메인 객체를 인터페이스로 감싸는 것
- 모든 상태 변경을 불변 테이블 복사로 만드는 것
- 전역 Event Bus 또는 범용 메시지 프레임워크를 만드는 것
- Dependency Injection 컨테이너를 도입하는 것
- 완전한 ECS, Clean Architecture, Event Sourcing을 구현하는 것
- View가 부드럽게 보이도록 Simulation 규칙을 바꾸는 것
- 자동화된 리플레이 저장을 첫 마일스톤에서 완성하는 것

## 4. 구조 한눈에 보기

```text
LÖVE callbacks
    |
    v
Scene / Composition Root
    |
    +-- InputController ---- raw input -> Command --------+
    |                                                   |
    +-- FixedTimestep ---------------------------------+|
                                                        v
                                                  Simulation
                                            +-------------------+
                                            | GameState         |
                                            | CommandProcessor  |
                                            | Transactions      |
                                            | Domain Systems    |
                                            | Factories         |
                                            +-------------------+
                                                |         |
                                           ViewData   Render Events
                                                |         |
                                                v         v
                                      GameplayView   Effects/Audio
```

상태가 흐르는 방향은 다음과 같이 제한한다.

```text
View/Input Adapter -> Command -> Simulation -> GameState
GameState -> ViewData -> View
Simulation -> RenderEvent -> View/Effect/Audio
```

View나 Render Event가 `GameState`를 직접 변경하는 역방향 호출은 허용하지
않는다.

## 5. 계층과 의존성 방향

### 5.1 Framework / Composition 계층

역할:

- LÖVE 콜백 연결
- SceneStack, FixedTimestep, VirtualResolution 조립
- 저장·사운드 같은 외부 기능 연결
- 서로 의존하는 객체를 생성하고 연결

예상 위치:

```text
src/main.lua
src/01_core/
src/03_game/scenes/
```

규칙:

- Composition Root만 구체 구현을 생성하고 연결한다.
- 도메인 모듈 안에서 LÖVE 장면, 입력 장치, 파일 시스템 구현을 직접 생성하지
  않는다.
- Scene은 화면 수명주기와 하위 Controller/View 연결을 담당하되,
  게임 규칙을 직접 구현하지 않는다.

### 5.2 Input / Controller 계층

역할:

- 마우스·터치 좌표를 가상 좌표로 받기
- HUD와 맵 영역을 구분
- UI 선택 상태와 확정 입력 해석
- Simulation이 이해할 `Command` 생성

예상 위치:

```text
src/03_game/input/
src/04_ui/ 또는 src/03_game/controllers/
```

규칙:

- Controller는 `GameState`를 직접 변경하지 않는다.
- Controller는 화면 좌표를 Command의 셀 좌표나 의미 있는 행동으로 변환한다.
- 타워 종류 선택, 패널 열기 같은 표현 전용 선택은 Controller가 소유할 수 있다.
- 배치, 판매, 업그레이드, 웨이브 시작은 반드시 Command로 전달한다.

### 5.3 Simulation / Domain 계층

역할:

- 모든 실제 게임 상태 소유
- 고정 스텝에서 웨이브, 이동, 전투, 출구 도달 처리
- Command 검증과 Transaction 실행
- ViewData와 Render Event 생성

예상 위치:

```text
src/03_game/simulation/
src/03_game/domain/
src/03_game/commands/
src/03_game/data/
```

규칙:

- `love.*`, 화면 픽셀, 터치 장치, 폰트, 오디오 API를 사용하지 않는다.
- 화면 프레임 `dt` 대신 고정 시뮬레이션 `dt`만 사용한다.
- `math.random`, `os.time`, 전역 상태, 순서가 없는 테이블 순회에 의존하지
  않는다.
- 모든 상태 변경은 Simulation 메서드, System 함수 또는 Transaction의
  commit 단계에서만 수행한다.
- 다른 계층의 View 구현을 `require`하지 않는다.

### 5.4 View 계층

역할:

- 맵, 타워, 적, 경로, 사거리, HUD, 결과 화면 렌더링
- Render Event를 애니메이션·사운드·토스트로 변환
- 보간 또는 표시 전용 애니메이션 적용

예상 위치:

```text
src/04_ui/
src/05_view/
```

규칙:

- View는 `GameState`를 직접 수정하지 않는다.
- View는 ViewData에 필요한 값만 읽는다.
- View의 임시 애니메이션 값은 결과 표시만 바꾸며 Simulation 상태를 결정하지
  않는다.
- View는 비용 부족, 편집 거절 같은 결과 코드를 사람이 읽는 문장으로 변환할
  수 있지만 Command 성공 여부를 바꾸지는 않는다.

## 6. 상태 소유권

| 상태 | 단일 소유자 | 직접 변경 가능한 위치 |
|---|---|---|
| 현재 phase | `GameState` | Simulation/Transaction |
| 맵 셀과 current path | Map Domain State | Map Transaction commit |
| 골드, 생명, 총 지출·획득 | Economy State | Simulation/Transaction |
| 적 위치, HP, 상태 효과, 합류 정보 | Enemy State | Movement/Combat/Transaction |
| 타워 위치, 레벨, cooldown, target | Tower State | Combat/Transaction |
| 웨이브 스폰 큐와 진행 상태 | Wave State | WaveRuntime |
| 시뮬레이션 tick과 RNG 상태 | `GameState` | Simulation |
| 다음 위협 데이터 | Level/Wave Data | 파일 데이터 또는 Factory |
| 선택 모드, 입력 후보, 확인 단계 | Controller/UI State | Controller |
| 애니메이션과 이펙트 진행 | View State | View |

중요한 제한은 소유자와 렌더링 편의를 동일시하지 않는 것이다. 예를 들어 적의
현재 위치는 Simulation이 소유하지만 View가 보간 좌표를 계산해 화면에 더
부드럽게 표시할 수 있다.

## 7. 핵심 계약

### 7.1 `GameState`

`GameState`는 Simulation의 루트 데이터다. 개념적 필드는 다음과 같다.

```lua
{
    revision = 0,
    tick = 0,
    fixedDt = 1 / 60,
    phase = "build",
    rng = { seed = 0, value = 0 },
    map = {...},
    economy = {...},
    enemies = {...},
    towers = {...},
    wave = {...},
    outcome = {...}
}
```

규칙:

- 외부에서 필드 값을 임의로 갱신하지 않는다.
- `revision`은 Transaction commit과 주요 상태 전이가 완료될 때 증가한다.
- ID는 배열 인덱스와 분리해 생성한다. 타워 판매·적 사망 후에도 명령과 이벤트가
  동일한 ID를 가리켜야 한다.
- 데이터 정의와 실행 인스턴스를 구분한다.

### 7.2 `Command`

Command는 “요청”이며 이미 성공한 결과가 아니다.

```lua
{
    id = 17,
    type = "PLACE_WALL",
    tick = 120,
    payload = {
        col = 4,
        row = 7
    }
}
```

선택한 Command:

```text
PLACE_WALL
REMOVE_WALL
PLACE_TOWER
SELL_TOWER
UPGRADE_TOWER
START_WAVE
```

UI 전용 선택:

```text
SELECT_PLACEMENT_MODE
SELECT_TOWER_TYPE
OPEN_PANEL
CLOSE_PANEL
CANCEL_PREVIEW
```

UI 선택은 Simulation 상태가 아니라 Controller/View 상태에만 영향을 주면
CommandProcessor를 통과하지 않아도 된다.

CommandProcessor는 입력받은 순서를 보존한다. 동일 tick에 여러 Command가
생성되면 Controller가 큐에 넣은 순서가 실행 순서가 된다.

### 7.3 `CommandResult`

모든 Transaction Command는 구조화된 결과를 반환한다.

```lua
{
    accepted = true,
    code = "COMMITTED",
    commandId = 17,
    revision = 31,
    events = {...}
}
```

거절 예:

```lua
{
    accepted = false,
    code = "PATH_BLOCKED",
    commandId = 18,
    revision = 31,
    events = {...}
}
```

권장 오류 코드:

```text
COMMITTED
INVALID_PHASE
INVALID_COMMAND
INVALID_CELL
CELL_OCCUPIED
INSUFFICIENT_GOLD
PATH_BLOCKED
ENEMY_OCCUPIES_CELL
NO_SAFE_JOIN
TARGET_NOT_FOUND
MAX_LEVEL_REACHED
```

`nil`, `false`만 반환하지 않는다. UI는 실패 원인을 CommandResult로부터
설명할 수 있어야 한다.

### 7.4 `Transaction`

Transaction은 `plan` 또는 `preview` 단계와 `commit` 단계를 분리한다.

```lua
local preview = PlaceWallTransaction.preview(state, command)

if not preview.valid then
    return CommandResult.reject(preview.code)
end

PlaceWallTransaction.commit(state, preview)
return CommandResult.accept(preview.events)
```

불변 조건:

1. preview 단계는 `GameState`를 변경하지 않는다.
2. preview의 모든 변경량은 `commit` 전에 계산된다.
3. 하나라도 검증 실패하면 `commit`을 호출하지 않는다.
4. commit 이후 실패를 기대하지 않는다.
5. commit은 같은 tick 안에서 관찰 가능한 하나의 작업이다.
6. rollback 구현보다 preview 검증을 우선한다.

preview 예:

```lua
{
    valid = true,
    code = "VALID",
    cost = 5,
    mapChange = {...},
    newPath = {...},
    enemyJoinPlans = {...},
    economyChange = {goldDelta = -5},
    events = {...}
}
```

Transaction은 공유 헬퍼를 사용할 수 있지만, 서로 다른 거래를 하나의
“만능 execute” 함수로 일반화하지 않는다.

### 7.5 `ViewData`

ViewData는 렌더링에 필요한 읽기 데이터다.

```lua
{
    phase = "wave",
    revision = 31,
    gold = 120,
    lives = 17,
    wave = {current = 2, total = 7},
    map = {...},
    enemies = {...},
    towers = {...},
    preview = {...},
    nextThreat = {...}
}
```

규칙:

- View가 필요한 정보만 포함한다.
- 초기에는 참조를 그대로 돌려주는 성능 최적 구현을 허용하되, 문서상으로는
  읽기 전용 계약으로 취급한다.
- ViewData 생성 비용이 커질 때까지 전체 GameState를 매 프레임 복사하지 않는다.
- ViewData는 화면 픽셀보다 게임 셀·논리 좌표를 우선 포함한다.

### 7.6 `RenderEvent`

RenderEvent는 Simulation에서 발생한 표현 가능한 사실이다.

```lua
{
    type = "TOWER_FIRED",
    tick = 42,
    towerId = 7,
    targetId = 11,
    damage = 8
}
```

예:

```text
COMMAND_COMMITTED
COMMAND_REJECTED
WALL_PLACED
WALL_REMOVED
TOWER_PLACED
TOWER_SOLD
TOWER_FIRED
ENEMY_DIED
ENEMY_REACHED_EXIT
WAVE_STARTED
WAVE_CLEARED
GAME_WON
GAME_LOST
```

Event는 상태 변경 요청이 아니라 결과 알림이다. View가 Event를 처리해도
Simulation GameState가 바뀌지 않는다. 같은 tick에 생성된 Event 순서를 보존한다.

## 8. 고정 타임스텝 실행 순서

한 simulation tick의 기본 순서는 다음과 같다. 이 순서는 현재
`GameplayScene:update`가 타워 처리, 적 이동, 웨이브 스폰을 수행하는 순서를
초기 migration 기준으로 보존한다.

```text
1. tick 시작과 Command 큐 스냅샷
2. Command를 생성 순서대로 실행
3. 타워 타겟, 공격, 피해, 사망 보상 처리
4. 적 이동과 출구 도달, 생명 감소 처리
5. WaveRuntime의 스폰 처리
6. 웨이브 종료·승리·패배 판정
7. 해당 tick의 Render Event 확정
8. tick 증가
```

이 순서를 함수에만 숨기지 않고 문서와 테스트에서 계약으로 유지한다. 실행
순서가 바뀌면 같은 tick의 “공격 후 이동” 같은 결과도 바뀔 수 있기 때문이다.
따라서 이 순서 변경은 구조 이동만으로 발생해서는 안 되며, 별도 게임플레이 결정과
회귀 사례 없이는 수행하지 않는다.

### 고정 스텝과 View 타이밍

```lua
fixedStep:update(frameDt, function(fixedDt)
    simulation:update(state, fixedDt, commands:drain())
end)

local viewData = simulation:getViewData(state)
local interpolationAlpha = math.max(0, math.min(1, fixedStep:getAlpha()))
view:draw(viewData, interpolationAlpha)
```

- Simulation은 `fixedDt`만 사용한다.
- View는 필요할 때 0~1 범위로 제한한 `alpha`를 보간에만 사용한다.
- 프레임 드랍 시 남는 시간의 처리 상한은 기존 FixedTimestep 정책을 유지한다.
- 반복 상한에 도달해 누적 시간이 남은 경우 Simulation 백로그는 유지하되,
  extrapolation을 막기 위해 raw `getAlpha()` 값을 View에 그대로 전달하지 않는다.
- 입력은 발생한 프레임에서 Controller가 큐에 넣고 다음 simulation tick에서
  처리한다.

## 9. 결정성 정책

결정성을 위해 다음을 규칙으로 둔다.

### 허용

- state 내부 tick과 revision
- Simulation에 소유된 RNG 상태
- 명시적인 ID 부여 순서
- 고정된 배열 순회
- Command 생성 순서와 Event 생성 순서
- 고정된 경로 탐색 이웃 순서

### 금지

- Simulation에서 `math.random`을 직접 호출
- `pairs` 순회 결과에 의존하는 상태 변경
- `love.timer`, 시스템 시각, 프레임 번호로 규칙 결정
- 테이블 메모리 주소나 참조 문자열을 ID로 사용
- 같은 tick 안에서 View 결과가 Simulation 상태를 바꾸는 것

### 결정성 검증

```text
같은 초기 State seed
+ 같은 Level/Wave/Tower/Enemy Data
+ 같은 FixedDt
+ 같은 순서의 Command
= 같은 최종 State fingerprint
```

최소 검증 항목:

- 적 좌표와 진행도
- 타워 cooldown과 target ID
- 골드와 생명
- 맵 셀과 경로
- 웨이브와 스폰 큐
- Simulation tick과 revision
- Render Event의 타입과 순서

## 10. 원자적 거래 상세

### 10.1 벽 설치

필요 상태:

- 대상 셀
- 비용
- 후보 그리드
- 후보 경로
- 적 점유 셀
- 각 적의 합류 계획

거절 조건:

```text
잘못된 셀
이미 점유된 셀
골드 부족
입구/출구 또는 금지 영역
편집 후 경로 없음
적이 대상 셀 또는 이동 구간을 점유
일부 적의 안전한 합류 없음
```

commit:

```text
맵 셀
current path
모든 관련 적의 다음 구간
골드
revision
Render Events
```

### 10.2 벽 제거

벽을 제거하면 경로가 짧아질 수 있으므로, 단순 제거가 아니라 모든 적의 다음
순방향 합류를 다시 계산해야 한다.

거절은 대상이 없거나 현재 적 상태에 유효한 합류 계획을 만들 수 없을 때
발생한다.

### 10.3 타워 설치

타워 설치는 맵 셀 점유, 골드, 경로, 적 합류를 벽 설치와 같은 거래 조건으로
확인한 뒤 Tower State를 생성한다. 타워 생성은 Factory가 데이터 정의를
검증한 후 수행한다.

### 10.4 타워 판매

preview에서 다음을 계산한다.

- 타워의 총 투자액
- 정책 환급액
- 제거된 셀에서의 후보 경로
- 이동 중인 적의 합류 가능성
- 제거할 tower ID와 target 참조

commit에서 타워와 맵 점유를 제거하고 골드를 지급한다. 환급액 계산과 타워 제거
사이의 중간 상태는 관찰되지 않아야 한다.

### 10.5 업그레이드

- 타워 존재와 최대 레벨을 확인한다.
- 비용을 먼저 계산한다.
- 골드가 충분한지 확인한다.
- upgrade definition을 Factory/Data에서 검증한다.
- commit에서 타워 속성과 골드를 함께 변경한다.

업그레이드가 맵과 경로를 바꾸지 않는 동안 적 합류 검사는 하지 않아도 된다.

## 11. Controller와 UI 상태

Controller는 다음 두 종류의 상태를 구분한다.

### 표시 상태

Simulation에 영향을 주지 않는다.

- 현재 배치 모드
- 선택한 타워 종류
- 열린 패널
- 후보 셀의 화면 강조
- 확인 대화상자 표시

### 게임 명령 후보

Simulation에 확인 요청으로 전달된다.

- `PLACE_WALL`
- `SELL_TOWER`
- `START_WAVE`

첫 탭 미리보기와 두 번째 확정 입력은 Controller가 관리할 수 있다. 다만 경로와
적 합류 가능성의 최종 판단은 Simulation Transaction이 수행한다. Controller는
Transaction 결과를 추측해 성공으로 표시하지 않는다.

## 12. Factory와 Data 경계

정적 정의는 다음에 둔다.

```text
EnemyData
TowerData
LevelData
WaveData
EconomyDefaults
```

실행 인스턴스는 다음에 둔다.

```text
Enemy State
Tower State
Wave Runtime Queue
```

Factory는 data ID의 존재와 필수 필드만 검증하고 실행 객체를 생성한다. Factory는
`love.graphics`, Scene, HUD에 의존하지 않는다.

```lua
local tower = TowerFactory.create("gun", {
    id = state.nextEntityId,
    col = 3,
    row = 7
})
```

Data에 값이 없거나 정의가 잘못되면 암묵적 기본값으로 정상처럼 보이지 말고
명시적인 오류를 반환한다.

## 13. 권장 폴더 구조

다음은 역할의 기준 구조이며 한 번에 모든 파일을 만들 필요는 없다.

```text
src/
├── 01_core/
│   ├── fixedTimestep.lua
│   ├── sceneStack.lua
│   └── virtualResolution.lua
├── 03_game/
│   ├── data/
│   │   ├── levels.lua
│   │   ├── enemies.lua
│   │   ├── towers.lua
│   │   └── waves.lua
│   ├── simulation/
│   │   ├── gameState.lua
│   │   ├── gameSimulation.lua
│   │   ├── commandProcessor.lua
│   │   ├── commandResult.lua
│   │   ├── renderEvent.lua
│   │   └── viewData.lua
│   ├── commands/
│   │   ├── placeWallTransaction.lua
│   │   ├── removeWallTransaction.lua
│   │   ├── placeTowerTransaction.lua
│   │   ├── sellTowerTransaction.lua
│   │   ├── upgradeTowerTransaction.lua
│   │   └── startWaveCommand.lua
│   ├── domain/
│   │   ├── map.lua
│   │   ├── pathPlanner.lua
│   │   ├── economy.lua
│   │   ├── movement.lua
│   │   ├── combat.lua
│   │   └── waveRuntime.lua
│   ├── factories/
│   │   ├── enemyFactory.lua
│   │   └── towerFactory.lua
│   ├── input/
│   │   ├── inputAdapter.lua
│   │   └── gameplayController.lua
│   └── scenes/
│       ├── gameplayScene.lua
│       └── ...
└── 04_ui/
    ├── gameplayView.lua
    ├── mapView.lua
    ├── unitView.lua
    └── hudView.lua
```

폴더 이름보다 의존성 방향과 상태 소유권이 우선이다. 파일 하나가 충분한 단순
역할은 추상화를 위해 더 쪼개지 않아도 된다.

## 14. 구현 전환 전략

한 번에 전체 코드 재작성하지 않고 다음 순서로 이동한다.

### M1. Characterization Harness

기존 동작을 구현 변경 없이 관찰 가능한 테스트로 고정한다.

- 맵 배치와 BFS 경로
- 적 이동과 재경로
- 타워 타겟·데미지·업그레이드
- 골드·생명
- 웨이브 스폰
- 현재 update 순서: 타워 공격 → 적 이동/출구 → 스폰 → 웨이브 종료
- `FixedTimestep`의 프레임 `dt` 제한, 누산, 반복 상한
- 반복 상한 도달 후 남은 누산과 0~1로 제한되는 render interpolation 값
- 입력 snapshot을 Scene에 전달하는 프레임 시점과 한 번 소비되는 동작
- HUD 탭 소비와 맵 입력 전달 경계
- Scene push/pop/replace와 진입·탈출 생명주기

기대 결과: 기존 정상·실패 동작이 기록되고 회귀 하네스가 녹색이다.

### M2. 경로 편집 원자성

- 첫 `GameState`, Command 큐, CommandResult의 최소 Simulation 경계 도입
- 벽과 타워 배치, 제거에 필요한 `preview -> commit/reject` 도입
- 새 경로 계산과 모든 지상 적의 안전한 합류 계획
- `RT-01`~`RT-08` 실패 상태 불변

이 단계에서 Scene이 Gameplay 규칙을 직접 조정하는 범위를 줄이되, 밸런스와
웨이브 수치를 바꾸지 않는다. UI 미리보기와 시각적 합류는 필요할 때만 최소
전체 실행으로 검증한다.

### M3. 경제·판매·업그레이드 거래

- 벽 제거 비용과 반복 편집 정책 연결
- 타워 판매와 총 투자액 기준 환급
- 타워 업그레이드 비용과 실패 불변
- `EC-01`~`EC-08`와 골드·맵·대상 상태의 원자성

### M4. 레벨별 웨이브와 데이터 파이프라인

Enemy, Tower, Wave 정의를 static data와 runtime state에서 분리하고 레벨별
6/7/8웨이브를 구현한다. 레벨 선택, Factory, 다음 위협 데이터, 스폰 완료 판정을
하네스로 검증한다.

### M5. HUD·결과·게임플레이 UX

HUD, 미리보기, 결과 화면이 ViewData를 사용하도록 옮기고 Render Event를
애니메이션·사운드에 연결한다. Scene은 수명주기와 조립에 집중하고 View가 Model을
변경하지 않는지 확인한다. 입력, HUD, 터치, 렌더링을 전체 실행으로 검증한다.

### M6. 밸런스 및 릴리스 검증

결정적 시뮬레이션과 플레이 테스트로 후보 수치를 조정한다. 전략 다양성,
레벨별 6/7/8웨이브, 약 20분 목표와 난이도 실패 신호를 증거와 함께 확인한다.

## 15. 테스트 전략

### 단위 하네스

| 대상 | 확인 |
|---|---|
| FixedTimestep/Scene/Input | 프레임 누산, 반복 상한, raw/backlog alpha와 clamped render alpha, snapshot 소비, HUD 탭 소비, 장면 전환 |
| PathPlanner | 같은 격자에서 같은 경로, 완전 차단 감지 |
| Movement | 위치, 진행도, 속도, 출구 도달 |
| Combat | 타겟 순서, 피해, 공중 대상 제한 |
| Economy | 지출, 획득, 생명, 실패 불변 |
| Factory | 정상 ID 생성, 잘못된 정의 거절 |

### Transaction 통합 하네스

| 대상 | 확인 |
|---|---|
| 벽 설치/제거 | `RT-*`, 모든 적 합류, 부분 실패 없음 |
| 타워 설치/판매 | 맵·타워·골드가 하나의 결과로 변경 |
| 업그레이드 | 비용·레벨·속성 변경의 원자성 |
| 웨이브 시작 | phase 전환과 스폰 상태 |

### 시뮬레이션 하네스

- 같은 입력과 fixed step 두 번 실행 후 fingerprint 동일
- Command 순서를 바꾸면 어떤 결과가 달라지는지 기록
- Render Event가 실제 Simulation 상태를 변경하지 않음

### 전체 LÖVE 실행

다음 항목에서만 필요하다.

- 터치/마우스 좌표가 Command로 변환되는지
- 첫 탭 preview, 두 번째 확정 UX
- HUD 표시와 실제 상태의 동기화
- 보간, 이펙트, 사운드
- 세로 화면 레이아웃

## 16. 코드 리뷰 체크리스트

다음 질문에 모두 답할 수 있어야 한다.

### 상태

- [ ] 변경되는 상태의 단일 소유자가 `GameState` 하위에 있는가?
- [ ] 배열 인덱스와 독립된 ID가 필요한 위치에서 ID를 사용하는가?
- [ ] View 전용 애니메이션 상태가 게임 규칙 상태와 섞이지 않았는가?

### Command/Transaction

- [ ] 입력이 Simulation 상태를 직접 바꾸지 않는가?
- [ ] preview가 실제 상태를 변경하지 않는가?
- [ ] 모든 실패가 구조화된 코드로 반환되는가?
- [ ] 하나라도 실패하면 골드, 맵, 적 상태가 모두 그대로인가?

### 결정성

- [ ] `math.random`, 시스템 시간, 프레임 `dt`를 게임 결정에 쓰지 않았는가?
- [ ] `pairs` 결과 순서를 규칙에 사용하지 않았는가?
- [ ] 같은 초기 상태와 Command에서 같은 결과가 나오는가?

### 계층

- [ ] Simulation/domain이 `love.*`를 사용하지 않는가?
- [ ] View가 Economy, Map, Enemy state를 직접 변경하지 않는가?
- [ ] Composition Root가 의존성을 연결하는가?
- [ ] 새 파일의 책임을 한 문장으로 설명할 수 있는가?

### 테스트

- [ ] 구조 변경 전에 characterization 테스트가 있는가?
- [ ] Transaction 성공과 각 거절 조건을 헤드리스로 검증하는가?
- [ ] 전체 실행이 꼭 필요하지 않은 경우 하네스에서 종료했는가?

## 17. 하지 말아야 할 구현

### View에서 거래 실행

```lua
function Hud:onSell()
    scene.economy:earn(tower:getSellValue())
    scene.map:remove(...)
end
```

이 방식은 경로·적 합류 실패 뒤 일부만 변경될 수 있다.

### 상태 변경 후 오류 검사

```lua
map:remove(cell)
economy:earn(refund)

if not pathPlanner:hasPath() then
    -- 늦은 rollback
end
```

후보를 모두 계산한 뒤 commit해야 한다.

### `love.*`를 Domain으로 끌어오기

```lua
if love.timer.getTime() > nextShot then
    tower:fire()
end
```

Simulation tick과 cooldown 상태를 사용한다.

### 모든 이벤트를 전역 Bus로 보내기

Simulation 메서드가 Event 목록을 반환하거나 짧은 명시적 buffer를 사용한다.
범용 Subscriber 프레임워크를 만들지 않는다.

### 모든 UI 선택을 Command로 만들기

타워 종류 선택처럼 표시와 입력 편의만 바꾸는 행동은 Controller state에서
처리한다. Command는 실제 게임 상태를 바꾸는 행동에만 사용한다.

## 18. 첫 구현 계획 입력

첫 구현 세션은 이 구조 전체를 한 번에 완성하지 않는다. 다음 범위를 권장한다.

```text
목표: M1 characterization harness
변경 후보:
  tests/*_harness.lua
  테스트에 필요한 최소 인젝션 지점
금지:
  밸런스 수치 변경
  UI 변경
  아키텍처 대규모 재작성
검증:
  기존 모듈 하네스 전체 통과
  src/tests 외 변경 없음 또는 변경 사유 기록
  LÖVE 전체 실행 불필요
```

그다음 세션부터 `GameState`, Simulation boundary, 첫 Transaction을 한 책임
단위씩 추가한다.

## 19. 재검토 조건

다음 조건이 증명되면 이 결정을 다시 검토한다.

- Transaction/preview 계산이 fixed-step 예산을 반복적으로 초과
- 결정적 Command 경계 때문에 터치 반응성이 사용자 측정에서 명확히 악화
- 동시 Entity 수가 객체 기반 시스템의 실제 성능 병목을 입증
- 네트워크 멀티플레이가 도입되어 Command 동기화 계약이 크게 확장
- ViewData 생성 비용이 실제 프로파일링에서 주요 병목으로 확인

단순히 코드 파일이 늘었다거나 다른 패턴이 유명하다는 이유만으로 구조를 바꾸지
않는다.

## 20. 승인 요약

최종 선택은 다음이다.

```text
Deterministic Simulation Core
+ Atomic Command/Transaction
+ Minimal MVC
+ Layered/Hexagonal boundaries
+ ViewData / Render Event
```

적용 원칙:

1. Simulation이 상태와 규칙을 소유한다.
2. 상태 변경은 Command 또는 Simulation tick에서만 발생한다.
3. 다중 상태 거래는 preview 후 commit하거나 전체 reject한다.
4. Controller와 View는 Simulation 상태를 직접 수정하지 않는다.
5. Domain은 `love.*`와 입력 장치에 의존하지 않는다.
6. 렌더링 이벤트는 결과를 표현할 뿐 상태를 다시 변경하지 않는다.
7. 구조 이동은 characterization harness 뒤에 진행한다.
