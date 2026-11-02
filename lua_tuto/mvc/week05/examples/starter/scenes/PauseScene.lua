-- PauseScene.lua  (STARTER)
-- 일시정지 오버레이(transparent). 아래 PlayScene 은 update 를 받지 못해 그대로 멈춘다.

local class = require("class")
local PauseView = require("PauseView")

local PauseScene = class()

-- TODO: 이 씬은 아래 게임 화면 위에 덮어 그려야 한다. 무엇을 true 로 해야 할까?

function PauseScene:init(ctx)
  self.ctx = ctx
end

function PauseScene:keypressed(key)
  -- TODO: P/Esc → 재개(self.stack:pop())
  --       Q     → 타이틀(self.stack:reset(self.ctx.scenes.Title(self.ctx)))
  --       ⚠️ 다른 씬을 require 하지 않고 ctx.scenes 로 만든다(순환 require 방지)
end

function PauseScene:draw(gfx)
  PauseView.draw(gfx, self.ctx.width, self.ctx.height)
end

return PauseScene
