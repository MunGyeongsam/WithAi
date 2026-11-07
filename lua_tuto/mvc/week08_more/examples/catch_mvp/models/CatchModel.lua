-- CatchModel.lua
-- "동전 받기" 규칙. love·View·Controller 를 모른다.
-- catch_mvc · catch_mvp · catch_mvvm 이 이 파일을 똑같이 쓴다(구조가 바뀌어도 Model 은 그대로라는 증거).

local class = require("class")
local prng = require("prng")
local R = require("rules")

local CatchModel = class()

function CatchModel:init(seed)
  self.rng = prng.seed(seed)
  self.lane = R.START_LANE
  self.items = {} -- { lane, row, kind = "coin"|"bomb" }
  self.score = 0
  self.hp = R.START_HP
  self.ticks = 0
  self.over = false
end

function CatchModel:move(dir)
  if self.over then
    return
  end
  self.lane = math.max(1, math.min(R.LANES, self.lane + dir))
end

--- 한 틱: 떨어짐 → 바닥 판정 → 게임 오버 확인 → 생성. 순서가 규칙이다(README 4절).
function CatchModel:tick()
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
    return
  end

  if self.ticks % R.SPAWN_EVERY == 0 then
    local lane, roll
    lane, self.rng = prng.range(self.rng, R.LANES)
    roll, self.rng = prng.range(self.rng, 10)
    items[#items + 1] = { lane = lane, row = 1, kind = roll <= R.BOMB_CHANCE and "bomb" or "coin" }
  end
end

return CatchModel
