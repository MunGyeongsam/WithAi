-- reducer_test.lua
-- Snake 리듀서(순수 함수)를 검사한다. Store·Dispatcher·화면 없이 함수만 부른다.
-- 실행: cd lua_tuto/mvc/week06/examples/tests && luajit reducer_test.lua [snake_flux|starter]

package.path = ((arg[0] or ""):match("(.*/)") or "./") .. "?.lua;" .. package.path
local h = require("helper")
local app = arg[1] or "snake_flux"
h.setupSnake(app)

local reducer = require("snakeReducer")
local A = require("actions")
local reduce = reducer.reduce

-- 원하는 모양의 상태를 직접 만든다(리듀서 입력은 그냥 테이블이므로 가능).
local function make(snake, dir, food)
  local s = reducer.initial(1)
  s.snake = snake
  s.dir, s.nextDir = dir, dir
  s.food = food
  return s
end

local function cells(list)
  local out = {}
  for i, p in ipairs(list) do
    out[i] = { x = p[1], y = p[2] }
  end
  return out
end

local function run(state, list)
  for _, a in ipairs(list) do
    state = reduce(state, a)
  end
  return state
end

print("[reducer_test] " .. app .. "/")

-- ── 초기 상태 ────────────────────────────────────────────────────────────
h.test("초기: 길이 3, 오른쪽, 먹이는 몸 위가 아님", function()
  local s = reducer.initial(7)
  for _, p in ipairs(s.snake) do
    if p.x == s.food.x and p.y == s.food.y then
      return false
    end
  end
  return #s.snake == 3 and s.dir == "right" and s.status == "playing"
end)

h.test("초기: 같은 시드 → 같은 먹이 위치, 다른 시드 → (대개) 다른 위치", function()
  local a, b, c = reducer.initial(7), reducer.initial(7), reducer.initial(12345)
  return a.food.x == b.food.x and a.food.y == b.food.y and (a.food.x ~= c.food.x or a.food.y ~= c.food.y)
end)

-- ── 이동·회전 ────────────────────────────────────────────────────────────
h.test("tick: 머리가 한 칸 전진, 길이 유지", function()
  local s0 = reducer.initial(1)
  local s1 = reduce(s0, A.tick())
  return s1.snake[1].x == s0.snake[1].x + 1 and #s1.snake == 3 and s1.ticks == 1
end)

h.test("turn 은 다음 tick 에 적용된다 (turn 만으로는 움직이지 않음)", function()
  local s0 = reducer.initial(1)
  local s1 = reduce(s0, A.turn("up"))
  local s2 = reduce(s1, A.tick())
  return s1.snake[1].y == s0.snake[1].y and s2.snake[1].y == s0.snake[1].y - 1
end)

h.test("반대 방향 turn 은 무시된다", function()
  local s = run(reducer.initial(1), { A.turn("left"), A.tick() })
  return s.dir == "right" and s.status == "playing"
end)

h.test("한 tick 안에 위→왼쪽을 빠르게 눌러도 제자리 역주행으로 죽지 않는다", function()
  -- 움직이는 방향(dir)이 아직 오른쪽이므로 왼쪽은 반대 → 무시, 위만 남는다
  local s = run(reducer.initial(1), { A.turn("up"), A.turn("left"), A.tick() })
  return s.status == "playing" and s.dir == "up"
end)

-- ── 죽음 ────────────────────────────────────────────────────────────────
-- 네 벽 모두: 벽 쪽 끝 칸에서 한 칸 더 가면 dead, 한 칸 안쪽에서 끝 칸으로 가면 살아 있음(off-by-one)
local WALLS = {
  { "right", { { 20, 5 }, { 19, 5 }, { 18, 5 } }, { { 19, 5 }, { 18, 5 }, { 17, 5 } } },
  { "left", { { 1, 5 }, { 2, 5 }, { 3, 5 } }, { { 2, 5 }, { 3, 5 }, { 4, 5 } } },
  { "up", { { 5, 1 }, { 5, 2 }, { 5, 3 } }, { { 5, 2 }, { 5, 3 }, { 5, 4 } } },
  { "down", { { 5, 20 }, { 5, 19 }, { 5, 18 } }, { { 5, 19 }, { 5, 18 }, { 5, 17 } } },
}

h.test("네 벽 어느 쪽이든 밖으로 나가면 dead", function()
  for _, w in ipairs(WALLS) do
    if reduce(make(cells(w[2]), w[1], { x = 10, y = 10 }), A.tick()).status ~= "dead" then
      error(w[1] .. " 벽을 통과함")
    end
  end
  return true
end)

h.test("벽 바로 앞 칸(격자 끝 칸)으로는 들어갈 수 있다 (경계 한 칸 차이)", function()
  for _, w in ipairs(WALLS) do
    local t = reduce(make(cells(w[3]), w[1], { x = 10, y = 10 }), A.tick())
    if t.status ~= "playing" then
      error(w[1] .. " 끝 칸에서 죽음")
    end
  end
  return true
end)

