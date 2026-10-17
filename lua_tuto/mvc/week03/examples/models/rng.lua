-- rng.lua
-- 결정적 난수 생성기(Park–Miller LCG). love 비의존 + 전역 상태 없음.
-- 같은 시드로 만들면 항상 같은 수열을 낸다 → 테스트/리플레이 가능.

local class = require("class")

local Rng = class()

--- @param seed number  1 ~ 2147483646 사이 정수(0 금지). 기본 1.
function Rng:init(seed)
  seed = seed or 1
  if seed <= 0 then
    seed = 1
  end
  self.state = seed % 2147483647
  if self.state == 0 then
    self.state = 1
  end
end

-- 다음 정수(1 ~ 2147483646). 상수는 double 정밀도(2^53) 안에서 안전하다.
function Rng:nextInt()
  self.state = (self.state * 48271) % 2147483647
  return self.state
end

-- 0.0 이상 1.0 미만 실수
function Rng:nextFloat()
  return (self:nextInt() - 1) / 2147483646
end

-- 1 ~ n 사이 정수
function Rng:range(n)
  return (self:nextInt() % n) + 1
end

return Rng
