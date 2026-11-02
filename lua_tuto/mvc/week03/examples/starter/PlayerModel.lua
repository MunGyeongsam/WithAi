-- PlayerModel.lua  (STARTER — 본문을 채운다)
-- 플레이어의 "상태 + 규칙"만 담는다. print / io / love 금지.
-- 참고: 2주차 galaga_monolith/main.lua 의 "플레이어 입력 + 이동", "발사(쿨다운)" 블록.

local class = require("class")

local PlayerModel = class()

--- 플레이어 상태
-- @field x,y      number  좌상단 좌표
-- @field w,h      number  크기 (40, 24)
-- @field cooldown number  다음 발사까지 남은 시간(초)
function PlayerModel:init(x, y)
  self.x = x
  self.y = y
  self.w = 40
  self.h = 24
  self.cooldown = 0
end

--- dir(-1|0|1) 방향으로 speed(px/s) 만큼 이동한다.
function PlayerModel:move(dt, dir, speed)
  -- TODO: love.keyboard 를 읽지 말 것. dir 은 바깥(Controller)이 준다.
end

--- x 를 [minX, maxX - w] 범위로 제한한다.
function PlayerModel:clamp(minX, maxX)
  -- TODO: 모놀리식의 "if player.x < 0 ... elseif player.x > 600 - player.w" 를 옮긴다.
  --       600 같은 매직 넘버 대신 인자를 쓴다.
end

function PlayerModel:tickCooldown(dt)
  -- TODO
end

function PlayerModel:canFire()
  -- TODO
  return false
end

function PlayerModel:resetCooldown(seconds)
  -- TODO
end

return PlayerModel
