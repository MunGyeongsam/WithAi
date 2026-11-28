# 작업 계획 - TD-PLAN-001 M1 Characterization Harness

> 상태: 확정
> 작업 ID: TD-PLAN-001
> 관련 마일스톤: [M0 implementation roadmap](M0-implementation-roadmap.md)의 M1
> 관련 설계:
> [ADR-001](../architecture/001-gameplay-architecture-review.md),
> [결정적 Simulation Core + Command 아키텍처](../architecture/002-deterministic-simulation-command-architecture.md)
> 기준 세션: [010_2026-11-28_session.md](../../worklogs/010_2026-11-28_session.md)

## 단일 목표

M2에서 구조를 이동하기 전에 현재 플레이 동작을 헤드리스 characterization
harness로 보호할 M1 구현 순서와 계약을 정한다.

이 계획은 구조·수치 변경의 실행 계획을 만들지 않는다. 다음 구현 세션은
현재 동작을 관찰 가능한 테스트로 기록하고, 꼭 필요한 최소 테스트 훅만
추가한다.

## 기준선

2026-11-28 조사 기준으로 기존 6개 도메인 하네스의 37개 테스트가 모두
통과했다.

| 범위 | 기존 하네스 | 보호 중인 동작 |
|---|---|---|
| Pathfinder | `pathfinder_harness.lua` 7개 | 직접 경로, 차단, 우회, BFS 길이, 같은 시작/끝, `canBlock` |
| Map | `map_harness.lua` 7개 | 초기 입·출구, 벽/타워 배치, 진입·출구 보호, 경로 차단 방지, 제거, 경로 재계산 |
| Economy | `economy_harness.lua` 4개 | 초기 자원, 지출 성공/실패, 획득, 생명 하한과 게임 오버 |
| Enemy | `enemy_harness.lua` 8개 | 지상/공중 생성, 이동, 출구 도달, 피해, 슬로우, 경로 갱신 무시/적용 |
| Tower | `tower_harness.lua` 7개 | 타입 생성/거절, 업그레이드, 공중 타겟 제한, 슬로우, 판매값 |
| Wave | `wave_harness.lua` 4개 | 초기 상태, 웨이브 시작, 1웨이브 스폰, 10웨이브 완료 |

기준선은 현재 동작의 기록이며 모든 동작이 요구사항으로 승인됐다는 뜻은
아니다. 테스트는 이동 과정에서 의도치 않은 변화만 차단한다. GDD와 충돌하는
관찰은 별도 결정을 요구하고 이 작업에서 조용히 수정하지 않는다.

## 현재 실행 경계

| 경계 | 현재 관찰 가능한 흐름 | M1 보호 필요성 |
|---|---|---|
| 프레임 입력 | `main.lua`: 물리 좌표를 가상 좌표로 변환한 뒤 InputAdapter에 저장 | P1: 좌표 변환과 pending tap 경계 |
| 입력 snapshot | 매 프레임 InputAdapter가 `tapped`를 초기화하고 pending tap을 한 번 내보냄 | P0: 한 번 소비되는 동작 |
| 씬 입력 | SceneStack이 top scene에 snapshot 전달 | P0: top scene만 반응 |
| gameplay 입력 | HUD가 먼저 탭을 소비하고, 남은 맵 탭만 배치 | P0: HUD/맵 우선순위 |
| 고정 스텝 | `dt`를 최대 0.25로 제한하고 1/60 step을 최대 8회 실행 | P0: 제한, 누산, 상한 |
| render alpha | 현재 `getAlpha()`는 accumulator / fixedDt를 그대로 반환 | P0: 반복 상한 후 raw와 render clamp 구분 |
| gameplay update | 타워 공격 → 적 이동/출구 → 웨이브 스폰 → 종료 → 게임오버 | P0: 규칙 이동 전 순서 기준선 |
| 전투 결과 | projectile을 즉시 타겟 피해/슬로우/범위 피해에 적용 | P1: 같은 타워 순서와 제거 관찰 |
| 웨이브 상태 | build에서만 시작하며 스폰 완료·적 0에서 build/victory | P0: phase 전이 |
| 씬 생명주기 | `push`, `pop`, `replace`, top update, 전체 stack draw | P0: stack 조정과 전환 기준선 |

## characterization 계약

### A. P0 런타임·입력 경계

1. `FixedTimestep`는 `dt > 0.25`를 0.25로 제한한다.
2. 기본 1/60 step과 설정 가능한 step을 누산기에서 정확히 소비한다.
3. `maxIterations` 도달 후 남은 accumulator는 보존된다.
4. raw backlog 값과 render용 0~1 clamped alpha를 별도로 관찰한다.
   현재 public API가 raw값만 제공하므로 최소 변경 지점의 시그니처는
   후속 구현 세션에서 결정한다.
5. InputAdapter의 pending mouse/touch tap은 다음 snapshot에 한 번만 나타난다.
6. hold 상태는 `love.timer.getTime()` 기반 현재 동작을 기록하되, M1에서는
   게임 규칙 결정성을 도입하기 위한 변경을 하지 않는다.
