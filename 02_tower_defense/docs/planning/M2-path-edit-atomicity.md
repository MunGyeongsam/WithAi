# 마일스톤 M2 - 경로 편집 원자성

> 상태: 계획됨
> 목표 기간: 착수 문서 확정 후 구현 세션 단위 진행
> 관련 GDD: [001 tower defense GDD](../design/001_2026-11-28_tower-defense-gdd.md)
> 관련 M0 로드맵: [M0 implementation roadmap](M0-implementation-roadmap.md)
> 상세 설계: [deterministic simulation command architecture](../architecture/002-deterministic-simulation-command-architecture.md)
> 실행 계획: [TD-PLAN-002](TD-PLAN-002-M2-path-edit-atomicity-plan.md)
> 후속 마일스톤: M3 - 경제·판매·업그레이드 거래

## 목표

벽·타워 배치와 벽 제거 요청을 Command/Transaction으로 변환해, 맵·경로·골드와
모든 지상 적의 합류 계획을 `preview -> commit` 또는 전체 `reject`로 원자적으로
처리한다.

## 사용자에게 제공하는 가치

- 이동 중 경로 편집이 적 좌표를 순간 이동시키거나 역행시키지 않는다.
- 경로·비용·합류 검증 중 하나라도 실패하면 사용자의 맵과 자원이 바뀌지 않는다.
- 공중 적은 지상 셀 편집의 영향을 받지 않으며 지상 적만 합류 계획을 갱신한다.
- UI가 단순 `false` 대신 구조화된 거절 이유를 후속 세션에서 사용할 수 있다.

## 범위

### 포함

- `GameState`, `CommandResult`, Command 큐와 처리 순서의 최소 Simulation 경계
- 벽 추가·제거의 원자적 preview/commit/reject
- 타워 추가의 원자적 preview/commit/reject
- M3 타워 판매 Transaction이 재사용할 수 있는 제거 preview 기반
- 새 지상 경로를 맵 편집마다 한 번 계산
- 현재 좌표를 유지하는 모든 지상 적의 순방향 합류 계획
- 적이 후보 셀 또는 현재 이동 구간을 점유한 경우 거절
- GDD `RT-01`~`RT-08`과 실패 상태 fingerprint
- Lua/LuaJIT headless transaction 통합 harness

### 제외

- 판매 환급률, 반복 경제 정책, 업그레이드 거래, `EC-01`~`EC-08` 구현
- 6/7/8웨이브 데이터와 Wave 10 victory 전이 수정
- ViewData, Render Event, HUD, 미리보기 UX, 결과 화면 구현
- 타워 종류·비용·데미지·사거리·적 속도 같은 밸런스 수치 변경
- 저장, 네트워크, ECS, 리플레이, 범용 Event Bus

ADR의 플레이어 Command 목록에는 독립 `REMOVE_TOWER`가 없다. 타워 제거 요청은
M3의 `SELL_TOWER`로 연결하며, M2는 맵 점유·객체 제거·합류 검증에 필요한 preview
계약과 타워 Factory 실패 원자성만 준비한다. 판매 환급과 총 투자액은 M3에서
담당한다.

벽 제거의 환급률도 M3 경제 정책에 속한다. M2는 제거 후보에서 기존 골드가
변경되지 않는 기하·경로·합류 원자성만 검증하며, M3이 확정하기 전 제거 성공에
골드 지급을 도입하지 않는다.

## 산출물

| 산출물 | 소유 모듈/문서 | 완료 기준 |
|---|---|---|
| 최소 Simulation 상태 경계 | `src/`의 신규 Simulation 계약 | GameState가 phase·tick·revision과 기존 map/economy/enemy/tower/wave 상태를 가진다. |
| Command 처리 계약 | CommandProcessor/CommandResult | 입력 순서를 보존하고 모든 거래 성공·실패가 구조화된 결과를 반환한다. |
| 경로 편집 Transaction | place/remove wall, place tower transactions | preview는 상태 불변이고, 하나라도 실패하면 commit하지 않는다. |
| 적 합류 planner | path/rejoin domain 경계 | 모든 지상 적의 계획이 성공해야만 하나의 편집으로 확정된다. |
| 통합 harness | `tests/`의 M2 transaction harness | `RT-01`~`RT-08`과 fingerprint 불변을 headless로 검증한다. |
| 인계 기록 | worklog와 상태 문서 | 변경 파일, 14/79 회귀 결과, 신규 테스트 수와 이월 항목이 기록된다. |

## 최소 계약

### GameState

M2의 첫 GameState는 기존 객체를 즉시 전부 복제하거나 교체하지 않는다.
Simulation이 소유하는 루트에 다음 상태를 최소한으로 묶는다.

