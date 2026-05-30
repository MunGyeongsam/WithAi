# Antigravity + Lua/LÖVE2D 통합 개발 환경 설정 가이드

본 문서는 Antigravity를 사용하여 LÖVE2D 및 Lua 개발 환경을 통합할 때의 운영 기준을 정리합니다. 학생마다 OS와 런타임 설치 상태가 다를 수 있으므로, 공통 실행 경로와 환경별 대체 경로를 함께 둡니다.

---

## 1. Antigravity 협업 모델 및 작동 원리

Antigravity는 단순한 자동완성 도구가 아니라, 워크스페이스의 흐름과 책임을 추론하고 대화형으로 코드를 설계 및 리팩터링하는 에이전트입니다.

### 핵심 동작 계층
1. **프로젝트 루트 지침 (`AGENTS.md` / `.antigravityrules.md`):**
   - 개발을 시작할 때 Antigravity가 가장 먼저 읽는 최우선순위 명세입니다.
   - 전역 오염 배제, 모듈 단위 설계, `update/draw` 아키텍처 분리 등의 코딩 표준이 명문화되어 있습니다.
2. **지능형 하위 규칙 (`.antigravity/rules/`):**
   - 파일 유형 및 작업 목적에 맞추어 활성화되는 정밀 룰셋입니다.
3. **특화 스킬 및 플로우 (`.antigravity/skills/` & `.antigravity/workflows/`):**
   - 복잡한 리팩터링 및 신규 게임플레이 모듈 스캐폴딩 작업을 위해 정의된 자가 에이전트 전용 프로세스입니다.

---

## 2. 통합 워크스페이스 설정 (VS Code 및 Antigravity-IDE)

에셋 정렬과 린터 규칙의 엄격성을 지키기 위해 다음 공통 설정을 워크스페이스에 통합하여 운용합니다:
- **코드 포맷터:** StyLua (`stylua.toml`)
- **코드 분석/린터:** Luacheck (`.luacheckrc`)
- **VS Code 설정:** `.vscode/settings.json` 내에 아래 항목을 정의하여 Love2D 환경의 글로벌 개체 인식 및 에디터 환경을 일치시킵니다.
  ```json
  "Lua.diagnostics.globals": [
      "love",
      "jit",
      "utf8"
  ]
  ```

환경 중립 원칙:
- 학생마다 OS와 런타임 설치 상태가 다를 수 있으므로, 실행 지침은 단일 경로를 가정하지 않는다.
- 가능하면 VS Code task 또는 저장소에 포함된 실행 진입점을 우선하고, OS별 차이는 보조 경로로 분리한다.
- 특정 PATH, 특정 드라이브 경로, 특정 운영체제 전용 명령은 기본값으로 가정하지 않는다.

검증 정책 (공통):
- 기본 검증은 테스트 하네스(단위/모듈/시뮬레이션) 우선으로 수행한다.
- LÖVE2D 전체 실행 검증은 최소한으로 유지한다.
- 전체 실행은 입력/렌더/프레임 루프 확인이 필요한 변경에서만 수행한다.
- 결과 보고는 하네스 검증과 실행 검증을 분리해서 기록한다.

---

## 3. LÖVE2D 로컬 실행 가이드

### 실행 옵션 3가지
1. **쉘 스크립트 실행:**
   - Windows 환경에서는 프로젝트 루트에 있는 `run.bat` 스크립트를 더블클릭하거나 터미널에서 실행할 수 있습니다.
   - macOS 또는 Linux 환경에서는 `run.sh`를 터미널에서 실행할 수 있습니다.
   - `run.sh`는 `love` 명령을 사용해 `project/src`를 실행하고, 필요하면 `LOVE_BIN`으로 대체 경로를 지정할 수 있습니다.
   - `run.bat`은 내부적으로 로컬 `"love-11.5-win64/lovec.exe" "project/src"`를 맵핑하여 구동합니다.
2. **VS Code 작업 자동화 (Tasks):**
   - `Ctrl + Shift + B` 또는 `Run Task`에서 **`Love2D: Run project`**, **`Run run.sh`**, **`Run run.bat`** 중 현재 환경에 맞는 항목을 선택합니다.
   - 개별 스크립트의 빠른 검증이 필요할 경우 **`Lua: Run current file`**을 사용할 수 있습니다.
3. **F5 디버그 단축키 실행:**
   - VS Code 내에서 `F5` 키를 누르면, 설정된 `Love2D: Run run.bat (F5)` 구성이 작동합니다.
   - 이 구성은 Windows 전용 보조 경로이며, 다른 환경에서는 task 기반 실행을 우선합니다.

---

## 4. 디렉토리 구조 및 역할 분담

Antigravity 통합 개발 환경으로 재편된 디렉토리 트리는 다음과 같이 일관되게 관리됩니다.

```
WithAi/
├── .antigravityrules.md         # Antigravity 전역 최우선 지침
├── .antigravity/
│   ├── rules/
│   │   └── lua-love2d.md       # LÖVE2D 및 LuaJIT 구체 제약 규칙
│   ├── skills/
│   │   ├── love2d-architect/   # 아키텍처 재설계 및 리팩터링 스킬
│   │   └── love2d-feature-scaffolding/ # 피처 생성 및 스캐폴딩 스킬
│   └── workflows/
│       └── release-check.md    # 릴리스 전 품질 체크리스트 워크플로우
├── .vscode/
│   ├── settings.json           # 언어 서버 및 린트 포맷 통합 설정
│   └── tasks.json              # 빌드 및 실행 자동화 태스크
├── AGENTS.md                   # 에이전트 기본 행동 강령
├── project/
│   └── src/                    # LÖVE2D 소스 코드 루트 (main.lua, config.lua 등)
├── run.bat                     # Windows 보조 실행 스크립트
└── run.sh                      # macOS/Linux 보조 실행 스크립트
```

---

## 5. 최상의 협업을 위한 팁

- **구현 계획(Planning Mode)의 활용:** 복잡한 변경이 필요할 경우 Antigravity는 자율적으로 `implementation_plan.md`를 구성하고 사용자에게 검토를 요청합니다. 이를 통해 코드 수정 시 발생할 수 있는 런타임 리스크를 사전에 예방합니다.
- **점진적 체크마크 관리:** 수정 상태는 항상 `task.md`를 통해 동적으로 상태가 반영되므로, 진행 상황을 한눈에 명확하게 진척률로 파악할 수 있습니다.
- **슬래시 명령어 추천:** 정기 릴리스나 장기 실행 테스팅이 필요하다면 `/goal` 및 `/schedule` 단축 액션을 제안하거나 사용해 보세요.
