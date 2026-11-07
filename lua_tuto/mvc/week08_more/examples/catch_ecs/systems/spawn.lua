-- spawn.lua (ECS 시스템)
-- 생성 표에서 종류를 골라 컴포넌트 묶음으로 엔티티를 만든다. 난수 상태를 받아 다음 상태를 돌려준다.

local prng = require("prng")
local R = require("rules")

return function(world, rng, spawnTable, kinds)
  local lane, roll
  lane, rng = prng.range(rng, R.LANES)
  roll, rng = prng.range(rng, 10)
  for _, entry in ipairs(spawnTable) do
    if roll <= entry.upTo then
      local kind = kinds[entry.kind]
      world:spawn({
        position = { lane = lane, row = 1 },
        falling = true,
        pickup = kind.pickup,
        sprite = kind.sprite,
      })
      break
    end
  end
  return rng
end
