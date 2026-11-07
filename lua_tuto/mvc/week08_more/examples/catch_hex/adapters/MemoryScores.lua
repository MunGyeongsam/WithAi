-- MemoryScores.lua (어댑터: SCORES 포트)
-- 메모리에만 둔다. 테스트용이며, 저장 기능이 없는 플랫폼의 대체로도 쓸 수 있다.

local class = require("class")

local MemoryScores = class()

function MemoryScores:init(best)
  self.best = best or 0
  self.saves = 0
end

function MemoryScores:loadBest()
  return self.best
end

function MemoryScores:saveBest(n)
  self.best = n
  self.saves = self.saves + 1
end

return MemoryScores
