# `.github` Copilot 운영 자산 사용 가이드

## 1. 목적

이 문서는 `.github/`에 있는 모든 운영 문서를 반복 사용하기 위한 참조서다.
각 문서에 대해 다음 세 가지를 구분한다.

- **암시적 사용**: Copilot 또는 VS Code가 작업 맥락과 파일 형식에 따라 자동 적용
- **명시적 사용**: 대화에서 문서, Agent, Skill 이름을 직접 지정
- **쉬운 사용법**: 복사해서 사용할 수 있는 짧은 프롬프트

상세한 기본 규칙과 프로젝트 범위는 [../../.github/copilot-instructions.md](../../.github/copilot-instructions.md)를 따른다.

> 권장 원칙: 규칙은 자동 적용되게 두고, 중요한 작업에서는 사용할 Agent나 Skill을 명시한다.

## 2. 전체 선택 기준

| 작업 단계 | 기본 선택 | 보조 선택 |
|---|---|---|
| 세션 시작 | `start-session` | `game-direction` |
| 다음 작업 결정 | `game-director` | `game-direction` |
| 프롬프트 개선 | `prompt-improver` | `prompt-improver.prompt.md` |
| 구조 설계 | `love2d-architect` | `mvc-boundary`, `love2d-architect` Skill |
| 기능 구현 | `love2d-feature-scaffold` | `headless-test-writer`, `lua51-guard` |
| Lua 문제 해결 | `lua-expert` | `lua51-guard` |
| 변경 검토 | `lua-reviewer` | `release-check` |
| 세션 종료 | `end-session` | `worklog-writer` |

Agent와 Skill을 모두 많이 호출하는 것보다 다음 조합이 효율적이다.

```text
작업 주도 Agent 1개
+ 작업 절차 Skill 1개
+ 종료 검토 lua-reviewer 또는 release-check 1개
```

## 3. 암시적 규칙 문서

이 문서는 작업 파일의 종류와 저장소 맥락에 따라 자동 적용될 가능성이 높다.
중요한 작업에서는 자동 적용을 가정하지 말고 짧게 명시하는 것이 안전하다.

### 3.1 `copilot-instructions.md`

파일: [../../.github/copilot-instructions.md](../../.github/copilot-instructions.md)

| 항목 | 내용 |
|---|---|
| 역할 | 현재 활성 프로젝트 범위와 일반 개발 원칙 지정 |
| 암시적 사용 | 저장소의 일반 Copilot 대화에서 프로젝트 규칙으로 참고 |
| 명시적 사용 | `.github/copilot-instructions.md를 최우선으로 적용해 주세요.` |
| 쉬운 사용 | `02_tower_defense만 수정하고, 한 작업에 목표 하나만 처리해 주세요.` |
| 추천 시점 | 모든 세션 |

반드시 기억할 적용 범위:

- 활성 프로젝트: `02_tower_defense/`
- 코드: `src/`
- 테스트: `tests/`
- 기록: `worklogs/`
- 외부 범위는 명시적 요청 없이는 수정하지 않음
- Test Harness First 원칙 적용

쉬운 시작 문구:

```text
.github/copilot-instructions.md를 적용해 주세요.
이번 세션은 02_tower_defense의 단일 목표만 처리합니다.
```

### 3.2 `instructions/lua-expert.instructions.md`

파일: [../../.github/instructions/lua-expert.instructions.md](../../.github/instructions/lua-expert.instructions.md)

| 항목 | 내용 |
|---|---|
| 역할 | Lua 5.1/LuaJIT 문법, 오류 처리, 성능 규칙 |
| 암시적 사용 | `**/*.lua` 파일 작업에 자동 적용 가능 |
| 명시적 사용 | `lua-expert.instructions.md 기준으로 Lua 5.1 호환성을 확인해 주세요.` |
| 쉬운 사용 | `LuaJIT 호환을 지키고 암묵적 전역 없이 수정해 주세요.` |
| 추천 시점 | 모든 Lua 구현 및 검토 |

주요 금지 사항:

- `table.unpack`, `goto`, `//`
- `<const>`, `<close>`
- 선언 없는 전역 대입
- 오류 은폐와 추측 기반 타입 변환

### 3.3 `instructions/lua-love2d.instructions.md`

파일: [../../.github/instructions/lua-love2d.instructions.md](../../.github/instructions/lua-love2d.instructions.md)

