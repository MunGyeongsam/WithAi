-- perf_test.lua
-- 성능 회귀 테스트. "시간"은 기계마다 흔들리므로 GC 를 멈추고 잰 "할당량"을 비교한다.
-- 절대값 대신 비율을 본다: 유도 미사일을 쏠 때 스텝당 할당이 안 쏠 때의 2배를 넘으면 실패.
-- (bench.lua 로 찾은 문제: 미사일 조준이 스텝마다 목표 목록 테이블을 새로 만들었다)
-- 실행: cd lua_tuto/mvc/week07/examples/tests && luajit perf_test.lua [galaga_final|starter]

package.path = ((arg[0] or ""):match("(.*/)") or "./") .. "?.lua;" .. package.path
local h = require("helper")
local app = arg[1] or "galaga_final"
h.setup(app)

if jit then
  jit.off() -- JIT 의 할당 제거(allocation sinking)가 끼면 같은 코드도 실행마다 숫자가 달라진다
end

local GameModel = require("GameModel")
local DT = 1 / 60

-- 플레이 중인 스텝만 세어 스텝당 평균 할당 바이트를 돌려준다.
local function allocPerStep(useMissile)
  local g = GameModel({ width = 600, height = 800, seed = 7 })
  g.lives = 1e9
  local input = { move = 0, fire = true, missile = false }
  local steps = 0
  collectgarbage("collect")
  collectgarbage("stop")
  local kb0 = collectgarbage("count")
  for step = 1, 1200 do
    if g.state ~= "playing" then
      break
    end
    input.move = (step % 120 < 60) and 1 or -1
    input.missile = useMissile and step % 90 < 45
    g:update(DT, input)
    g:drainEvents()
    steps = steps + 1
  end
  local bytes = (collectgarbage("count") - kb0) * 1024
  collectgarbage("restart")
  return bytes / steps, steps
end

print("[perf_test] " .. app .. "/")

h.test("유도 미사일을 써도 스텝당 할당이 2배를 넘지 않는다 (목표 목록을 매 스텝 만들지 않기)", function()
  local off, n1 = allocPerStep(false)
  local on, n2 = allocPerStep(true)
  print(string.format("         미사일 끔 %.1f B/스텝 (%d스텝)   켬 %.1f B/스텝 (%d스텝)   비율 %.2f", off, n1, on, n2, on / off))
  return n1 > 600 and n2 > 600 and on / off < 2
end)

h.finish()
