-- InputController.lua
-- 입력(키 상태)을 해석해 Model 이 이해하는 입력 계약 { move, fire, missile } 로 바꾼다.
-- love.keyboard 를 직접 부르지 않고 isDown 함수를 주입받는다 → 창 없이 테스트 가능.
-- 5주차: 재시작·종료 같은 "화면 흐름" 키는 씬(scenes/)의 책임으로 옮겨졌다. 여기는 게임플레이 입력만.

local class = require("class")

local InputController = class()

local DEFAULT_KEYS = {
  left = { "left", "a" },
  right = { "right", "d" },
  fire = { "space" },
  missile = { "x" },
}

--- @param isDown function(key) -> boolean   보통 love.keyboard.isDown
--- @param keys  table|nil  키 배치. 기본 DEFAULT_KEYS
function InputController:init(isDown, keys)
  self.isDown = isDown
  self.keys = keys or DEFAULT_KEYS
  -- 프레임마다 새 테이블을 만들지 않고 재사용한다(GC 부담 감소).
  self.input = { move = 0, fire = false, missile = false }
end

local function anyDown(isDown, list)
  for i = 1, #list do
    if isDown(list[i]) then
      return true
    end
  end
  return false
end

--- 연속 입력(누르고 있는 키) → 입력 계약. 프레임당 1회 호출.
-- @return table { move = -1|0|1, fire = boolean, missile = boolean }
function InputController:read()
  local move = 0
  if anyDown(self.isDown, self.keys.left) then
    move = move - 1
  end
  if anyDown(self.isDown, self.keys.right) then
    move = move + 1
  end
  self.input.move = move
  self.input.fire = anyDown(self.isDown, self.keys.fire)
  self.input.missile = anyDown(self.isDown, self.keys.missile)
  return self.input
end

return InputController
