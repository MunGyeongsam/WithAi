-- combo_test.lua
-- 7주차 신규 기능 "콤보"의 명세이자 검사. AI 에게 기능을 맡길 때 이 파일을 함께 준다.
--   models/ComboModel.lua : ComboModel() → count, timer, tick(dt), hit() → 배율, multiplier(), reset()
--                           WINDOW = 1.0초, MAX_MULT = 4
--   GameModel             : game.combo, 적 격추 점수 = 100 × 배율, 플레이어 피격 시 콤보 끊김, 보스 피격은 무관
--                           이벤트 { type="combo", count, mult } — 콤보 2 이상일 때 enemy_destroyed 바로 뒤
--                           RULES_VERSION = 2 (점수가 바뀌면 보스 등장 시점이 바뀌어 옛 리플레이가 맞지 않는다)
--   HudView               : 콤보 2 이상일 때 "COMBO n  xm"
-- 실행: cd lua_tuto/mvc/week07/examples/tests && luajit combo_test.lua [galaga_final|starter]

package.path = ((arg[0] or ""):match("(.*/)") or "./") .. "?.lua;" .. package.path
local h = require("helper")
local app = arg[1] or "galaga_final"
h.setup(app)

local GameModel = require("GameModel")
local GameView = require("GameView")
local EnemyModel = require("EnemyModel")
local BulletModel = require("BulletModel")
local okCombo, ComboModel = pcall(require, "ComboModel")

local DT = 1 / 60
local IDLE = { move = 0, fire = false, missile = false }

-- 적 3기(세 번째는 멀리 두어 전멸→재생성이 끼지 않게)만 있는 판.
local function smallGame()
  local g = GameModel({ width = 600, height = 800, seed = 3 })
  g.enemies = { EnemyModel(100, 300), EnemyModel(260, 300), EnemyModel(500, 100) }
  g.enemyFireTimer = 1e9 -- 적 총알이 끼지 않게
  return g
end

-- 적 e 위에 멈춘 총알을 놓고 1스텝 진행 → 그 적이 격추된다.
local function shoot(g, e)
  g.bullets[#g.bullets + 1] = BulletModel(e.x + 16, e.y + 8, 0, 0, 4, 12, "player")
  g:update(DT, IDLE)
  return g:drainEvents()
end

local function find(events, kind)
  for i, ev in ipairs(events) do
    if ev.type == kind then
      return ev, i
    end
  end
  return nil
end

print("[combo_test] " .. app .. "/")

-- ── ComboModel 단독 ─────────────────────────────────────────────────────
h.test("ComboModel: 격추마다 배율 1,2,3,4,4 (최대 4)", function()
  local c = ComboModel()
  local got = {}
  for i = 1, 5 do
    got[i] = c:hit()
  end
  return table.concat(got, ",") == "1,2,3,4,4" and c.count == 5
end)

h.test("ComboModel: WINDOW 안이면 유지, WINDOW 가 지나면 끊김", function()
  local c = ComboModel()
  c:hit()
  c:hit()
  c:tick(ComboModel.WINDOW * 0.9)
  local kept = c.count == 2
  c:tick(ComboModel.WINDOW * 0.2)
  return kept and c.count == 0 and c:multiplier() == 1
end)

-- ── GameModel 연결 ──────────────────────────────────────────────────────
h.test("연속 격추: 두 번째 적은 200점 + combo 이벤트(count 2, mult 2)가 enemy_destroyed 바로 뒤", function()
  local g = smallGame()
  shoot(g, g.enemies[1])
  local s1 = g.score
  local events = shoot(g, g.enemies[2])
  local combo, ci = find(events, "combo")
  local _, di = find(events, "enemy_destroyed")
  return s1 == 100 and g.score == 300 and combo and combo.count == 2 and combo.mult == 2 and ci == di + 1
end)

h.test("WINDOW 가 지나 격추하면 콤보 없이 100점씩, combo 이벤트 없음", function()
  local g = smallGame()
  shoot(g, g.enemies[1])
  for _ = 1, math.ceil(ComboModel.WINDOW / DT) + 1 do
    g:update(DT, IDLE)
  end
  g:drainEvents()
  local events = shoot(g, g.enemies[2])
  return g.score == 200 and find(events, "combo") == nil
end)

h.test("플레이어가 맞으면 콤보가 끊긴다", function()
  local g = smallGame()
  shoot(g, g.enemies[1])
  shoot(g, g.enemies[2])
  local p = g.player
  g.enemyBullets[1] = BulletModel(p.x + 10, p.y + 5, 0, 0, 4, 12, "enemy")
  g:update(DT, IDLE)
  return g.lives == 2 and g.combo.count == 0
end)

h.test("보스 피격은 콤보를 바꾸지 않는다 (콤보 점수는 적 격추에만)", function()
  local g = smallGame()
  g.enemies = { EnemyModel(500, 100) }
  shoot(g, g.enemies[1])
  g.enemies = { EnemyModel(20, 700) }
  g.score = 1000
  g:update(DT, IDLE) -- 보스 등장
  local boss, count, score = g.boss, g.combo.count, g.score
  g.bullets[#g.bullets + 1] = BulletModel(boss.x + 10, boss.y + 10, 0, 0, 4, 12, "player")
  g:update(DT, IDLE)
  return boss.hp == boss.maxHp - 1 and g.combo.count == count and g.score == score
end)

h.test("규칙 버전이 2 로 올라갔다 (점수 배율 → 보스 등장 시점이 달라짐)", function()
  return GameModel.RULES_VERSION == 2
end)

-- ── View ────────────────────────────────────────────────────────────────
h.test("HUD: 콤보 2 이상이면 'COMBO 2  x2', 1 이면 표시 없음. 그리기는 Model 을 바꾸지 않는다", function()
  local g = smallGame()
  local view = GameView({ width = 600, height = 800, rand = h.fixedRand() })
  shoot(g, g.enemies[1])
  local g1 = h.fakeGfx()
  view:draw(g1, g)
  shoot(g, g.enemies[2])
  local before = h.snapshot(g)
  local g2 = h.fakeGfx()
  view:draw(g2, g)
  return not h.printed(g1, "COMBO") and h.printed(g2, "COMBO 2  x2") and h.same(before, h.snapshot(g))
end)

if not okCombo then
  print("  (models/ComboModel.lua 를 불러오지 못했다: " .. tostring(ComboModel):match("[^\n]+") .. ")")
end
h.finish()
