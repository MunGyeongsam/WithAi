# 02_tower_defense 문서 인덱스

## 목적

이 폴더는 기획 방향, 구현 계획, 구조적 결정을 서로 혼동하지 않고
추적하기 위한 문서의 위치와 작성 기준을 정의한다.

문서는 정답을 미리 고정하는 기록이 아니라, 현재 판단 근거와 다음 행동을
세션 간에 연결하는 도구다. 특히 게임 방향이 확정되기 전에는 선택안을
나란히 기록하고 승인된 결론만 `확정` 상태로 표시한다.

## 문서 종류와 역할

| 종류 | 위치 | 역할 | 기록하지 않는 것 |
|---|---|---|---|
| GDD | `design/` | 플레이어 경험, 핵심 루프, 규칙, 콘텐츠, 밸런스의 기획 기준 | 구현 일정이나 세부 코드 설계 |
| 마일스톤 | `planning/` | 일정 구간에서 달성할 결과와 종료 조건 | 일일 실행 순서나 상세 기술 결정 |
| 작업 계획 | `planning/` | 한 세션 또는 작업 단위의 범위, 완료 기준, 검증 순서 | 이미 끝난 작업의 사실 기록 |
| 세션 상태 | `planning/SESSION-STATUS.md` | 세션 간 현재 작업, 우선순위, 차단 요소, 다음 행동 | 실제 변경 이력이나 다음 프롬프트 본문 |
| ADR | `architecture/` | 중요한 기술 선택의 맥락, 대안, 결과, 근거 | 기능 상세 기획이나 진행 상황 |
| worklog | `../worklogs/` | 실제 변경, 검증 결과, 결정, 다음 TODO의 세션 기록 | 미래 약속이나 아직 승인되지 않은 방향 |

## 폴더 구조

```text
docs/
├── README.md
├── design/
│   └── gdd-template.md
├── planning/
│   ├── SESSION-STATUS.md
│   ├── milestone-template.md
│   └── work-plan-template.md
├── architecture/
│   └── adr-template.md
├── templates/
│   └── worklog-template.md
└── copilot-github-usage-guide.md
```

## 템플릿

| 문서 | 템플릿 | 권장 파일명 예시 |
|---|---|---|
| GDD | [gdd-template.md](design/gdd-template.md) | `001_2026-11-28_tower-defense-gdd.md` |
| 마일스톤 | [milestone-template.md](planning/milestone-template.md) | `M1-prototype-playable.md` |
| 작업 계획 | [work-plan-template.md](planning/work-plan-template.md) | `TD-001-tower-selection-plan.md` |
| 세션 상태 | [SESSION-STATUS.md](planning/SESSION-STATUS.md) | 고정 파일 |
| ADR | [adr-template.md](architecture/adr-template.md) | `001-fixed-timestep-policy.md` |
| worklog | [worklog-template.md](templates/worklog-template.md) | `002_2026-11-28_session.md` |

## 기존 문서

- [타워 디펜스 개발 용어집](glossary.md):
  ADR, MVC, 패턴, 아키텍처, 테스트, Lua/LÖVE 용어의 정의와 프로젝트 적용 예
- [Copilot/GitHub 운영 자산 사용 가이드](copilot-github-usage-guide.md):
  이 프로젝트의 Agent, Skill, Prompt 선택과 세션 운영 참조
- [게임플레이 아키텍처 검토](architecture/001-gameplay-architecture-review.md):
  구현 전 MVC, 상태 소유권, 원자적 거래, 데이터/팩토리 선택안
- [결정적 Simulation Core + Command 아키텍처](architecture/002-deterministic-simulation-command-architecture.md):
  수락된 게임플레이 아키텍처의 계층, 계약, 원자적 거래, 결정성, 전환과 검증 기준
- [M0 구현 로드맵](planning/M0-implementation-roadmap.md):
  아키텍처 확정부터 밸런스·릴리스 검증까지의 마일스톤과 선행 조건
- [TD-ARCH-001 작업 계획](planning/TD-ARCH-001-work-plan.md):
  첫 아키텍처 검토 세션의 범위와 완료 기준

## 작성 규칙

1. 기존 문서는 덮어쓰지 않는다. 보완이 필요하면 새 번호 문서를 만들거나
   원 문서 상태에 후속 문서 링크를 추가한다.
2. 하나의 문서는 하나의 역할만 가진다. 작업 계획과 worklog를 같은 기록으로
   사용하지 않는다.
3. 모든 결론은 `초안`, `검토 중`, `확정`, `대체됨` 중 하나의 상태를 가진다.
4. 방향성 문장은 근거와 검증 가능한 관찰을 함께 적는다. 개인 취향만으로
   `확정`하지 않는다.
5. 비교 중인 선택안은 모두 남긴다. 예시 데이터나 범위는 예시임을 표시하고
   실제 기획 결정으로 취급하지 않는다.
6. ADR은 결정이 내려진 뒤 작성하되, 확정 전 검토가 필요하면 `검토 중`
   상태로 작성할 수 있다.
7. 계획의 각 완료 기준은 확인 가능해야 한다. "좋게 만든다" 대신
   "선택 상태가 HUD에 표시되고 관련 하네스가 통과한다"처럼 쓴다.
8. 구현 작업은 Test Harness First로 기술한다. 전체 LÖVE2D 실행은 입력,
   렌더링, 프레임 타이밍처럼 하네스로 확인할 수 없는 경우에만 계획한다.
9. 실제 `worklog`는 `02_tower_defense/worklogs/`에 작성한다.
   `docs/templates/worklog-template.md`는 복사용 양식일 뿐이다.
10. 문서에 구현되지 않은 수치가 등장하면 `예시`, `가설`, `확정값` 중
    하나를 명시한다.

## 권장 흐름

1. GDD에서 플레이어 경험과 선택안의 범위를 정한다.
2. 마일스톤에서 그 범위를 검증 가능한 단계로 나눈다.
3. 작업 계획에서 현재 한 작업의 파일 범위와 완료 기준을 정한다.
4. ADR에서 중요한 기술 선택과 대안 폐기 이유를 기록한다.
5. 구현 후 worklog에 실제 변경, 검증, 결정, 다음 TODO를 남긴다.
6. `start-session`은 세션 상태와 최신 worklog를 순서대로 읽고, `end-session`은
   상태 갱신과 새 worklog 작성을 완료한다.

## 변경 문서 검토

- 문서의 역할이 표의 정의와 일치하는가?
- 확정되지 않은 방향을 확정처럼 표현하지 않았는가?
- 필수 섹션과 예시가 유지되었는가?
- 링크와 권장 파일명이 실제 구조와 일치하는가?
- `src/` 또는 `tests/` 변경이 필요하다는 결론을 문서 검토와 혼동하지 않았는가?
