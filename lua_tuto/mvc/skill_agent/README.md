# 스킬 · 에이전트 학생 키트 — 개요

> 대상: 기말과제(바이브 코딩, 게임시스템설계 + 게임인공지능 공동 채점)
> 도구: **Gemini 앱(채팅 + 스킬)** 과 **Google Antigravity(코딩 에이전트)**
> 기준일: 2026-11. 도구 화면과 정책은 자주 바뀌므로 수업 전에 실제 계정으로 한 번 확인한다.

이 폴더 문서:
- [README.md](./README.md): 개요 (이 문서)
- [작성_가이드.md](./작성_가이드.md): 규칙, 스킬, 워크플로, 에이전트의 개념, 작성법, 사용 예시 3개씩
- [사용법_명시적_암시적.md](./사용법_명시적_암시적.md): 키트 항목별 동작 방식, 명시적 호출과 암시적 트리거 예시 3개씩, Antigravity/Gemini 앱 차이
- [프롬프트_예시집.md](./프롬프트_예시집.md): 나쁜 예 / 좋은 예 10쌍
- [강사노트.md](./강사노트.md): 학생이 볼 파일 순서, 도구 소개 요점, 예시 활용법 (진행자용)
- 학생 배포용 통합 가이드 (프롬프트 팁 포함): [../../../docs/ai/prompt-engineering-guide-student.md](../../../docs/ai/prompt-engineering-guide-student.md)

---

## 1. 왜 스킬과 에이전트인가

- 프롬프트를 매번 새로 쓰면 제약(Lua 5.1, `local`만 사용, MVC 경계)이 빠진다.
- 자주 쓰는 지시를 **재사용 가능한 파일**로 만들어 두면 매 세션 같은 품질을 얻는다.
- 학생은 키트를 **쓰는 것**에서 시작해, 자기 프로젝트용 스킬을 **직접 만드는 것**까지 간다. 이 과정이 작업 로그의 "개선 이력"이 된다.

## 2. 도구 현황 (2026-11 확인)

| 도구 | 형태 | 개인 무료 사용 | 비고 |
|---|---|---|---|
| Gemini 앱 | 채팅 + **스킬** | 가능 | Gems 는 개인 계정 기준 2026-11-17 읽기 전용, 2026-12-17 삭제. 학교(Workspace) 계정은 2027년 전환 |
| Antigravity | 코딩 에이전트 (IDE, VS Code 확장, CLI) | 가능 (주간 사용량 제한) | 규칙, 스킬, 워크플로, 커스텀 에이전트 지원 |
| Gemini CLI / Code Assist | 에이전트 | ❌ 2026-06-18 개인·무료 종료 | Antigravity 로 이전됨 |