7. SceneStack은 top scene에만 update와 snapshot을 전달한다.
8. push/replace는 onEnter, pop/replace는 onExit 순서를 현재 계약으로 기록한다.
9. VirtualResolution은 레터박스 scale/offset과 screen→virtual 좌표 왕복을
   보호한다.
10. HUD 패널 안의 아무 탭도 map placement로 전달되지 않는다.

### B. P0 gameplay 순서

1. 타워 `update`와 피해 적용은 모든 적 `update`보다 먼저 실행된다.
2. 적이 같은 tick에 죽으면 보상을 받고 목록에서 제거된다.
3. 죽지 않고 출구에 도달한 적은 생명 1을 잃고 목록에서 제거된다.
4. 웨이브 스폰은 적 이동 뒤 실행된다.
5. spawner가 끝나고 적 목록이 비면 build 또는 victory로 전이한다.
6. economy game over 판정은 웨이브 종료 판정 뒤 실행된다.
7. gameover/victory 상태의 일반 update는 게임 시스템을 진행하지 않는다.
8. start wave는 build 상태에서만 허용되고 phase 전이는 성공 시에만 일어난다.

### C. P1 도메인·실패 계약

1. Map의 범위 밖, 이미 점유된 셀, 입·출구, 경로 차단 배치는 실패한다.
2. 제거는 wall/tower에서만 성공한다.
3. 잘못된 tower type은 `nil`, `getCost`의 잘못된 type은 현재 `0`을 반환한다.
4. Economy의 골드 부족 지출은 false이고 gold/totalSpent를 바꾸지 않는다.
5. Enemy는 flying일 때 새 지상 경로를 무시한다.
6. 빈/잘못된 새 경로에 대한 현재 no-op 동작을 기록한다.
7. Tower target은 공중 제한, 사거리, 진행도 우선순서를 따른다.
8. Wave queue는 현재 delay 순서를 보존하고, 모든 queue가 끝난 뒤
   `spawning=false`가 된다.
9. Level data의 현재 3개 정의와 이름·맵·자원 초기값을 데이터 회귀 기준으로
   고정한다. 레벨 3의 다중 입구 기획은 이 작업에서 구현하지 않는다.

## M1 작업 묶음과 파일 범위

각 묶음은 다음 작업에 영향을 주지 않는 최소 행동 경계 하나를 보호한다.

### 작업 1 - Core Runtime Characterization

우선순위: P0

추가/수정 후보:

- `tests/core/fixed_timestep_harness.lua` 신규
- `tests/core/scene_stack_harness.lua` 신규
- `tests/core/virtual_resolution_harness.lua` 신규
- `tests/core/input_adapter_harness.lua` 신규
- `src/01_core/fixedTimestep.lua`의 최소 observational API 필요 여부 검토

완료 기준:

- A항의 1~9가 입력 fixture와 assertion으로 관찰된다.
- 구현 로직은 그대로이고 test-only 접근 필요 시 하나의 명시적 메서드만
  추가한다.

### 작업 2 - Input Consumption Characterization

우선순위: P0

추가/수정 후보:

- `tests/scenes/input_routing_harness.lua` 신규
- `tests/ui/hud_harness.lua` 신규
- `src/03_game/scenes/` 또는 `src/04_ui/hud.lua`의 최소 인젝션 지점 검토

완료 기준:

- top scene 입력 전달과 snapshot 1회 소비를 확인한다.
- HUD 안 tap 소비, HUD 밖 wall/tower placement, build 상태 start wave를
  시나리오로 확인한다.
- `love.graphics` stubs는 behavior test에만 쓰고 렌더 출력 검증은 추가하지
  않는다.

### 작업 3 - Gameplay Update Characterization

우선순위: P0

추가/수정 후보:

- `tests/scenes/gameplay_scene_harness.lua` 신규
- `src/03_game/scenes/gameplayScene.lua`의 최소 의존성 주입 또는 fixture
  helper 필요 여부 검토

완료 기준:

- B항의 1~8이 고정된 stub tower/enemy/wave/economy로 관찰된다.
- 타워 공격 → 적 이동/출구 → 스폰 → 종료 → 게임오버 순서를 이벤트 trace로
  비교한다.
- phase와 gold/lives/enemies/wave state fingerprint를 assertion한다.

### 작업 4 - Domain Gap Characterization

우선순위: P1

수정 후보:

- 기존 `map_harness.lua`
- 기존 `economy_harness.lua`
- 기존 `enemy_harness.lua`
- 기존 `tower_harness.lua`
- 기존 `wave_harness.lua`
- `tests/data/levels_harness.lua` 신규

완료 기준:

- C항의 1~9 중 기존 하네스가 아직 보지 않는 실패·경계 계약을 추가한다.
- 캐릭터라이징과 밸런스 검증을 분리한다. HP·속도 같은 수치는 구조 이동
  전 fingerprint fixture로만 사용한다.

