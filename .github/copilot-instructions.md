# 02_tower_defense Copilot 지침

이 Copilot 환경의 활성 개발 대상은 `02_tower_defense/` 하나로 한다.
다른 프로젝트와 강의 자료는 참조하거나 수정하지 않는다.

## 우선 원칙

- 작은 모듈과 명시적 의존성을 사용하고 암묵적 전역을 만들지 않는다.
- Lua 코드는 `.github/instructions/lua-expert.instructions.md`, LÖVE2D 코드는 `.github/instructions/lua-love2d.instructions.md`를 따른다.
- 타워 디펜스의 기존 모듈 경계와 고정 타임스텝, 씬 스택, 가상 해상도 구조를 보존한다.
- 한 작업에는 하나의 목표를 두고, 관련 파일 밖의 기존 변경은 수정하지 않는다.
- 규칙, 스킬, 에이전트가 같은 작업을 설명할 때 가장 구체적인 파일 규칙을 우선한다.
- 코딩 전후에 관련 skill을 사용할 수 있으면 그 절차를 따른다.

## 작업 범위

- 기본 코드 범위: `02_tower_defense/src/`
- 테스트 범위: `02_tower_defense/tests/`
- 작업 기록: `02_tower_defense/worklogs/`
- 명시적 요청 없이는 `01_breakout/`, `c_tuto/`, `lua_tuto/`, `love2d_tuto/`, 문서 전체는 수정하지 않는다.

## 검증

Test Harness First:
- 기본값: 테스트 하네스(단위/모듈/시뮬레이션) 검증을 우선한다.
- 게임 전체 실행(LÖVE2D run)은 다음 경우에만 수행한다:
	- 입력/렌더/프레임 타이밍처럼 런타임 루프 확인이 필요한 변경
	- 하네스로 재현되지 않는 통합 문제 확인
- 불필요한 전체 실행은 반복하지 않고, 하네스 결과와 런타임 실행 결과를 분리해 보고한다.
- 코드 작업 결과에는 변경 파일, 동작 변화, 검증 결과를 포함한다.

주요 task:
- 타워 디펜스 실행: `Love2D: Run Tower Defense`
- 현재 헤드리스 테스트: `Lua: Run current test`
- Lua 파일 실행: `Lua: Run current file`

실행 방식은 task 이름을 우선하고, 환경에 따른 대안은 별도로 안내한다.