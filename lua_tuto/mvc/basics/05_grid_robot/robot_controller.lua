-- robot_controller.lua
-- Controller: 키(w/a/s/d)를 방향(up/left/down/right)으로 바꿔 Model 에 전달한다.
-- 키 배치를 바꾸고 싶으면 KEY_TO_DIRECTION 만 고치면 된다. Model 은 키를 모른다.
-- LÖVE2D 에서는 love.keypressed(key) 에서 controller:handle(key) 를 부르면 그대로 동작한다.

local KEY_TO_DIRECTION = {
  w = "up",
  s = "down",
  a = "left",
  d = "right",
}

local RobotController = {}
RobotController.__index = RobotController

function RobotController.new(model, view)
  return setmetatable({ model = model, view = view }, RobotController)
end

function RobotController:handle(key)
  local model, view = self.model, self.view
  if key == "q" then
    return false
  end

  local direction = KEY_TO_DIRECTION[key]
  if not direction then
    view:showMessage("w/a/s/d 로 이동, q 로 종료")
    return true
  end

  local result, err = model:move(direction)
  if not result then
    view:showMessage(err)
    return true
  end

  if result == "blocked" then
    view:showMessage("벽입니다")
  end
  view:render(model)
  if result == "goal" then
    view:showMessage(string.format("목표 도착! 총 %d번 이동", model.moves))
    return false
  end
  return true
end

return RobotController
