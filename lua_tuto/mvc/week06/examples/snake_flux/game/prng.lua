-- prng.lua
-- 순수 함수 난수(Park–Miller). 상태를 숨기지 않는다: 값과 "다음 상태"를 함께 돌려준다.
-- 리듀서가 순수하려면 난수 상태도 state 안에 들어 있어야 한다.

local prng = {}

local M = 2147483647

--- 시드를 유효한 상태(1 ~ M-1)로 맞춘다.
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
