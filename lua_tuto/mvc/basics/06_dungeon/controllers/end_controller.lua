-- end_controller.lua
-- 게임 오버 / 승리 화면 입력 담당. 어떤 입력이든 종료를 요청한다.

local EndController = {}
EndController.__index = EndController

function EndController.new()
  return setmetatable({}, EndController)
end

function EndController:handle()
  return true, nil, "quit"
end

return EndController
