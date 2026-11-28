# Copilot 워크스페이스 지침

이 저장소의 활성 AI 개발 설정은 `AGENTS.md`, `.github/`, `.vscode/`와 `docs/ai/conventions.md`를 기준으로 한다.

## 우선 원칙

- 작은 모듈과 명시적 의존성을 사용하고 암묵적 전역을 만들지 않는다.
- Lua 코드는 `.github/instructions/lua-expert.instructions.md`, LÖVE2D 코드는 `.github/instructions/lua-love2d.instructions.md`를 따른다.
- 한 작업에는 하나의 목표를 두고, 관련 파일 밖의 기존 변경은 수정하지 않는다.
- 규칙, 스킬, 에이전트가 같은 작업을 설명할 때 가장 구체적인 파일 규칙을 우선한다.
- 코딩 전후에 관련 skill을 사용할 수 있으면 그 절차를 따른다.

## 검증

Test Harness First:
- 기본값: 테스트 하네스(단위/모듈/시뮬레이션) 검증을 우선한다.
- 게임 전체 실행(LÖVE2D run)은 다음 경우에만 수행한다:
	- 입력/렌더/프레임 타이밍처럼 런타임 루프 확인이 필요한 변경
	- 하네스로 재현되지 않는 통합 문제 확인
- 불필요한 전체 실행은 반복하지 않고, 하네스 결과와 런타임 실행 결과를 분리해 보고한다.
- 코드 작업 결과에는 변경 파일, 동작 변화, 검증 결과를 포함한다.

주요 task:
- Lua 실행: `Lua: Run current file`
- 벽돌깨기 실행: `Love2D: Run Breakout`
- 타워 디펜스 실행: `Love2D: Run Tower Defense`
- 현재 헤드리스 테스트: `Lua: Run current test`

실행 방식과 설치 경로는 학생 환경에 따라 다를 수 있으므로 task 이름을 우선하고 OS별 대안은 별도로 안내한다.