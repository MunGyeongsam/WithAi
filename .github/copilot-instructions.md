# 이 워크스페이스를 위한 Copilot 개발 지침

이 저장소는 Lua 및 LÖVE2D 워크스페이스입니다.

다음 규칙을 우선 따르세요:
- 모듈은 작게 유지하고 암묵적 전역은 피합니다.
- LuaJIT 및 LÖVE2D 호환 코드를 우선합니다.
- update와 draw 책임을 분리합니다.
- 게임 루프 동작은 결정적으로 유지하고 숨은 프레임 부수 효과를 피합니다.
- 동작을 변경할 때는 짧은 검증 단계를 함께 제시합니다.
- 학생별 OS와 런타임 차이를 가정하지 말고, 가능한 경우 저장소의 task와 공통 문서를 우선합니다.
- 특정 PATH, 특정 드라이브, 특정 운영체제 전용 명령은 기본값으로 가정하지 않습니다.

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