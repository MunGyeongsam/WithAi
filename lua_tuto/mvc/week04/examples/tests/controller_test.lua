-- controller_test.lua
-- InputController 를 창 없이 검사한다. 키보드 대신 "가짜 isDown" 을 주입한다.
-- 실행: cd lua_tuto/mvc/week04/examples/tests && luajit controller_test.lua [galaga_mvc|galaga_mvc_full|starter]

package.path = ((arg[0] or ""):match("(.*/)") or "./") .. "?.lua;" .. package.path
local h = require("helper")
local app = arg[1] or "galaga_mvc"
h.setup(app)

local GameModel = require("GameModel")
local InputController = require("InputController")

-- 눌린 키 집합으로 isDown 을 흉내 낸다.
local function keys(...)
  local set = {}
  for _, k in ipairs({ ... }) do
    set[k] = true
  end
  return function(k)
    return set[k] == true
  end
end

local function newController(isDown)
  local game = GameModel({ width = 600, height = 800, seed = 1 })
  return InputController(game, isDown), game
end

print("[controller_test] " .. app .. "/")

h.test("아무 키도 없으면 move=0, fire=false", function()
  local c = newController(keys())
  local input = c:read()
  return input.move == 0 and input.fire == false
end)

h.test("← 는 move=-1, → 는 move=1", function()
  local left = newController(keys("left")):read().move
  local right = newController(keys("right")):read().move
  return left == -1 and right == 1
end)

h.test("A/D 도 같은 의미 (키 배치는 Controller 의 책임)", function()
  return newController(keys("a")):read().move == -1 and newController(keys("d")):read().move == 1
end)

h.test("←·→ 동시 입력은 상쇄되어 move=0", function()
  return newController(keys("left", "right")):read().move == 0
end)

h.test("Space 는 fire=true", function()
  return newController(keys("space")):read().fire == true
end)

h.test("Esc 는 'quit' 를 돌려줄 뿐 Model 을 건드리지 않는다", function()
  local c, game = newController(keys())
  local before = h.snapshot(game)
  local result = c:keypressed("escape")
  return result == "quit" and h.same(before, h.snapshot(game))
end)

h.test("플레이 중 R 은 무시된다", function()
  local c, game = newController(keys())
  game.score = 500
  return c:keypressed("r") == nil and game.score == 500
end)

h.test("게임오버에서 R 은 Model 을 리셋한다", function()
  local c, game = newController(keys())
  game.state = "gameover"
  game.score = 500
  return c:keypressed("r") == "restart" and game.state == "playing" and game.score == 0
end)

h.test("read() 결과를 Model 에 넣으면 실제로 움직인다 (C → M 연결)", function()
  local c, game = newController(keys("right"))
  local x0 = game.player.x
  game:update(1 / 60, c:read())
  return game.player.x > x0
end)

h.finish()
