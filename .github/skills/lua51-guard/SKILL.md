---
name: lua51-guard
description: Lua 코드를 작성하거나 검토할 때 Lua 5.1, LuaJIT, LÖVE 11.5 호환성을 점검할 때 사용합니다.
---

# 목적

Lua 5.2 이상 문법, 다른 언어 습관, 잘못된 LÖVE 11 API, 암묵적 전역을 걸러낸다.

# 금지 목록

| 금지 | 대체 |
|---|---|
| `a // b` | `math.floor(a / b)` |
| `table.unpack(t)` | `unpack(t)` |
| `a != b` | `a ~= b` |
| `<const>`, `<close>`, `goto` | Lua 5.1 제어 구조 |
| `math.tointeger`, `math.type` | Lua 5.1 연산 |
| `local` 없는 대입 | 명시적 `local` |
| `for i = 0, #t - 1` | `for i = 1, #t` |
| `love.graphics.setColor(255, ...)` | `setColor(1, ...)` |

# 절차

1. 새 코드에는 위 규칙을 적용한다.
2. 검토에서는 위반마다 `파일:줄`, 문제, 수정을 제시한다.
3. LÖVE 전용 API는 헤드리스 Model과 테스트에 넣지 않는다.
4. 구멍이 있을 수 있는 테이블은 `#t` 대신 별도 개수나 반복 계약을 확인한다.
5. 확실하지 않은 항목은 추측하지 말고 `확인 필요`로 표시한다.

# 출력 형식

| 파일:줄 | 문제 | 수정안 |
|---|---|---|

마지막 줄은 `위반 N건` 또는 `위반 없음`으로 끝낸다.
