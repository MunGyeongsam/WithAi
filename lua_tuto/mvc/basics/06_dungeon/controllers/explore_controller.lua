-- explore_controller.lua
-- 탐험 모드 입력 담당. 규약: handle(game, input) → ok, err

local ExploreController = {}
ExploreController.__index = ExploreController

function ExploreController.new()
  return setmetatable({}, ExploreController)
end

function ExploreController:handle(game, input)
  if input == "n" then
    return game:explore()
  elseif input == "i" then
    return game:openInventory()
  end
  return false, "탐험 중에는 n / i 만 쓸 수 있습니다"
end

return ExploreController
