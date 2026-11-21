---
name: mvc-boundary
description: LÖVE2D MVC 프로젝트(models/ views/ controllers/ main.lua)에서 계층 경계 위반을 점검하거나, 새 코드를 어느 계층에 둘지 정할 때 사용한다.
---

# 목적

수업 week03~04 의 MVC 규칙을 지키게 한다. 핵심은 **Model 은 아무것도 모른다**이다.

# 계층 규칙

| 계층 | 할 수 있는 것 | 금지 |
|---|---|---|
| `models/` | 게임 규칙, 상태, `update(dt, input)`, 이벤트 쌓기(`drainEvents`) | `love.*`, `print`, `io`, View/Controller `require` |
| `views/` | 주입받은 `gfx` 로 그리기, `onEvent` 로 연출 | `love.*` 직접 호출, Model 값 **수정**, Controller `require` |
| `controllers/` | 주입받은 `isDown` 으로 입력 계약 `{ move, fire }` 만들기 | `love.*` 직접 호출, View `require`, Model 직접 수정 |
| `main.lua` | 조립(composition root), 프레임 순서 C → M(고정 스텝) → 이벤트 → V | 게임 규칙 구현 |

의존 방향: C → M, V → M. **M 에서 나가는 화살표는 없다.**

# 절차

1. 대상 파일이 어느 계층인지 경로로 판단한다.
2. 위 표의 금지 항목을 찾는다. 주석 안의 단어는 제외한다.
3. View 가 Model 필드에 대입(`model.x = ...`)하거나 Model 메서드 중 상태를 바꾸는 것을 호출하는지 확인한다.
4. 새 기능 요청이면 "규칙/상태 → Model, 그림/연출 → View, 입력 해석 → Controller" 로 나눈 배치안을 먼저 제시한다.
5. 저장소에 `tests/layer_check.lua` 가 있으면 그 실행을 권한다.

# 하지 말 것

- 경계를 지키려고 기능을 빼거나 바꾸지 않는다.
- Model 에 그리기용 필드(색상, 스프라이트 경로 등)를 추가하지 않는다.

# 출력 형식

| 파일:줄 | 계층 | 위반 | 옮길 위치 / 수정안 |
|---|---|---|---|

마지막 줄: `경계 위반 N건` 또는 `경계 위반 없음`
