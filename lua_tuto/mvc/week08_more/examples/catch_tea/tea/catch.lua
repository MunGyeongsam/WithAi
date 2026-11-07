-- catch.lua (TEA · The Elm Architecture)
-- 프로그램 = 순수 함수 세 개. 받은 model 을 절대 고치지 않는다.
--   init(seed)          → model
--   update(model, msg)  → 새 model, effects(데이터 목록 | nil)
--   view(model)         → 그리기 명령 목록(데이터). gfx 를 모른다.
-- msg: { type = "move", dir = -1|1 } | { type = "tick" }
-- effect: { type = "beep", name = "coin"|"bomb" }  — 실제 소리는 runtime 바깥(main)이 낸다.

local prng = require("prng")
local R = require("rules")

local catch = {}

catch.TICK = R.TICK
catch.CELL = 60
catch.HUD = 40

function catch.init(seed)
  return {
    rng = prng.seed(seed),
    lane = R.START_LANE,
    items = {},
    score = 0,
    hp = R.START_HP,
    ticks = 0,
    over = false,
  }
end

--- 얕은 복사 + 바뀐 필드만 덮어쓰기. 바뀌지 않은 하위 테이블은 옛 model 과 공유한다.
local function with(model, changes)
  local m = {}
  for k, v in pairs(model) do
    m[k] = v
  end
  for k, v in pairs(changes) do
    m[k] = v
  end
  return m
end

local function tick(model)
  local ticks = model.ticks + 1
  local score, hp, rng = model.score, model.hp, model.rng
  local items, effects = {}, {}

  for _, it in ipairs(model.items) do
    local row = it.row + 1
    if row >= R.ROWS then
      if it.lane == model.lane then
        if it.kind == "coin" then
          score = score + R.COIN_SCORE
        else
          hp = hp - 1
        end
        effects[#effects + 1] = { type = "beep", name = it.kind }
      end
    else
      items[#items + 1] = { lane = it.lane, row = row, kind = it.kind }
    end
  end

  if hp <= 0 then
    return with(model, { ticks = ticks, score = score, hp = 0, items = items, over = true }), effects
  end

  if ticks % R.SPAWN_EVERY == 0 then
    local lane, roll
    lane, rng = prng.range(rng, R.LANES)
    roll, rng = prng.range(rng, 10)
    items[#items + 1] = { lane = lane, row = 1, kind = roll <= R.BOMB_CHANCE and "bomb" or "coin" }
  end

  return with(model, { ticks = ticks, score = score, hp = hp, items = items, rng = rng }), effects
end

function catch.update(model, msg)
  if model.over then
    return model
  end
  if msg.type == "move" then
    local lane = math.max(1, math.min(R.LANES, model.lane + msg.dir))
    if lane == model.lane then
      return model -- 같은 테이블 = "변화 없음"
    end
    return with(model, { lane = lane })
  elseif msg.type == "tick" then
    return tick(model)
  end
  return model
end

local KEYS = { left = -1, a = -1, right = 1, d = 1 }

--- 키 → msg. 순수 함수라 표 하나로 테스트된다.
function catch.onKey(key)
  local dir = KEYS[key]
  if dir then
    return { type = "move", dir = dir }
  end
  return nil
end

local COLORS = {
  coin = { 1, 0.85, 0.2 },
  bomb = { 0.9, 0.25, 0.25 },
}

function catch.view(model)
  local C, top = catch.CELL, catch.HUD
  local out = {}
  local function add(cmd)
    out[#out + 1] = cmd
  end

  add({ "setColor", 0.15, 0.15, 0.2 })
  for lane = 1, R.LANES do
    add({ "rectangle", "line", (lane - 1) * C, top, C, R.ROWS * C })
  end

  for _, it in ipairs(model.items) do
    local c = COLORS[it.kind]
    add({ "setColor", c[1], c[2], c[3] })
    add({ "circle", "fill", (it.lane - 0.5) * C, top + (it.row - 0.5) * C, C * 0.3 })
  end

  add({ "setColor", 0.3, 0.8, 1 })
  add({ "rectangle", "fill", (model.lane - 1) * C + 8, top + (R.ROWS - 1) * C + 20, C - 16, C - 28 })

  add({ "setColor", 1, 1, 1 })
  add({ "print", "SCORE " .. model.score, 8, 12 })
  if model.hp <= 1 then
    add({ "setColor", 1, 0.3, 0.3 })
  end
  add({ "print", "HP " .. string.rep("*", model.hp), 200, 12 })

  if model.over then
    add({ "setColor", 1, 1, 1 })
    add({ "printf", "GAME OVER  -  R", 0, top + 2 * C, R.LANES * C, "center" })
  end
  return out
end

return catch
