-- CatchView.lua (MVVM)
-- ViewModel 의 속성에 "한 번" 바인딩해 두고, 바뀔 때 들어온 값만 보관해 그린다.
-- 키 입력을 ViewModel 명령으로 바꾸는 것도 View 의 일이다. Model 은 모른다.

local class = require("class")
local R = require("rules")

local CatchView = class()

CatchView.CELL = 60
CatchView.HUD = 40
CatchView.FLASH = 0.3

local COLORS = {
  coin = { 1, 0.85, 0.2 },
  bomb = { 0.9, 0.25, 0.25 },
}

function CatchView:init(vm)
  self.vm = vm
  self.flash = 0
  self.unbinds = {}

  self:_bind(vm.playerLane, function(v)
    self.lane = v
  end)
  self:_bind(vm.items, function(v)
    self.items = v
  end)
  self:_bind(vm.scoreText, function(v)
    self.scoreText = v
  end)
  self:_bind(vm.hpText, function(v)
    self.hpText = v
  end)
  self:_bind(vm.danger, function(v)
    self.danger = v
  end)
  self:_bind(vm.gameOverText, function(v)
    self.overText = v
  end)
  -- 화면 전용 반응: HP 가 줄면 깜빡인다. Model 에 "맞았다" 이벤트가 없어도 된다.
  self:_bind(vm.hp, function(v)
    if self.lastHp and v < self.lastHp then
      self.flash = CatchView.FLASH
    end
    self.lastHp = v
  end)
end

function CatchView:_bind(observable, fn)
  self.unbinds[#self.unbinds + 1] = observable:bind(fn)
end

--- 바인딩 해제. 안 하면 ViewModel 이 이 View 를 계속 붙잡는다(누수).
function CatchView:destroy()
  for _, unbind in ipairs(self.unbinds) do
    unbind()
  end
  self.unbinds = {}
end

function CatchView:update(dt)
  self.flash = math.max(0, self.flash - dt)
end

function CatchView:keypressed(key)
  if key == "left" or key == "a" then
    self.vm:moveLeft()
  elseif key == "right" or key == "d" then
    self.vm:moveRight()
  end
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

  if self.flash > 0 then
    gfx.setColor(1, 0, 0, self.flash / CatchView.FLASH * 0.35)
    gfx.rectangle("fill", 0, 0, R.LANES * C, top + R.ROWS * C)
  end
end

return CatchView
