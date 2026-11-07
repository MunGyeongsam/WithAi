-- CatchView.lua (MVP · Passive View)
-- Model 을 모른다. Presenter 가 넣어 준 값을 보관했다가 그리기만 한다. 판단(if)이 거의 없다.

local class = require("class")
local R = require("rules")

local CatchView = class()

CatchView.CELL = 60
CatchView.HUD = 40

local COLORS = {
  coin = { 1, 0.85, 0.2 },
  bomb = { 0.9, 0.25, 0.25 },
}

function CatchView:init()
  self.lane = R.START_LANE
  self.items = {}
  self.scoreText = ""
  self.hpText = ""
  self.danger = false
  self.overText = nil
end

function CatchView:showPlayer(lane)
  self.lane = lane
end

function CatchView:showItems(items)
  self.items = items
end

function CatchView:showScore(text)
  self.scoreText = text
end

function CatchView:showHp(text, danger)
  self.hpText = text
  self.danger = danger
end

function CatchView:showGameOver(text)
  self.overText = text
end

function CatchView:draw(gfx)
  local C, top = CatchView.CELL, CatchView.HUD

  gfx.setColor(0.15, 0.15, 0.2)
  for lane = 1, R.LANES do
    gfx.rectangle("line", (lane - 1) * C, top, C, R.ROWS * C)
  end

  for _, it in ipairs(self.items) do
    gfx.setColor(COLORS[it.kind])
    gfx.circle("fill", (it.lane - 0.5) * C, top + (it.row - 0.5) * C, C * 0.3)
  end

  gfx.setColor(0.3, 0.8, 1)
  gfx.rectangle("fill", (self.lane - 1) * C + 8, top + (R.ROWS - 1) * C + 20, C - 16, C - 28)

  gfx.setColor(1, 1, 1)
  gfx.print(self.scoreText, 8, 12)
  if self.danger then
    gfx.setColor(1, 0.3, 0.3)
  end
  gfx.print(self.hpText, 200, 12)

  if self.overText then
    gfx.setColor(1, 1, 1)
    gfx.printf(self.overText, 0, top + 2 * C, R.LANES * C, "center")
  end
end

return CatchView
