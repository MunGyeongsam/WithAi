-- PlayScene.lua
-- 플레이 씬: 4주차 main.lua 가 하던 일(M·V·C 조립 + 프레임 루프)을 그대로 옮겨 왔다.
-- P/Esc → 일시정지(push), 게임이 끝나면 결과 화면을 위에 쌓는다(push).

local class = require("class")
local GameModel = require("GameModel")
local GameView = require("GameView")
local InputController = require("InputController")

local PlayScene = class()

local FIXED_DT = 1 / 60
local MAX_FRAME_DT = 0.25

function PlayScene:init(ctx)
  self.ctx = ctx
  self.acc = 0
  self.game = GameModel({ width = ctx.width, height = ctx.height, seed = ctx.seed() })
  self.view = GameView({ width = ctx.width, height = ctx.height, rand = ctx.rand })
  self.controller = InputController(ctx.isDown)
end

function PlayScene:update(dt)
  if dt > MAX_FRAME_DT then
    dt = MAX_FRAME_DT
  end

  local input = self.controller:read()
  self.acc = self.acc + dt
  while self.acc >= FIXED_DT do
    self.game:update(FIXED_DT, input)
    self.acc = self.acc - FIXED_DT
  end

  local events = self.game:drainEvents()
  for i = 1, #events do
    self.view:onEvent(events[i])
  end
  self.view:update(dt)

  -- TODO: 게임이 끝났으면(state ~= "playing") 결과 씬을 "위에 쌓는다"(push).
  --       self.ctx.scenes.Result(self.ctx, self.game)
  --       왜 switch 가 아니라 push 일까? (힌트: 결과 화면 아래에 무엇이 보여야 하나)
  --       왜 한 번만 쌓일까? (힌트: SceneStack 은 맨 위 씬에만 update 를 준다)
end

function PlayScene:draw(gfx)
  self.view:draw(gfx, self.game)
end

function PlayScene:keypressed(key)
  -- TODO: P/Esc → 일시정지 씬을 위에 쌓는다(self.ctx.scenes.Pause(self.ctx))
end

return PlayScene
