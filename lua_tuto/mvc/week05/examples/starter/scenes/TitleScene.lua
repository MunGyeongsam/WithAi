-- TitleScene.lua
-- 타이틀 화면. Enter/Space → 게임 시작, Esc → 종료 요청.
-- love 를 모른다. 필요한 것은 모두 ctx 로 받는다(ctx.scenes 로 다른 씬을 만든다).

local class = require("class")
local TitleView = require("TitleView")

local TitleScene = class()

--- @param ctx table  { width, height, scenes, quit, ... } (main 이 만든 공용 문맥)
function TitleScene:init(ctx)
  self.ctx = ctx
end

function TitleScene:keypressed(key)
  if key == "return" or key == "space" then
    self.stack:switch(self.ctx.scenes.Play(self.ctx))
  elseif key == "escape" then
    self.ctx.quit()
  end
end

function TitleScene:draw(gfx)
  TitleView.draw(gfx, self.ctx.width, self.ctx.height)
end

return TitleScene