### 작업 5 - Baseline Runner and Boundaries

우선순위: P2

추가 후보:

- `tests/run_all_harnesses.lua`
- 단일 하네스 runner 또는 공용 assertion helper가 필요한 경우에만
  `tests/support/`의 최소 유틸리티

완료 기준:

- 모든 하네스를 한 명령으로 실행하고 첫 실패에서 종료한다.
- 각 Lua 모듈의 `package.loaded` 격리 및 공용 `love` stub 충돌이 없다.
- M1 runner가 임의 파일 탐색이나 실행 순서 비결정성에 의존하지 않는다.

## 구현 순서

1. 기존 6개 하네스 기준선을 다시 실행하고 모두 녹색인지 확인한다.
2. `love`에 독립적인 P0 코어 하네스부터 추가한다.
3. SceneStack/InputAdapter/HUD 입력 전달을 작은 fixture로 보호한다.
4. GameplayScene update trace를 추가하되 현실 타이머나 LÖVE 창에 의존하지
   않는다.
5. 기존 도메인 하네스의 실패 계약과 level data fixture를 보강한다.
6. 마지막에 runner를 추가하고 전체 하네스를 단일 순서로 실행한다.
7. 소스 변경이 있었다면 각 변경의 목적을 “테스트 관찰을 위한 최소 훅”으로
   제한했는지 diff에서 검토한다.

## 실패·변경 정책

- 기존 동작과 테스트 예상값이 다르면 코드를 즉시 맞추지 않는다. 현재
  코드, GDD, ADR을 대조해 characterization 오류인지 실제 버그인지 구분한다.
- 기존 수치가 하네스에서 fail하면 밸런스값을 수정하지 않고 fixture나 ADR
  기대 결과를 조정한다.
- 버그가 발견되더라도 M1에서 규칙을 변경하지 않는다. 실패 계약을 기록하고
  다음 마일스톤 작업으로 분리한다.
- 소스에서 새 `love.*` 의존성을 추가하지 않는다.
- 하나의 테스트 훅이 두 행동 경계를 우회하면 더 작은 public seam 또는
  module fixture로 다시 설계한다.

## 검증 명령

개별 하네스는 기존 task `Lua: Run current test`로 실행한다.

기준선 전체 실행:

```sh
cd 02_tower_defense/tests
lua pathfinder_harness.lua
lua map_harness.lua
lua economy_harness.lua
lua enemy_harness.lua
lua tower_harness.lua
lua wave_harness.lua
```

M1 runner 추가 후:

```sh
lua 02_tower_defense/tests/run_all_harnesses.lua
```

실행 위치는 디렉터리 의존성을 줄이는 방향으로 runner에서 정규화한다.

## 종료 기준

- [ ] 기준선 6개 하네스 전체가 녹색이다.
- [ ] P0 런타임·입력 계약이 헤드리스로 관찰된다.
- [ ] GameplayScene update 순서와 phase/gameplay 결과가 fixture fingerprint로
  관찰된다.
- [ ] HUD 탭 소비와 map 입력 경계가 headless fixture로 관찰된다.
- [ ] P1 도메인 실패 계약이 기존 하네스에 추가된다.
- [ ] 반복 상한 뒤 raw/backlog alpha와 clamped render alpha가 구분된다.
- [ ] 전체 하네스 runner가 첫 실패에서 비정상 종료한다.
- [ ] 소스 변경은 최소 test seam만 포함하고 밸런스, 기능, UI는 변경하지
  않는다.
- [ ] M1에서 만든 소스가 Lua 5.1/LuaJIT와 LÖVE 11.5에서 문법 호환이다.
- [ ] `git diff --check`가 통과한다.
- [ ] 구현 세션 worklog에 변경 파일, 테스트 수, 실패·다음 TODO를 기록한다.

## 전체 LÖVE 실행 판정

M1 기본 검증에서는 제외한다.

근거:

- 고정 스텝, 입력 snapshot, Scene 생명주기, HUD 탭 소비는 fixture와 stub으로
  재현할 수 있다.
- M1은 렌더 픽셀, 보간 시각, 터치 감각, 프레임 타이밍 UX를 변경하지 않는다.
- 전체 실행은 구현 이후 실제 좌표 변환·렌더링 회귀가 하네스에서 재현되지
  않거나 다음 UX 마일스톤에서 입력/표현을 변경할 때만 수행한다.

## 다음 작업으로 넘길 정보

M1 완료 직후 다음 대상은 M2의 첫 경로 편집 Transaction이다. M1은 다음
fingerprint와 fixture를 다음 세션에 제공해야 한다.

- map grid와 current path
- economy gold/lives/totalSpent/totalEarned
- enemy 위치, HP, waypointIndex, slow state, reached/dead
- tower cooldown, target 선택, level
- wave currentWave, queue size, spawning, completion
- simulation step 순서와 입력 소비 순서

새 아키텍처를 이 목록보다 넓은 범위에 동시에 적용하지 않는다.
