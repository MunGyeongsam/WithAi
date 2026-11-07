-- collect.lua (ECS 시스템)
-- 바닥에 닿은 pickup 을 같은 칸의 "받는 쪽"(player + position)에 적용하고 지운다.
-- 아이템이 무엇인지 묻지 않는다. pickup 의 숫자(score·damage·heal)만 본다.

local R = require("rules")

return function(world)
  local players = world:query("player", "position")
  for _, id in ipairs(world:query("pickup", "position")) do
    local pos = world:get(id, "position")
    if pos.row >= R.ROWS then
      local pickup = world:get(id, "pickup")
      for _, pid in ipairs(players) do
        if world:get(pid, "position").lane == pos.lane then
          local wallet = world:get(pid, "wallet")
          local health = world:get(pid, "health")
          if wallet and pickup.score then
            wallet.score = wallet.score + pickup.score
          end
          if health and pickup.damage then
            health.hp = health.hp - pickup.damage
          end
          if health and pickup.heal then
            health.hp = math.min(health.max, health.hp + pickup.heal)
          end
        end
      end
      world:destroy(id)
    end
  end
end
