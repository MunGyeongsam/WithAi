---
name: headless-test-writer
description: LÖVE 창 없이 luajit 로 실행되는 Model/View/Controller 헤드리스 테스트를 작성할 때 사용한다. 새 동작을 구현하기 전이나 버그를 재현할 때 쓴다.
---

# 목적

"완료"를 판단할 수 있는 테스트를 먼저 만든다. 테스트는 `love` 없이 `luajit 파일.lua` 로 돌아가야 한다.

# 규칙

- Model 테스트는 게임 코드 중 Model 만 `require` 한다 (테스트 도우미 `helper` 는 예외). `love` 는 쓰지 않는다.
- View 테스트는 **가짜 gfx**(호출 기록기)를, Controller 테스트는 **가짜 isDown** 을 주입한다.
- 테스트 하나는 동작 하나만 검사한다. 이름은 "~하면 ~한다" 형식.
- 테스트 함수는 통과 시 **반드시 `true` 를 반환**한다. (`a and b` 가 `nil` 을 내면 실패로 본다)
- 무작위가 있으면 시드를 고정해 결정적으로 만든다.
- 고정 스텝 `dt = 1/60` 으로 N 스텝 진행하는 헬퍼를 쓴다.
- 저장소에 `tests/helper.lua` 가 있으면 그 러너(`helper.setup`, `helper.test`, `helper.finish`)를 그대로 쓴다.

# 절차

1. 검증할 동작을 목록으로 먼저 보여 주고 승인받는다. (예: FSM 전이 조건마다 1개)
2. 정상 경우, 경계값(0, 최대, 빈 목록), 실패 경우를 각각 고려한다.
3. 테스트 파일을 작성한다. 구현 코드는 고치지 않는다.
4. 실행 명령을 알려 준다. 예: `cd tests && luajit enemy_fsm_test.lua`
5. 구현 전이라면 "지금은 실패가 정상"이라고 명시한다.

# 하지 말 것

- 테스트를 통과시키려고 기대값을 구현에 맞춰 바꾸지 않는다.
- 기존 테스트를 삭제하거나 약하게 만들지 않는다.
- 내부 구현 세부(지역 변수 이름 등)에 의존하는 테스트를 쓰지 않는다.

# 출력 형식

1. 검증 목록 표 (테스트 이름 | 준비 | 행동 | 기대)
2. 테스트 코드
3. 실행 명령과 예상 결과

# 예시

아래는 EnemyModel 에 FSM 용 `update(dt, world)` 와 `state` 필드를 **새로 추가한다고 가정**한 테스트다.
(week04 의 EnemyModel 에는 아직 `update` 가 없다.)

```lua
local helper = require("helper")
helper.setup("galaga_mvc") -- tests/ 옆의 앱 폴더 이름. 제출 구조(project/src, project/tests)라면 "src"
local Enemy = require("EnemyModel")

helper.test("플레이어가 사거리 안에 들어오면 idle 에서 chase 로 바뀐다", function()
  local e = Enemy(100, 100)
  e:update(1/60, { playerX = 120, playerY = 100 }) -- world: Model 이 넘겨주는 주변 정보
  return e.state == "chase"
end)

helper.finish()
```