```lua
{
    revision = 0,
    tick = 0,
    nextEntityId = 1,
    phase = "build",
    map = {...},
    economy = {...},
    enemies = {...},
    towers = {...},
    wave = {...}
}
```

`nextEntityId`는 적·타워 실행 인스턴스의 ID를 부여하는 데 사용하고 배열
인덱스와 분리한다. Command ID는 게임 상태가 아니라 입력/Controller의 Command
생성기가 갖는 세션 단위 단조 증가 카운터로 만든다. 생성기는 queue lifetime 동안
ID를 재사용하지 않는다. 기존 Scene/Enemy/Tower에 ID가 없는 전환은 TD-M2-003의
적 합류와 TD-M2-004의 타워 연결에서 명시적으로 추가하고, 기존 M1 harness
기대값을 유지한다.

`GameState` 도입은 M2에서 점진적으로 연결하며 기존 런타임에 도입되지 않은
RNG, ViewData, RenderEvent, 저장 상태를 요구하지 않는다. 초기 구현에서 기존
객체를 참조로 보관하는 경우에도, 연결 완료 후 `GameState` 밖의 두 번째 변경
경로를 남기지 않는다. TD-M2-001은 독립 fixture 계약만 검증하고 GameplayScene의
상태 소유권을 아직 이동하지 않는다.

### Command와 CommandResult

- 동일 tick의 Command는 enqueue 순서대로 실행한다.
- M2 플레이어 Command 종류는 `PLACE_WALL`, `REMOVE_WALL`, `PLACE_TOWER`로
  제한한다.
- Command는 생성 시 `id`, `type`, `tick`, `payload`를 가지며 CommandProcessor는
  누락되거나 등록되지 않은 명령을 `INVALID_COMMAND`로 거절한다.
- Command 생성자가 명시적인 단조 증가 ID를 부여한다. Processor는 기존 ID를
  보존하며 새 ID를 할당하지 않는다.
- `build`와 `wave` phase에서만 경로 편집을 허용하며 `gameover`, `victory`는
  `INVALID_PHASE`로 거절한다.
- 성공은 `accepted=true`, `code="COMMITTED"`이고 revision이 commit 뒤 값이다.
- 거절은 `accepted=false`이며 M2에서 실제 사용하는 원인 코드만 반환한다.
- `INVALID_PHASE`, `INVALID_COMMAND`, `INVALID_CELL`, `CELL_OCCUPIED`,
  `INSUFFICIENT_GOLD`, `PATH_BLOCKED`, `ENEMY_OCCUPIES_CELL`,
  `NO_SAFE_JOIN`, `TARGET_NOT_FOUND`를 우선 사용한다.
- `CommandResult`는 상태를 소유하지 않는다. commit 가능한 handler 또는
  Transaction만 revision을 증가시킨다. CommandProcessor는 handler의 결과를
  전달하고 성공 결과를 관찰하기 위해 별도로 상태를 변경하지 않는다.
- M2의 `events`는 순서가 보존된 결과 데이터이거나 빈 배열이다. Render Event
  소비자와 시각 효과 연결은 이 마일스톤에서 구현하지 않는다.
- `drain()`은 시작 시점 큐의 CommandResult를 생성 순서대로 배열에 담아
  반환한다. drain 중 새로 enqueue된 Command는 다음 drain에 남는다.
- CommandProcessor는 큐에 넣은 Command 참조를 실행 중 수정하지 않는다. 동일
  Command 객체나 ID를 같은 pending queue에 두 번 넣으면 뒤 항목은
  `INVALID_COMMAND`로 거절한다. 이전 drain에 사용된 ID의 영구 이력 검사는
  Processor가 저장하지 않으며, 생성기의 단조 증가가 이를 보장한다.

### Transaction

1. `preview(state, command)`는 상태를 읽기만 하고 모든 변경량을 계산한다.
2. preview는 map grid, current path, 골드, 적과 타워 목록, revision, tick을
   포함한 실제 상태를 변경하지 않는다.
3. 후보 맵에서 경로를 계산하고 모든 지상 적의 합류 계획을 만든다.
4. 공중 적은 합류 계획과 지상 점유 검사에서 제외한다.
5. 한 적이라도 합류에 실패하면 preview는 전체 reject가 된다.
6. 모든 검증이 통과했을 때만 commit이 맵, 경로, 적 합류, 비용, revision을
   한 작업으로 변경한다.
7. commit 중 실패는 설계하지 않는다. 발견하면 preview 누락으로 취급한다.
8. reject와 취소는 `accepted=false` 결과만 반환하고 revision을 유지한다.
9. 동일 명령에서 검증 순서는 phase → 명령 shape → 대상 셀/타입 → 점유 → 골드
   → 후보 경로 → 적 점유/합류 순서로 고정한다. 같은 상황에서 여러 조건이
   실패해도 항상 같은 첫 거절 코드가 반환된다.
