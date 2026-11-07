-- mvc_test.lua
-- 기준점: MVC 의 View 를 테스트하면 무엇이 불편한지 "드러내는" 테스트. (README 2-3)
-- 실행: cd lua_tuto/mvc/week08_more/examples/tests && luajit mvc_test.lua

package.path = ((arg[0] or ""):match("(.*/)") or "./") .. "?.lua;" .. package.path
local helper = require("helper")
local root = helper.setup("catch_mvc")

local R = require("rules")
local CatchModel = require("CatchModel")
local CatchView = require("CatchView")
local CatchController = require("CatchController")

print("[mvc_test] MVC 기준점")

helper.test("Controller: TICK 만큼 시간이 흐르면 Model 이 한 틱 진행", function()
  local m = CatchModel(1)
  local c = CatchController(m)
  c:update(R.TICK * 0.5)
  local before = m.ticks
  c:update(R.TICK * 0.5)
  return before == 0 and m.ticks == 1
end)

helper.test("Controller: 키 → Model:move", function()
  local m = CatchModel(1)
  local c = CatchController(m)
  c:keypressed("left")
  c:keypressed("x")
  return m.lane == R.START_LANE - 1
end)

helper.test("[불편] 'SCORE 10' 문구를 확인하려면 가짜 gfx 로 draw 전체를 돌려야 한다", function()
  local m = CatchModel(1)
  m.score = 10
  local gfx = helper.fakeGfx()
  CatchView.draw(gfx, m)
  return helper.printed(gfx, "SCORE 10")
end)

helper.test("[불편] HP 1 의 빨간색 규칙은 setColor 호출 순서를 뒤져야 확인된다", function()
  local m = CatchModel(1)
  m.hp = 1
  local gfx = helper.fakeGfx()
  CatchView.draw(gfx, m)
  for i, c in ipairs(gfx.calls) do
    if c.name == "print" and tostring(c.args[1]):find("HP", 1, true) then
      local prev = gfx.calls[i - 1]
      return prev.name == "setColor" and prev.args[1] == 1 and prev.args[2] == 0.3
    end
  end
  return false
end)

helper.test("[결합 측정] View 가 직접 읽는 Model 필드 = 5개 (이름이 바뀌면 View 가 깨진다)", function()
  local src = helper.readFile(root .. "views/CatchView.lua")
  local fields, n = {}, 0
  for name in src:gmatch("model%.([%a_][%w_]*)") do
    if not fields[name] then
      fields[name] = true
      n = n + 1
    end
  end
  print("        View → Model 필드: " .. n .. "개")
  return n == 5 and fields.items and fields.lane and fields.score and fields.hp and fields.over
end)

helper.finish()
