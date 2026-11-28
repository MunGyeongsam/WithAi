# 마일스톤 M1 - Characterization Harness

> 상태: 진행 예정
> 목표 기간: 구조 이동 전 선행 마일스톤
> 관련 M0 로드맵: [M0 implementation roadmap](M0-implementation-roadmap.md)
> 실행 계획: [TD-PLAN-001 M1 characterization 계획](TD-PLAN-001-M1-characterization-plan.md)
> 관련 ADR: [001-gameplay-architecture-review.md](../architecture/001-gameplay-architecture-review.md)
> 상세 설계: [002-deterministic-simulation-command-architecture.md](../architecture/002-deterministic-simulation-command-architecture.md)
> 후속 마일스톤: M2 - 경로 편집 원자성

## 목표

구조를 이동하거나 기능을 추가하기 전에 현재 플레이 동작을
헤드리스 characterization harness로 관찰 가능한 계약으로 보호한다.

M1은 새 아키텍처를 구현하는 단계가 아니다. 현재 동작의 정상 결과와
실패 결과를 회귀 기준선으로 남겨 M2 이후 변경이 의도된 것인지 우발적인
회귀인지 구분할 수 있게 한다.

## 사용자에게 제공하는 가치

- 입력, 고정 스텝, 전투 순서, 경제, 웨이브에서 플레이어가 체감하는 현재
  동작이 구조 변경 중에 흔들리지 않는다.
- 문제가 발생했을 때 화면 감각이나 추측이 아니라 fixture와 state
  fingerprint로 회귀 지점을 찾을 수 있다.
- LÖVE 창 없이 빠르게 반복 검증할 수 있어 이후 마일스톤의 입력·상태·경로
  변경에 대한 피드백 시간을 줄인다.

## 문서 역할 구분

| 문서 | 역할 | 이 문서와의 관계 |
|---|---|---|
| [M0 implementation roadmap](M0-implementation-roadmap.md) | M1~M6의 전체 순서, 목적, 선행 조건을 정의한다. | M1의 위치와 M2~M6 의존성을 제공한다. |
| 이 문서 | M1의 독립 범위, 산출물, 검증 대상, 종료 게이트를 정의한다. | M1이 끝났다고 판단하는 기준 문서다. |
| [TD-PLAN-001](TD-PLAN-001-M1-characterization-plan.md) | 현재 M1 실행 세션의 작업 묶음, 파일 후보, 구현 순서, 구체 계약을 정의한다. | M1 범위는 넘지 않는 세부 실행 입력이다. |

작업 순서가 바뀌어도 M1의 목표와 종료 게이트는 유지한다. 반대로 마일스톤
범위가 바뀌려면 M1 문서와 M0 로드맵을 함께 갱신해야 하며, 작업 계획만으로
범위를 확장하지 않는다.

## 선행 조건과 의존성

| 항목 | 상태 | 해소 기준 |
|---|---|---|
| 게임플레이 방향과 현재 규칙 | 준비됨 | GDD의 기존 핵심 루프와 후보 수치를 유지한다. |
| 아키텍처 선택 | 준비됨 | ADR-001 수락과 상세 Simulation/Command 설계가 존재한다. |
| M1 실행 계획 | 준비됨 | TD-PLAN-001이 P0/P1 계약과 검증 순서를 정의한다. |
| 현재 기준선 | 확인 필요 | M1 구현 시작 시 기존 하네스가 모두 녹색인지 다시 확인한다. |
| 최소 관찰 지점 | 조건부 | fixture만으로 관찰할 수 없을 때에만 테스트 목적의 최소 seam을 추가한다. |

## 범위

### 포함

- FixedTimestep, 입력 snapshot, SceneStack, 좌표 변환의 현재 동작 보호
- HUD와 map placement 사이의 입력 소비 우선순위 보호
- GameplayScene의 tick 순서와 phase 전이 보호
- 지도, 경제, 적, 타워, 웨이브의 정상·실패 경계 보강
- 현재 레벨 정의와 state fingerprint 기준선
- 모든 M1 harness를 결정적 순서로 실행하는 최소 runner

### 명시적 제외

