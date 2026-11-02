-- PauseView.lua
-- 일시정지 오버레이: 반투명 막 + 안내 문구. 아래 게임 화면은 SceneStack 이 먼저 그려 둔다.

local PauseView = {}

function PauseView.draw(gfx, width, height)
  gfx.setColor(0, 0, 0, 0.6)
  gfx.rectangle("fill", 0, 0, width, height)
  gfx.setColor(1, 1, 1)
  gfx.printf("PAUSED\n\nP / Esc : RESUME\nQ : TITLE", 0, height * 0.4, width, "center")
end

return PauseView
