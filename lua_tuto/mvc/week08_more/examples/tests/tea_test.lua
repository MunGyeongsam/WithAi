-- tea_test.lua
-- TEA: update 는 받은 model 을 고치지 않는다, effect 는 데이터다, view 도 데이터다, 불변이라 캐시·되감기가 공짜다.
-- 실행: cd lua_tuto/mvc/week08_more/examples/tests && luajit tea_test.lua

package.path = ((arg[0] or ""):match("(.*/)") or "./") .. "?.lua;" .. package.path
local helper = require("helper")
helper.setup("catch_tea")

local R = require("rules")
local catch = require("catch")
local Runtime = require("Runtime")

local TICK = { type = "tick" }

local function hasText(cmds, text)
  for _, c in ipairs(cmds) do
    if (c[1] == "print" or c[1] == "printf") and c[2]:find(text, 1, true) then
      return true
    end
  end
  return false
end

print("[tea_test] TEA")

helper.test("update 는 받은 model 을 고치지 않는다(40틱 + 이동)", function()
  local m = catch.init(3)
  for i = 1, 40 do
    local before = helper.snapshot(m)
    local msg = (i % 5 == 0) and { type = "move", dir = 1 } or TICK
    local nextModel = catch.update(m, msg)
    if not helper.same(before, helper.snapshot(m)) then
      return false
    end
    m = nextModel
  end
  return true
end)

helper.test("벽에서 이동 → 같은 테이블을 돌려준다(= 변화 없음)", function()
  local m = catch.init(1)
  for _ = 1, 5 do
    m = catch.update(m, { type = "move", dir = 1 })
  end
  return catch.update(m, { type = "move", dir = 1 }) == m
end)

helper.test("effect 는 데이터: 동전을 받으면 { beep, coin } 을 돌려줄 뿐 소리를 내지 않는다", function()
  local m = catch.init(1)
  m.items = { { lane = R.START_LANE, row = R.ROWS - 1, kind = "coin" } }
  local m2, effects = catch.update(m, TICK)
  return m2.score == R.COIN_SCORE and #effects == 1 and effects[1].type == "beep" and effects[1].name == "coin"
end)

helper.test("view 는 데이터: gfx 없이 'SCORE 0' 명령을 찾는다", function()
  return hasText(catch.view(catch.init(1)), "SCORE 0")
end)

helper.test("onKey: 키 → msg 표", function()
  local l, x = catch.onKey("left"), catch.onKey("x")
  return l.type == "move" and l.dir == -1 and x == nil
end)

helper.test("Runtime: effect 는 주입된 처리기로만 나간다", function()
  local heard = {}
  local rt = Runtime(catch, 1, function(e)
    heard[#heard + 1] = e.name
  end)
  rt.model.items = { { lane = R.START_LANE, row = R.ROWS - 1, kind = "bomb" } }
  rt:update(R.TICK)
  return heard[1] == "bomb" and rt.model.hp == R.START_HP - 1
end)

helper.test("Runtime: model 이 그대로면 view 를 다시 계산하지 않는다(캐시)", function()
  local rt = Runtime(catch, 1)
  rt:draw(helper.fakeGfx())
  rt:draw(helper.fakeGfx())
  rt:keypressed("x") -- 모르는 키: model 그대로
  rt:draw(helper.fakeGfx())
  local cached = rt.viewCalls
  rt:keypressed("left")
  rt:draw(helper.fakeGfx())
  return cached == 1 and rt.viewCalls == 2
end)

helper.test("Runtime: draw 는 명령을 gfx 호출로 옮긴다", function()
  local gfx = helper.fakeGfx()
  Runtime(catch, 1):draw(gfx)
  return helper.printed(gfx, "SCORE 0")
end)

helper.test("되감기: 옛 model 이 그대로 남아 있어 4단계 전으로 돌아간다", function()
  local rt = Runtime(catch, 9)
  for _ = 1, 6 do
    rt:update(R.TICK)
  end
  local at2 = rt.history[3]
  rt:rewind(4)
  return rt.model == at2 and rt.model.ticks == 2
end)

helper.finish()
