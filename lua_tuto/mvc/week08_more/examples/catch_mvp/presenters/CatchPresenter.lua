-- CatchPresenter.lua (MVP)
-- 입력·시간을 받아 Model 을 움직이고, 화면에 보일 "값"을 만들어 View 에 밀어 넣는다(Push).
-- 표시 규칙(문구, HP 위험 여부)은 여기 있다 → gfx 없이 테스트된다.
-- View 계약: showPlayer(lane) · showItems(list) · showScore(text) · showHp(text, danger) · showGameOver(text|nil)

local class = require("class")
local R = require("rules")

local CatchPresenter = class()

local MOVES = { left = -1, a = -1, right = 1, d = 1 }

function CatchPresenter:init(model, view)
  self.model = model
  self.view = view
  self.acc = 0
  self:present()
end

function CatchPresenter:update(dt)
  self.acc = self.acc + dt
  local ticked = false
  while self.acc >= R.TICK do
    self.acc = self.acc - R.TICK
    self.model:tick()
    ticked = true
  end
  if ticked then
    self:present()
  end
end

function CatchPresenter:onKey(key)
  local dir = MOVES[key]
  if dir and not self.model.over then
    self.model:move(dir)
    self:present()
  end
end

function CatchPresenter:present()
  local m, v = self.model, self.view
  local items = {}
  for i, it in ipairs(m.items) do
    items[i] = { lane = it.lane, row = it.row, kind = it.kind }
  end
  v:showPlayer(m.lane)
  v:showItems(items)
  v:showScore("SCORE " .. m.score)
  v:showHp("HP " .. string.rep("*", m.hp), m.hp <= 1)
  v:showGameOver(m.over and "GAME OVER  -  R" or nil)
end

return CatchPresenter
