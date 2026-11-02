-- flux_test.lua
-- Dispatcher·Store·ActionLog·ReplayPlayer 와 실제 App 을 창 없이 검사한다.
-- 핵심: 기록한 Action 을 재생하면 "몇 fps 로 돌았든" 같은 상태가 나온다.
-- 실행: cd lua_tuto/mvc/week06/examples/tests && luajit flux_test.lua [snake_flux|starter]

package.path = ((arg[0] or ""):match("(.*/)") or "./") .. "?.lua;" .. package.path
local h = require("helper")
local app = arg[1] or "snake_flux"
h.setupSnake(app)

local reducer = require("snakeReducer")
local A = require("actions")
local Store = require("Store")
local Dispatcher = require("Dispatcher")
local ActionLog = require("ActionLog")
local ReplayPlayer = require("ReplayPlayer")
local App = require("App")

local function wire()
  local store = Store(reducer.reduce, nil)
  local d = Dispatcher(A.validate)
  local log = ActionLog()
  d:register(store)
  d:tap(function(a)
    log:record(a)
  end)
  return store, d, log
end

-- 실제 App 을 frameDt 간격으로 돌리며, 매 프레임 "먹이 쪽으로 키를 누르는" 봇이 플레이한다.
-- 사람과 같은 경로(keypressed)로만 입력한다. 먹이를 먹어야 난수(먹이 위치) 재현까지 검사된다.
local OPP = { up = "down", down = "up", left = "right", right = "left" }
local STEP = { up = { 0, -1 }, down = { 0, 1 }, left = { -1, 0 }, right = { 1, 0 } }

-- 역주행·벽·몸(꼬리 제외)을 피하는 방향 중 먹이에 가장 가까워지는 쪽. 없으면 nil.
local function botKey(s)
  local hd = s.snake[1]
  local best, bestD
  for _, dir in ipairs({ "up", "down", "left", "right" }) do
    if dir ~= OPP[s.dir] then
      local nx, ny = hd.x + STEP[dir][1], hd.y + STEP[dir][2]
      local blocked = nx < 1 or nx > s.w or ny < 1 or ny > s.h
      for i = 1, #s.snake - 1 do
        if s.snake[i].x == nx and s.snake[i].y == ny then
          blocked = true
        end
      end
      if not blocked then
        local d = math.abs(s.food.x - nx) + math.abs(s.food.y - ny)
        if not bestD or d < bestD then
          best, bestD = dir, d
        end
      end
    end
  end
  return best
end

local function playApp(seed, frameDt, seconds)
  local a = App({ seed = function()
    return seed
  end })
  local t = 0
  while t < seconds do
    local s = a.store:getState()
    if s.status == "playing" and s.food then
      local key = botKey(s)
      if key then
        a:keypressed(key)
      end
    end
    a:update(frameDt)
    t = t + frameDt
  end
  return a
end

print("[flux_test] " .. app .. "/")

-- ── Dispatcher ───────────────────────────────────────────────────────────
h.test("잘못된 Action 은 거부되고(에러) 기록·상태 모두 그대로", function()
  local store, d, log = wire()
  d:dispatch(A.restart(1))
  local before = store:getState()
  local ok = pcall(function()
    d:dispatch({ type = "turn", dir = "diagonal" })
  end)
  return not ok and log:size() == 1 and store:getState() == before
end)

h.test("dispatch 도중 dispatch 는 에러, 그 뒤에도 Dispatcher 는 계속 쓸 수 있다", function()
  local store, d = wire()
  d:dispatch(A.restart(1))
  store:subscribe(function()
    d:dispatch(A.tick())
  end)
  local ok = pcall(function()
    d:dispatch(A.tick())
  end)
  store.listeners = {}
  local ok2 = pcall(function()
    d:dispatch(A.tick())
  end)
  return not ok and ok2
end)

h.test("Store 가 에러를 내도 그 Action 은 이미 기록돼 있다 (tap 이 먼저 → 터진 판을 재생해 재현 가능)", function()
  local log = ActionLog()
  local d = Dispatcher(A.validate)
  d:register(Store(function(s, a)
    if a.type == "tick" then
      error("리듀서 버그")
    end
    return reducer.reduce(s, a)
  end, nil))
  d:tap(function(a)
    log:record(a)
  end)
  d:dispatch(A.restart(1))
  local ok = pcall(function()
    d:dispatch(A.tick())
  end)
  return not ok and log:size() == 2 and log.entries[2].type == "tick"
end)

