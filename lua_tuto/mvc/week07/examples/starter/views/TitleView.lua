-- TitleView.lua
-- 타이틀 화면을 그린다.

local TitleView = {}

function TitleView.draw(gfx, width, height, message)
  gfx.setColor(0.4, 0.9, 1)
  gfx.printf("GALAGA", 0, height * 0.35, width, "center")
  gfx.setColor(1, 1, 1)
  gfx.printf("Enter / Space : START\nL : LOAD REPLAY\nEsc : QUIT", 0, height * 0.5, width, "center")
  if message then
    gfx.setColor(1, 0.6, 0.4)
    gfx.printf(message, 0, height * 0.65, width, "center")
  end
end

return TitleView
