-- TitleScene.lua
-- 타이틀 화면. Enter/Space → 게임 시작, L → 저장된 리플레이, Esc → 종료 요청.
-- love 를 모른다. 필요한 것은 모두 ctx 로 받는다(ctx.scenes 로 다른 씬을 만든다).

local class = require("class")
local TitleView = require("TitleView")
local InputRecorder = require("InputRecorder")

local TitleScene = class()

--- @param ctx table  { width, height, scenes, quit, storage, ... } (main 이 만든 공용 문맥)
function TitleScene:init(ctx)
  self.ctx = ctx
  self.message = nil
end

function TitleScene:keypressed(key)
  if key == "return" or key == "space" then
    self.stack:switch(self.ctx.scenes.Play(self.ctx))
  elseif key == "l" then
    self:_loadReplay()
  elseif key == "escape" then
    self.ctx.quit()
  end
end

function TitleScene:_loadReplay()
  local text = self.ctx.storage.read(self.ctx.scenes.Result.REPLAY_FILE)
  if not text then
    self.message = "NO SAVED REPLAY"
    return
  end
  local rec = InputRecorder.parse(text)
  if not rec then
    self.message = "INVALID REPLAY FILE"
    return
  end
  self.stack:switch(self.ctx.scenes.Replay(self.ctx, rec))
end

function TitleScene:draw(gfx)
  TitleView.draw(gfx, self.ctx.width, self.ctx.height, self.message)
end

return TitleScene
