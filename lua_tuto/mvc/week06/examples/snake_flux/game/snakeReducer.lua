-- snakeReducer.lua
-- Snake 의 모든 규칙. 순수 함수: reduce(state, action) → 새 state.
-- ⚠️ 받은 state 는 절대 고치지 않는다. 바뀐 부분만 새 테이블로 만들고 나머지는 공유한다.
--    (그래서 옛 state 를 보관해 두면 그대로 "과거"가 된다 — 시간 여행의 바탕)
--
-- state 계약:
--   w, h        격자 크기
--   snake       { {x=,y=}, ... }  머리가 1번. 각 칸 테이블은 만든 뒤 바꾸지 않는다
--   dir         지금 움직이는 방향
--   nextDir     다음 tick 에 적용할 방향 (turn 이 바꾼다)
--   food        {x=,y=} | nil
--   score       먹은 개수
--   status      "playing" | "dead"
--   rng         prng 상태 (난수도 state 안에 있어야 순수하다)
--   ticks       지난 tick 수

local prng = require("prng")

local reducer = {}

local W, H = 20, 20

local DELTA = {
  up = { 0, -1 },
  down = { 0, 1 },
  left = { -1, 0 },
  right = { 1, 0 },
}
local OPPOSITE = { up = "down", down = "up", left = "right", right = "left" }

local function copy(t)
  local c = {}
  for k, v in pairs(t) do
    c[k] = v
  end
  return c
end

local function occupied(snake, x, y)
  for i = 1, #snake do
    if snake[i].x == x and snake[i].y == y then
      return true
    end
  end
  return false
end

-- 빈 칸을 정해진 순서로 나열한 뒤 난수로 하나 고른다(같은 rng 상태 → 같은 자리).
local function placeFood(snake, w, h, rng)
  local free = {}
  for y = 1, h do
    for x = 1, w do
      if not occupied(snake, x, y) then
        free[#free + 1] = { x = x, y = y }
      end
    end
  end
  if #free == 0 then
    return nil, rng
  end
  local i, nextRng = prng.range(rng, #free)
  return free[i], nextRng
end

function reducer.initial(seed)
  local cx, cy = math.floor(W / 2), math.floor(H / 2)
  local snake = { { x = cx, y = cy }, { x = cx - 1, y = cy }, { x = cx - 2, y = cy } }
  local food, rng = placeFood(snake, W, H, prng.seed(seed))
  return {
    w = W,
    h = H,
    snake = snake,
    dir = "right",
    nextDir = "right",
    food = food,
    score = 0,
    status = "playing",
    rng = rng,
    ticks = 0,
  }
end

local function turn(state, dir)
  if state.status ~= "playing" or dir == OPPOSITE[state.dir] or dir == state.nextDir then
    return state -- 바뀐 게 없으면 같은 테이블을 돌려준다(변경 없음을 싸게 알 수 있다)
  end
  local s = copy(state)
  s.nextDir = dir
  return s
end

local function tick(state)
  if state.status ~= "playing" then
    return state
  end
  local s = copy(state)
  s.dir = state.nextDir
  s.ticks = state.ticks + 1

  local head = state.snake[1]
  local d = DELTA[s.dir]
  local nx, ny = head.x + d[1], head.y + d[2]

  local eats = state.food and nx == state.food.x and ny == state.food.y
  -- 꼬리는 이번 tick 에 비켜나므로(먹지 않을 때) 꼬리 칸으로 들어가는 건 충돌이 아니다.
  local body = state.snake
  local hitSelf = false
  for i = 1, #body - (eats and 0 or 1) do
    if body[i].x == nx and body[i].y == ny then
      hitSelf = true
      break
    end
  end
  if nx < 1 or nx > state.w or ny < 1 or ny > state.h or hitSelf then
    s.status = "dead"
    return s
  end

  local snake = { { x = nx, y = ny } }
  local keep = eats and #body or #body - 1
  for i = 1, keep do
    snake[#snake + 1] = body[i] -- 기존 칸 테이블은 공유(바꾸지 않으므로 안전)
  end
  s.snake = snake

  if eats then
    s.score = state.score + 1
    s.food, s.rng = placeFood(snake, state.w, state.h, state.rng)
  end
  return s
end

--- 순수 리듀서. 모르는 action 은 state 를 그대로 돌려준다(검증은 Dispatcher 의 일).
function reducer.reduce(state, action)
  if action.type == "restart" then
    return reducer.initial(action.seed)
  elseif action.type == "turn" then
    return turn(state, action.dir)
  elseif action.type == "tick" then
    return tick(state)
  end
  return state
end

return reducer
