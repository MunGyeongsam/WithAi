-- BulletModel.lua
-- 투사체 1발의 "상태 + 등속 이동"만 담는다. love 비의존.
-- 플레이어/적 총알을 같은 모델로 쓴다(kind 로 구분).

local class = require("class")

local BulletModel = class()

--- 투사체 상태
-- @field x,y   number
-- @field w,h   number
-- @field vx,vy number  속도(px/s)
-- @field kind  string  "player" | "enemy"
function BulletModel:init(x, y, vx, vy, w, h, kind)
  self.x = x
  self.y = y
  self.vx = vx
  self.vy = vy
  self.w = w
  self.h = h
  self.kind = kind
end

function BulletModel:update(dt)
  self.x = self.x + self.vx * dt
  self.y = self.y + self.vy * dt
end

-- 월드 경계를 벗어났는가(여유 margin 포함)
function BulletModel:isOffscreen(width, height, margin)
  margin = margin or 24
  return self.y + self.h < -margin
    or self.y > height + margin
    or self.x + self.w < -margin
    or self.x > width + margin
end

return BulletModel
