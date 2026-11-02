-- ComboModel.lua
-- 연속 격추 콤보(7주차 신규 기능). 상태만 갖는 작은 Model. love 비의존, 결정적.
-- WINDOW 초 안에 다음 적을 격추하면 콤보가 이어지고, 점수 배율 = min(콤보 수, MAX_MULT).
-- 보스 피격은 콤보와 무관하다. 플레이어가 맞으면 콤보가 끊긴다.

local class = require("class")

local ComboModel = class()

ComboModel.WINDOW = 1.0
ComboModel.MAX_MULT = 4

--- @field count number  지금까지 이어진 격추 수(0 = 콤보 없음)
--- @field timer number  콤보가 끊기기까지 남은 시간(초)
function ComboModel:init()
  self.count = 0
  self.timer = 0
end

--- 매 스텝 시간 진행. 시간이 다 되면 콤보가 끊긴다.
function ComboModel:tick(dt)
  if self.count > 0 then
    self.timer = self.timer - dt
    if self.timer <= 0 then
      self.count = 0
      self.timer = 0
    end
  end
end

--- 적 격추 1회. @return number  이번 격추에 적용할 점수 배율
function ComboModel:hit()
  self.count = self.count + 1
  self.timer = ComboModel.WINDOW
  return self:multiplier()
end

function ComboModel:multiplier()
  return math.min(math.max(self.count, 1), ComboModel.MAX_MULT)
end

function ComboModel:reset()
  self.count = 0
  self.timer = 0
end

return ComboModel
