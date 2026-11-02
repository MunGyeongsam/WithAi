-- TitleView.lua
-- 타이틀 화면을 그린다.

local TitleView = {}

function TitleView.draw(gfx, width, height)
  gfx.setColor(0.4, 0.9, 1)
  gfx.printf("GALAGA", 0, height * 0.35, width, "center")
  gfx.setColor(1, 1, 1)
  gfx.printf("Enter / Space : START\nEsc : QUIT", 0, height * 0.5, width, "center")
end

return TitleView
