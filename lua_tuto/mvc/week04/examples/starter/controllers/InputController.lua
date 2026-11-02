-- InputController.lua  (STARTER)
-- 입력(키 상태)을 해석해 Model 이 이해하는 입력 계약 { move, fire } 로 바꾼다.
-- love.keyboard 를 직접 부르지 않고 isDown 함수를 주입받는다 → 창 없이 테스트 가능.

local class = require("class")

local InputController = class()

local DEFAULT_KEYS = {
  left = { "left", "a" },
  right = { "right", "d" },
  fire = { "space" },
  restart = "r",
  quit = "escape",
}

--- @param game   table              GameModel (명령 대상)
--- @param isDown function(key)->bool 보통 love.keyboard.isDown
--- @param keys   table|nil          키 배치. 기본 DEFAULT_KEYS
function InputController:init(game, isDown, keys)
  self.game = game
  self.isDown = isDown
  self.keys = keys or DEFAULT_KEYS
  -- 프레임마다 새 테이블을 만들지 않고 재사용한다(GC 부담 감소).
  self.input = { move = 0, fire = false }
end

--- 연속 입력(누르고 있는 키) → 입력 계약. 프레임당 1회 호출.
-- @return table { move = -1|0|1, fire = boolean }
function InputController:read()
  -- TODO: self.keys.left 중 하나라도 눌리면 -1, right 면 +1 (둘 다면 0)
  --       fire 키가 눌렸는지. 결과를 self.input 에 채워 돌려준다.
  return self.input
end

--- 단발 입력(눌린 순간) → Model 명령 또는 앱 명령.
-- @return string|nil  "quit" | "restart" | nil
function InputController:keypressed(key)
  -- TODO: quit 키 → "quit" 반환 (종료 자체는 main 이 한다 — 왜?)
  --       restart 키 + 게임오버 상태 → self.game:reset() 후 "restart"
  return nil
end

return InputController
