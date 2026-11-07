-- PrngRandom.lua (어댑터: RANDOM 포트)
-- 시드로 정해지는 난수. 다른 예제의 prng 와 같은 수열을 낸다.

local class = require("class")
local prng = require("prng")

local PrngRandom = class()

function PrngRandom:init(seed)
  self.state = prng.seed(seed)
end

function PrngRandom:range(n)
  local v
  v, self.state = prng.range(self.state, n)
  return v
end

return PrngRandom