-- ── Store ────────────────────────────────────────────────────────────────
h.test("Store 구독자는 상태가 실제로 바뀔 때만 불린다", function()
  local store, d = wire()
  d:dispatch(A.restart(1))
  local calls = 0
  store:subscribe(function()
    calls = calls + 1
  end)
  d:dispatch(A.turn("right")) -- 이미 오른쪽 → 변화 없음
  d:dispatch(A.tick()) -- 변화 있음
  return calls == 1
end)

-- ── ActionLog ────────────────────────────────────────────────────────────
h.test("기록은 보낸 테이블의 복사본이다 (보낸 쪽이 테이블을 재사용·수정해도 기록 불변)", function()
  local _, d, log = wire()
  local reused = A.restart(5)
  d:dispatch(reused)
  reused.seed = 999 -- 4주차 InputController 처럼 테이블을 재사용하는 쪽을 흉내
  return log.entries[1].seed == 5
end)

h.test("문자열로 저장했다 복원해도 같은 기록", function()
  local _, d, log = wire()
  for _, a in ipairs({ A.restart(1793597350001), A.turn("up"), A.tick(), A.turn("left"), A.tick() }) do
    d:dispatch(a)
  end
  local back = ActionLog.parse(log:serialize())
  return h.same(h.snapshot(log.entries), h.snapshot(back.entries))
end)

h.test("기록을 리듀서로 다시 계산하면 실시간 상태와 같다 (먹이 여러 개 포함)", function()
  local a = playApp(42, 1 / 60, 20)
  local live = a.store:getState()
  if live.score < 3 then
    error("봇이 먹이를 충분히 먹지 못함: " .. live.score)
  end
  return h.same(h.snapshot(live), h.snapshot(a.log:replay(reducer.reduce, nil)))
end)

h.test("시간 여행: 앞 n개 Action 만 재계산하면 n번째 시점의 상태", function()
  local store, d, log = wire()
  local seen = {}
  d:dispatch(A.restart(3))
  for i = 1, 8 do
    d:dispatch(i == 4 and A.turn("down") or A.tick())
    seen[log:size()] = store:getState()
  end
  for n, st in pairs(seen) do
    if not h.same(h.snapshot(st), h.snapshot(log:replay(reducer.reduce, nil, n))) then
      error("n=" .. n)
    end
  end
  return true
end)

h.test("옛 상태는 그대로 남아 있다 (리듀서가 새 테이블을 만들기 때문 — 시간 여행의 바탕)", function()
  local store, d = wire()
  d:dispatch(A.restart(3))
  local old = store:getState()
  local oldHeadX = old.snake[1].x
  for _ = 1, 5 do
    d:dispatch(A.tick())
  end
  return old.snake[1].x == oldHeadX and old.ticks == 0
end)

-- ── 프레임률과 재생 (4주차 [한계] 의 후속) ───────────────────────────────
h.test("20fps 로 한 판을 기록 → 재생 속도를 바꿔(초당 7개, 300개) 재생해도 같은 결과", function()
  local live = playApp(42, 3 / 60, 20)
  local final = h.snapshot(live.store:getState())
  if final.score < 3 then
    error("먹이를 충분히 먹지 못함")
  end
  for _, speed in ipairs({ 7, 300 }) do
    local store = Store(reducer.reduce, nil)
    local d = Dispatcher(A.validate)
    d:register(store)
    local p = ReplayPlayer(live.log.entries, function(x)
      d:dispatch(x)
    end, speed)
    while not p:done() do
      p:update(1 / 60)
    end
    if not h.same(final, h.snapshot(store:getState())) then
      error("재생 속도 " .. speed .. " 에서 다름")
    end
  end
  return true
end)

h.test("[한계, 그대로] 사람처럼 '시각'에 누른 키는 tick 경계 근처에서 프레임률에 따라 결과가 갈린다", function()
  -- tick 은 0.12초마다(0.36, 0.48, …). 0.46초에 ↑ 를 누르면
  --   60fps: 0.4667초 프레임에서 읽힘 → 0.48초 tick 에 적용
  --   20fps: 0.50초 프레임에서야 읽힘 → 0.60초 tick 에 적용 (한 칸 늦게 꺾음)
  local function headAfter(frameDt)
    local a = App({ seed = function()
      return 42
    end })
    local t, pressed = 0, false
    while t < 1.0 do
      if not pressed and t >= 0.46 then
        pressed = true
        a:keypressed("up")
      end
      a:update(frameDt)
      t = t + frameDt
    end
    local hd = a.store:getState().snake[1]
    return hd.x, hd.y
  end
  local x60, y60 = headAfter(1 / 60)
  local x20, y20 = headAfter(3 / 60)
  return x60 ~= x20 or y60 ~= y20
end)

