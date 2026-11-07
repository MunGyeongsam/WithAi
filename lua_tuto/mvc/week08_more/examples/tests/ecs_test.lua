-- ecs_test.lua
-- ECS: World 기본 동작, 새 종류(하트)는 데이터만으로, 받는 쪽이 둘이어도 시스템 수정 없이.
-- 실행: cd lua_tuto/mvc/week08_more/examples/tests && luajit ecs_test.lua

package.path = ((arg[0] or ""):match("(.*/)") or "./") .. "?.lua;" .. package.path
local helper = require("helper")
local root = helper.setup("catch_ecs")

local R = require("rules")
local World = require("World")
local kinds = require("kinds")
local CatchGame = require("CatchGame")

local function dropAt(game, lane, kind)
  local k = kinds[kind]
  game.world:spawn({
    position = { lane = lane, row = R.ROWS - 1 },
    falling = true,
    pickup = k.pickup,
    sprite = k.sprite,
  })
end

print("[ecs_test] ECS")

helper.test("World: query 는 모든 컴포넌트를 가진 것만, 번호 순으로", function()
  local w = World()
  local a = w:spawn({ position = {}, falling = true })
  w:spawn({ position = {} })
  local c = w:spawn({ position = {}, falling = true })
  local ids = w:query("position", "falling")
  return #ids == 2 and ids[1] == a and ids[2] == c
end)

helper.test("World: destroy 는 flush 전까지 미뤄진다", function()
  local w = World()
  local a = w:spawn({ position = {} })
  w:destroy(a)
  local still = #w:query("position")
  w:flush()
  return still == 1 and #w:query("position") == 0 and w:get(a, "position") == nil
end)

helper.test("동전·폭탄 규칙은 다른 구조와 같다", function()
  local g = CatchGame({ seed = 1 })
  dropAt(g, R.START_LANE, "coin")
  dropAt(g, R.START_LANE + 1, "bomb")
  g:tick()
  local s = g:summary()
  return s.score == R.COIN_SCORE and s.hp == R.START_HP
end)

helper.test("새 종류 하트: HP +1, 최대치는 넘지 않는다", function()
  local g = CatchGame({ seed = 1 })
  g.world:get(g.player, "health").hp = 1
  dropAt(g, R.START_LANE, "heart")
  g:tick()
  local healed = g:summary().hp
  dropAt(g, R.START_LANE, "heart")
  dropAt(g, R.START_LANE, "heart")
  dropAt(g, R.START_LANE, "heart")
  g:tick()
  return healed == 2 and g:summary().hp == R.START_HP
end)

helper.test("WITH_HEART 생성 표로 돌리면 하트가 실제로 나온다", function()
  local g = CatchGame({ seed = 5, spawnTable = kinds.WITH_HEART })
  for _ = 1, 400 do
    g:tick()
    for _, id in ipairs(g.world:query("pickup")) do
      if g.world:get(id, "pickup").heal then
        return true
      end
    end
  end
  return false
end)

helper.test("[확장 비용] systems/ 와 CatchGame 에 'heart' 라는 단어가 없다(데이터만 추가)", function()
  for _, f in ipairs({ "systems/fall.lua", "systems/collect.lua", "systems/spawn.lua", "systems/render.lua", "game/CatchGame.lua" }) do
    if helper.readFile(root .. f):find("heart") then
      return false
    end
  end
  return true
end)

helper.test("받는 쪽 엔티티를 하나 더 만들면 시스템 수정 없이 둘 다 받는다", function()
  local g = CatchGame({ seed = 1 })
  local p2 = g.world:spawn({
    position = { lane = R.START_LANE, row = R.ROWS },
    player = true,
    wallet = { score = 0 },
  })
  dropAt(g, R.START_LANE, "coin")
  g:tick()
  return g:summary().score == R.COIN_SCORE and g.world:get(p2, "wallet").score == R.COIN_SCORE
end)

helper.test("render: 엔티티 수만큼 그리고 HUD 를 찍는다", function()
  local g = CatchGame({ seed = 1 })
  dropAt(g, 1, "coin")
  dropAt(g, 2, "heart")
  local gfx = helper.fakeGfx()
  g:draw(gfx)
  local circles, polys = 0, 0
  for _, c in ipairs(gfx.calls) do
    if c.name == "circle" then
      circles = circles + 1
    elseif c.name == "polygon" then
      polys = polys + 1
    end
  end
  return circles == 1 and polys == 1 and helper.printed(gfx, "SCORE 0")
end)

helper.finish()