- 게임플레이 규칙, 밸런스 수치, 적·타워 스펙 변경
- 새로운 배치, 판매, 업그레이드, Command/Transaction 구현
- HUD·렌더링·터치 UX의 기능 또는 시각 디자인 변경
- `GameState`, Simulation boundary, Factory의 선제적 도입
- 6/7/8웨이브 콘텐츠 구현과 M4 데이터 파이프라인 변경
- M2~M6 세부 마일스톤 문서 작성
- 리플레이, 저장, 네트워크, ECS, 범용 Event Bus 도입

## 산출물

| 산출물 | 소유 문서/모듈 | 완료 기준 |
|---|---|---|
| P0 runtime/input characterization | core·scene·input harness | 고정 스텝, snapshot 소비, scene 전달, 좌표 변환과 HUD 소비가 headless로 관찰된다. |
| P0 gameplay orchestration characterization | gameplay scene harness | update 순서와 phase·state 결과가 결정적 fixture trace로 관찰된다. |
| P1 domain boundary characterization | 기존 domain harness 보강 | 현재 정상·실패 계약과 level data fingerprint가 확인된다. |
| 통합 실행 기준선 | 하네스 runner | 정해진 순서로 전체 M1 harness를 실행하고 첫 실패에서 종료한다. |
| 최소 관찰 지점 | 필요 시 관련 source seam | 기존 동작을 바꾸지 않으며 테스트 관찰 목적 한 개가 명시된다. |
| 완료 근거 | 구현 worklog와 상태 문서 | 실제 변경 파일, 테스트 수, 미실행 항목, M2 인계가 기록된다. |

## 검증 대상

### P0 - 반드시 M1 종료 전에 관찰

- frame `dt` 제한, fixed step 누산, 반복 상한과 남은 accumulator
- raw backlog와 0~1 범위의 render interpolation 값 구분
- mouse/touch pending tap의 1회 소비
- SceneStack의 top-only update/input과 push/pop/replace 생명주기
- VirtualResolution의 scale, offset과 좌표 왕복
- HUD 영역 tap 소비 후 map placement에 전달하지 않는 동작
- build에서만 wave를 시작하는 phase 계약
- 타워 공격 → 적 이동/출구 → 스폰 → 웨이브 종료 → 게임오버 순서
- 적 사망 보상, 출구 생명 감소, victory/gameover 상태에서 일반 update 중단

### P1 - M1 종료 전에 실패·경계 계약 보강

- 잘못된 셀, 점유 셀, 입·출구, 경로 차단 배치 실패
- wall/tower 제거 성공 범위와 경제 실패 시 상태 불변
- 잘못된 tower type과 현재 `getCost` 실패 반환값
- flying enemy의 지상 경로 갱신 무시
- target 선택의 공중 제한, 사거리, 진행도 우선순위
- wave queue의 delay 순서와 spawning 완료 조건
- 현재 level 이름·맵·자원 초기값의 데이터 회귀

P0는 구조 이동의 순서와 입력 전달을 보호하는 회귀 게이트다. P1은 도메인
실패 경계를 넓혀 다음 Transaction 작업의 이전/이후 비교 입력을 만드는
게이트다.

## 검증 전략

- **우선 하네스**: Lua/LuaJIT에서 실행 가능한 단위 및 fixture 기반 통합
  harness를 사용한다.
- **결정성 검증**: 같은 fixture와 입력 순서에서 phase, gold, lives, path,
  unit state, queue, event trace fingerprint가 같은지 확인한다.
- **정적 경계 검증**: 새 test seam 외의 source 동작 변경과 `love.*` 의존성
  유입이 없는지 diff에서 확인한다.
- **전체 LÖVE 실행**: M1 기본 종료 검증에서 제외한다.
- **전체 실행 예외**: 실제 입력 콜백, 좌표 변환, 렌더링, 보간 시각처럼
  headless fixture로 재현되지 않는 회귀가 발견되었거나 해당 구현을 M1
  안에서 변경한 경우에만 최소 실행한다.

M1은 입력과 표현 로직을 바꾸지 않으므로 전체 LÖVE 실행을 반복하지 않는다.
터치 감각, HUD 시각 품질, 렌더 픽셀은 M5의 검증 대상이다.