h.test("반면 '상태를 보고 반응하는' 입력(봇)은 프레임률이 달라도 결과가 같다 (기록에 중복 turn 만 늘어남)", function()
  local a60, a20 = playApp(42, 1 / 60, 20), playApp(42, 3 / 60, 20)
  local s60, s20 = a60.store:getState(), a20.store:getState()
  return h.same(h.snapshot(s60), h.snapshot(s20)) and a60.log:size() > a20.log:size()
end)

-- ── 실제 App (main.lua 가 쓰는 바로 그 조립) ─────────────────────────────
h.test("App: 어떤 키를 눌러도 이전 state 테이블은 그대로 (상태는 Action→리듀서로만 바뀜, 실행 중 검사)", function()
  -- layer_check 의 문자열 검사는 근사치다(우회 가능). 이 테스트가 진짜 보호막이다.
  -- 점수·길이가 0·3 이 아닌 상태에서 해야 "0 으로 덮어쓰기" 같은 변경도 드러난다.
  local a = playApp(42, 1 / 60, 10)
  local pre = a.store:getState()
  if pre.score == 0 or pre.status ~= "playing" then
    error("전제 실패: 점수가 있는 진행 중 상태가 아님")
  end
  for _, key in ipairs({ "up", "left", "down", "right", "w", "a", "s", "d", "v", "x", "space", "r" }) do
    local old = a.store:getState()
    local before = h.snapshot(old)
    a:keypressed(key)
    local ok, where = h.same(before, h.snapshot(old))
    if not ok then
      error("'" .. key .. "' 가 이전 상태를 고침: " .. where)
    end
  end
  return true
end)
h.test("App: 창을 끌어 2초 멈췄다 와도 tick 이 한꺼번에 몰리지 않는다 (프레임 dt 상한 0.25초)", function()
  local a = App({ seed = function()
    return 42
  end })
  a:update(2.0)
  return a.store:getState().ticks <= 2
end)

h.test("App: 시작하면 restart 가 기록되고, R 은 새 시드로 restart", function()
  local n = 0
  local a = App({ seed = function()
    n = n + 1
    return n
  end })
  a:keypressed("r")
  local e = a.log.entries
  return e[1].type == "restart" and e[2].type == "restart" and e[1].seed ~= e[2].seed
end)

h.test("App: 살아 있을 때 V 는 무시, 죽은 뒤 V → 리플레이가 실시간 최종 상태와 똑같이 끝난다", function()
  local alive = App({ seed = function()
    return 1
  end })
  alive:keypressed("v")
  if alive.mode ~= "live" then
    error("살아 있는데 리플레이가 시작됨")
  end
  local a = playApp(42, 1 / 60, 60)
  if a.store:getState().status ~= "dead" then
    error("봇이 60초 안에 죽지 않음")
  end
  local live = h.snapshot(a.store:getState())
  a:keypressed("v")
  local liveStoreBefore = a.store:getState()
  while not a.player:done() do
    a:update(1 / 60)
  end
  return a.mode == "replay" and h.same(live, h.snapshot(a:currentState())) and a.store:getState() == liveStoreBefore
end)

h.test("App: 리플레이 중 Esc → 실시간 화면으로 (종료하지 않음)", function()
  local a = playApp(42, 1 / 60, 60)
  a:keypressed("v")
  local r = a:keypressed("escape")
  return r == nil and a.mode == "live"
end)

h.test("App: 화면 — 죽으면 GAME OVER, 리플레이 중엔 REPLAY 표시", function()
  local a = playApp(42, 1 / 60, 60)
  local g1 = h.fakeGfx()
  a:draw(g1)
  a:keypressed("v")
  local g2 = h.fakeGfx()
  a:draw(g2)
  return h.printed(g1, "GAME OVER") and h.printed(g2, "REPLAY")
end)

h.finish()
