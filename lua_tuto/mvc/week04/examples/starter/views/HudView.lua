-- HudView.lua  (STARTER)
-- 점수·라이프·게임오버 문구. Model 을 읽기만 한다.

local HudView = {}

--- @param game table  GameModel (읽기 전용: score, lives, state)
function HudView.draw(gfx, game, width, height)
  -- TODO: gfx.print("SCORE " .. game.score, 10, 10)
  --       gfx.print("LIVES " .. game.lives, width - 100, 10)
  --       state == "gameover" 이면 가운데에 "GAME OVER\nPress R" (gfx.printf)
end

return HudView
