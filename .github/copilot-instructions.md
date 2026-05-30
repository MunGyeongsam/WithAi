# 이 워크스페이스를 위한 Copilot 개발 지침

이 저장소는 Lua 및 LÖVE2D 워크스페이스입니다.

다음 규칙을 우선 따르세요:
- 모듈은 작게 유지하고 암묵적 전역은 피합니다.
- LuaJIT 및 LÖVE2D 호환 코드를 우선합니다.
- update와 draw 책임을 분리합니다.
- 게임 루프 동작은 결정적으로 유지하고 숨은 프레임 부수 효과를 피합니다.
- 검증은 테스트 하네스 우선으로 진행하고, 게임 실행 검증은 최소한으로 유지합니다.
- 학생별 OS와 런타임 차이를 가정하지 말고, 가능한 경우 저장소의 task와 공통 문서를 우선합니다.
- 특정 PATH, 특정 드라이브, 특정 운영체제 전용 명령은 기본값으로 가정하지 않습니다.

검증 정책 (Test Harness First):
- 기본값: 테스트 하네스(단위/모듈/시뮬레이션) 검증을 우선한다.
- 게임 전체 실행(LÖVE2D run)은 다음 경우에만 수행한다:
	- 입력/렌더/프레임 타이밍처럼 런타임 루프 확인이 필요한 변경
	- 하네스로 재현되지 않는 통합 문제 확인
- 에이전트는 가능한 경우 "실행 생략 가능 여부"를 먼저 판단하고, 불필요한 전체 실행을 반복하지 않는다.
- PR/리뷰 보고에는 "하네스 검증 결과"와 "필요 시 최소 실행 검증 1회"를 분리해서 기록한다.

주요 검증 태스크:
- Lua 실행: Lua: Run current file
- LÖVE2D 실행: Love2D: Run project
- 환경 차이가 있으면 task 이름을 우선하고, 대체 실행 경로는 설명에 분리합니다.

참조 규칙과 컨벤션:
- AGENTS.md
- docs/ai/conventions.md
- docs/ai/windsurf-copilot-setup.md
- docs/ai/ai-usage-guide.md
- .github/instructions/lua-expert.instructions.md
- .github/skills/lua-expert/SKILL.md
- .github/agents/lua-expert.agent.md
- .github/prompts/prompt-expert.prompt.md