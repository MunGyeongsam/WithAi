# Windsurf + Copilot + Lua/Love2D 설정 가이드

## 공통 항목과 도구 전용 항목

두 도구에서 공통으로 공유:
- 마크다운 문서 기반 프로젝트 구조와 코딩 컨벤션
- Lua formatter/linter 설정(stylua.toml, .luacheckrc, .editorconfig)
- Lua/Love2D 실행을 위한 .vscode 워크스페이스 설정

환경 중립 원칙:
- 학생마다 OS와 런타임 설치 상태가 다를 수 있으므로, 실행 지침은 단일 경로를 가정하지 않는다.
- 가능하면 VS Code task 또는 저장소에 포함된 실행 진입점을 우선하고, OS별 차이는 보조 विकल्प으로 분리한다.
- 특정 PATH, 특정 드라이브 경로, 특정 운영체제 전용 명령은 기본값으로 가정하지 않는다.

Copilot 전용:
- .github/copilot-instructions.md
- .github/instructions/*.instructions.md
- .github/agents/*.agent.md
- .github/skills/*/SKILL.md

Windsurf 전용:
- Windsurf 규칙과 메모리는 Windsurf 네이티브 설정/rules 에서 관리
- 마크다운 문서의 핵심 팀 규칙만 Windsurf rules 로 동기화

## 팀 기본 운영 기준

1. 공통 팀 규칙은 docs/ai/conventions.md 에 둔다.
2. 자동화 및 품질 게이트는 scripts/check.sh 에 유지한다.
3. 위 규칙을 Copilot 과 Windsurf 지침 체계에 동기화한다.
4. .github AI 파일은 Copilot 연동 계층으로 보고, 원본 규칙 저장소로 사용하지 않는다.
5. 토큰 효율과 도구 선택 기준은 docs/ai/ai-usage-guide.md 에 둔다.

## 이 워크스페이스의 Love2D 워크플로우

- 게임 실행: task "Love2D: Run project" 또는 "Run run.sh" / "Run run.bat"
- 현재 Lua 파일 실행: task "Lua: Run current file"
- LuaLS globals: love, jit, utf8

## 사전 요구사항

1. Love2D 를 설치하고, 각 학생 환경에서 사용 가능한 실행 방식(전역 `love`, 저장소 포함 런타임, 또는 VS Code task)을 하나 이상 준비한다.
2. 에디터에 Lua 언어 지원 확장을 설치한다.
3. 포맷/린트 일관성을 위해 StyLua + Luacheck 를 사용한다.
4. 실행 방식이 다르더라도 문서와 task 이름은 가능한 한 공통으로 유지한다.

## 공식 문서 기반 Windsurf 사용 가이드

1. 고급 에이전트 기능은 Windsurf 네이티브 에디터 사용을 우선한다. VS Code 플러그인은 유지보수 모드로 안내된다.
2. VS Code 플러그인을 사용할 경우 VS Code 1.89 이상을 사용한다.
3. 확장 충돌을 피하기 위해 AI 자동완성 제공자는 동시에 여러 개를 활성화하지 않는다.
4. Windsurf 에디터에서는 VS Code Marketplace 가 아니라 Open VSX 확장을 사용한다.

## 이 저장소에서 사용할 Windsurf 프로젝트 구조

- .windsurf/rules/*.md
- .windsurf/workflows/*.md
- .windsurf/skills/<skill-name>/SKILL.md
- AGENTS.md (root and optional subdirectories)
- .codeiumignore

## Rules 와 활성화 방식 (검증됨)

워크스페이스 rules 는 frontmatter trigger 모드를 지원:
- always_on
- model_decision
- glob (with globs)
- manual (activate via @rule-name)

실무 권장:
1. 항상 필요한 제약은 루트 AGENTS.md 에 둔다.
2. 디렉토리별 규칙은 하위 AGENTS.md 에 둔다.
3. 길고 선택적인 가이드는 model_decision rules 에 둔다.

## Skills vs Workflows (검증됨)

1. Skills 는 모델 판단으로 자동 호출되며 @skill-name 으로 수동 호출 가능하다.
2. Workflows 는 수동 전용이며 /workflow-name 으로 실행한다.
3. 보조 파일이 필요한 반복형 다단계 작업에는 Skills 를 우선한다.

## Memory 와 공유 동작 (검증됨)

1. 자동 메모리는 로컬 전용이며 워크스페이스 범위다.
2. 팀 지식은 .windsurf/rules 또는 저장소의 AGENTS.md 에 기록한다.
3. 개인 전역 기본값은 ~/.codeium/windsurf/memories/global_rules.md 를 사용한다.

## Ignore 전략 (검증됨)

1. Cascade 가 읽기/수정/인덱싱하지 않아야 할 경로를 위해 저장소 루트에 .codeiumignore 를 둔다.
2. 생성 산출물, 벤더 의존성, 대용량 에셋은 .codeiumignore 에 넣는다.
3. 조직 공통 ignore 는 ~/.codeium/.codeiumignore 를 사용한다.
