-- HudView.lua
-- 점수·라이프·게임오버 문구. Model 을 읽기만 한다.

local HudView = {}

--- @param game table  GameModel (읽기 전용: score, lives, state)
function HudView.draw(gfx, game, width, height)
  gfx.setColor(1, 1, 1)
  gfx.print("SCORE " .. game.score, 10, 10)
  gfx.print("LIVES " .. game.lives, width - 100, 10)
  if game.state == "gameover" then
    gfx.printf("GAME OVER\nPress R", 0, height * 0.475, width, "center")
  end
end

return HudView
