---
name: mvc-boundary
description: LÖVE2D MVC 프로젝트의 계층 경계를 점검하거나 새 코드를 Model, View, Controller 중 어느 계층에 배치할지 결정할 때 사용합니다.
---

# 계층 규칙

| 계층 | 허용 책임 | 금지 |
|---|---|---|
| `models/` | 게임 규칙, 상태, `update`, 이벤트 생성 | `love.*`, 출력, 파일 입출력, View/Controller 의존 |
| `views/` | 주입받은 그래픽 계약으로 그리기와 연출 | Model 상태 변경, Controller 의존, 직접 입력 해석 |
| `controllers/` | 주입받은 입력에서 입력 계약 생성 | View 의존, 직접 그리기, Model 직접 수정 |
| `main.lua` | 의존성 조립과 프레임 순서 | 게임 규칙 구현 |

의존 방향은 Controller/View에서 Model로 향할 수 있지만, Model은 다른 계층을 알지 못해야 한다.

# 절차

1. 파일 경로와 실제 의존성으로 계층을 확인한다.
2. Model에서 `love.*`, 출력, 파일 입출력을 찾는다.
3. View가 Model 필드를 직접 변경하는지 확인한다.
4. Controller가 View에 의존하거나 모델 상태를 직접 변경하는지 확인한다.
5. 새 기능은 규칙과 상태는 Model, 렌더링은 View, 입력 해석은 Controller로 배치한다.
6. `tests/layer_check.lua`가 있으면 우선 실행한다.

# 출력 형식

| 파일:줄 | 계층 | 문제 | 권장 수정 |
|---|---|---|---|

마지막 줄은 `경계 위반 N건` 또는 `경계 위반 없음`으로 끝낸다.