| 항목 | 내용 |
|---|---|
| 역할 | LÖVE2D 게임 루프, MVC, 검증 책임 |
| 암시적 사용 | `**/*.lua` 파일 작업에 자동 적용 가능 |
| 명시적 사용 | `lua-love2d.instructions.md 기준으로 update/draw와 MVC 경계를 지켜 주세요.` |
| 쉬운 사용 | `상태 변경은 update에, 렌더링은 draw에 두고 헤드리스 테스트부터 작성해 주세요.` |
| 추천 시점 | 모든 LÖVE2D 기능 설계와 구현 |

주요 요구:

- Model은 `love.*`에 의존하지 않음
- View는 상태를 변경하지 않음
- Controller는 입력만 해석함
- `main.lua`는 의존성 조립과 실행 순서만 담당
- 프레임 동작은 고정 스텝 기준

## 4. 명시적으로 선택하는 Agent

Agent는 세션의 **주 전문가**다. 일반적인 Agent 호출 대신 아래 역할 중 하나를 직접 지정한다.

### 4.1 `game-director`

파일: [../../.github/agents/game-director.agent.md](../../.github/agents/game-director.agent.md)

- **암시적 사용**: “다음에 무엇을 할까?”처럼 방향성 또는 우선순위 요청에서 선택될 수 있음
- **명시적 사용**: `game-director 에이전트로 작업해 주세요.`
- **쉬운 사용**:

```text
game-director 에이전트로 최신 worklog와 현재 코드의 핵심 갭 3개만 찾아 주세요.
이번 세션 Top 3, 완료 기준, 하네스 검증을 제안해 주세요. 코드는 수정하지 마세요.
```

- **추천 시점**: 세션 시작, 방향 점검, 마일스톤 우선순위 결정
- **하지 않을 일**: 세부 Lua 구현의 전담

### 4.2 `love2d-architect`

파일: [../../.github/agents/love2d-architect.agent.md](../../.github/agents/love2d-architect.agent.md)

- **암시적 사용**: 모듈 경계나 구조 재설계 요청에서 선택될 수 있음
- **명시적 사용**: `love2d-architect 에이전트로 작업해 주세요.`
- **쉬운 사용**:

```text
love2d-architect 에이전트로 GameplayScene의 책임을 분석해 주세요.
먼저 현재 구조와 위험을 보여 주고, 최소 변경안과 검증 계획만 작성하세요.
아직 코드는 수정하지 마세요.
```

- **추천 시점**: 책임 분리, 의존성 재정리, 큰 리팩터링
- **하지 않을 일**: 기획 방향 결정

### 4.3 `love2d-feature-scaffold`

파일: [../../.github/agents/love2d-feature-scaffold.agent.md](../../.github/agents/love2d-feature-scaffold.agent.md)

- **암시적 사용**: 새 LÖVE2D 기능 구현 요청에서 선택될 수 있음
- **명시적 사용**: `love2d-feature-scaffold 에이전트로 구현해 주세요.`
- **쉬운 사용**:

```text
love2d-feature-scaffold 에이전트로 TD-001의 첫 완료 기준만 구현하세요.
먼저 헤드리스 테스트를 만들고, update/draw 경계를 지키며 변경하세요.
```

- **추천 시점**: 승인된 작업 문서 기반 구현
- **하지 않을 일**: 범위가 불명확한 여러 기능 동시 구현

### 4.4 `lua-expert`

파일: [../../.github/agents/lua-expert.agent.md](../../.github/agents/lua-expert.agent.md)

- **암시적 사용**: Lua 문법, 테이블, 성능, 오류 처리 문제에서 선택될 수 있음
- **명시적 사용**: `lua-expert 에이전트로 진단해 주세요.`
- **쉬운 사용**:

```text
lua-expert 에이전트로 이 버그의 Lua 수준 원인만 진단하세요.
원인, 경계 사례, 추천 수정 방향, 검증 계획을 출력하세요.
```

- **추천 시점**: Lua/JIT 수준 디버깅과 리팩터링
- **하지 않을 일**: 게임 재미 방향 결정

### 4.5 `lua-reviewer`

파일: [../../.github/agents/lua-reviewer.agent.md](../../.github/agents/lua-reviewer.agent.md)

- **암시적 사용**: 구현 후 “리뷰해줘” 요청에서 선택될 수 있음
- **명시적 사용**: `lua-reviewer 에이전트로 현재 diff를 검토해 주세요.`
- **쉬운 사용**:

