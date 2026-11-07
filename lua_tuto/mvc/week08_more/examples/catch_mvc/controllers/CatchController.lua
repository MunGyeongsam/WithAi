-- CatchController.lua (MVC)
-- 입력과 시간을 Model 호출로 바꾼다. View 를 모른다.

local class = require("class")
local R = require("rules")

local CatchController = class()

local MOVES = { left = -1, a = -1, right = 1, d = 1 }

function CatchController:init(model)
  self.model = model
  self.acc = 0
end

function CatchController:update(dt)
  self.acc = self.acc + dt
  while self.acc >= R.TICK do
    self.acc = self.acc - R.TICK
    self.model:tick()
  end
end

function CatchController:keypressed(key)
  local dir = MOVES[key]
  if dir then
    self.model:move(dir)
  end
end

return CatchController
