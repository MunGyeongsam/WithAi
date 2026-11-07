-- Runtime.lua (TEA)
-- 프로그램을 돌리는 유일한 "가변" 부분: 현재 model 보관, 시간 → tick msg, effect 전달, view 결과 캐시.
-- love 를 모른다(gfx 와 effect 처리기는 주입받는다).

local class = require("class")

local unpack = table.unpack or unpack

local Runtime = class()

--- @param program table init·update·view·onKey·TICK
--- @param onEffect function|nil effect 하나를 받아 바깥 세계에 실행한다
function Runtime:init(program, seed, onEffect)
  self.program = program
  self.model = program.init(seed)
  self.onEffect = onEffect or function() end
  self.acc = 0
  self.history = { self.model }
  self.viewCalls = 0
end

function Runtime:send(msg)
  local model, effects = self.program.update(self.model, msg)
  if model ~= self.model then
    self.model = model
    self.history[#self.history + 1] = model
  end
  if effects then
    for _, e in ipairs(effects) do
      self.onEffect(e)
    end
  end
end

--- 시간 구독: 실시간을 tick msg 로 바꾼다.
function Runtime:update(dt)
  self.acc = self.acc + dt
  while self.acc >= self.program.TICK do
    self.acc = self.acc - self.program.TICK
    self:send({ type = "tick" })
  end
end

function Runtime:keypressed(key)
  local msg = self.program.onKey(key)
  if msg then
    self:send(msg)
  end
end

--- model 이 불변이므로 "같은 테이블이면 화면도 같다". 비교 한 번으로 view 재계산을 건너뛴다.
function Runtime:commands()
  if self.cachedFor ~= self.model then
    self.cached = self.program.view(self.model)
    self.cachedFor = self.model
    self.viewCalls = self.viewCalls + 1
  end
  return self.cached
end

function Runtime:draw(gfx)
  for _, cmd in ipairs(self:commands()) do
    gfx[cmd[1]](unpack(cmd, 2))
  end
end

--- 시간 여행: n 단계 전 model 로 되돌린다(옛 model 이 그대로 남아 있으니 가능하다).
function Runtime:rewind(steps)
  local n = math.max(1, #self.history - steps)
  for i = #self.history, n + 1, -1 do
    self.history[i] = nil
  end
  self.model = self.history[n]
end

return Runtime