```text
lua-reviewer 에이전트로 현재 변경만 읽기 전용 검토하세요.
Lua 5.1, 전역, MVC, 결정성, 테스트 누락에 해당하는 높은 신뢰도 문제만 보고하세요.
마지막은 "커밋 가능" 또는 "수정 필요"로 끝내세요.
```

- **추천 시점**: 구현 세션 마지막
- **하지 않을 일**: 코드 직접 수정

## 5. 명시적으로 적용하는 Skill

Skill은 특정 종류의 작업에서 따라야 할 **절차와 산출물 형식**이다.
중요 작업에서는 주 Skill 하나를 직접 지정한다.

### 5.1 `game-direction`

파일: [../../.github/skills/game-direction/SKILL.md](../../.github/skills/game-direction/SKILL.md)

- **암시적 사용**: 방향성, 재미, 우선순위 질문에서 선택될 수 있음
- **명시적 사용**: `game-direction skill을 적용해 주세요.`
- **쉬운 사용**:

```text
game-direction skill 절차로 최신 worklog, src, tests를 확인하세요.
핵심 갭 3개와 이번 세션 Top 3만 작성하세요.
```

### 5.2 `headless-test-writer`

파일: [../../.github/skills/headless-test-writer/SKILL.md](../../.github/skills/headless-test-writer/SKILL.md)

- **암시적 사용**: 구현 전 테스트 작성 요청에서 선택될 수 있음
- **명시적 사용**: `headless-test-writer skill을 적용해 주세요.`
- **쉬운 사용**:

```text
headless-test-writer skill로 TD-001의 정상, 경계값, 실패 동작만 먼저 작성하세요.
구현 코드는 이번 단계에서 수정하지 마세요.
```

### 5.3 `love2d-architect`

파일: [../../.github/skills/love2d-architect/SKILL.md](../../.github/skills/love2d-architect/SKILL.md)

- **암시적 사용**: 구조, 의존성, 리팩터링 설계에서 선택될 수 있음
- **명시적 사용**: `love2d-architect skill 절차를 사용해 주세요.`
- **쉬운 사용**:

```text
love2d-architect skill로 현재 구조, 최소 구조 변경안, 의존성 메모, 검증 단계를 작성하세요.
```

### 5.4 `love2d-feature-scaffold`

파일: [../../.github/skills/love2d-feature-scaffold/SKILL.md](../../.github/skills/love2d-feature-scaffold/SKILL.md)

- **암시적 사용**: 작은 새 기능 추가에서 선택될 수 있음
- **명시적 사용**: `love2d-feature-scaffold skill을 적용해 주세요.`
- **쉬운 사용**:

```text
love2d-feature-scaffold skill로 첫 완료 기준 하나만 구현하세요.
영향 파일과 상태 흐름을 먼저 식별하고 update/draw를 분리하세요.
```

### 5.5 `lua-expert`

파일: [../../.github/skills/lua-expert/SKILL.md](../../.github/skills/lua-expert/SKILL.md)

- **암시적 사용**: Lua 문법과 데이터 구조 중심 작업에서 선택될 수 있음
- **명시적 사용**: `lua-expert skill 절차를 사용해 주세요.`
- **쉬운 사용**:

```text
lua-expert skill로 Lua 수준 원인, 추천 수정, 경계 사례를 먼저 정리하세요.
```

### 5.6 `lua51-guard`

파일: [../../.github/skills/lua51-guard/SKILL.md](../../.github/skills/lua51-guard/SKILL.md)

- **암시적 사용**: Lua 호환성 검사 요청에서 선택될 수 있음
- **명시적 사용**: `lua51-guard를 실행해 주세요.`
- **쉬운 사용**:

```text
lua51-guard로 변경된 Lua 파일만 검사하세요.
파일:줄, 문제, 수정안만 표로 출력하고 마지막에 위반 건수를 표시하세요.
```

### 5.7 `mvc-boundary`

파일: [../../.github/skills/mvc-boundary/SKILL.md](../../.github/skills/mvc-boundary/SKILL.md)

- **암시적 사용**: 기능 배치와 계층 경계 질문에서 선택될 수 있음
- **명시적 사용**: `mvc-boundary skill로 책임 위치를 결정해 주세요.`
- **쉬운 사용**:

```text
mvc-boundary skill로 이 기능을 Model/View/Controller 중 어디에 둘지 결정하세요.
계층, 파일, 데이터 흐름, 금지 의존성을 표로 작성하세요.
```

