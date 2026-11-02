-- ReplayPlayer.lua
-- 기록된 Action 을 다시 dispatch 한다. 키보드·Ticker 대신 "기록"이 입력원이 되는 Controller.
-- 재생 속도(초당 Action 수)는 결과에 영향이 없다. 순서만 같으면 같은 상태가 나온다.

local class = require("class")

local ReplayPlayer = class()

--- @param entries  table              ActionLog.entries
--- @param dispatch function(action)
--- @param perSecond number            초당 재생할 Action 수
function ReplayPlayer:init(entries, dispatch, perSecond)
  self.entries = entries
  self.dispatch = dispatch
  self.perSecond = perSecond
  self.cursor = 0
  self.acc = 0
end

function ReplayPlayer:done()
  return self.cursor >= #self.entries
end

function ReplayPlayer:update(dt)
  self.acc = self.acc + dt * self.perSecond
  while self.acc >= 1 and not self:done() do
    self.acc = self.acc - 1
    self.cursor = self.cursor + 1
    self.dispatch(self.entries[self.cursor])
  end
end

return ReplayPlayer
