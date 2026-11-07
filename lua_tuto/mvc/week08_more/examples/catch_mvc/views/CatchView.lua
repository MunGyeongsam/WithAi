-- CatchView.lua (MVC)
-- Model 을 직접 읽어(Pull) 그린다. 문구("SCORE"), 위험 색(HP 1) 같은 "표시 규칙"도 여기 있다.
-- → 표시 규칙을 검사하려면 가짜 gfx 로 draw 를 돌려야 하고, Model 필드 이름이 바뀌면 여기가 깨진다(README 2-3).

local R = require("rules")

local CatchView = {}

CatchView.CELL = 60
CatchView.HUD = 40

local COLORS = {
  coin = { 1, 0.85, 0.2 },
  bomb = { 0.9, 0.25, 0.25 },
}

function CatchView.draw(gfx, model)
  local C, top = CatchView.CELL, CatchView.HUD

  gfx.setColor(0.15, 0.15, 0.2)
  for lane = 1, R.LANES do
    gfx.rectangle("line", (lane - 1) * C, top, C, R.ROWS * C)
  end

  for _, it in ipairs(model.items) do
    gfx.setColor(COLORS[it.kind])
    gfx.circle("fill", (it.lane - 0.5) * C, top + (it.row - 0.5) * C, C * 0.3)
  end

  gfx.setColor(0.3, 0.8, 1)
  gfx.rectangle("fill", (model.lane - 1) * C + 8, top + (R.ROWS - 1) * C + 20, C - 16, C - 28)

  gfx.setColor(1, 1, 1)
  gfx.print("SCORE " .. model.score, 8, 12)
  if model.hp <= 1 then
    gfx.setColor(1, 0.3, 0.3)
  end
  gfx.print("HP " .. string.rep("*", model.hp), 200, 12)

  if model.over then
    gfx.setColor(1, 1, 1)
    gfx.printf("GAME OVER  -  R", 0, top + 2 * C, R.LANES * C, "center")
  end
end

return CatchView