### 5.8 `prompt-improver`

파일: [../../.github/skills/prompt-improver/SKILL.md](../../.github/skills/prompt-improver/SKILL.md)

- **암시적 사용**: “프롬프트를 개선해줘” 요청에서 선택될 수 있음
- **명시적 사용**: `/prompt-improver` 호출 또는 `prompt-improver skill을 적용해 주세요.`
- **쉬운 사용**:

```text
/prompt-improver

다음 원본 프롬프트를 실행하지 말고 개선만 해 주세요:
"""
[원본 요청]
"""

6요소 진단, 세션 분리 제안, 짧은 프롬프트, 상세 프롬프트를 출력하세요.
```

중요 작업은 개선 결과를 확인한 후 별도 메시지로 실행한다.

### 5.9 `release-check`

파일: [../../.github/skills/release-check/SKILL.md](../../.github/skills/release-check/SKILL.md)

- **암시적 사용**: 릴리스 전 점검과 최종 검증 질문에서 선택될 수 있음
- **명시적 사용**: `release-check skill을 적용해 주세요.`
- **쉬운 사용**:

```text
release-check skill로 변경 파일, 런타임 위험, 필요한 검증을 정리하세요.
전체 게임 실행이 필요한 경우에만 최소 1회 실행하세요.
```

### 5.10 `worklog-writer`

파일: [../../.github/skills/worklog-writer/SKILL.md](../../.github/skills/worklog-writer/SKILL.md)

- **암시적 사용**: 세션 기록이나 인계 요청에서 선택될 수 있음
- **명시적 사용**: `worklog-writer skill을 적용해 주세요.`
- **쉬운 사용**:

```text
worklog-writer skill로 오늘의 worklog를 작성하세요.
미확인 검증은 "확인 필요"로 표시하고 다음 세션 인계는 10줄 이내로 작성하세요.
```

## 6. Prompt 파일의 쉬운 사용법

Prompt 파일은 Agent의 역할과 달리 **복사해서 실행할 수 있는 템플릿**이다.
지원되는 환경에서는 `/프롬프트 이름`처럼 선택하고, 그렇지 않으면 파일 내용을 대화에 붙여 넣는다.

### 6.1 `start-session.prompt.md`

파일: [../../.github/prompts/start-session.prompt.md](../../.github/prompts/start-session.prompt.md)

- **암시적 사용**: 새 작업 시작 요청에서 절차를 참고할 수 있음
- **명시적 사용**: `/start-session`
- **쉬운 사용**:

```text
/start-session

이번 목표:
TD-001에서 타워 선택 기능의 첫 완료 기준만 구현
```

사용 전에 목표 한 문장, 수정 허용 파일, 완료 기준을 채운다.

### 6.2 `end-session.prompt.md`

파일: [../../.github/prompts/end-session.prompt.md](../../.github/prompts/end-session.prompt.md)

- **암시적 사용**: 세션 종료나 결과 정리 요청에서 참고될 수 있음
- **명시적 사용**: `/end-session`
- **쉬운 사용**:

```text
/end-session

커밋은 하지 말고 하네스 검증, diff 검토, worklog, 다음 세션 프롬프트를 작성해 주세요.
```

### 6.3 `prompt-improver.prompt.md`

파일: [../../.github/prompts/prompt-improver.prompt.md](../../.github/prompts/prompt-improver.prompt.md)

- **암시적 사용**: 모호한 요청을 명확히 하도록 제안할 수 있음
- **명시적 사용**: `/prompt-improver`
- **쉬운 사용**:

```text
/prompt-improver

원본 요청:
"""
타워 디펜스의 업그레이드 기능을 완성해줘
"""
```

개선 프롬프트를 실행하지 말고 먼저 제안하도록 명시하는 것이 원칙이다.

### 6.4 `game-director-session.prompt.md`

파일: [../../.github/prompts/game-director-session.prompt.md](../../.github/prompts/game-director-session.prompt.md)

- **암시적 사용**: 세션 우선순위 요청에서 참고될 수 있음
- **명시적 사용**: `/game-director-session`
- **쉬운 사용**:

```text
/game-director-session

현재 src, tests, 최신 worklog를 기준으로 오늘 작업 Top 3만 제안하세요.
코드는 수정하지 마세요.
```

### 6.5 `improve-then-execute.prompt.md`

파일: [../../.github/prompts/improve-then-execute.prompt.md](../../.github/prompts/improve-then-execute.prompt.md)

