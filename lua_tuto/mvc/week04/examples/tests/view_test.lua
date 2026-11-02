-- view_test.lua
-- View 를 창 없이 검사한다. love.graphics 대신 "호출 기록기(가짜 gfx)" 를 넘긴다.
-- 핵심 검사: View 는 Model 을 절대 바꾸지 않는다.
-- 실행: cd lua_tuto/mvc/week04/examples/tests && luajit view_test.lua [galaga_mvc|galaga_mvc_full|starter]

package.path = ((arg[0] or ""):match("(.*/)") or "./") .. "?.lua;" .. package.path
local h = require("helper")
local app = arg[1] or "galaga_mvc"
h.setup(app)

local GameModel = require("GameModel")
local GameView = require("GameView")
local BulletModel = require("BulletModel")

local W, H = 600, 800

local function newPair()
  local game = GameModel({ width = W, height = H, seed = 1 })
  local view = GameView({ width = W, height = H, rand = h.fixedRand() })
  return game, view
end

-- 게임을 조금 진행시켜 총알·이벤트가 있는 "평범한 프레임" 상태를 만든다.
local function busyGame()
  local game, view = newPair()
  for _ = 1, 90 do
    game:update(1 / 60, { move = 1, fire = true })
  end
  local events = game:drainEvents()
  for i = 1, #events do
    view:onEvent(events[i])
  end
  view:update(1 / 60)
  return game, view
end

print("[view_test] " .. app .. "/")

h.test("draw 는 Model 을 바꾸지 않는다 (읽기 전용 약속 검사)", function()
  local game, view = busyGame()
  local before = h.snapshot(game)
  view:draw(h.fakeGfx(), game)
  local ok, where = h.same(before, h.snapshot(game))
  if not ok then
    error("draw 가 바꾼 곳: " .. where)
  end
  return true
end)

h.test("onEvent·update 도 Model 을 바꾸지 않는다", function()
  local game, view = busyGame()
  local before = h.snapshot(game)
  view:onEvent({ type = "enemy_destroyed", x = 100, y = 100 })
  view:onEvent({ type = "player_hit" })
  view:update(0.1)
  return h.same(before, h.snapshot(game))
end)

h.test("살아있는 적 수만큼 + 플레이어 1개를 그린다", function()
  local game, view = newPair()
  game.enemies[1].alive = false
  game.enemies[2].alive = false
  local gfx = h.fakeGfx()
  view:draw(gfx, game)
  -- 총알·파티클·번쩍임이 없는 초기 상태: 사각형 = 플레이어 1 + 적 30
  return h.count(gfx, "rectangle") == 1 + 30
end)

h.test("총알도 그린다 (플레이어·적 각 1발)", function()
  local game, view = newPair()
  game.bullets[1] = BulletModel(10, 10, 0, 0, 4, 12, "player")
  game.enemyBullets[1] = BulletModel(20, 20, 0, 0, 4, 12, "enemy")
  local gfx = h.fakeGfx()
  view:draw(gfx, game)
  return h.count(gfx, "rectangle") == 1 + 32 + 2
end)

h.test("HUD 는 점수와 라이프를 출력한다", function()
  local game, view = newPair()
  game.score = 1234
  local gfx = h.fakeGfx()
  view:draw(gfx, game)
  local found = false
  for _, c in ipairs(gfx.calls) do
    if c.name == "print" and tostring(c.args[1]):find("1234") then
      found = true
    end
  end
  return found
end)

h.test("enemy_destroyed 이벤트 → 파티클 생성, 시간이 지나면 사라짐", function()
  local _, view = newPair()
  view:onEvent({ type = "enemy_destroyed", x = 100, y = 100 })
  local made = #view.effects.particles
  for _ = 1, 60 do
    view:update(1 / 60)
  end
  return made > 0 and #view.effects.particles == 0
end)

h.test("player_hit 이벤트 → 화면 흔들림 오프셋 발생 후 0 으로 복귀", function()
  local _, view = newPair()
  view:onEvent({ type = "player_hit" })
  view:update(1 / 60)
  local shaking = view.effects.ox ~= 0 or view.effects.oy ~= 0
  for _ = 1, 60 do
    view:update(1 / 60)
  end
  return shaking and view.effects.ox == 0 and view.effects.oy == 0
end)

h.test("모르는 이벤트는 조용히 무시 (Model 이 이벤트를 늘려도 View 가 깨지지 않음)", function()
  local _, view = newPair()
  view:onEvent({ type = "something_new" })
  view:update(1 / 60)
  return true
end)

h.test("push/pop 짝이 맞는다 (그리기 상태 누수 방지)", function()
  local game, view = busyGame()
  local gfx = h.fakeGfx()
  view:draw(gfx, game)
  return h.count(gfx, "push") == h.count(gfx, "pop")
end)

h.finish()
