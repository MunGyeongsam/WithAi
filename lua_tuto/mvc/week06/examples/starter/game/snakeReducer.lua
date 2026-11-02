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
  -- TODO: 다음 경우엔 state 를 "그대로" 돌려준다(새 테이블 만들지 말 것):
  --       죽었음 / 현재 이동 방향(dir)의 반대(OPPOSITE) / 이미 같은 nextDir
  --       그 외엔 copy(state) 한 뒤 nextDir 만 바꾼 새 테이블을 돌려준다.
  --       ⚠️ state.nextDir = dir 처럼 받은 state 를 고치면 순수성 테스트가 실패한다.
  return state
end

local function tick(state)
  -- TODO 순서:
  --   1) 죽었으면 state 그대로
  --   2) s = copy(state); s.dir = state.nextDir; s.ticks = state.ticks + 1
  --   3) 새 머리 좌표 = 머리 + DELTA[s.dir]. 먹이를 먹는가(eats)?
  --   4) 벽 또는 몸 충돌이면 s.status = "dead" 후 반환
  --      (먹지 않을 때 꼬리 칸은 이번 tick 에 비켜나므로 충돌 아님 → 검사 범위 #body - 1)
  --   5) 새 snake 배열 = { 새 머리 } + 기존 칸들(먹었으면 전부, 아니면 마지막 빼고) — 기존 칸 테이블은 공유
  --   6) 먹었으면 s.score + 1, s.food, s.rng = placeFood(새 snake, w, h, state.rng)
  return state
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
