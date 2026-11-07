-- rules_test.lua
-- "동전 받기" 규칙 명세(README 3절)를 기준 구현(catch_mvc 의 CatchModel)으로 확인한다.
-- 다른 다섯 구조가 같은 규칙을 지키는지는 equivalence_test 가 본다.
-- 실행: cd lua_tuto/mvc/week08_more/examples/tests && luajit rules_test.lua

package.path = ((arg[0] or ""):match("(.*/)") or "./") .. "?.lua;" .. package.path
local helper = require("helper")
helper.setup("catch_mvc")

local R = require("rules")
local CatchModel = require("CatchModel")

print("[rules_test] 규칙 명세")

helper.test("시작: 가운데 칸, HP 3, 점수 0, 아이템 없음", function()
  local m = CatchModel(1)
  return m.lane == R.START_LANE and m.hp == R.START_HP and m.score == 0 and #m.items == 0
end)

helper.test("이동은 1~LANES 를 벗어나지 않는다", function()
  local m = CatchModel(1)
  for _ = 1, 10 do
    m:move(-1)
  end
  local left = m.lane
  for _ = 1, 10 do
    m:move(1)
  end
  return left == 1 and m.lane == R.LANES
end)

helper.test("SPAWN_EVERY 틱마다 1번 줄에 하나 생긴다", function()
  local m = CatchModel(7)
  m:tick()
  local after1 = #m.items
  m:tick()
  return after1 == 0 and #m.items == 1 and m.items[1].row == 1
end)

helper.test("한 틱에 한 줄 떨어지고, ROWS 에 닿으면 사라진다", function()
  local m = CatchModel(7)
  m.items = { { lane = 1, row = R.ROWS - 2, kind = "coin" } }
  m.ticks = 100 -- 홀수 틱 직전: 다음 틱(101)엔 생성 없음
  m:tick()
  local fell = m.items[1] and m.items[1].row == R.ROWS - 1
  m:tick()
  -- 102 틱엔 새 아이템이 생기므로 남은 것은 1번 줄의 새 아이템뿐이어야 한다
  return fell and #m.items == 1 and m.items[1].row == 1
end)

helper.test("같은 칸 동전 → +COIN_SCORE", function()
  local m = CatchModel(1)
  m.items = { { lane = R.START_LANE, row = R.ROWS - 1, kind = "coin" } }
  m:tick()
  return m.score == R.COIN_SCORE and m.hp == R.START_HP
end)

helper.test("같은 칸 폭탄 → HP -1", function()
  local m = CatchModel(1)
  m.items = { { lane = R.START_LANE, row = R.ROWS - 1, kind = "bomb" } }
  m:tick()
  return m.hp == R.START_HP - 1 and m.score == 0
end)

helper.test("다른 칸이면 아무 일 없이 사라진다", function()
  local m = CatchModel(1)
  m.items = { { lane = 1, row = R.ROWS - 1, kind = "bomb" } }
  m:tick()
  return m.hp == R.START_HP and #m.items == 0
end)

helper.test("HP 0 → 게임 오버. 이후 틱·이동은 무시", function()
  local m = CatchModel(1)
  m.hp = 1
  m.items = { { lane = R.START_LANE, row = R.ROWS - 1, kind = "bomb" } }
  m:tick()
  local ticks, lane = m.ticks, m.lane
  m:tick()
  m:move(-1)
  return m.over and m.hp == 0 and m.ticks == ticks and m.lane == lane
end)

helper.test("같은 시드 → 같은 아이템 수열", function()
  local a, b = CatchModel(42), CatchModel(42)
  for _ = 1, 40 do
    a:tick()
    b:tick()
  end
  return helper.same(a.items, b.items) and a.score == b.score
end)

helper.finish()
