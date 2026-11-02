-- EnemyModel.lua
-- 적 1기의 "상태"만 담는다. 편대 이동/발사 결정은 GameModel 이 조율. love 비의존.

local class = require("class")

local EnemyModel = class()

--- 적 상태
-- @field x,y   number  좌상단 좌표
-- @field w,h   number  크기
-- @field alive boolean 생존 여부
function EnemyModel:init(x, y)
  self.x = x
  self.y = y
  self.w = 36
  self.h = 28
  self.alive = true
end

function EnemyModel:centerX()
  return self.x + self.w * 0.5
end

function EnemyModel:centerY()
  return self.y + self.h * 0.5
end

return EnemyModel
