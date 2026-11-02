-- bench.lua
-- 창 없이 겔러그를 자동 조종으로 돌리며 계층별 비용(시간·메모리 할당)을 잰다.
-- 실행: cd lua_tuto/mvc/week07/examples/tests && luajit bench.lua [galaga_final|starter] [스텝 수]
-- 함수 단위로 더 보려면: luajit -jp=f bench.lua   (LuaJIT 내장 샘플링 프로파일러)
--
-- ⚠️ 시간(µs)은 기계·인터프리터·다른 프로그램에 따라 흔들린다. 같은 기계에서 "전후 비교"에만 쓴다.
--    할당(바이트)은 GC 를 멈추고 세므로 같은 코드면 거의 같은 값이 나온다 → 비교 기준으로 더 믿을 만하다.

package.path = ((arg[0] or ""):match("(.*/)") or "./") .. "?.lua;" .. package.path
local h = require("helper")
local app = arg[1] or "galaga_final"
local STEPS = tonumber(arg[2]) or 36000 -- 60Hz 로 10분
h.setup(app)

local GameModel = require("GameModel")
local GameView = require("GameView")
local InputRecorder = require("InputRecorder")

local DT = 1 / 60

-- 아무것도 하지 않는 gfx: 그리기 "호출 비용"만 남기고 실제 렌더링 비용은 뺀다.
local nullGfx = setmetatable({}, {
  __index = function(t, k)
    local f = function() end
    rawset(t, k, f)
    return f
  end,
})

local input = { move = 0, fire = true, missile = false }
local function autopilot(g, step)
  local px = g.player.x + g.player.w * 0.5
  local bestX, bestD = nil, math.huge
  for _, e in ipairs(g.enemies) do
    if e.alive then
      local d = math.abs(e:centerX() - px)
      if d < bestD then
        bestX, bestD = e:centerX(), d
      end
    end
  end
  if not bestX and g.boss and g.boss.alive then
    bestX = g.boss:centerX()
  end
  input.move = 0
  if bestX then
    local aim = bestX + math.sin(step / 40) * 60
    if math.abs(aim - px) > 4 then
      input.move = aim > px and 1 or -1
    end
  end
  input.missile = step % 90 < 45
  return input
end

local function newGame()
  local g = GameModel({ width = 600, height = 800, seed = 7 })
  g.lives = 1e9 -- 게임오버 없이 정상 상태(steady state)를 오래 잰다
  return g
end

-- 측정 구간마다 GC 를 멈추고 시간·할당량을 누적한다.
local acc = {}
local function measure(name, fn)
  local kb0 = collectgarbage("count")
  local t0 = os.clock()
  fn()
  local a = acc[name] or { t = 0, kb = 0 }
  a.t = a.t + (os.clock() - t0)
  a.kb = a.kb + (collectgarbage("count") - kb0)
  acc[name] = a
end

local game = newGame()
local view = GameView({ width = 600, height = 800, rand = h.fixedRand() })
local rec = InputRecorder(7)
local maxBullets, maxEnemyBullets, maxParticles, sumBullets, wins = 0, 0, 0, 0, 0

collectgarbage("collect")
collectgarbage("stop")
for step = 1, STEPS do
  local inp = autopilot(game, step)
  measure("1 Model:update", function()
    game:update(DT, inp)
  end)
  measure("2 InputRecorder:record", function()
    rec:record(inp)
  end)
  measure("3 drain + View:onEvent/update", function()
    local events = game:drainEvents()
    for i = 1, #events do
      view:onEvent(events[i])
    end
    view:update(DT)
  end)
  measure("4 View:draw", function()
    view:draw(nullGfx, game)
  end)

  local nb = #game.bullets
  sumBullets = sumBullets + nb
  maxBullets = math.max(maxBullets, nb)
  maxEnemyBullets = math.max(maxEnemyBullets, #game.enemyBullets)
  maxParticles = math.max(maxParticles, #view.effects.particles)
  if game.state ~= "playing" then
    wins = wins + 1
    game = newGame()
  end
  if step % 6000 == 0 then -- 멈춘 GC 때문에 메모리가 무한히 늘지 않게 중간에 한 번씩 비운다
    collectgarbage("restart")
    collectgarbage("collect")
    collectgarbage("stop")
  end
end
collectgarbage("restart")

print(string.format("[bench] %s/  %d 스텝 (%.0f초 분량), 보스 격파 %d회", app, STEPS, STEPS * DT, wins))
print(string.format("  최대 동시: 내 총알 %d (평균 %.1f), 적 총알 %d, 파티클 %d", maxBullets, sumBullets / STEPS, maxEnemyBullets, maxParticles))
print("  구간                              µs/스텝   바이트/스텝   (60fps 한 프레임 = 16667µs)")
local names = {}
for k in pairs(acc) do
  names[#names + 1] = k
end
table.sort(names)
local totalT = 0
for _, k in ipairs(names) do
  local a = acc[k]
  totalT = totalT + a.t
  print(string.format("  %-32s %8.2f   %10.1f", k, a.t / STEPS * 1e6, a.kb * 1024 / STEPS))
end
print(string.format("  %-32s %8.2f   (프레임 예산의 %.2f%%)", "합계", totalT / STEPS * 1e6, totalT / STEPS * 1e6 / 16667 * 100))
