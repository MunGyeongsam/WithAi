-- CatchViewModel.lua (MVVM)
-- 화면이 필요로 하는 값을 Observable "속성"으로, 화면이 할 수 있는 일을 "명령"(메서드)으로 내놓는다.
-- View 를 모른다. 누가 몇 개 바인딩했는지도 모른다.

local class = require("class")
local Observable = require("Observable")
local R = require("rules")

local CatchViewModel = class()

function CatchViewModel:init(model)
  self.model = model
  self.acc = 0

  -- 속성
  self.playerLane = Observable(model.lane)
  self.items = Observable({})
  self.scoreText = Observable("")
  self.hp = Observable(model.hp)
  self.hpText = Observable("")
  self.danger = Observable(false)
  self.gameOverText = Observable(nil)

  self:_sync(true)
end

-- 명령
function CatchViewModel:moveLeft()
  self:_move(-1)
end

function CatchViewModel:moveRight()
  self:_move(1)
end

function CatchViewModel:update(dt)
  self.acc = self.acc + dt
  local ticked = false
  while self.acc >= R.TICK do
    self.acc = self.acc - R.TICK
    self.model:tick()
    ticked = true
  end
  if ticked then
    self:_sync(true)
  end
end

function CatchViewModel:_move(dir)
  self.model:move(dir)
  self:_sync(false)
end

--- Model → 속성. 값이 같으면 Observable 이 알아서 조용히 넘어간다.
function CatchViewModel:_sync(itemsChanged)
  local m = self.model
  self.playerLane:set(m.lane)
  if itemsChanged then
    local list = {}
    for i, it in ipairs(m.items) do
      list[i] = { lane = it.lane, row = it.row, kind = it.kind }
    end
    self.items:set(list)
  end
  self.scoreText:set("SCORE " .. m.score)
  self.hp:set(m.hp)
  self.hpText:set("HP " .. string.rep("*", m.hp))
  self.danger:set(m.hp <= 1)
  self.gameOverText:set(m.over and "GAME OVER  -  R" or nil)
end

return CatchViewModel