**핵심 사실:** Gemini 앱과 Antigravity 는 같은 공개 표준([Agent Skills](https://agentskills.io/home))의 `SKILL.md` 를 쓴다. **스킬 파일 하나를 양쪽에서 쓸 수 있다.**

## 3. 네 가지 개념

| 종류 | 비유 | 언제 적용되나 | Antigravity 위치 | Gemini 앱 |
|---|---|---|---|---|
| 규칙 (Rules) | 교칙 | 항상, 또는 조건에 맞을 때 | `AGENTS.md`, `.agents/rules/*.md` | 스킬로 대체 |
| 스킬 (Skills) | 업무 매뉴얼 | 관련 작업일 때 AI 가 골라 읽음 | `.agents/skills/<이름>/SKILL.md` | ✅ 업로드 |
| 워크플로 (Workflows) | 체크리스트 | `/이름` 으로 직접 호출 | `.agents/workflows/<이름>.md` ※ | ❌ |
| 에이전트 (Agents) | 전문가 동료 | 역할을 맡기거나 위임 | `.agents/agents/<이름>.md` | ❌ |

> 한 문장: **규칙은 "항상 지킬 것", 스킬은 "이럴 때 이렇게", 워크플로는 "이 순서대로", 에이전트는 "이 역할만".**
>
> ※ 워크플로 파일 경로는 공식 문서에 명시돼 있지 않아 규칙·스킬과 같은 관례(`.agents/`)를 따랐다. Antigravity 의 Customizations → Workflows 패널에 보이는지 수업 전에 확인하고, 안 보이면 패널에서 새로 만든 뒤 내용을 붙여 넣는다.

## 4. 키트 구성

> 이 키트(`kit/.agents/`)는 학생 배포와 Antigravity 수업용 원본이다. 저장소 루트의 활성 개발 설정은 Copilot 전용 `.github/`이며, 이 키트와 동기화하지 않는다.

### 규칙 3개 (Antigravity 전용)

| 규칙 | 트리거 | 내용 |
|---|---|---|
| [project-core](./kit/.agents/rules/project-core.md) | `always_on` | 모듈 패턴, update/draw 분리, 결정적 루프, 출력 형식(변경 파일·리스크·검증) |
| [lua-love2d](./kit/.agents/rules/lua-love2d.md) | `model_decision` | LuaJIT/LÖVE 11 호환, 암묵적 전역 금지, 모듈 경계 |
| [lua-expert](./kit/.agents/rules/lua-expert.md) | `model_decision` | Lua 5.1 문법, 경계값 처리, 불필요한 할당 줄이기 |

> `project-core` 의 검증 예시는 VS Code task 이름(`Love2D: Run project`)이다. task 가 없는 환경에서는 `love .` 또는 헤드리스 테스트 실행으로 대신한다.

### 스킬 9개 (Gemini 앱 + Antigravity 공용)

| 스킬 | 하는 일 | 관련 과목 |
|---|---|---|
| [lua51-guard](./kit/.agents/skills/lua51-guard/SKILL.md) | Lua 5.1/LuaJIT/LÖVE 11 함정 점검 | 게임시스템설계 |
| [mvc-boundary](./kit/.agents/skills/mvc-boundary/SKILL.md) | MVC 계층 경계 위반 점검, 코드 배치 판단 | 게임인공지능 |
| [game-ai-pattern-coach](./kit/.agents/skills/game-ai-pattern-coach/SKILL.md) | 적 AI 패턴 선택 코칭 (골격과 힌트만, 완성 코드 금지) | 게임인공지능 |
| [headless-test-writer](./kit/.agents/skills/headless-test-writer/SKILL.md) | 창 없이 도는 테스트 작성 | 공통 |
| [worklog-writer](./kit/.agents/skills/worklog-writer/SKILL.md) | 작업 로그와 인계 메모 작성 | 공통 (로그 채점 핵심) |
| [prompt-improver](./kit/.agents/skills/prompt-improver/SKILL.md) | 프롬프트를 6요소 기준으로 진단·개선 | 공통 |
| [lua-expert](./kit/.agents/skills/lua-expert/SKILL.md) | Lua 문법, 테이블, 메타테이블, 모듈, 오류 처리 | 게임시스템설계 |
| [love2d-architect](./kit/.agents/skills/love2d-architect/SKILL.md) | 모듈 분리, 의존성 정리, 구조 리팩터링 | 공통 |
| [love2d-feature-scaffold](./kit/.agents/skills/love2d-feature-scaffold/SKILL.md) | update/draw 분리를 지키는 새 기능 골격 | 공통 |

### 에이전트 6개 (Antigravity 전용)

| 에이전트 | 허용 도구 | 역할 |
|---|---|---|
| [planner](./kit/.agents/agents/planner.md) | 읽기만 | 계획과 수정 허용 파일 목록 제시. 수정 불가 |
| [lua-reviewer](./kit/.agents/agents/lua-reviewer.md) | 읽기만 | Lua 문법·MVC·테스트 기준 리뷰 보고서 |
| [test-runner](./kit/.agents/agents/test-runner.md) | 읽기 + 명령 실행 | 테스트만 실행하고 결과 요약. 수정 불가. 서브에이전트 전용 (`mainAgent: false`) |
| [lua-expert](./kit/.agents/agents/lua-expert.md) | 제한 없음 (수정 가능) | Lua 언어 수준 설계·리팩터링 |
| [love2d-architect](./kit/.agents/agents/love2d-architect.md) | 제한 없음 (수정 가능) | 모듈 경계·의존성 구조 설계 |
| [love2d-feature-scaffold](./kit/.agents/agents/love2d-feature-scaffold.md) | 제한 없음 (수정 가능) | 게임플레이 기능 추가·재구성 |

> 설계 의도: 위 3개는 **코드를 고칠 수 없는 에이전트**다. 계획, 리뷰, 실행 결과를 보고 수정 여부를 판단하는 것은 학생 몫이다. 아래 3개는 코드를 고칠 수 있으므로 프롬프트에 **수정 허용 파일**을 반드시 적는다.
>
> 같은 이름(`lua-expert`, `love2d-architect`, `love2d-feature-scaffold`)이 규칙·스킬·에이전트에 함께 있다. 명시적으로 부를 때는 "lua-expert **스킬**로", "lua-expert **에이전트**에게"처럼 종류를 붙인다.

### 워크플로 3개 (Antigravity 전용)

| 워크플로 | 순서 |
|---|---|
| [/start-session](./kit/.agents/workflows/start-session.md) | 인계 메모 → 목표 1개 → 수정 허용 파일 → 되돌리기 지점 커밋 → planner 계획 → 승인 대기 |
| [/end-session](./kit/.agents/workflows/end-session.md) | test-runner → diff 요약(범위 밖 변경 표시) → lua-reviewer → worklog-writer → 커밋 메시지 제안 |
| [/prompt-expert](./kit/.agents/workflows/prompt-expert.md) | 요청 요약 → 빠진 목표·제약·출력 형식 찾기 → 확인 질문 → 짧은/상세 추천 프롬프트 |

## 5. 폴더 구조와 배포 파일

```
skill_agent/
├── README.md                 # 개요 (이 문서)
├── 작성_가이드.md
├── 사용법_명시적_암시적.md
├── 프롬프트_예시집.md
├── 강사노트.md
├── kit/.agents/              # 원본 (수정은 여기서)
│   ├── rules/<3개>.md
│   ├── skills/<9개>/SKILL.md
│   ├── agents/<6개>.md
│   └── workflows/<3개>.md
├── gemini_skills/<스킬>.zip  # Gemini 앱 업로드용 (스킬마다 1개, zip 최상위에 SKILL.md)
└── antigravity_kit.zip       # 학생 프로젝트 루트에 풀면 .agents/ 가 생김
```

## 6. 설치

**Gemini 앱**
1. gemini.google.com → 왼쪽 메뉴 **Customize** → 위쪽 **Skills**
2. 업로드 → `gemini_skills/` 안의 zip 하나 선택 (스킬마다 반복)
3. 업로드한 스킬을 활성화한다. 대화에서 자동으로 쓰이거나, 직접 지정할 수 있다. 여러 스킬을 함께 쓸 수 있다.

**Antigravity**
1. 학생 프로젝트 루트에서 `antigravity_kit.zip` 을 푼다 → `.agents/` 폴더가 생긴다.
2. 이미 `.agents/` 가 있으면 하위 폴더만 합친다.
3. Customizations 패널에서 스킬, 에이전트, 워크플로가 보이는지 확인한다.

## 7. 수업 운영 (1일차 실습에 포함)

| 시간 | 내용 |
|---|---|
| 10분 | 네 가지 개념 설명 (3절 표) |
| 10분 | 키트 설치 (Gemini 앱 또는 Antigravity) |
| 20분 | `lua51-guard` 를 켜고/끄고 같은 프롬프트 비교 → **작업 로그 #0** |
| 과제 중 | 학생이 자기 프로젝트용 스킬 1개 이상 직접 작성, "스킬 없이 vs 적용" 비교 기록 |

채점 연결: 제공 키트는 모든 학생이 같으므로 점수 차이를 만들지 않는다. 차이는 **활용 기록**과 **직접 만든 스킬**에서 나며, AI 협업 로그(10점)의 "개선 이력" 항목에서 평가한다.

## 8. 유지보수 메모

- 원본은 `kit/.agents/` 다. 수정 후 zip 을 다시 만든다 (macOS/Linux 예시):

```sh
cd lua_tuto/mvc/skill_agent
for d in kit/.agents/skills/*/; do n=$(basename "$d"); (cd "$d" && rm -f "../../../../gemini_skills/$n.zip" && zip -q -X "../../../../gemini_skills/$n.zip" SKILL.md); done
(cd kit && rm -f ../antigravity_kit.zip && zip -q -r -X ../antigravity_kit.zip .agents -x '*.DS_Store')
```

- Windows 에서는 탐색기에서 각 스킬 폴더의 `SKILL.md` 를 선택 → "압축(ZIP) 폴더로 보내기" 로 같은 결과를 만들 수 있다.
- Copilot 설정은 루트 `.github/`에서 별도로 관리한다. 교육용 `kit/.agents/` 변경을 `.github/`에 자동으로 복사하지 않는다.

## 참조 링크

- Gemini 앱 스킬 만들기: https://support.google.com/gemini/answer/17094296
- Gems → Skills 전환: https://support.google.com/gemini/answer/18560919
- Antigravity 스킬: https://antigravity.google/docs/skills
- Antigravity 규칙: https://antigravity.google/docs/rules
- Antigravity 규칙과 워크플로: https://antigravity.google/docs/rules-workflows
- Antigravity 커스텀 서브에이전트: https://antigravity.google/docs/subagents
- Gemini CLI → Antigravity CLI 전환: https://developers.googleblog.com/an-important-update-transitioning-gemini-cli-to-antigravity-cli/
- Agent Skills 공개 표준: https://agentskills.io/home
