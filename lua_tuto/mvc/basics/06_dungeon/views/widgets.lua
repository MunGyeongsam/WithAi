-- widgets.lua
-- 여러 View 가 함께 쓰는 그리기 도구. 게임의 "UI 공용 컴포넌트"에 해당한다.

local Widgets = {}

-- bar(7, 10, 10) → "[#######...]"
function Widgets.bar(current, max, width)
  width = width or 10
  local ratio = max > 0 and current / max or 0
  local filled = math.floor(math.max(0, math.min(1, ratio)) * width + 0.5)
  return "[" .. string.rep("#", filled) .. string.rep(".", width - filled) .. "]"
end

return Widgets
