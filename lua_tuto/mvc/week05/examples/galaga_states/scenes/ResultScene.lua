-- ResultScene.lua
-- 결과 오버레이(transparent). 멈춘 마지막 판 위에 GAME OVER / YOU WIN 을 띄운다.
-- R → 새 게임(reset), Enter/Esc → 타이틀(reset).

local class = require("class")
local ResultView = require("ResultView")

local ResultScene = class()

ResultScene.transparent = true

--- @param game table  끝난 GameModel (읽기 전용: state, score)
function ResultScene:init(ctx, game)
  self.ctx = ctx
  self.won = game.state == "won"
  self.score = game.score
end

function ResultScene:keypressed(key)
  if key == "r" then
    self.stack:reset(self.ctx.scenes.Play(self.ctx))
  elseif key == "return" or key == "escape" then
    self.stack:reset(self.ctx.scenes.Title(self.ctx))
  end
end

function ResultScene:draw(gfx)
  ResultView.draw(gfx, self.ctx.width, self.ctx.height, self.won, self.score)
end

return ResultScene
