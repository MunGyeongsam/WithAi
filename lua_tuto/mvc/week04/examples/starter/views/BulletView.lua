-- BulletView.lua  (STARTER)
-- 플레이어/적 총알을 그린다. Model 을 읽기만 한다.

local BulletView = {}

local PLAYER_COLOR = { 1, 1, 0.3 }
local ENEMY_COLOR = { 1, 0.6, 0.2 }

--- @param bullets      table  플레이어 BulletModel 배열 (읽기 전용)
--- @param enemyBullets table  적 BulletModel 배열 (읽기 전용)
function BulletView.draw(gfx, bullets, enemyBullets)
  -- TODO: 플레이어 총알(PLAYER_COLOR), 적 총알(ENEMY_COLOR) 을 각각 사각형으로
end

return BulletView
