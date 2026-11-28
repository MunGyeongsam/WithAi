---
applyTo: "**/*.lua"
description: Lua와 LÖVE2D 게임 루프, 계층, 검증 책임을 위한 규칙입니다.
---

# Lua 및 LÖVE2D 규칙

- `lua-expert.instructions.md`의 Lua 규칙을 먼저 적용합니다.
- `update`의 상태 변경과 `draw`의 렌더링을 분리하고 `draw`에서 게임 상태를 변경하지 않습니다.
- 프레임 동작은 `dt` 또는 고정 스텝 계약에 따라 결정적으로 유지합니다.
- Model은 입력 장치, 렌더링, 파일 입출력, 전역 `love.*`에 의존하지 않습니다.
- View는 주입된 그래픽 계약만 사용하고 Model 상태를 직접 수정하지 않습니다.
- Controller는 입력을 해석해 계약 객체를 만들고 View를 호출하지 않습니다.
- `main.lua`는 의존성을 조립하고 Controller → Model → View의 실행 순서를 관리합니다.
- 새 동작은 가능한 한 헤드리스 테스트로 먼저 검증하고, 입력·렌더링·프레임 타이밍 변경에만 전체 게임 실행을 사용합니다.