-- PauseScene.lua
-- 일시정지 오버레이(transparent). 아래 PlayScene 은 update 를 받지 못해 그대로 멈춘다.
-- P/Esc → 재개(pop), Q → 타이틀로(reset).

local class = require("class")
local PauseView = require("PauseView")

local PauseScene = class()

PauseScene.transparent = true

function PauseScene:init(ctx)
  self.ctx = ctx
end

function PauseScene:keypressed(key)
  if key == "p" or key == "escape" then
    self.stack:pop()
  elseif key == "q" then
    self.stack:reset(self.ctx.scenes.Title(self.ctx))
  end
end

function PauseScene:draw(gfx)
  PauseView.draw(gfx, self.ctx.width, self.ctx.height)
end

return PauseScene
