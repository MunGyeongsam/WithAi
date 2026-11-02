-- BossModel.lua
-- 보스 1기의 상태 + 이동 + 원형 탄막 발사. love 비의존.
-- 탄막은 기존 BulletModel(vx, vy 보유) 그대로 쓴다 → 총알 자료구조를 바꿀 필요가 없다.

local class = require("class")
local BulletModel = require("BulletModel")

local BossModel = class()

local SPEED = 70
local FIRE_INTERVAL = 1.2
local RADIAL_COUNT = 18
local BULLET_SPEED = 180

--- 보스 상태
-- @field x,y,w,h     number
-- @field hp,maxHp    number
-- @field alive       boolean
-- @field dir         number  -1 | 1
-- @field fireTimer   number  다음 탄막까지 남은 시간(초)
function BossModel:init(x, y, hp)
  self.x, self.y = x, y
  self.w, self.h = 120, 60
  self.hp, self.maxHp = hp, hp
  self.alive = true
  self.dir = 1
  self.fireTimer = 1.0
end

function BossModel:centerX()
  return self.x + self.w * 0.5
end

function BossModel:centerY()
  return self.y + self.h * 0.5
end

--- 좌우 왕복 이동 + 주기적 원형 탄막. 새 총알은 out 배열에 추가한다.
function BossModel:update(dt, width, out)
  self.x = self.x + self.dir * SPEED * dt
  if self.x < 10 then
    self.x, self.dir = 10, 1
  elseif self.x > width - 10 - self.w then
    self.x, self.dir = width - 10 - self.w, -1
  end

  self.fireTimer = self.fireTimer - dt
  if self.fireTimer <= 0 then
    self.fireTimer = FIRE_INTERVAL
    local cx, cy = self:centerX(), self:centerY()
    for k = 0, RADIAL_COUNT - 1 do
      local a = (k / RADIAL_COUNT) * math.pi * 2
      out[#out + 1] = BulletModel(cx, cy, math.cos(a) * BULLET_SPEED, math.sin(a) * BULLET_SPEED, 6, 6, "enemy")
    end
  end
end

--- 피해를 받는다. @return boolean  이번 피해로 쓰러졌는가
function BossModel:takeDamage(amount)
  self.hp = self.hp - amount
  if self.hp <= 0 then
    self.hp = 0
    self.alive = false
    return true
  end
  return false
end

return BossModel