10. 타워 생성처럼 실패 가능한 런타임 객체 작업은 commit 전에 detached
    인스턴스를 생성하고, commit은 검증된 값과 인스턴스를 붙이는 작업만 한다.
11. `REMOVE_WALL`은 대상 셀이 wall인 경우만 유효하다. 빈 셀, 입·출구, 타워 셀은
    `TARGET_NOT_FOUND`로 거절한다. commit은 지불 비용·환급 계산을 다시 검사하지
    않고 preview에 계산된 값을 그대로 적용한다.

## 적 합류 불변 조건

1. 편집 성공 후에도 적의 현재 `x`, `y` 좌표는 commit 시점에 변하지 않는다.
2. 새 경로는 편집당 한 번 계산하며 같은 경로를 공유한다.
3. 적마다 현재 구간에 맞는 다음 waypoint와 합류 지점을 결정한다.
4. 다음 이동은 출구 방향으로만 진행한다. 입구 방향 역행, 구간 건너뛰기,
   좌표 보정 순간 이동을 금지한다.
5. 현재 구간을 끝내야 새 경로에 진입할 수 있는 적은 현재 waypoint 정보를
   유지하고, 새 경로에 순방향으로 연결될 합류 계획을 가진다.
6. 일부 적의 합류가 실패하면 그 어떤 적도 새 경로를 받지 않는다.
7. 적 좌표를 포함한 진행 상태 fingerprint는 거절 후 완전히 같다.
8. 현재 이동 구간의 점유 계산은 현재 셀과 다음 `waypointIndex` 목표 셀 사이를
   연결하는 통행 셀 전체를 포함한다. 선분이 실제 grid 셀을 건너뛴 것으로
   해석되는 경우 해당 편집은 거절한다.
9. 각 적의 합류 계획은 `enemyId`, 기존 구간의 완료 조건, 새 경로의 첫 연결
   waypoint, 연결 후 waypoint index를 값으로 계산한다. commit 시 적은 이 계획을
   한꺼번에 받고 좌표를 즉시 보정하지 않는다.
10. commit 후 `progress`는 기존 값보다 감소하지 않는다. 경로 길이가 짧아진
    경우 정규화된 진행도를 그대로 재계산해 뒤로 가는 대신 `max(old, new)`로
    단조성을 보존한다.
11. `dead` 또는 `reachedEnd` 적은 합류 계획에서 제외한다. 같은 fixed tick에서
    새로 스폰되는 적은 Command drain 뒤 새 current path로 생성된다.

### 합류 모델 제약

현재 `Enemy:updatePath`는 가장 가까운 waypoint 하나를 골라 `waypointIndex`를
교체한다. 이 동작은 GDD의 현재 구간 완료·순방향 연결 보장을 표현하지 못하므로
M2 Transaction은 이 메서드를 직접 호출하지 않는다. 기존 메서드는 M1 회귀를
위해 유지하되, 새 합류 planner는 현재 구간과 연결 waypoint를 명시적으로
구분한 join plan을 반환한다.

## 작업 묶음

1. `TD-M2-001`: 최소 GameState, CommandResult, CommandProcessor 계약과 fixture
2. `TD-M2-002`: 첫 `PLACE_WALL` preview/commit/reject Transaction
3. `TD-M2-003`: 벽 제거와 모든 지상 적 순방향 합류
4. `TD-M2-004`: 타워 배치와 M3 판매용 preview seam
5. `TD-M2-005`: `RT-01`~`RT-08` 통합, M1 회귀, M2 종료 검토

## 의존성과 선행 조건

| 항목 | 상태 | 해소 기준 |
|---|---|---|
| M1 characterization | 완료 | 14 harness, 79 사례가 Lua 5.1/LuaJIT에서 통과 |
| GDD 합류·원자성 규칙 | 준비됨 | `RT-01`~`RT-08`과 편집 원자성 정책 존재 |
| Simulation/Command ADR | 준비됨 | 상세 계약과 의존성 방향 존재 |
| M2 실행 계획 | 준비됨 | `TD-PLAN-002`가 첫 구현 파일 범위와 종료 조건을 고정 |
| 실행 인스턴스 ID | 미정 | TD-M2-003에서 적 ID, TD-M2-004에서 타워 ID를 연결하고 중복/재사용 금지 계약을 harness로 확인 |
| Wave 10 victory | 별도 이월 | M2 거래와 섞지 않고 별도 작업으로 유지 |

## 검증 전략

