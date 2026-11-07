-- mvp_test.lua
-- MVP: 표시 규칙이 Presenter 로 옮겨져 gfx 없이 검사되는가, View 는 정말 수동적인가.
-- 실행: cd lua_tuto/mvc/week08_more/examples/tests && luajit mvp_test.lua

package.path = ((arg[0] or ""):match("(.*/)") or "./") .. "?.lua;" .. package.path
local helper = require("helper")
local root = helper.setup("catch_mvp")

local R = require("rules")
local CatchModel = require("CatchModel")
local CatchPresenter = require("CatchPresenter")
local CatchView = require("CatchView")

--- View 계약만 흉내 내는 가짜. 마지막 값과 호출 횟수를 기록한다.
local function fakeView()
  local v = { calls = 0, last = {} }
  for _, name in ipairs({ "showPlayer", "showItems", "showScore", "showHp", "showGameOver" }) do
    v[name] = function(self, a, b)
      self.calls = self.calls + 1
      self.last[name] = { a, b }
    end
  end
  return v
end

print("[mvp_test] MVP")

helper.test("생성 즉시 View 계약 5개를 모두 채운다", function()
  local v = fakeView()
  CatchPresenter(CatchModel(1), v)
  return v.calls == 5 and v.last.showScore[1] == "SCORE 0" and v.last.showGameOver[1] == nil
end)

helper.test("동전을 받으면 showScore('SCORE 10') — gfx 없이 확인", function()
  local m, v = CatchModel(1), fakeView()
  local p = CatchPresenter(m, v)
  m.items = { { lane = R.START_LANE, row = R.ROWS - 1, kind = "coin" } }
  p:update(R.TICK)
  return v.last.showScore[1] == "SCORE 10"
end)

helper.test("HP 1 이면 showHp(text, danger=true) — '빨간색 규칙'이 값으로 검사된다", function()
  local m, v = CatchModel(1), fakeView()
  local p = CatchPresenter(m, v)
  m.hp = 2
  m.items = { { lane = R.START_LANE, row = R.ROWS - 1, kind = "bomb" } }
  p:update(R.TICK)
  return v.last.showHp[1] == "HP *" and v.last.showHp[2] == true
end)

helper.test("게임 오버 후 키는 무시되고 View 에 아무것도 밀지 않는다", function()
  local m, v = CatchModel(1), fakeView()
  local p = CatchPresenter(m, v)
  m.over = true
  local calls = v.calls
  p:onKey("left")
  return v.calls == calls and m.lane == R.START_LANE
end)

helper.test("Presenter 가 넘긴 아이템 목록은 Model 의 테이블이 아니다(View 가 Model 을 못 고친다)", function()
  local m, v = CatchModel(1), fakeView()
  local p = CatchPresenter(m, v)
  m.items = { { lane = 1, row = 1, kind = "coin" } }
  p:present()
  local shown = v.last.showItems[1]
  shown[1].row = 99
  return m.items[1].row == 1 and shown ~= m.items
end)

helper.test("Passive View: Model 없이 값만 넣어도 그린다", function()
  local view = CatchView()
  view:showScore("SCORE 77")
  view:showHp("HP **", false)
  view:showGameOver("GAME OVER  -  R")
  local gfx = helper.fakeGfx()
  view:draw(gfx)
  return helper.printed(gfx, "SCORE 77") and helper.printed(gfx, "GAME OVER")
end)

helper.test("[결합 측정] View 가 읽는 Model 필드 = 0개", function()
  local src = helper.readFile(root .. "views/CatchView.lua")
  return not src:find("model%.") and not src:find("CatchModel")
end)

helper.test("[비용] 이동 한 번에도 View 호출 5번(수다스러운 인터페이스)", function()
  local v = fakeView()
  local p = CatchPresenter(CatchModel(1), v)
  local before = v.calls
  p:onKey("right")
  print("        이동 1회 → View 호출 " .. (v.calls - before) .. "번")
  return v.calls - before == 5
end)

helper.finish()
