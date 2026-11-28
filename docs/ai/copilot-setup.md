# Copilot + Lua/LÖVE2D 개발환경 가이드

## 단일 설정 원천

이 워크스페이스의 활성 AI 개발 설정은 `.github/`에 둔다.

- `copilot-instructions.md`: 저장소 전체 원칙
- `instructions/*.instructions.md`: 파일 범위별 자동 규칙
- `skills/*/SKILL.md`: 관련 작업에서 선택되는 절차
- `agents/*.agent.md`: 명시적 역할과 위임
- `prompts/*.prompt.md`: 세션 시작, 종료, 요청 개선 같은 정형 작업

루트 `AGENTS.md`와 `docs/ai/conventions.md`는 사람과 편집자가 함께 참조하는 공통 원칙이다.

## 적용 흐름

1. Copilot이 `AGENTS.md`와 `.github/copilot-instructions.md`를 읽는다.
2. Lua 파일에는 `.github/instructions/lua-expert.instructions.md`가 적용된다.
3. LÖVE2D 코드에는 `.github/instructions/lua-love2d.instructions.md`도 적용된다.
4. 요청 성격에 맞는 skill 또는 custom agent가 추가로 선택된다.
5. 검증은 `.vscode/tasks.json`의 task를 우선 사용한다.

## 주요 에이전트

- `lua-expert`: Lua 언어, 데이터 구조, 오류 처리
- `love2d-architect`: 구조, 모듈 경계, 의존성
- `love2d-feature-scaffold`: 기능 구현과 update/draw 분리
- `lua-reviewer`: 읽기 전용 변경 검토
- `game-director`: 벽돌깨기 방향과 우선순위
- `c-master-instructor`: C 교육 콘텐츠

## 주요 스킬

- `lua51-guard`: Lua 5.1/LuaJIT/LÖVE 호환성
- `mvc-boundary`: MVC 계층 경계
- `headless-test-writer`: 헤드리스 테스트
- `release-check`: 변경 후 품질 점검
- `prompt-improver`: 프롬프트 개선
- `worklog-writer`: 작업 로그와 인계 메모

## 검증 task

- `Lua: Run current file`: 현재 Lua 파일 실행
- `Lua: Run current test`: 현재 헤드리스 테스트 실행
- `Love2D: Run Breakout`: 벽돌깨기 실행
- `Love2D: Run Tower Defense`: 타워 디펜스 실행
- `Run run.sh` / `Run run.bat`: 저장소 실행 스크립트

특정 설치 경로는 사용자 또는 VS Code 개인 설정에서 관리한다. 팀 저장소에는 특정 운영체제나 Homebrew 경로를 기본값으로 넣지 않는다.

## 환경 중립 원칙

학생마다 운영체제와 런타임 설치 상태가 다를 수 있으므로 task 이름과 저장소 스크립트를 먼저 사용한다. OS별 대안은 검증 실패 시에만 별도로 안내한다.

## 교육용 `.agents` 키트

`lua_tuto/mvc/skill_agent/kit/.agents/`는 학생에게 Antigravity 배포 파일을 설명하기 위한 교육 자료다. 루트의 활성 Copilot 설정이 아니며 `.github/`와 자동 동기화 대상도 아니다.
