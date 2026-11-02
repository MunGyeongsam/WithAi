-- ResultScene.lua
-- 결과 오버레이(transparent). 멈춘 마지막 판 위에 GAME OVER / YOU WIN 을 띄운다.
-- R → 새 게임(reset), V → 방금 판 리플레이(reset), S → 기록 저장, Enter/Esc → 타이틀(reset).

local class = require("class")
local ResultView = require("ResultView")

local ResultScene = class()

ResultScene.transparent = true
ResultScene.REPLAY_FILE = "replay.txt"

--- @param game      table  끝난 GameModel (읽기 전용: state, score)
--- @param recording table  InputRecorder (리플레이용)
function ResultScene:init(ctx, game, recording)
  self.ctx = ctx
  self.won = game.state == "won"
  self.score = game.score
  self.recording = recording
  self.message = nil
end

function ResultScene:keypressed(key)
  if key == "r" then
    self.stack:reset(self.ctx.scenes.Play(self.ctx))
  elseif key == "v" and self.recording then
    self.stack:reset(self.ctx.scenes.Replay(self.ctx, self.recording))
  elseif key == "s" and self.recording then
    local ok = self.ctx.storage.write(ResultScene.REPLAY_FILE, self.recording:serialize())
    self.message = ok and "SAVED" or "SAVE FAILED"
  elseif key == "return" or key == "escape" then
    self.stack:reset(self.ctx.scenes.Title(self.ctx))
  end
end

function ResultScene:draw(gfx)
  ResultView.draw(gfx, self.ctx.width, self.ctx.height, self.won, self.score, self.message)
end

return ResultScene
