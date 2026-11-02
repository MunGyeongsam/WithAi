-- Ticker.lua
-- 고정 간격으로 tick Action 을 보낸다. "시간이 흐른다"도 Action 이므로 기록·재생된다.

local class = require("class")
local actions = require("actions")

local Ticker = class()

--- @param dispatch function(action)
--- @param interval number  tick 간격(초)
function Ticker:init(dispatch, interval)
  self.dispatch = dispatch
  self.interval = interval
  self.acc = 0
end

function Ticker:update(dt)
  self.acc = self.acc + dt
  while self.acc >= self.interval do
    self.acc = self.acc - self.interval
    self.dispatch(actions.tick())
  end
end

return Ticker
