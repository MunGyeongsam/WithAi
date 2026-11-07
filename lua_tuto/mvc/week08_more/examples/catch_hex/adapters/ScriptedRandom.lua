-- ScriptedRandom.lua (어댑터: RANDOM 포트)
-- 정해 둔 값을 차례로 돌려준다. "3번 칸에 폭탄"을 시드 찾기 없이 바로 만든다(테스트·튜토리얼용).

local class = require("class")

local ScriptedRandom = class()

function ScriptedRandom:init(values)
  self.values = values
  self.i = 0
end

function ScriptedRandom:range(n)
  self.i = self.i + 1
  local v = self.values[self.i]
  if v == nil then
    error("ScriptedRandom: 대본이 끝났다 (" .. self.i .. "번째)", 2)
  end
  assert(v >= 1 and v <= n, "ScriptedRandom: 범위 밖 값 " .. v)
  return v
end

return ScriptedRandom
