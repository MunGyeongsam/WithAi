-- integration_test.lua
-- main.lua 의 프레임 루프(C → M 고정 스텝 → drainEvents → V)를 창 없이 재현해 검사한다.
-- 실행: cd lua_tuto/mvc/week04/examples/tests && luajit integration_test.lua [galaga_mvc|galaga_mvc_full|starter]

package.path = ((arg[0] or ""):match("(.*/)") or "./") .. "?.lua;" .. package.path
local h = require("helper")
local app = arg[1] or "galaga_mvc"
h.setup(app)

local GameModel = require("GameModel")
local GameView = require("GameView")
local InputController = require("InputController")
local BulletModel = require("BulletModel")

local W, H = 600, 800
local FIXED_DT = 1 / 60

-- main.lua 와 같은 순서로 한 프레임을 돈다.
local function newApp(seed, isDown)
  local app = {
    game = GameModel({ width = W, height = H, seed = seed }),
    view = GameView({ width = W, height = H, rand = h.fixedRand() }),
    acc = 0,
  }
  app.controller = InputController(app.game, isDown)
  function app.frame(dt)
    local input = app.controller:read()
    app.acc = app.acc + dt
    while app.acc >= FIXED_DT do
      app.game:update(FIXED_DT, input)
      app.acc = app.acc - FIXED_DT
    end
    local events = app.game:drainEvents()
    for i = 1, #events do
      app.view:onEvent(events[i])
    end
    app.view:update(dt)
    app.view:draw(h.fakeGfx(), app.game)
  end
  return app
end

local holdRightFire = function(k)
  return k == "right" or k == "space"
end

print("[integration_test] " .. app .. "/")

h.test("입력이 일정하면 프레임률이 달라도(60fps vs 20fps) 같은 시간 뒤 Model 상태가 같다", function()
  -- 입력이 내내 같으므로 스텝 수만 같으면 결과가 같아야 한다(고정 타임스텝 검사).
  local a = newApp(7, holdRightFire)
  local b = newApp(7, holdRightFire)
  for _ = 1, 180 do
    a.frame(1 / 60)
  end
  for _ = 1, 60 do
    b.frame(3 / 60)
  end
  return h.same(h.snapshot(a.game), h.snapshot(b.game))
end)

-- 한계를 문서로만 적지 않고 테스트로 고정한다(특성 테스트). 입력 해상도가 바뀌면(예: 프레임을 건너뛰는 입력 시각 처리) 이 테스트가 알려 준다.
-- ⚠️ 6주차 입력 기록은 이것을 고치지 않는다(판을 재현할 뿐). 그래서 이 테스트는 6주차 이후에도 통과하는 게 맞다.
h.test("[한계] 입력이 바뀌면 프레임률에 따라 결과가 달라질 수 있다 (입력을 프레임당 1번 읽기 때문)", function()
  local function play(frameDt, frames)
    local clock = 0
    local a = newApp(1, function(k)
      return k == "right" and clock < 0.31 -- 0.31초에 키를 뗈다
    end)
    for _ = 1, frames do
      a.frame(frameDt)
      clock = clock + frameDt
    end
    return a.game.player.x
  end
  return play(1 / 60, 60) ~= play(3 / 60, 20)
end)

h.test("한 프레임에 여러 스텝이 돌아도 적 파괴 연출이 View 에 도착한다", function()
  local a = newApp(1, function()
    return false
  end)
  local e = a.game.enemies[1]
  a.game.bullets[1] = BulletModel(e.x + 4, e.y + 4, 0, 0, 4, 12, "player")
  a.frame(3 / 60) -- 저사양: 한 프레임 = 3스텝
  return #a.view.effects.particles > 0
end)

h.test("10초 플레이 동안 에러 없이 돌고, 점수가 오른다", function()
  local a = newApp(42, holdRightFire)
  for _ = 1, 600 do
    a.frame(1 / 60)
  end
  return a.game.score > 0
end)

h.test("View 를 붙여도 Model 결과는 View 없이 돌린 것과 같다", function()
  local withView = newApp(42, holdRightFire)
  for _ = 1, 600 do
    withView.frame(1 / 60)
  end
  local bare = GameModel({ width = W, height = H, seed = 42 })
  local input = { move = 1, fire = true }
  for _ = 1, 600 do
    bare:update(FIXED_DT, input)
  end
  bare:drainEvents()
  return h.same(h.snapshot(bare), h.snapshot(withView.game))
end)

h.finish()
