-- scene_test.lua
-- SceneStack 과 씬 전환을 창 없이 검사한다. 키 입력은 stack:keypressed, 누르고 있는 키는 ctx.held.
-- 실행: cd lua_tuto/mvc/week05/examples/tests && luajit scene_test.lua [galaga_states|starter]

package.path = ((arg[0] or ""):match("(.*/)") or "./") .. "?.lua;" .. package.path
local h = require("helper")
local app = arg[1] or "galaga_states"
h.setup(app)

local SceneStack = require("SceneStack")

local DT = 1 / 60

-- 타이틀부터 시작하는 앱 하나를 만든다(main.lua 의 love.load 와 같은 일).
local function newApp()
  local ctx = h.fakeCtx()
  local stack = SceneStack()
  stack:push(ctx.scenes.Title(ctx))
  return stack, ctx
end

local function startPlay()
  local stack, ctx = newApp()
  stack:keypressed("return")
  return stack, ctx, stack:top()
end

local function printed(gfx, text)
  for _, c in ipairs(gfx.calls) do
    if (c.name == "print" or c.name == "printf") and tostring(c.args[1]):find(text, 1, true) then
      return true
    end
  end
  return false
end

print("[scene_test] " .. app .. "/")

-- ── SceneStack 자체 (씬 없이 기록용 가짜 씬으로) ─────────────────────────
h.test("SceneStack: push/pop/switch/reset 이 enter·exit·pause·resume 을 올바른 순서로 부른다", function()
  local log = {}
  local function scene(name)
    return {
      enter = function()
        log[#log + 1] = name .. ".enter"
      end,
      exit = function()
        log[#log + 1] = name .. ".exit"
      end,
      pause = function()
        log[#log + 1] = name .. ".pause"
      end,
      resume = function()
        log[#log + 1] = name .. ".resume"
      end,
    }
  end
  local s = SceneStack()
  s:push(scene("A"))
  s:push(scene("B"))
  s:pop()
  s:switch(scene("C"))
  s:reset(scene("D"))
  local got = table.concat(log, " ")
  local want = "A.enter A.pause B.enter B.exit A.resume A.exit C.enter C.exit D.enter"
  if got ~= want then
    error("순서: " .. got)
  end
  return s:size() == 1
end)

h.test("SceneStack: 투명한 씬 아래로 불투명한 씬까지만 그린다", function()
  local drawn = {}
  local function scene(name, transparent)
    return {
      transparent = transparent,
      draw = function()
        drawn[#drawn + 1] = name
      end,
    }
  end
  local s = SceneStack()
  s:push(scene("A", false))
  s:push(scene("B", false))
  s:push(scene("C", true))
  s:draw(h.fakeGfx())
  return table.concat(drawn, ",") == "B,C"
end)

h.test("SceneStack: 맨 위 씬만 update·keypressed 를 받는다", function()
  local hits = {}
  local function scene(name)
    return {
      update = function()
        hits[#hits + 1] = name .. ".u"
      end,
      keypressed = function()
        hits[#hits + 1] = name .. ".k"
      end,
    }
  end
  local s = SceneStack()
  s:push(scene("A"))
  s:push(scene("B"))
  s:update(DT)
  s:keypressed("x")
  return table.concat(hits, ",") == "B.u,B.k"
end)

-- ── 타이틀 ───────────────────────────────────────────────────────────────
h.test("타이틀: Enter → 플레이 (스택 1개, 새 게임 1번 생성)", function()
  local stack, ctx, play = startPlay()
  return stack:size() == 1 and play.game ~= nil and ctx.seeds == 1
end)

h.test("타이틀: Esc → 종료 요청(ctx.quit) — 씬은 love.event 를 모른다", function()
  local stack, ctx = newApp()
  stack:keypressed("escape")
  return ctx.quitCalled
end)

h.test("타이틀 화면에는 게임이 그려지지 않는다", function()
  local stack = newApp()
  local gfx = h.fakeGfx()
  stack:draw(gfx)
  return h.count(gfx, "rectangle") == 0 and printed(gfx, "GALAGA")
end)

-- ── 일시정지 ─────────────────────────────────────────────────────────────
h.test("플레이: P → 일시정지가 위에 쌓인다 (스택 2개)", function()
  local stack = startPlay()
  stack:keypressed("p")
  return stack:size() == 2 and stack:top().transparent == true
end)

h.test("일시정지 중에는 시간이 흘러도 게임이 멈춰 있고 시간도 쌓이지 않는다", function()
  local stack, ctx, play = startPlay()
  ctx.held.right, ctx.held.space = true, true
  stack:update(DT)
  stack:keypressed("p")
  local before = h.snapshot(play.game)
  local acc = play.acc
  for _ = 1, 120 do
    stack:update(DT)
  end
  return h.same(before, h.snapshot(play.game)) and play.acc == acc
end)

h.test("재개하면 밀린 시간을 한꺼번에 따라잡지 않는다 (재개 직후 1스텝만)", function()
  local stack, ctx, play = startPlay()
  stack:keypressed("p")
  for _ = 1, 120 do
    stack:update(DT)
  end
  stack:keypressed("p")
  ctx.held.right = true
  local x0 = play.game.player.x
  stack:update(DT)
  local moved = play.game.player.x - x0
  return math.abs(moved - 320 * DT) < 1e-9 -- PLAYER_SPEED × 1스텝
end)

h.test("일시정지 화면: 멈춘 게임 위에 오버레이를 그린다", function()
  local stack = startPlay()
  stack:keypressed("p")
  local gfx = h.fakeGfx()
  stack:draw(gfx)
  return h.count(gfx, "rectangle") > 32 and printed(gfx, "PAUSED")
end)

h.test("일시정지: Q → 타이틀 (스택 1개)", function()
  local stack = startPlay()
  stack:keypressed("p")
  stack:keypressed("q")
  return stack:size() == 1 and stack:top().game == nil and stack:top().transparent ~= true
end)

-- ── 결과 ─────────────────────────────────────────────────────────────────
h.test("게임오버 → 결과가 위에 1번만 쌓인다", function()
  local stack, _, play = startPlay()
  play.game.state = "gameover"
  stack:update(DT)
  stack:update(DT)
  local gfx = h.fakeGfx()
  stack:draw(gfx)
  return stack:size() == 2 and printed(gfx, "GAME OVER")
end)

h.test("승리 → 결과에 YOU WIN", function()
  local stack, _, play = startPlay()
  play.game.state = "won"
  stack:update(DT)
  local gfx = h.fakeGfx()
  stack:draw(gfx)
  return printed(gfx, "YOU WIN")
end)

h.test("결과: R → 새 게임 (점수 0, 시드 새로 받음, 스택 1개)", function()
  local stack, ctx, play = startPlay()
  play.game.score = 1234
  play.game.state = "gameover"
  stack:update(DT)
  stack:keypressed("r")
  local fresh = stack:top()
  return stack:size() == 1 and fresh ~= play and fresh.game.score == 0 and ctx.seeds == 2
end)

h.test("결과: Enter → 타이틀", function()
  local stack, _, play = startPlay()
  play.game.state = "gameover"
  stack:update(DT)
  stack:keypressed("return")
  return stack:size() == 1 and stack:top().game == nil
end)

h.test("전체 경로: 타이틀 → 플레이 → 일시정지 → 재개 → 게임오버 → 재도전 → 일시정지 → 타이틀", function()
  local stack, ctx = newApp()
  local path = {}
  local function note()
    local top = stack:top()
    path[#path + 1] = (top.game and "Play") or (top.transparent and (top.won ~= nil and "Result" or "Pause")) or "Title"
  end
  note()
  stack:keypressed("return"); note()
  stack:keypressed("p"); note()
  stack:keypressed("p"); note()
  stack:top().game.state = "gameover"
  stack:update(DT); note()
  stack:keypressed("r"); note()
  stack:keypressed("escape"); note()
  stack:keypressed("q"); note()
  local got = table.concat(path, ">")
  if got ~= "Title>Play>Pause>Play>Result>Play>Pause>Title" then
    error(got)
  end
  return ctx.seeds == 2
end)

h.finish()
