-- App.lua
-- 조립(composition). Store·Dispatcher·ActionLog·Controller·View 를 만들고 연결한다.
-- love 를 모른다 → 테스트가 main.lua 대신 이 App 을 그대로 돌릴 수 있다.
-- (4주차 integration_test 는 main 의 루프를 "흉내" 냈다. 이번엔 진짜를 돌린다.)

local class = require("class")
local actions = require("actions")
local reducer = require("snakeReducer")
local Store = require("Store")
local Dispatcher = require("Dispatcher")
local ActionLog = require("ActionLog")
local InputController = require("InputController")
local Ticker = require("Ticker")
local ReplayPlayer = require("ReplayPlayer")
local SnakeView = require("SnakeView")

local App = class()

local TICK = 0.12
local REPLAY_SPEED = 40 -- 초당 Action 수 (재생 속도는 결과에 영향이 없다)
local MAX_FRAME_DT = 0.25 -- 창 끌기 등으로 멈춘 뒤 tick 이 한꺼번에 몰려 조작 못 하고 죽는 것을 막는다

--- @param ctx table  { seed = function() -> integer }
function App:init(ctx)
  self.ctx = ctx
  self.log = ActionLog()
  self.store = Store(reducer.reduce, nil)
  self.dispatcher = Dispatcher(actions.validate)
  self.dispatcher:register(self.store)
  self.dispatcher:tap(function(a)
    self.log:record(a)
  end)

  local dispatch = function(a)
    self.dispatcher:dispatch(a)
  end
  self.input = InputController(dispatch, ctx.seed)
  self.ticker = Ticker(dispatch, TICK)
  self.mode = "live"
  dispatch(actions.restart(ctx.seed()))
end

--- 마지막 restart 부터 끝까지 = 마지막 판의 Action 들
function App:lastGameEntries()
  local entries = self.log.entries
  local from = 1
  for i = #entries, 1, -1 do
    if entries[i].type == "restart" then
      from = i
      break
    end
  end
  local out = {}
  for i = from, #entries do
    out[#out + 1] = entries[i]
  end
  return out
end

--- 기록으로만 움직이는 별도 Store 를 만들어 재생한다(실시간 Store 는 건드리지 않는다).
function App:startReplay()
  self.replayStore = Store(reducer.reduce, nil)
  local d = Dispatcher(actions.validate)
  d:register(self.replayStore)
  self.player = ReplayPlayer(self:lastGameEntries(), function(a)
    d:dispatch(a)
  end, REPLAY_SPEED)
  self.player:update(1 / REPLAY_SPEED) -- 첫 Action(restart)을 바로 적용해 빈 화면을 피한다
  self.mode = "replay"
end

function App:update(dt)
  if dt > MAX_FRAME_DT then
    dt = MAX_FRAME_DT
  end
  if self.mode == "live" then
    if self.store:getState().status == "playing" then
      self.ticker:update(dt)
    end
  else
    self.player:update(dt)
  end
end

--- @return string|nil  "quit" 이면 종료 요청
function App:keypressed(key)
  if self.mode == "replay" then
    if key == "escape" or key == "v" then
      self.mode = "live"
    end
    return nil
  end
  if key == "escape" then
    return "quit"
  end
  if self.input:keypressed(key, self.store:getState()) == "replay" then
    self:startReplay()
  end
  return nil
end

function App:currentState()
  if self.mode == "replay" then
    return self.replayStore:getState()
  end
  return self.store:getState()
end

function App:draw(gfx)
  local label = nil
  if self.mode == "replay" then
    label = self.player:done() and "REPLAY END (Esc)" or "REPLAY"
  end
  SnakeView.draw(gfx, self:currentState(), label)
end

return App