- **암시적 사용**: 작업 요청과 프롬프트 개선 요구가 함께 있어도 자동 실행되지 않아야 함
- **명시적 사용**: `/improve-then-execute`
- **쉬운 사용**:

```text
/improve-then-execute

[원본 요청을 입력]
```

1차 응답에서 개선안을 확인한 뒤 다음 턴에 입력한다.

```text
개선안으로 실행해줘
```

개선 단계에서는 파일 변경이나 실행을 하지 않는다.

> 이 파일은 현재 worktree에 새로 추가된 자산이며, 아직 커밋 여부는 사용자 결정 대상이다.

## 7. 추천 세션 흐름

### 7.1 기획과 문서 세션

```text
1. /game-director-session
2. /prompt-improver
3. 개선 프롬프트 검토
4. /start-session
5. game-director로 문서 작성
6. /end-session
7. worklog-writer 적용
```

### 7.2 기능 구현 세션

```text
1. /start-session
2. mvc-boundary 또는 love2d-architect
3. headless-test-writer
4. love2d-feature-scaffold
5. lua51-guard
6. lua-reviewer
7. /end-session
```

### 7.3 버그 수정 세션

```text
1. lua-expert로 원인 진단
2. headless-test-writer로 재현 테스트 작성
3. 최소 수정
4. 관련 헤드리스 테스트 실행
5. lua-reviewer
6. worklog-writer
```

### 7.4 중요한 프롬프트 실행

```text
1. /prompt-improver
2. 개선 결과 검토
3. 필요하면 범위, 파일, 완료 기준 수정
4. 새 메시지에서 상세 실행 프롬프트 사용
5. /start-session
```

## 8. 프롬프트 빠른 템플릿

### 8.1 설계 전용

```text
[Agent 또는 Skill]을 적용하세요.

목표:
[단일 목표]

참조:
- [문서]
- [코드]
- [worklog]

제약:
- [수정 금지 범위]
- [허용 파일]
- 아직 구현하지 말 것

출력:
- 현재 상태
- 선택안
- 위험
- 완료 기준
- 검증 계획
```

### 8.2 구현 전용

```text
[구현 Agent]로 [작업 문서]의 완료 기준 하나만 구현하세요.

수정 허용:
- [파일 목록]

먼저 headless-test-writer로 테스트하고,
그다음 최소 구현을 적용하세요.

완료 기준:
- [측정 가능한 조건]

검증:
- [하네스 또는 task 이름]

커밋하지 마세요.
```

### 8.3 최종 검토

```text
lua-reviewer로 현재 diff만 읽기 전용 검토하세요.
범위 밖 변경은 무시하지 말고 사용자 변경과 분리해 보고하세요.
호환성, 전역, MVC, 결정성, 누락 테스트 위반만 출력하세요.
```

## 9. 자주 생기는 오용

| 오용 | 문제 | 권장 |
|---|---|---|
| 모든 Agent를 동시에 지정 | 역할 충돌과 긴 컨텍스트 | Agent 1개만 주 역할로 지정 |
| 프롬프트 개선과 실행을 같은 턴에 수행 | 승인 전 범위 고착 | `/prompt-improver` 후 새 턴에서 실행 |
| 기획과 구현을 함께 요청 | 방향 확정 전에 구현 | 문서 세션과 구현 세션 분리 |
| 매 세션 전체 게임 실행 | 느리고 재현성 낮음 | 헤드리스 테스트 우선 |
| 모든 파일 읽기 요청 | 세션 컨텍스트 낭비 | 작업 관련 참조만 명시 |
| worklog를 구현 계획으로 사용 | 과거 기록과 미래 계약 혼합 | 계획은 task 문서, 결과는 worklog |

## 10. 짧은 추천 문구

가장 자주 사용할 수 있는 문구는 다음이다.

### 세션 시작

```text
start-session 절차로 이번 목표, 수정 허용 파일, 완료 기준, 하네스 검증을 먼저 확정해 주세요.
```

### 구현

```text
작업 문서의 첫 완료 기준만 구현하고, 먼저 실패하는 헤드리스 테스트를 작성해 주세요.
```

### 검토

```text
lua-reviewer로 현재 diff만 읽기 전용 검토하고 높은 신뢰도 문제만 보고해 주세요.
```

### 세션 종료

```text
end-session과 worklog-writer를 적용해 검증 결과와 다음 세션 프롬프트를 작성해 주세요.
```
