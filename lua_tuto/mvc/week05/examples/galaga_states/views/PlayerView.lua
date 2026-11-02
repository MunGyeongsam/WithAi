-- PlayerView.lua
-- 플레이어를 그린다. Model 을 읽기만 한다(쓰기 금지).

local PlayerView = {}

local COLOR = { 0.4, 0.9, 1 }

--- @param gfx    table  love.graphics 또는 같은 함수를 가진 가짜(테스트용)
--- @param player table  PlayerModel (읽기 전용)
function PlayerView.draw(gfx, player)
  gfx.setColor(COLOR[1], COLOR[2], COLOR[3])
  gfx.rectangle("fill", player.x, player.y, player.w, player.h)
end

return PlayerView
