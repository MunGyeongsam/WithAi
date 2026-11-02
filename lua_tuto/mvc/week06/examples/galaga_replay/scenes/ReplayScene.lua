-- ReplayScene.lua
-- 기록(시드 + 스텝별 입력)으로 같은 판을 다시 돌린다. 키보드 대신 "기록"이 입력원이다.
-- Space 로 1배속/4배속 전환 — 배속을 바꿔도(프레임당 스텝 수가 바뀌어도) 결과는 같다.
-- Esc/Enter → 타이틀.

local class = require("class")
local GameModel = require("GameModel")
local GameView = require("GameView")
local ReplayView = require("ReplayView")

local ReplayScene = class()

local FIXED_DT = 1 / 60
local MAX_FRAME_DT = 0.25

--- @param recording table  InputRecorder (seed, steps)
function ReplayScene:init(ctx, recording)
  self.ctx = ctx
  self.recording = recording
  self.cursor = 0
  self.acc = 0
  self.speed = 1
  self.game = GameModel({ width = ctx.width, height = ctx.height, seed = recording.seed })
  self.view = GameView({ width = ctx.width, height = ctx.height, rand = ctx.rand })
end

function ReplayScene:done()
  return self.cursor >= #self.recording.steps
end

function ReplayScene:update(dt)
  if dt > MAX_FRAME_DT then
    dt = MAX_FRAME_DT
  end
  self.acc = self.acc + dt * self.speed
  while self.acc >= FIXED_DT and not self:done() do
    self.cursor = self.cursor + 1
    self.game:update(FIXED_DT, self.recording.steps[self.cursor])
    self.acc = self.acc - FIXED_DT
  end
  local events = self.game:drainEvents()
  for i = 1, #events do
    self.view:onEvent(events[i])
  end
  self.view:update(dt)
end

function ReplayScene:keypressed(key)
  if key == "space" then
    self.speed = (self.speed == 1) and 4 or 1
  elseif key == "escape" or key == "return" then
    self.stack:reset(self.ctx.scenes.Title(self.ctx))
  end
end

function ReplayScene:draw(gfx)
  self.view:draw(gfx, self.game)
  ReplayView.draw(gfx, self.ctx.width, self.cursor, #self.recording.steps, self.speed)
end

return ReplayScene
