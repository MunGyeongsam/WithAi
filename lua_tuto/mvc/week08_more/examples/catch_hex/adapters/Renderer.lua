-- Renderer.lua (어댑터: 화면)
-- 코어의 상태를 읽어 그린다. gfx 는 주입받는다. 코어는 이 파일을 모른다.

local R = require("rules")

local Renderer = {}

local CELL, HUD = 60, 40

local COLORS = {
  coin = { 1, 0.85, 0.2 },
  bomb = { 0.9, 0.25, 0.25 },
}

function Renderer.draw(gfx, game)
  gfx.setColor(0.15, 0.15, 0.2)
  for lane = 1, R.LANES do
    gfx.rectangle("line", (lane - 1) * CELL, HUD, CELL, R.ROWS * CELL)
  end

  for _, it in ipairs(game.items) do
    gfx.setColor(COLORS[it.kind])
    gfx.circle("fill", (it.lane - 0.5) * CELL, HUD + (it.row - 0.5) * CELL, CELL * 0.3)
  end

  gfx.setColor(0.3, 0.8, 1)
  gfx.rectangle("fill", (game.lane - 1) * CELL + 8, HUD + (R.ROWS - 1) * CELL + 20, CELL - 16, CELL - 28)

  gfx.setColor(1, 1, 1)
  gfx.print("SCORE " .. game.score, 8, 4)
  gfx.print("BEST " .. game.best, 8, 20)
  if game.hp <= 1 then
    gfx.setColor(1, 0.3, 0.3)
  end
  gfx.print("HP " .. string.rep("*", game.hp), 200, 12)

  if game.over then
    gfx.setColor(1, 1, 1)
    local text = game.newBest and "NEW BEST!  -  R" or "GAME OVER  -  R"
    gfx.printf(text, 0, HUD + 2 * CELL, R.LANES * CELL, "center")
  end
end

return Renderer
