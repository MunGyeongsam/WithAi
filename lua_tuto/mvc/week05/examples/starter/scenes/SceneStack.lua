-- SceneStack.lua  (STARTER)
-- 스택 기반 상태 기계(pushdown automaton). 맨 위 씬만 update·keypressed 를 받는다.
-- 씬 인터페이스 (모두 선택 — 없으면 건너뛴다):
--   enter()  exit()        스택에 들어올 때 / 완전히 빠질 때
--   pause()  resume()      위에 다른 씬이 덮일 때 / 다시 맨 위가 될 때
--   update(dt) draw(gfx) keypressed(key)
--   transparent = true     아래 씬도 함께 그린다(일시정지·결과 오버레이)
-- 검사: tests/scene_test.lua 의 "SceneStack:" 로 시작하는 3개가 먼저 통과해야 한다.

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

--- 위에 쌓는다. 아래 씬은 멈춘다(pause). 새 씬에 scene.stack = self 를 꼭 넣는다(씬이 전환을 요청할 때 쓴다).
function SceneStack:push(scene)
  -- TODO: below:pause() → scene.stack = self → 쌓기 → scene:enter()
end

--- 맨 위를 뺀다. 드러난 씬은 다시 돈다(resume).
function SceneStack:pop()
  -- TODO: 빼기 → scene:exit() → 새 맨 위:resume() → 뺀 씬 반환
end

--- 맨 위를 바꾼다(아래 씬은 그대로 멈춰 있다 — pause/resume 은 부르지 않는다).
function SceneStack:switch(scene)
  -- TODO: old:exit() → 교체 → scene.stack = self → scene:enter()
end

--- 전부 비우고 새 씬 하나로 시작한다(예: 타이틀로 돌아가기).
function SceneStack:reset(scene)
  -- TODO: 위에서부터 하나씩 exit 하며 비우고 → push(scene)
end

function SceneStack:update(dt)
  -- TODO: 맨 위 씬에만 (모든 씬에 주면 일시정지가 게임을 멈추지 못한다)
end

function SceneStack:keypressed(key)
  -- TODO: 맨 위 씬에만
end

--- 맨 위부터 내려가며 투명하지 않은 씬을 찾고, 그 씬부터 위로 차례대로 그린다.
function SceneStack:draw(gfx)
  -- TODO: 예) [Title] → Title / [Play, Pause(투명)] → Play, Pause / [A, B, C(투명)] → B, C
end

return SceneStack
