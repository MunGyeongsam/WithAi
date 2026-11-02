-- feature_test.lua
-- galaga_mvc_full 에 추가된 기능(유도 미사일·보스)만 검사한다.
-- 기존 기능은 controller/view/integration 테스트를 galaga_mvc_full 로 다시 돌려 회귀를 확인한다.
-- 실행: cd lua_tuto/mvc/week07/examples/tests && luajit feature_test.lua [galaga_final|starter]  (4주차에서 가져옴)

package.path = ((arg[0] or ""):match("(.*/)") or "./") .. "?.lua;" .. package.path
local h = require("helper")
local app = arg[1] or "galaga_final"
h.setup(app)

local GameModel = require("GameModel")
local GameView = require("GameView")
local InputController = require("InputController")
local BulletModel = require("BulletModel")
local BossModel = require("BossModel")
local homing = require("homing")

local DT = 1 / 60
local IDLE = { move = 0, fire = false, missile = false }

local function newGame()
  return GameModel({ width = 600, height = 800, seed = 1 })
end

-- 보스를 등장시키고 편대를 비운다(편대가 보스 앞을 막고 있으면 총알을 적이 먼저 맞는다).
local function bossOnly()
  local g = newGame()
  g.score = 1000
  g:update(DT, IDLE)
  for _, e in ipairs(g.enemies) do
    e.alive = false
  end
  g:drainEvents()
  return g, g.boss
end

local function hasEvent(events, t)
  for _, e in ipairs(events) do
    if e.type == t then
      return true
    end
  end
  return false
end

print("[feature_test] " .. app .. "/")

-- ── 유도 (순수 함수: 창도 GameModel 도 없이 검사) ───────────────────────
h.test("homing.nearest 는 가장 가까운 목표를 고른다", function()
  local x, y = homing.nearest({ { x = 0, y = 0 }, { x = 10, y = 10 }, { x = 100, y = 0 } }, 12, 12)
  return x == 10 and y == 10
end)

h.test("homing.steer 는 목표 쪽으로 꺾되 속력은 유지한다", function()
  local b = { x = 0, y = 0, vx = 0, vy = -100 }
  homing.steer(b, 100, 0, 100, 0.5)
  local speed = math.sqrt(b.vx * b.vx + b.vy * b.vy)
  return b.vx > 0 and math.abs(speed - 100) < 1e-9
end)

-- ── 미사일 ───────────────────────────────────────────────────────────────
h.test("missile 입력 → kind='missile' 투사체 생성", function()
  local g = newGame()
  g:update(DT, { move = 0, fire = false, missile = true })
  return #g.bullets == 1 and g.bullets[1].kind == "missile"
end)

h.test("미사일은 옆에 있는 적 쪽으로 휜다", function()
  local g = newGame()
  local e = g.enemies[1]
  local m = BulletModel(e:centerX() + 200, e:centerY() + 200, 0, -440, 6, 14, "missile")
  g.bullets[1] = m
  g:update(DT, IDLE)
  return m.vx < 0 -- 적이 왼쪽 위에 있으므로 왼쪽으로 꺾임
end)

h.test("일반 총알은 휘지 않는다 (유도가 다른 총알로 번지지 않음)", function()
  local g = newGame()
  local b = BulletModel(500, 600, 0, -520, 4, 12, "player")
  g.bullets[1] = b
  g:update(DT, IDLE)
  return b.vx == 0
end)

-- ── 보스 ────────────────────────────────────────────────────────────────
h.test("점수 1000 이상이면 보스 등장 + boss_appeared", function()
  local g = newGame()
  g.score = 1000
  g:update(DT, IDLE)
  return g.boss ~= nil and hasEvent(g:drainEvents(), "boss_appeared")
end)

h.test("보스는 한 번에 18발 원형 탄막을 쏜다 (기존 BulletModel 재사용)", function()
  local boss = BossModel(240, 70, 40)
  local out = {}
  boss:update(1.0, 600, out)
  local radial = #out == 18
  local moving = out[1] and (out[1].vx ~= 0 or out[1].vy ~= 0)
  return radial and moving and getmetatable(out[1]) == BulletModel
end)

h.test("보스 피격 → HP 감소 + boss_hit", function()
  local g, boss = bossOnly()
  g.bullets[#g.bullets + 1] = BulletModel(boss.x + 10, boss.y + 10, 0, 0, 4, 12, "player")
  g:update(DT, IDLE)
  return boss.hp == boss.maxHp - 1 and hasEvent(g:drainEvents(), "boss_hit")
end)

h.test("보스 격파 → state='won', 보상 점수, boss_destroyed", function()
  local g, boss = bossOnly()
  boss.hp = 1
  local before = g.score
  g.bullets[#g.bullets + 1] = BulletModel(boss.x + 10, boss.y + 10, 0, 0, 4, 12, "player")
  g:update(DT, IDLE)
  return g.state == "won" and g.score == before + 2000 and hasEvent(g:drainEvents(), "boss_destroyed")
end)

h.test("편대가 보스 앞에 있으면 총알은 적이 먼저 맞는다 (충돌 순서 규칙)", function()
  local g = newGame()
  g.score = 1000
  g:update(DT, IDLE)
  local boss = g.boss
  g.bullets[#g.bullets + 1] = BulletModel(boss.x + 10, boss.y + 10, 0, 0, 4, 12, "player")
  g:update(DT, IDLE)
  return boss.hp == boss.maxHp
end)

-- (4주차의 "승리 후 R 로 재시작 (Controller)" 는 5주차에 재시작이 씬으로 옮겨져 scene_test 가 맡는다)

h.test("X 키 → input.missile (Controller)", function()
  local c = InputController(function(k)
    return k == "x"
  end)
  return c:read().missile == true
end)

-- ── View ────────────────────────────────────────────────────────────────
h.test("보스가 있으면 보스 + HP 바(2) = 사각형 3개를 더 그리고, Model 은 바꾸지 않는다", function()
  local g = newGame()
  local view = GameView({ width = 600, height = 800, rand = h.fixedRand() })
  local gfx0 = h.fakeGfx()
  view:draw(gfx0, g)
  g.score = 1000
  g:update(DT, IDLE)
  local before = h.snapshot(g)
  local gfx1 = h.fakeGfx()
  view:draw(gfx1, g)
  return h.count(gfx1, "rectangle") - h.count(gfx0, "rectangle") == 3 and h.same(before, h.snapshot(g))
end)

h.test("새 이벤트(boss_*)를 몰라도 기존 EffectsView 는 깨지지 않는다", function()
  local view = GameView({ width = 600, height = 800, rand = h.fixedRand() })
  view:onEvent({ type = "boss_appeared" })
  view:onEvent({ type = "boss_hit", x = 1, y = 1 })
  view:update(DT)
  return true
end)

h.finish()
