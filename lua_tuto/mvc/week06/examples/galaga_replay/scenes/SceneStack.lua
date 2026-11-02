-- SceneStack.lua
-- 스택 기반 상태 기계(pushdown automaton). 맨 위 씬만 update·keypressed 를 받는다.
-- 씬 인터페이스 (모두 선택):
--   enter()  exit()        스택에 들어올 때 / 완전히 빠질 때
--   pause()  resume()      위에 다른 씬이 덮일 때 / 다시 맨 위가 될 때
--   update(dt) draw(gfx) keypressed(key)
--   transparent = true     아래 씬도 함께 그린다(일시정지·결과 오버레이)

local class = require("class")

local SceneStack = class()

function SceneStack:init()
  self.scenes = {}
end

function SceneStack:top()
  return self.scenes[#self.scenes]
end

function SceneStack:size()
  return #self.scenes
end

--- 위에 쌓는다. 아래 씬은 멈춘다(pause).
function SceneStack:push(scene)
  local below = self:top()
  if below and below.pause then
    below:pause()
  end
  scene.stack = self
  self.scenes[#self.scenes + 1] = scene
  if scene.enter then
    scene:enter()
  end
end

--- 맨 위를 뺀다. 드러난 씬은 다시 돈다(resume).
function SceneStack:pop()
  local scene = table.remove(self.scenes)
  if scene and scene.exit then
    scene:exit()
  end
  local below = self:top()
  if below and below.resume then
    below:resume()
  end
  return scene
end

--- 맨 위를 바꾼다(아래 씬은 그대로 멈춰 있다).
function SceneStack:switch(scene)
  local old = table.remove(self.scenes)
  if old and old.exit then
    old:exit()
  end
  scene.stack = self
  self.scenes[#self.scenes + 1] = scene
  if scene.enter then
    scene:enter()
  end
end

--- 전부 비우고 새 씬 하나로 시작한다(예: 타이틀로 돌아가기).
function SceneStack:reset(scene)
  while #self.scenes > 0 do
    local old = table.remove(self.scenes)
    if old.exit then
      old:exit()
    end
  end
  self:push(scene)
end

function SceneStack:update(dt)
  local top = self:top()
  if top and top.update then
    top:update(dt)
  end
end

function SceneStack:keypressed(key)
  local top = self:top()
  if top and top.keypressed then
    top:keypressed(key)
  end
end

--- 맨 위부터 내려가며 투명하지 않은 씬을 찾고, 그 씬부터 위로 차례대로 그린다.
function SceneStack:draw(gfx)
  local first = #self.scenes
  while first > 1 and self.scenes[first].transparent do
    first = first - 1
  end
  for i = first, #self.scenes do
    local scene = self.scenes[i]
    if scene.draw then
      scene:draw(gfx)
    end
  end
end

return SceneStack
