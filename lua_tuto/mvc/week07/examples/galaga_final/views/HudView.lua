-- HudView.lua
-- 점수·라이프. Model 을 읽기만 한다.
-- 5주차: "GAME OVER / YOU WIN" 문구는 결과 씬(ResultView)으로 옮겼다.

local HudView = {}

--- @param game table  GameModel (읽기 전용: score, lives, combo)
function HudView.draw(gfx, game, width, height)
  gfx.setColor(1, 1, 1)
  gfx.print("SCORE " .. game.score, 10, 10)
  gfx.print("LIVES " .. game.lives, width - 100, 10)
  local combo = game.combo
  if combo.count >= 2 then
    gfx.setColor(1, 0.85, 0.3)
    gfx.printf("COMBO " .. combo.count .. "  x" .. combo:multiplier(), 0, 10, width, "center")
  end
end

return HudView
