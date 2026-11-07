-- hex_test.lua
-- Hexagonal: 포트에 꽂는 어댑터만 바꿔 코어를 검사한다. 시드 찾기 없이 대본으로, 파일 없이 메모리로.
-- 실행: cd lua_tuto/mvc/week08_more/examples/tests && luajit hex_test.lua

package.path = ((arg[0] or ""):match("(.*/)") or "./") .. "?.lua;" .. package.path
local helper = require("helper")
helper.setup("catch_hex")

local R = require("rules")
local CatchGame = require("CatchGame")
local ScriptedRandom = require("ScriptedRandom")
local MemoryScores = require("MemoryScores")
local FileScores = require("FileScores")
local Renderer = require("Renderer")

local function ticks(game, n)
  for _ = 1, n do
    game:tick()
  end
end

-- 생성 시점부터 바닥까지 걸리는 틱 수
local FALL = R.ROWS - 1

--- 대본 만들기: { kind, ... } → 난수 값 목록. 뒤에 1번 칸 동전(플레이어가 못 받는 칸)을 넉넉히 붙인다.
local function script(lane, kindsList)
  local values = {}
  for _, kind in ipairs(kindsList) do
    values[#values + 1] = lane
    values[#values + 1] = kind == "bomb" and 1 or 10
  end
  for _ = 1, 20 do
    values[#values + 1] = 1
    values[#values + 1] = 10
  end
  return values
end

print("[hex_test] Hexagonal")

helper.test("대본 난수: '3번 칸 폭탄'(lane 3, roll 1)을 바로 만든다", function()
  local g = CatchGame({ random = ScriptedRandom({ 3, 1 }), scores = MemoryScores() })
  ticks(g, R.SPAWN_EVERY)
  local it = g.items[1]
  return it.lane == 3 and it.kind == "bomb"
end)

helper.test("대본 난수: 폭탄 세 개를 맞으면 게임 오버", function()
  local values = script(R.START_LANE, { "bomb", "bomb", "bomb" })
  local g = CatchGame({ random = ScriptedRandom(values), scores = MemoryScores() })
  ticks(g, R.SPAWN_EVERY * 2 + FALL) -- 틱 2·4 생성 → 7·9 착지
  local mid = g.hp
  ticks(g, 2) -- 틱 6 생성 → 11 착지
  return mid == 1 and g.over and g.hp == 0
end)

helper.test("최고 점수: 넘으면 저장, 못 넘으면 저장하지 않는다", function()
  local function play(best, coins)
    local list = {}
    for _ = 1, coins do
      list[#list + 1] = "coin"
    end
    for _ = 1, 3 do
      list[#list + 1] = "bomb"
    end
    local scores = MemoryScores(best)
    local g = CatchGame({ random = ScriptedRandom(script(R.START_LANE, list)), scores = scores })
    while not g.over do
      g:tick()
    end
    return g, scores
  end
  local g1, s1 = play(10, 2)
  local g2, s2 = play(50, 2)
  return g1.newBest and s1.best == 20 and s1.saves == 1 and not g2.newBest and s2.saves == 0
end)

helper.test("포트 검사: 모양이 틀린 어댑터는 경계에서 바로 거부", function()
  local ok, err = pcall(CatchGame, { random = ScriptedRandom({}), scores = { loadBest = function() return 0 end } })
  return not ok and err:find("saveBest", 1, true) ~= nil
end)

helper.test("FileScores: 가짜 fs 로 읽기·쓰기, 깨진 파일은 0", function()
  local files = {}
  local fs = {
    getInfo = function(name)
      return files[name] and {} or nil
    end,
    read = function(name)
      return files[name]
    end,
    write = function(name, text)
      files[name] = text
    end,
  }
  local s = FileScores(fs)
  local empty = s:loadBest()
  s:saveBest(120)
  local saved = s:loadBest()
  files[FileScores.FILE] = "12abc"
  return empty == 0 and saved == 120 and s:loadBest() == 0
end)

helper.test("Renderer 어댑터: 코어 상태로 SCORE·BEST 를 그린다", function()
  local g = CatchGame({ random = ScriptedRandom({}), scores = MemoryScores(70) })
  local gfx = helper.fakeGfx()
  Renderer.draw(gfx, g)
  return helper.printed(gfx, "SCORE 0") and helper.printed(gfx, "BEST 70")
end)

helper.finish()
