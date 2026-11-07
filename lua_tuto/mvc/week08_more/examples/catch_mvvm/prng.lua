-- prng.lua
-- 순수 함수 난수(Park–Miller). 6주차 snake_flux 와 같다. 값과 "다음 상태"를 함께 돌려준다.

local prng = {}

local M = 2147483647

function prng.seed(n)
  local s = math.floor(n or 1) % M
  if s == 0 then
    s = 1
  end
  return s
end

--- @return number 1~n 사이 정수, number 다음 상태
function prng.range(s, n)
  local s2 = (s * 48271) % M
  return (s2 % n) + 1, s2
end

return prng
