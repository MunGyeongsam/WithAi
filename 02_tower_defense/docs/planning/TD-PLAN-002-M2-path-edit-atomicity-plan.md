# 작업 계획 - TD-PLAN-002 M2 경로 편집 원자성 착수

> 상태: 완료
> 세션/작업일: 2026-11-28
> 담당: Copilot 세션
> 관련 마일스톤: [M2 path edit atomicity](M2-path-edit-atomicity.md)
> 관련 GDD: [tower defense GDD](../design/001_2026-11-28_tower-defense-gdd.md)
> 관련 ADR: [deterministic simulation command architecture](../architecture/002-deterministic-simulation-command-architecture.md)
> 기준 세션: [017_2026-11-28_session.md](../../worklogs/017_2026-11-28_session.md)

## 단일 목표

M2 경로 편집 원자성의 전체 범위, 최소 `GameState`/Command 계약, 첫 구현
단위, 파일 후보와 종료 게이트를 구현 전에 문서로 고정한다.

이 작업은 Simulation 또는 Transaction을 구현하지 않는다.

## 현황과 갭

### 현재 상태

- M1은 14개 harness와 79개 검증 사례가 Lua 5.1/LuaJIT에서 통과했다.
- 현재 배치는 `GameplayScene`이 `GameMap.canPlace`, `Economy.spend`,
  `Enemy.updatePath`를 순서대로 직접 호출한다.
- 기존 map 배치는 완전 경로 차단을 막지만 적 점유 셀과 안전 합류를 검증하지
  않는다.
- 새 GameState, Command 큐, CommandResult, Transaction 모듈은 없다.
- GDD `RT-01`~`RT-08`과 상세 아키텍처는 편집 원자성 계약을 이미 정의했다.
- 현재 적·타워 객체에는 명시적 실행 ID가 없고, `Enemy:updatePath`는 현재
  구간이 아니라 최근접 waypoint 선택만 수행한다.

### 이번 작업의 갭

- M2의 milestone 종료 조건을 별도 문서로 고정해야 한다.
- 전체 M2 구현을 작은 단일 책임 세션으로 나눌 작업 순서가 없다.
- 첫 세션의 `src/`·`tests/` 파일 후보와 회귀 기준이 없다.
- M3 판매·업그레이드 정책과 M2 타워 배치 범위를 분리해야 한다.
- Wave 10 victory와 M2 원자성 작업의 범위를 섞지 않아야 한다.

## 허용 범위

### 이 착수 작업에서 수정 가능

- `02_tower_defense/docs/planning/M2-path-edit-atomicity.md`
- `02_tower_defense/docs/planning/TD-PLAN-002-M2-path-edit-atomicity-plan.md`
- `02_tower_defense/docs/planning/SESSION-STATUS.md`
- `02_tower_defense/docs/planning/M0-implementation-roadmap.md`
- `02_tower_defense/worklogs/018_2026-11-28_session.md`

### 수정 금지

- `02_tower_defense/src/`
- `02_tower_defense/tests/`
- 밸런스 수치, 레벨 데이터, 웨이브 순서와 victory 전이
- UI·렌더링·입력 UX
- `02_tower_defense/run.bat`의 기존 사용자 변경

## M2 구현 분해

### TD-M2-001 - 최소 Command 경계

단일 목표: `GameState`, `CommandResult`, FIFO CommandProcessor를 headless로
관찰 가능하게 추가한다.

변경 후보:

- `src/02_model/gameState.lua` 또는 현재 패키지 규칙에 맞는 Simulation 경계
- `src/02_model/commandResult.lua`
- `src/02_model/commandProcessor.lua`
- `tests/model/command_processor_harness.lua`

이 작업의 Transaction 구현은 없다. 기존 Scene은 아직 직접 상태를 조정하며,
새 경계는 fixture 기반 unit contract만 검증한다. 독립 fixture의 객체 참조는
GameState의 소유권 이동을 표현하지 않으며, 실제 GameplayScene 연결은 후속
Transaction 세션에서 단일 변경 경로를 전환할 때 수행한다.

완료 기준:

- Command enqueue 순서와 동일 tick FIFO가 검증된다.
- `drain()` 결과가 시작 시점 Command 순서와 같고, drain 중 추가된 명령은
  다음 drain으로 남는다. Processor 자체는 `tick`을 증가시키지 않는다.
- accepted/rejected 결과에 commandId, accepted, code, revision, events가 있다.
- reject, invalid Command, terminal phase는 상태와 revision을 바꾸지 않는다.
- 잘못된 Command가 구조화된 `INVALID_COMMAND`로 실패한다.
- handler fixture가 상태 변경과 revision 증가를 직접 수행한 결과를 Processor가
  그대로 반환한다. Processor는 revision을 별도로 증가시키지 않는다.
- drain 시작 후 enqueue된 Command는 다음 drain으로 보존된다.
- M1 14/79 runner가 그대로 통과한다.
- 동일 pending queue에서 중복 Command ID와 동일 객체 재enqueue가
  `INVALID_COMMAND`로 거절되고 다른 항목 순서는 유지된다. 이전 drain ID
  이력은 Processor가 보관하지 않는다.