## 관찰 가능한 종료 조건

M1은 다음 조건이 모두 확인되어야 완료로 기록할 수 있다.

- [ ] 기존 기준선과 새 P0/P1 harness가 정해진 runner에서 모두 통과한다.
- [ ] P0 입력·runtime·gameplay 순서가 fixture assertion 또는 trace로
  관찰된다.
- [ ] P1 domain 정상·실패 계약과 level fingerprint가 관찰된다.
- [ ] characterization 기대값이 코드에 없는 새 규칙이나 밸런스 결정을
  만들지 않는다.
- [ ] source 변경이 있었다면 변경마다 최소 test seam 목적과 불변 동작을
  설명할 수 있다.
- [ ] Lua 5.1/LuaJIT와 LÖVE 11.5 문법 경계를 유지한다.
- [ ] 전체 LÖVE 실행은 미실행이거나 예외 사유와 최소 실행 결과가 기록된다.
- [ ] `src/`와 `tests/` 변경의 실제 검증 결과가 구현 worklog에 기록된다.
- [ ] `git diff --check`가 통과한다.
- [ ] M2가 사용할 상태 fingerprint와 fixture 계약이 인계 문서에 있다.

## 위험과 대응

| 위험 | 영향 | 대응 |
|---|---|---|
| 현재 관찰값을 의도된 규칙으로 오해 | 우발적 동작이 영구 계약처럼 굳음 | GDD·ADR과 충돌하는 관찰은 수정하지 않고 별도 결정 항목으로 남긴다. |
| 테스트 가능성을 위해 큰 seam이나 DI 추가 | 구조 이동이 M1 안에서 시작됨 | fixture 하나로 단일 행동 경계를 노출하는 최소 지점만 허용한다. |
| 숫자와 타이밍 fixture가 구현 세부사항에 과결합 | 후속 리팩터링 비용 증가 | HP·속도는 fingerprint로만 쓰고, 외부 행동과 순서 중심으로 assertion한다. |
| 하네스 실행 순서와 공용 stub 충돌 | 결과가 비결정적이거나 재현되지 않음 | 명시적인 runner 순서와 Lua module 격리를 강제한다. |
| characterizing 중 실제 버그 발견 | M1이 규칙 수정 작업으로 확장됨 | 실패 계약을 기록하고 수정은 후속 작업으로 분리한다. |
| 하네스가 렌더·터치 UX까지 검증한다고 가정 | M1 기간 확대와 중복 실행 | headless로 보장 가능한 행동만 포함하고 표현 검증은 M5로 넘긴다. |

## M2 인계 조건

M2는 아래 항목을 M1의 입력으로 받아야 한다.

- 결정적 초기 fixture와 map grid/current path fingerprint
- economy의 gold/lives/totalSpent/totalEarned fingerprint
- enemy 위치, HP, waypoint, slow, 사망·출구 상태
- tower cooldown, target, level과 공격 순서 trace
- wave phase, queue, spawning, 완료 결과
- fixed-step 및 입력 소비 순서
- M1에서 관찰한 미해결 버그와 GDD/ADR 재판단이 필요한 항목

M1이 완료되지 않은 상태에서 M2가 `GameState`, CommandResult,
Transaction을 구현하기 시작하지 않는다. 다만 M2는 M1 harness를 안전하게
재사용하거나 기대값 변경 이유가 승인되었음을 확인한 뒤 기존 계약을 리팩터링할
수 있다.

## M2~M6 후속 문서 정책

M2~M6의 상세 마일스톤 문서는 각 마일스톤 착수 직전에 별도로 작성한다.
이번 M1 문서에서 동시에 만들지 않는다. 후속 검토 세션에서는 작성 시점의
선행 조건, M0 대비 갱신 시점, milestone template의 필수 항목만 확정하고
범위·종료 조건은 각 착수 문서에서 다시 확인한다.

## 마감 기록

- 완료일: 미정
- 실제 결과: 진행 예정
- 이월 항목: M1 종료 시 기록
- 관련 worklog: M1 구현 세션 종료 시 기록
