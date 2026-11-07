-- CatchGame.lua (Hexagonal · 코어)
-- 규칙만 안다. 난수와 최고 점수 저장은 "포트"로 받는다 — 어디서 오는지(파일? 메모리? 테스트 대본?) 모른다.

local class = require("class")
local Ports = require("Ports")
local R = require("rules")

local CatchGame = class()

--- @param ports table { random = RANDOM 포트, scores = SCORES 포트 }
function CatchGame:init(ports)
  self.random = Ports.check("random", ports.random, Ports.RANDOM)
  self.scores = Ports.check("scores", ports.scores, Ports.SCORES)
  self.best = self.scores:loadBest()
  self.newBest = false
  self.lane = R.START_LANE
  self.items = {}
  self.score = 0
  self.hp = R.START_HP
  self.ticks = 0
  self.over = false
end

function CatchGame:move(dir)
  if self.over then
    return
  end
  self.lane = math.max(1, math.min(R.LANES, self.lane + dir))
end

function CatchGame:tick()
  if self.over then
    return
  end
  self.ticks = self.ticks + 1

  local items = self.items
  for i = #items, 1, -1 do
    local it = items[i]
    it.row = it.row + 1
    if it.row >= R.ROWS then
      if it.lane == self.lane then
        if it.kind == "coin" then
          self.score = self.score + R.COIN_SCORE
        else
          self.hp = self.hp - 1
        end
      end
      table.remove(items, i)
    end
  end

  if self.hp <= 0 then
    self.hp = 0
    self.over = true
    self:_finish()
    return
  end

  if self.ticks % R.SPAWN_EVERY == 0 then
    local lane = self.random:range(R.LANES)
    local roll = self.random:range(10)
    items[#items + 1] = { lane = lane, row = 1, kind = roll <= R.BOMB_CHANCE and "bomb" or "coin" }
  end
end

function CatchGame:_finish()
  if self.score > self.best then
    self.best = self.score
    self.newBest = true
    self.scores:saveBest(self.score)
  end
end

return CatchGame
