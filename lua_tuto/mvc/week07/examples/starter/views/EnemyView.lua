-- EnemyView.lua
-- 살아있는 적을 그린다. Model 을 읽기만 한다.

local EnemyView = {}

local COLOR = { 1, 0.4, 0.4 }

--- @param enemies table  EnemyModel 배열 (읽기 전용)
function EnemyView.draw(gfx, enemies)
  gfx.setColor(COLOR[1], COLOR[2], COLOR[3])
  for i = 1, #enemies do
    local e = enemies[i]
    if e.alive then
      gfx.rectangle("fill", e.x, e.y, e.w, e.h)
    end
  end
end

return EnemyView
