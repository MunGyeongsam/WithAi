-- phase_test.lua
-- 진행 단계 State(FormationPhase / BossPhase)를 창 없이 검사한다.
-- 실행: cd lua_tuto/mvc/week05/examples/tests && luajit phase_test.lua [galaga_states|starter]

package.path = ((arg[0] or ""):match("(.*/)") or "./") .. "?.lua;" .. package.path
local h = require("helper")
local app = arg[1] or "galaga_states"
local root = h.setup(app)

local GameModel = require("GameModel")
local BulletModel = require("BulletModel")

local DT = 1 / 60
local IDLE = { move = 0, fire = false, missile = false }

local function newGame()
  return GameModel({ width = 600, height = 800, seed = 1 })
end

local function hasEvent(events, t)
  for _, e in ipairs(events) do
    if e.type == t then
      return true
    end
  end
  return false
end

local function killAll(g)
  for _, e in ipairs(g.enemies) do
    e.alive = false
  end
end

local function aliveCount(g)
  local n = 0
  for _, e in ipairs(g.enemies) do
    if e.alive then
      n = n + 1
    end
  end
  return n
end

print("[phase_test] " .. app .. "/")

h.test("시작 단계는 편대전(formation)", function()
  return newGame().phase.name == "formation"
end)

h.test("편대전: 전멸하면 새 편대 + formation_cleared", function()
  local g = newGame()
  killAll(g)
  g:update(DT, IDLE)
  return aliveCount(g) == 32 and hasEvent(g:drainEvents(), "formation_cleared")
end)

h.test("점수 1000 → 보스전으로 전환 + 보스 등장 + boss_appeared", function()
  local g = newGame()
  g.score = 1000
  g:update(DT, IDLE)
  return g.phase.name == "boss" and g.boss ~= nil and hasEvent(g:drainEvents(), "boss_appeared")
end)

h.test("보스전: 전멸해도 새 편대가 나오지 않는다", function()
  local g = newGame()
  g.score = 1000
  g:update(DT, IDLE)
  killAll(g)
  g:update(DT, IDLE)
  return aliveCount(g) == 0 and not hasEvent(g:drainEvents(), "formation_cleared")
end)

h.test("보스전: 보스 격파 → won", function()
  local g = newGame()
  g.score = 1000
  g:update(DT, IDLE)
  killAll(g)
  g.boss.hp = 1
  g.bullets[#g.bullets + 1] = BulletModel(g.boss.x + 10, g.boss.y + 10, 0, 0, 4, 12, "player")
  g:update(DT, IDLE)
  return g.state == "won" and hasEvent(g:drainEvents(), "boss_destroyed")
end)

-- 무작위 동등성 비교(equivalence_test)로는 거의 나오지 않는 경계 상황이라 따로 고정한다.
h.test("격파 스텝에 총알 3발이 동시에 맞아도 보상·격파 이벤트는 1번", function()
  local g = newGame()
  g.score = 1000
  g:update(DT, IDLE)
  killAll(g)
  g:drainEvents()
  g.boss.hp = 1
  for i = 1, 3 do
    g.bullets[#g.bullets + 1] = BulletModel(g.boss.x + 10 * i, g.boss.y + 10, 0, 0, 4, 12, "player")
  end
  local before = g.score
  g:update(DT, IDLE)
  local destroyed = 0
  for _, e in ipairs(g:drainEvents()) do
    if e.type == "boss_destroyed" then
      destroyed = destroyed + 1
    end
  end
  return destroyed == 1 and g.score == before + 2000
end)

h.test("reset 하면 다시 편대전부터", function()
  local g = newGame()
  g.score = 1000
  g:update(DT, IDLE)
  g:reset()
  return g.phase.name == "formation" and g.boss == nil
end)

-- 확장 지점 시연: GameModel 을 고치지 않고 새 단계를 끼워 넣을 수 있다.
h.test("새 단계(테스트 안에서 만든 BonusPhase)를 GameModel 수정 없이 끼울 수 있다", function()
  local entered, steps = false, 0
  local BonusPhase = {
    name = "bonus",
    enter = function()
      entered = true
    end,
    update = function()
      steps = steps + 1
    end,
    resolveCollisions = function() end,
    afterStep = function() end,
  }
  local g = newGame()
  g:changePhase(BonusPhase)
  g:update(DT, IDLE)
  g:update(DT, IDLE)
  return entered and steps == 2 and g.phase.name == "bonus"
end)

h.test("GameModel 에는 보스 전용 규칙이 없다 (정적 검사)", function()
  local f = assert(io.open(root .. "models/GameModel.lua", "r"))
  local src = f:read("*a"):gsub("%-%-[^\n]*", "")
  f:close()
  local leaks = {}
  for _, word in ipairs({ "BossModel", "BOSS_", "bossSpawned", "takeDamage", '"won"' }) do
    if src:find(word, 1, true) then
      leaks[#leaks + 1] = word
    end
  end
  if #leaks > 0 then
    error("남아 있는 보스 규칙: " .. table.concat(leaks, ", "))
  end
  return true
end)

h.finish()
