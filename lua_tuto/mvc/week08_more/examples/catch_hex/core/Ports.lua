-- Ports.lua (Hexagonal)
-- 포트 = 코어가 바깥에 요구하는 "모양". 어댑터가 모양을 지키는지 경계에서 한 번 검사한다.

local Ports = {}

Ports.RANDOM = { "range" } -- range(n) → 1~n 정수
Ports.SCORES = { "loadBest", "saveBest" } -- loadBest() → 정수, saveBest(n)

function Ports.check(name, adapter, spec)
  if type(adapter) ~= "table" then
    error(name .. " 포트에 어댑터가 없다", 3)
  end
  for _, fn in ipairs(spec) do
    if type(adapter[fn]) ~= "function" then
      error(name .. " 어댑터에 " .. fn .. " 이(가) 없다", 3)
    end
  end
  return adapter
end

return Ports
