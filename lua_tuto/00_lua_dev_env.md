# 00. Lua 개발 환경 설정

> **목표**: VS Code를 설치하고, 통합 터미널에서 Lua 5.1.5를 설치한 뒤, 첫 스크립트를 실행한다.

---

## 필요한 것

| 순서 | 구성 요소 | 용도 |
|:----:|-----------|------|
| 1 | **VS Code** | 코드 편집기 + 통합 터미널 |
| 2 | **Lua 5.1.5** | Lua 인터프리터 (LÖVE2D가 사용하는 버전) |
| 3 | **sumneko Lua 확장** | 자동 완성, 문법 검사, 타입 힌트 |

> 💡 VS Code를 먼저 설치하면 통합 터미널(`` Ctrl+` ``)에서 나머지를 전부 할 수 있다.
> 별도 cmd/PowerShell을 열 필요가 없다.

---

## 1. VS Code 설치

- https://code.visualstudio.com/ 에서 OS에 맞는 버전 다운로드 및 설치
- 설치 후 실행, 통합 터미널 열기: `` Ctrl+` `` (macOS: `` Cmd+` ``)

---

## 2. Lua 5.1.5 설치 (VS Code 터미널에서)

VS Code 터미널을 열고 아래 순서대로 진행한다.

### Windows

#### 방법 A: LuaBinaries (권장)

1. https://luabinaries.sourceforge.net/download.html 에서 **lua-5.1.5_Win64_bin.zip** 다운로드
2. 적당한 폴더에 압축 해제 (예: `C:\lua`)
3. 시스템 환경 변수 PATH에 해당 폴더 추가

```
시스템 속성 → 환경 변수 → Path → 편집 → 새로 만들기 → C:\lua
```

4. **VS Code 터미널을 닫았다 다시 열고** 확인:

```
lua5.1 -v
```

> ⚠️ 실행 파일 이름이 `lua5.1.exe`인 경우가 많다. `lua.exe`로 복사하거나
> 이름을 바꾸면 편하다.

#### 방법 B: LuaRocks 포함 올인원

- https://github.com/rjpcomputing/luaforwindows/releases 에서 **Lua for Windows** 설치
- Lua 5.1 + 주요 라이브러리 + SciTE 에디터가 한 번에 설치됨
- 설치 후 VS Code 터미널을 다시 열면 `lua`가 바로 동작한다

### macOS

```bash
# Homebrew가 없으면 먼저 설치
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Lua 5.1 설치
brew install lua@5.1
```

설치 후 같은 터미널에서 바로 확인:

```bash
lua5.1 -v
# 또는
lua -v    # Homebrew 버전에 따라 심링크가 다를 수 있음
```

> 💡 macOS에 기본 설치된 Lua가 있을 수 있다. `which lua`로 경로를 확인하고
> 버전이 5.1.x인지 체크한다.

---

## 3. VS Code 확장 프로그램

### 필수

| 확장 | ID | 설명 |
|------|----|------|
| **Lua** (sumneko) | `sumneko.lua` | 언어 서버 — 자동 완성, 진단, 타입 추론 |

`Ctrl+Shift+X` (macOS: `Cmd+Shift+X`) → `sumneko.lua` 검색 → 설치

또는 터미널에서:

```bash
code --install-extension sumneko.lua
```

### 추천

| 확장 | ID | 설명 |
|------|----|------|
| Code Runner | `formulahendry.code-runner` | 단축키 한 번으로 현재 파일 실행 |
| Error Lens | `usernamehw.errorlens` | 에러를 코드 옆에 인라인 표시 |

### Code Runner 설정

Code Runner를 설치하면 `Ctrl+Alt+N` (macOS: `Ctrl+Opt+N`)으로 현재 파일을 바로 실행할 수 있다.

`.vscode/settings.json`에 아래를 추가하면 Lua 5.1로 실행된다:

```json
{
  "code-runner.executorMap": {
    "lua": "lua5.1"
  },
  "code-runner.runInTerminal": true,
  "code-runner.clearPreviousOutput": true
}
```

- `code-runner.executorMap` — Lua 파일을 `lua5.1` 명령으로 실행
- `code-runner.runInTerminal` — 출력 패널 대신 터미널에서 실행 (`io.read()` 등 입력이 가능해짐)
- `code-runner.clearPreviousOutput` — 실행할 때마다 이전 출력을 자동으로 지움

> ⚠️ Windows에서 `lua.exe`로 이름을 바꿨다면 `"lua": "lua"`로 설정한다.

### 워크스페이스 설정 (선택)

프로젝트 루트에 `.vscode/settings.json`을 만들어 sumneko가 Lua 5.1 모드로 동작하게 한다:

```json
{
  "Lua.runtime.version": "Lua 5.1",
  "Lua.diagnostics.globals": ["love"],
  "Lua.workspace.library": [],
  "Lua.telemetry.enable": false
}
```

- `Lua.runtime.version` — 5.1 문법 기준으로 진단
- `Lua.diagnostics.globals` — LÖVE2D의 `love` 전역을 경고 없이 사용

---

## 4. Hello World — 설치 확인

VS Code에서 `hello.lua` 파일을 만든다:

```lua
print("Hello, Lua!")
print("버전: " .. _VERSION)
```

통합 터미널에서 실행:

```bash
lua5.1 hello.lua
```

출력:

```
Hello, Lua!
버전: Lua 5.1
```

> 이 워크스페이스에서는 **Terminal → Run Task → Lua: Run current file**로도 실행할 수 있다.

---

## 5. LÖVE2D 설치 (게임 개발용)

Lua 문법 학습에는 인터프리터만 있으면 된다.
LÖVE2D는 Phase 3(11장~)부터 필요하므로 지금 설치하지 않아도 괜찮다.

VS Code 터미널에서:

```bash
# macOS
brew install love

# Windows — 공식 사이트에서 zip 다운로드 후 PATH에 추가
# https://love2d.org/
```

확인:

```bash
love --version
```

---

## 6. 자주 만나는 문제

| 증상 | 원인 | 해결 |
|------|------|------|
| `'lua'은(는) 내부 또는 외부 명령...이 아닙니다` | PATH 미등록 | 환경 변수에 Lua 경로 추가 후 **VS Code 터미널을 다시 열기** |
| `lua: cannot open hello.lua` | 경로 불일치 | 터미널에서 `cd`로 파일 폴더로 이동, 또는 VS Code에서 폴더 열기 |
| sumneko가 경고를 너무 많이 표시 | 기본 진단이 엄격함 | `settings.json`에서 `Lua.diagnostics.severity` 조정 |
| `love`가 버전이 다름 | 여러 버전 설치 | `love --version`으로 11.x 확인, 아니면 PATH 순서 조정 |

---

## 요약

```
VS Code 설치 → 터미널에서 Lua 5.1.5 설치 → sumneko 확장 설치 → hello.lua 실행 → 완료
```

다음 장: [01. Lua란? 왜 게임에서 쓰나?](01_intro.md)
