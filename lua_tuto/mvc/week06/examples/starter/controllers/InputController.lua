-- InputController.lua
-- 키 입력을 Action 으로 바꿔 dispatch 한다. 상태를 직접 고치지 않는다.
-- 4주차 겔러그와 달리 "누르고 있는 키"를 매 프레임 읽지 않고, 눌린 순간을 Action 으로 보낸다.

local class = require("class")
local actions = require("actions")

local InputController = class()

local KEY_TO_DIR = {
  up = "up",
  w = "up",
  down = "down",
  s = "down",
  left = "left",
  a = "left",
  right = "right",
  d = "right",
}

--- @param dispatch function(action)
--- @param newSeed  function() -> integer   새 판 시드 (조립부가 정한다)
function InputController:init(dispatch, newSeed)
  self.dispatch = dispatch
  self.newSeed = newSeed
end

--- @return string|nil  "replay" 이면 리플레이 요청(앱 흐름이라 조립부가 처리)
function InputController:keypressed(key, state)
  local dir = KEY_TO_DIR[key]
  if dir then
    self.dispatch(actions.turn(dir))
  elseif key == "r" then
    self.dispatch(actions.restart(self.newSeed()))
  elseif key == "v" and state.status == "dead" then
    return "replay"
  end
  return nil
end

return InputController
