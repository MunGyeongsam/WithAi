-- render.lua (ECS 시스템)
-- position + sprite 를 가진 엔티티를 그리고, player 의 wallet·health 로 HUD 를 그린다. gfx 는 주입받는다.

local R = require("rules")

local CELL, HUD = 60, 40

local function drawSprite(gfx, pos, sprite)
  local cx, cy = (pos.lane - 0.5) * CELL, HUD + (pos.row - 0.5) * CELL
  gfx.setColor(sprite.color)
  if sprite.shape == "circle" then
    gfx.circle("fill", cx, cy, CELL * 0.3)
  elseif sprite.shape == "diamond" then
    local r = CELL * 0.3
    gfx.polygon("fill", cx, cy - r, cx + r, cy, cx, cy + r, cx - r, cy)
  else
    gfx.rectangle("fill", (pos.lane - 1) * CELL + 8, HUD + (pos.row - 1) * CELL + 20, CELL - 16, CELL - 28)
  end
end

return function(gfx, world, over)
  gfx.setColor(0.15, 0.15, 0.2)
  for lane = 1, R.LANES do
    gfx.rectangle("line", (lane - 1) * CELL, HUD, CELL, R.ROWS * CELL)
  end

  for _, id in ipairs(world:query("position", "sprite")) do
    drawSprite(gfx, world:get(id, "position"), world:get(id, "sprite"))
  end

  for _, id in ipairs(world:query("player", "wallet", "health")) do
    local hp = world:get(id, "health").hp
    gfx.setColor(1, 1, 1)
    gfx.print("SCORE " .. world:get(id, "wallet").score, 8, 12)
    if hp <= 1 then
      gfx.setColor(1, 0.3, 0.3)
    end
    gfx.print("HP " .. string.rep("*", hp), 200, 12)
  end

  if over then
    gfx.setColor(1, 1, 1)
    gfx.printf("GAME OVER  -  R", 0, HUD + 2 * CELL, R.LANES * CELL, "center")
  end
end
