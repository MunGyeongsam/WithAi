-- battle_controller.lua
-- 전투 모드 입력 담당. 같은 "i" 키라도 모드별 Controller 가 따로 해석한다.

local BattleController = {}
BattleController.__index = BattleController

function BattleController.new()
  return setmetatable({}, BattleController)
end

function BattleController:handle(game, input)
  if input == "a" then
    return game:attack()
  elseif input == "r" then
    return game:flee()
  elseif input == "i" then
    return game:openInventory()
  end
  return false, "전투 중에는 a / r / i 만 쓸 수 있습니다"
end

return BattleController