### TD-M2-002 - 첫 PLACE_WALL Transaction

단일 목표: 벽 추가 하나의 preview/commit/reject와 빈 적 목록 상태의 원자성을
구현한다.

완료 기준:

- 후보 grid에서만 경로를 계산한다.
- 범위·점유·골드·경로 실패가 실제 상태 fingerprint를 바꾸지 않는다.
- 성공 시 맵, 경로, 골드, revision만 같은 commit에서 변경된다.
- accepted commit마다 revision은 정확히 한 번 증가한다.
- fixed tick에서는 Command가 전투·이동보다 먼저 실행되는지 trace로 확인한다.
- M1 map/economy/gameplay 회귀가 통과한다.

### TD-M2-003 - 벽 제거와 적 합류

단일 목표: 모든 지상 적의 순방향 합류 계획을 추가하고 `REMOVE_WALL`도 같은
거래 계약으로 처리한다.

완료 기준:

- 적 좌표와 기존 경로는 preview에서 변하지 않는다.
- 현재 이동 구간의 통행 셀과 다음 waypoint 관계가 join plan으로 기록된다.
- 모든 지상 적의 합류가 준비되기 전 commit하지 않는다.
- `Enemy:updatePath`의 nearest waypoint 동작을 새 Transaction 합류에 사용하지
  않는다.
- 편집 후 progress가 기존 값보다 감소하지 않는다.
- `RT-01`~`RT-08` 중 합류 관련 사례가 통과한다.
- 공중 적은 경로와 좌표가 유지된다.
- dead/reachedEnd 적은 join plan에서 제외한다.

### TD-M2-004 - 타워 배치와 판매 preview seam

단일 목표: `PLACE_TOWER`에 맵·경로·객체 목록·골드·합류를 같은 원자성 계약으로
연결하고, M3 `SELL_TOWER`가 재사용할 제거 preview 경계를 준비한다.

완료 기준:

- 판매 환급·업그레이드는 구현하지 않는다.
- `REMOVE_TOWER` Command를 생성하지 않는다. 플레이어 타워 제거는 M3의
  `SELL_TOWER`에서 시작한다.
- 타워 객체 생성 실패도 부분 commit을 남기지 않는다.
- detached 타워 인스턴스가 preview에서 생성되고 commit은 목록 연결과 map
  점유만 수행해 commit 실패 지점을 제거한다.
- target 참조와 tower 목록의 거절 fingerprint가 유지된다.
- M1 tower/hud/gameplay 회귀가 통과한다.

### TD-M2-005 - RT 통합과 M2 종료 검토

완료 기준:

- `RT-01`~`RT-08` 단일 통합 harness가 Lua 5.1과 LuaJIT에서 통과한다.
- M1 runner와 M2 runner를 한 회귀 실행에서 확인한다.
- M2 종료 체크리스트와 wave victory 이월 항목을 업데이트한다.

## 첫 구현 세션 계약

다음 구현 세션의 단일 목표는 `TD-M2-001`이다.

### 최소 요구

1. `GameState.new`가 fixture의 map/economy/enemies/towers/wave 객체를 루트
   참조로 보관하되, 이 세션에는 GameplayScene을 연결하지 않는다.
2. 초기 `revision`, `tick`, `phase`와 명시적인 `nextEntityId`를 갖는다.
   Command ID는 Processor 밖의 fixture 생성기에서 단조 증가시킨다.
3. CommandProcessor는 FIFO queue와 결정적인 handler 디스패치만 한다.
4. CommandResult는 성공·실패를 반환하는 작은 데이터 생성자다.
5. CommandProcessor는 기존 Command ID를 보존하고 새 ID를 생성하지 않는다.
6. reject는 GameState를 변경하지 않고 현재 revision을 반환한다.
7. handler fixture가 성공 commit처럼 상태와 revision을 갱신하고,
   Processor는 그 결과를 그대로 반환한다.
8. 누락 ID·payload, 미등록 type은 Processor 검증으로, 금지 phase는 handler
   검증으로 구조화된 거절 결과가 된다.
9. 이 세션은 Scene, 입력, 경로, 경제, 타워, 적 구현을 변경하지 않는다.

### 다음 세션 파일 범위

허용:

- 새 Simulation/Core 계약 파일
- 새 CommandProcessor harness
- M2 실행 runner에 연결이 꼭 필요한 최소 수정

금지:

- `gameplayScene.lua`, `gameMap.lua`, `pathfinder.lua`, `enemy.lua`,
  `economy.lua`, `tower.lua`, `waveManager.lua`의 동작 변경
- Transaction preview/commit 구현
- HUD와 LÖVE 입력/렌더링 변경

## 실패 상태 fingerprint

M2 실패 검증은 최소한 다음 값을 편집 전후 문자열 또는 fixture로 비교한다.

- phase, tick, revision
- map grid, current path
- gold, lives, totalSpent, totalEarned
- tower ID·위치·level·cooldown·target
- enemy ID·좌표·HP·waypointIndex·progress·slow·dead/reachedEnd
- wave currentWave, queue, spawning
- nextEntityId