- **우선 하네스:** Lua 5.1로 M1 runner와 신규 transaction harness 실행
- **결정성:** 동일 state fingerprint와 Command 순서에서 같은 결과와 revision 확인
- **거절 불변:** 실패 전후의 맵, 경로, 골드, 적, 타워 fingerprint 완전 비교
- **통합:** `GameplayScene`이 CommandProcessor를 한 경로로 사용하도록 연결한 후
  입력 라우팅 회귀를 실행
- **실행 순서:** fixed tick 시작에 Command를 FIFO로 전부 drain한 뒤 전투·이동
  순서를 기존 gameplay 업데이트와 동일하게 진행하고, CommandProcessor 자체는
  tick을 증가시키지 않는다.
- **전체 실행:** M2 구현 기본 종료에서는 제외
- **전체 실행 예외:** 실제 입력 preview, 시각적 합류, 터치 좌표를 변경한 경우에만
  최소 LÖVE 실행

## 종료 기준

- [ ] M1의 14 harness·79 사례가 변경 후에도 모두 통과한다.
- [ ] `GameState`, Command 큐, `CommandResult`가 단일 소유·입력 순서를 보장한다.
- [ ] 벽·타워 배치와 벽 제거 모두 preview에서 충분한 검증을 수행한다.
- [ ] 모든 지상 적의 합류가 성공한 경우에만 commit한다.
- [ ] accepted commit마다 revision은 정확히 한 번 증가한다.
- [ ] 거절은 맵·경로·골드·타워·적 상태 fingerprint를 바꾸지 않는다.
- [ ] 공중 적의 경로와 좌표가 지상 편집에 의해 변하지 않는다.
- [ ] 적·타워 ID, Command ID, queue 결과가 배열 인덱스와 결합되지 않는다.
- [ ] 동일 입력 실패가 deterministic한 첫 거절 코드와 빈 state diff를 반환한다.
- [ ] 현재 이동 구간과 새 경로 합류가 좌표 변경 없이 계획·적용된다.
- [ ] `RT-01`~`RT-08`이 Lua/LuaJIT harness에서 관찰된다.
- [ ] ADR에 없는 `REMOVE_TOWER` Command를 추가하지 않는다.
- [ ] 밸런스·HUD·웨이브 데이터·victory 문제가 변경되지 않는다.
- [ ] `git diff --check`와 신규 하네스가 통과한다.
- [ ] M3로 판매 환급과 업그레이드 경제 계약을 이관한다.

## 위험과 대응

| 위험 | 영향 | 대응 |
|---|---|---|
| 기존 Scene과 새 GameState 사이 상태가 이중 소유됨 | 부분 변경과 디버깅 난이도 증가 | TD-M2-001은 독립 fixture만 검증하고, 실제 연결 세션에서는 GameState를 읽기·쓰기의 단일 진입점으로 전환한다. |
| 적 합류를 nearest waypoint 선택으로 단순화 | 역행·단축·순간 이동이 생김 | 합류를 현재 진행 구간, 순방향 연결 가능성, 좌표 유지의 결과 계획으로 검증한다. |
| preview 도중 원본 맵을 임시 변경 | reject 후 상태 오염 | 후보 grid와 경로·합류 결과를 값으로 복사해 실제 상태와 분리한다. |
| 거래마다 전체 state를 이동 | 큰 리팩터링과 회귀 확대 | Lua 객체는 기존 모듈에 유지하고 상태 경계만 점진적으로 좁힌다. |
| M3 판매 정책이 M2로 유입 | 비용·환급 규칙 재정의 | M2는 타워 배치와 판매용 preview seam만 두고 실행 `SELL_TOWER`와 환급은 M3에서 담당한다. |
| 벽 제거 refund가 M2에서 임시 규칙으로 굳음 | 제거 사용자가 GDD와 다른 경제 결과를 얻음 | M2 harness는 제거 중 골드 불변만 검증하고, M3 전에는 사용자 입력 경로로 `REMOVE_WALL`을 노출하지 않는다. |
| 적/타워 ID 도입이 배열 순서를 바꿈 | target, join plan, 판매 대상이 다른 객체를 가리킴 | TD-M2-003/004에서 ID lookup fixture를 먼저 보호하고 Transaction은 인덱스 대신 ID를 사용한다. |
| progress 정규화가 타겟 우선순위를 역행시킴 | 합류만으로 타워 target이 뒤쪽 적으로 바뀜 | commit 후 progress 단조성을 fingerprint와 targeting fixture로 검증한다. |

## 마감 기록

- 완료일: 미정
- 실제 결과: 미정
- 이월 항목: 판매·업그레이드 경제, Wave 10 victory, 입력 preview UX
- 관련 worklog: 미정
