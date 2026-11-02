-- BossView.lua
-- 보스와 HP 바를 그린다. Model 을 읽기만 한다.

local BossView = {}

--- @param boss table|nil  BossModel (읽기 전용). 없으면 아무것도 그리지 않는다
function BossView.draw(gfx, boss, width)
  if not (boss and boss.alive) then
    return
  end
  gfx.setColor(0.9, 0.3, 0.9)
  gfx.rectangle("fill", boss.x, boss.y, boss.w, boss.h)

  local barW = width - 200
  gfx.setColor(0.2, 0.2, 0.2)
  gfx.rectangle("fill", 100, 40, barW, 10)
  gfx.setColor(1, 0.2, 0.2)
  gfx.rectangle("fill", 100, 40, barW * (boss.hp / boss.maxHp), 10)
end

return BossView