M2에서 신규 타워·적 ID를 fixture에 도입할 때는 1부터 시작하는 명시적 증가 값을
사용한다. 배열 인덱스나 메모리 주소를 식별자로 쓰지 않는다.

preview 결과 객체는 fingerprint에 포함하지 않으며, 실제 Simulation 상태와
분리해 검증한다.

## 회귀 및 검증 게이트

| 단계 | 검증 | 기대 결과 |
|---|---|---|
| 착수 전 | `lua5.1 02_tower_defense/tests/run_all_harnesses.lua` | 14 harness, 79 사례 통과 |
| TD-M2-001 | `Lua: Run current test` | Command 경계, FIFO, queue snapshot, reject 불변 통과 |
| Transaction마다 | M1 runner | 14/79 회귀 통과 |
| M2 종료 | M1 runner + M2 전용 통합 runner | `RT-01`~`RT-08`과 모든 기존 사례 통과 |
| Lua 호환성 | Lua 5.1/LuaJIT 구문·하네스 | 양쪽 성공 |
| 문서 | 링크, 필수 섹션, `git diff --check` | 깨짐·공백 오류 없음 |

- 전체 LÖVE 실행 판정: 불필요
- 판정 근거: 착수 문서와 TD-M2-001은 입력·렌더링·프레임 루프를 변경하지
  않으며 핵심 계약을 fixture로 검증할 수 있다.

## 위험과 대체 경로

| 위험 | 징후 | 대응 |
|---|---|---|
| 첫 세션이 Transaction까지 확장됨 | 새 plan/preview/map 변경 파일이 생김 | TD-M2-001은 Command contract만으로 줄이고 Transaction은 다음 ID로 넘긴다. |
| GameState가 기존 객체를 복사해 이중 상태가 됨 | Scene와 Simulation에서 서로 다른 상태로 보임 | 기존 객체 참조를 보관하고 복사는 fingerprint에만 사용한다. |
| M1 검증 기대값이 변경됨 | runner 사례 fail 또는 기대값 수정 필요 | 동작 회귀인지 의도된 계층 이동인지 대조하고 기대값은 별도 승인 없이 바꾸지 않는다. |
| 타워 제거가 판매로 확장됨 | 환급·투자액 파일이나 `REMOVE_TOWER`가 생김 | M2는 M3 `SELL_TOWER`용 preview seam까지만 준비한다. |
| 벽 제거 refund가 임시 규칙으로 굳음 | 플레이어에게 M3 이전 골드 지급이 연결됨 | M2는 gold 불변만 검증하고 M3 정책 전 사용자 입력으로 제거를 노출하지 않는다. |
| 합류 검증이 nearest waypoint 휴리스틱에 남음 | 역행·구간 건너뛰기 fixture가 실패 | 현재 구간과 출구 방향 연결성을 갖는 합류 plan을 별도 데이터로 계산한다. |
| 기존 적·타워에 ID 연결이 누락됨 | join/target 참조가 배열 삭제 뒤 다른 객체를 가리킴 | TD-M2-003에서 enemy ID, TD-M2-004에서 tower ID와 lookup fixture를 추가한다. |
| progress 재정규화가 감소함 | RT-05 또는 타겟 순서가 회귀 | old/new progress의 `max`와 targeting fixture를 검증한다. |
| 여러 실패 조건의 코드가 호출 순서에 따라 달라짐 | 같은 fixture 실행에서 거절 이유가 변함 | phase→shape→target→gold→path→join의 우선순위를 fixture로 고정한다. |

## 이번 문서 작업 완료 기준

- [x] M2 milestone 문서가 목표, 포함·제외, 산출물, 종료 게이트를 갖는다.
- [x] 첫 GameState/CommandResult/CommandProcessor 최소 범위를 정의했다.
- [x] 벽·타워 배치와 벽 제거의 preview/commit/reject 원자성을 정의했다.
- [x] 모든 지상 적 합류 성공 조건과 공중 적 제외를 정의했다.
- [x] 실행 ID, 현재 이동 구간, progress 단조성의 M2 계약을 정의했다.
- [x] 실패 fingerprint와 M1 14/79 회귀 입력을 고정했다.
- [x] Wave 10 victory와 M3 경제 정책을 별도 작업으로 분리했다.
- [x] 첫 구현 `TD-M2-001` 파일 범위와 완료 기준을 단일 목표로 제한했다.
- [x] `src/`와 `tests/`를 수정하지 않았다.
- [x] ADR 외 `REMOVE_TOWER` Command와 M3 경제 정책을 M2에서 배제했다.

## 세션 종료 보고

- 변경 파일: M2 milestone, TD-PLAN-002, 상태 문서, M0 링크, 새 worklog
- 검증 결과: 핵심 문서 링크 존재, 필수 섹션 확인, `git diff --check` 통과
- 완료되지 않은 항목: 없음
- 다음 세션 프롬프트: `TD-M2-001` 최소 Command 경계 구현