h.test("자기 몸에 부딪히면 dead", function()
  -- 머리(5,5)가 위로 가면 (5,4) = 몸
  local s = make(cells({ { 5, 5 }, { 6, 5 }, { 6, 4 }, { 5, 4 }, { 4, 4 } }), "up", { x = 1, y = 1 })
  return reduce(s, A.tick()).status == "dead"
end)

h.test("꼬리가 있던 칸으로는 들어갈 수 있다 (꼬리가 같은 tick 에 비켜나므로)", function()
  -- 2×2 로 도는 뱀: 머리(5,5) 위로 → (5,4) 는 꼬리
  local s = make(cells({ { 5, 5 }, { 6, 5 }, { 6, 4 }, { 5, 4 } }), "up", { x = 1, y = 1 })
  return reduce(s, A.tick()).status == "playing"
end)

h.test("dead 이후 tick·turn 은 아무것도 바꾸지 않는다 (같은 테이블)", function()
  local s = make(cells({ { 20, 5 }, { 19, 5 }, { 18, 5 } }), "right", { x = 1, y = 1 })
  local dead = reduce(s, A.tick())
  return reduce(dead, A.tick()) == dead and reduce(dead, A.turn("up")) == dead
end)

-- ── 먹기 ────────────────────────────────────────────────────────────────
h.test("먹이를 먹으면 길이 +1, 점수 +1, 새 먹이는 몸 위가 아니고 난수 상태가 바뀐다", function()
  local s = make(cells({ { 5, 5 }, { 4, 5 }, { 3, 5 } }), "right", { x = 6, y = 5 })
  local t = reduce(s, A.tick())
  for _, p in ipairs(t.snake) do
    if p.x == t.food.x and p.y == t.food.y then
      return false
    end
  end
  return #t.snake == 4 and t.score == 1 and t.rng ~= s.rng
end)

h.test("마지막 빈 칸의 먹이를 먹어 판이 꽉 차면 새 먹이는 nil", function()
  -- 지그재그 경로로 판 전체를 덮고, 경로 1번 칸만 비워 먹이로 둔다. 머리(경로 2번)가 바로 옆.
  local path = {}
  for y = 1, 20 do
    for i = 1, 20 do
      local x = (y % 2 == 1) and i or (21 - i)
      path[#path + 1] = { x, y }
    end
  end
  local body = {}
  for i = 2, #path do
    body[#body + 1] = path[i]
  end
  local s = make(cells(body), "left", { x = path[1][1], y = path[1][2] })
  local t = reduce(s, A.tick())
  return t.status == "playing" and #t.snake == 400 and t.food == nil and t.score == s.score + 1
end)

-- ── 순수성 ──────────────────────────────────────────────────────────────
h.test("순수성: tick·turn·먹기·restart 모두 입력 state 를 바꾸지 않는다", function()
  local cases = {
    { reducer.initial(3), A.tick() },
    { reducer.initial(3), A.turn("up") },
    { make(cells({ { 5, 5 }, { 4, 5 }, { 3, 5 } }), "right", { x = 6, y = 5 }), A.tick() },
    { reducer.initial(3), A.restart(99) },
  }
  for i, c in ipairs(cases) do
    local before = h.snapshot(c[1])
    reduce(c[1], c[2])
    local ok, where = h.same(before, h.snapshot(c[1]))
    if not ok then
      error("case " .. i .. " 이 입력을 바꿈: " .. where)
    end
  end
  return true
end)

h.test("순수성: 같은 state + 같은 action → 같은 결과 (몇 번을 불러도)", function()
  local s = make(cells({ { 5, 5 }, { 4, 5 }, { 3, 5 } }), "right", { x = 6, y = 5 })
  return h.same(h.snapshot(reduce(s, A.tick())), h.snapshot(reduce(s, A.tick())))
end)

h.test("변화 없는 turn(같은 방향)은 같은 테이블을 돌려준다 (변경 감지가 == 한 번)", function()
  local s = reducer.initial(1)
  return reduce(s, A.turn("right")) == s
end)

h.test("restart 는 Action 에 담긴 시드로 새 판을 만든다 (시드를 무시하면 리플레이 외엔 모두 같은 판)", function()
  local dead = make(cells({ { 20, 5 }, { 19, 5 }, { 18, 5 } }), "right", { x = 1, y = 1 })
  local a, b = reduce(dead, A.restart(7)), reduce(dead, A.restart(12345))
  return h.same(h.snapshot(a), h.snapshot(reducer.initial(7))) and not h.same(h.snapshot(a), h.snapshot(b))
end)

h.test("모르는 action 은 state 를 그대로 돌려준다", function()
  local s = reducer.initial(1)
  return reduce(s, { type = "nope" }) == s
end)

h.finish()
