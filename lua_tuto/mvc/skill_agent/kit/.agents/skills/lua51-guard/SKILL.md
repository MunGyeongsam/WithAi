---
name: lua51-guard
description: Lua 코드를 작성하거나 검토할 때 Lua 5.1/LuaJIT 및 LÖVE 11.5 호환성을 점검한다. .lua 파일을 만들거나 고치거나 리뷰할 때 사용한다.
---

# 목적

AI가 자주 섞어 쓰는 Lua 5.3/5.4 문법, 다른 언어 습관, 구버전 LÖVE API를 걸러낸다.
코드를 새로 작성할 때는 아래 규칙을 지켜서 쓰고, 검토 요청이면 위반만 보고한다.

# 절차

1. 대상 코드를 아래 "금지 목록"과 한 줄씩 대조한다.
2. 위반마다 `파일:줄`, 문제, 수정안을 표로 제시한다.
3. 위반이 없으면 "위반 없음" 한 줄만 출력한다.
4. 확신이 없는 항목은 "확인 필요"로 표시하고 이유를 쓴다. 추측으로 단정하지 않는다.

# 금지 목록

| 금지 | 대체 | 이유 |
|---|---|---|
| `a // b` | `math.floor(a / b)` | 정수 나눗셈은 5.3+ |
| `table.unpack(t)` | `unpack(t)` | 5.1 은 전역 `unpack` |
| `a != b` | `a ~= b` | Lua 의 같지 않음 |
| `local x <const> = 1`, `<close>` | 일반 `local` | 5.4 전용 |
| 전역 `utf8.*` | LÖVE 코드(View 등)에서만 `local utf8 = require("utf8")` | 5.3+ 표준 라이브러리. LuaJIT 에는 없고 LÖVE 가 모듈로 제공. `models/` 와 헤드리스 테스트에서는 쓰지 않는다 |
| `math.tointeger`, `math.type` | `math.floor` 등 | 5.3+ |
| `goto` | 반복문/함수로 구조화 | Lua 5.2+ 문법. LuaJIT 은 지원하지만 Lua 5.1 표준이 아니므로 수업에서는 쓰지 않는다 |
| `local` 없는 대입 (`count = 0`) | `local count = 0` | 암묵적 전역 누수 |
| `for i = 0, #t - 1` | `for i = 1, #t` | 1-based 인덱스 |
| `obj.method()` (self 필요 시) | `obj:method()` | self 누락 |
| `love.graphics.setColor(255, 0, 0)` | `setColor(1, 0, 0)` | LÖVE 11 은 0~1 범위 |
| `#t` 로 구멍 있는 테이블 길이 계산 | 별도 count 관리 | 구멍이 있으면 `#` 결과가 불확정 |

# 하지 말 것

- 요청하지 않은 리팩터링이나 이름 변경
- 기능(게임 동작) 변경
- 새 외부 라이브러리 도입

# 출력 형식

| 파일:줄 | 문제 | 수정안 |
|---|---|---|

마지막 줄: `위반 N건` 또는 `위반 없음`

# 예시

나쁜 예:
```lua
score = 0
local half = width // 2
if state != "dead" then end
```

좋은 예:
```lua
local score = 0
local half = math.floor(width / 2)
if state ~= "dead" then end
```
