-- BulletModel.lua  (STARTER — 본문을 채운다)
-- 투사체 1발의 "상태 + 등속 이동". print / io / love 금지.
-- 플레이어/적 총알을 같은 모델로 쓴다(kind 로 구분).

local class = require("class")

local BulletModel = class()

--- 투사체 상태
-- @field x,y   number
-- @field w,h   number
-- @field vx,vy number  속도(px/s). 위로 가면 vy < 0
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
  -- TODO: 속도 × dt 만큼 이동
end

--- 월드 경계(+margin)를 벗어났는가
function BulletModel:isOffscreen(width, height, margin)
  margin = margin or 24
  -- TODO: 네 방향 모두 검사 (모놀리식은 위/아래만 봤다 — 왜 부족한가?)
  return false
end

return BulletModel
