-- SnakeView.lua
-- Store 의 상태를 읽어 그리기만 한다. dispatch 하지 않고, 상태를 고치지 않는다.

local SnakeView = {}

local CELL = 28
local TOP = 40 -- 위쪽 점수 표시줄

SnakeView.CELL = CELL
SnakeView.TOP = TOP

--- @param state table   snakeReducer 의 state (읽기 전용)
--- @param label string|nil  화면 위에 덧붙일 표시 (예: "REPLAY")
function SnakeView.draw(gfx, state, label)
  local w, h = state.w * CELL, state.h * CELL

  gfx.setColor(0.08, 0.08, 0.12)
  gfx.rectangle("fill", 0, TOP, w, h)

  if state.food then
    gfx.setColor(1, 0.35, 0.35)
    gfx.rectangle("fill", (state.food.x - 1) * CELL + 4, TOP + (state.food.y - 1) * CELL + 4, CELL - 8, CELL - 8)
  end

  for i = #state.snake, 1, -1 do
    local p = state.snake[i]
    if i == 1 then
      gfx.setColor(0.6, 1, 0.6)
    else
      gfx.setColor(0.3, 0.8, 0.4)
    end
    gfx.rectangle("fill", (p.x - 1) * CELL + 1, TOP + (p.y - 1) * CELL + 1, CELL - 2, CELL - 2)
  end

  gfx.setColor(1, 1, 1)
  gfx.print("SCORE " .. state.score .. "   TICK " .. state.ticks, 10, 12)
  if label then
    gfx.printf(label, 0, 12, w - 10, "right")
  end
  if state.status == "dead" then
    gfx.printf("GAME OVER\nR : RESTART   V : REPLAY", 0, TOP + h * 0.45, w, "center")
  end
end

return SnakeView
