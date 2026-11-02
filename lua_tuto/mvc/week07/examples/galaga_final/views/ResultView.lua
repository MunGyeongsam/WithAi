-- ResultView.lua
-- 결과 오버레이: GAME OVER 또는 YOU WIN + 최종 점수.

local ResultView = {}

function ResultView.draw(gfx, width, height, won, score, message)
  gfx.setColor(0, 0, 0, 0.5)
  gfx.rectangle("fill", 0, 0, width, height)
  if won then
    gfx.setColor(0.6, 1, 0.6)
  else
    gfx.setColor(1, 0.5, 0.5)
  end
  gfx.printf((won and "YOU WIN!" or "GAME OVER") .. "\nSCORE " .. score, 0, height * 0.4, width, "center")
  gfx.setColor(1, 1, 1)
  gfx.printf("R : RETRY   V : REPLAY   S : SAVE REPLAY\nEnter : TITLE", 0, height * 0.55, width, "center")
  if message then
    gfx.printf(message, 0, height * 0.65, width, "center")
  end
end

return ResultView
