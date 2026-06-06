# 001 - 2026-05-30 - Game Architecture Direction

## 목적
- 현재까지 논의한 아키텍처 방향과 구현 원칙을 고정한다.
- 다음 세션/다른 디바이스에서도 같은 기준으로 이어서 개발할 수 있게 한다.

## 현재 프로젝트 상태 요약
- 대상: LÖVE2D 기반 세로 모드 벽돌깨기.
- 기준 해상도: 540x1200 (portrait).
- 가상 해상도/레터박스 적용.
- 레벨 데이터 분리 + 레벨별 테마/속도/체력 벽돌 반영.
- 기본 이펙트(사운드/파티클/화면 흔들림/점수 팝업) 적용.

## 합의한 기술 방향
- 메인 패턴: Hybrid.
- 권장 조합:
  1. Scene Stack (강력 추천)
  2. Mode Strategy (강력 추천)
  3. Flux 스타일 상태 관리 (메타/UI에 부분 도입)
  4. ECS (지금은 보류, 엔티티 폭증 시 ECS-lite 도입)

## 왜 이 방향인가
- Scene Stack: 메뉴/일시정지/결과/오버레이 전환에 강함.
- Mode Strategy: Classic/ComboRush/Survival 같은 모드 확장 시 핵심 물리 재사용 가능.
- Flux(부분): 세팅/진행도/선택 상태를 단방향으로 안정 관리.
- ECS 보류: 현재 스케일에선 과설계 리스크가 큼.

## 리팩터링 우선순위
1. 상태 전이 정리 (완료: 상태 상수화 + 전이 경로 정리)
2. 입력 어댑터 분리 (키보드/터치 공통 명령)
3. 레벨 데이터 검증 강화 (기본 구조 검증 추가됨)
4. 이펙트/점수 규칙 모듈화
5. 성능 미세 최적화(alive count 캐시, 파티클 풀)

## 세로 모드 운영 원칙
- 월드 좌표계는 고정(540x1200) 유지.
- 렌더링은 가상 해상도 계층에서 스케일링.
- 레벨 패턴과 배치 계산은 세로 기준으로 유지.
- 모바일 확장 시 입력은 터치 기준 우선 설계.

## 다음 구현 권장 순서
1. Input Adapter 도입 (keyboard + touch 공통 인터페이스)
2. Scene Stack 최소 골격 도입
3. Mode 인터페이스 도입 (classic mode 분리)
4. 체인 시스템(차별화 핵심) 추가

## 파일/모듈 권장 구조(초안)
- project/src/01_core/
  - virtualResolution.lua
  - sceneStack.lua
  - stateMachine.lua
- project/src/03_game/
  - breakout.lua
  - levels.lua
  - modes/
    - classicMode.lua
    - comboRushMode.lua
  - input/
    - inputAdapter.lua
    - touchInput.lua
- project/src/04_ui/
  - hud.lua

## 세션 간 인수인계 체크리스트
- 최근 worklog 파일 확인
- 현재 브랜치와 HEAD 커밋 확인
- 미커밋 변경 확인
- 실행 태스크로 동작 확인(run.sh 또는 Love2D task)
- 우선순위 TODO 1개만 선택해서 진행

## Worklog 운영 원칙
- 기본: 일일 1파일 원칙을 사용한다.
- 같은 날짜의 추가 작업은 새 파일을 만들지 않고 기존 날짜 파일에 누적 기록한다.
- 새 날짜가 시작되면 다음 번호로 새 worklog 파일을 생성한다.

## 세션 운영 플로우 (총괄 에이전트)
1. 세션 시작: `game-director`로 Top 3 우선순위 확정
2. 구현: Top 1부터 순차 진행 (하네스 우선 검증)
3. 점검: 전체 실행 검증은 필요 시 최소 수행
4. 기록: 같은 날짜 worklog 파일에 결정/변경/TODO 누적

참조 파일:
- `.github/agents/game-director.agent.md`
- `.github/skills/game-direction/SKILL.md`
- `.github/prompts/game-director-session.prompt.md`
