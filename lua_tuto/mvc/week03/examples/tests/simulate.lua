-- simulate.lua
-- 창 없이 GameModel 을 돌려 "게임이 머릿속에서 돈다"를 눈으로 확인한다.
-- 간단한 자동 조종(가장 가까운 적 아래로 이동 + 계속 발사)이 입력을 대신한다.
-- 실행: cd lua_tuto/mvc/week03/examples/tests
--   luajit simulate.lua               ← seed 42, 30초
--   luajit simulate.lua 7 60          ← seed 7, 60초
--   luajit simulate.lua 42 30 starter ← 내가 채운 starter/ 로 실행

local here = (arg[0] or ""):match("(.*/)") or "./"
local seed = tonumber(arg[1]) or 42
local seconds = tonumber(arg[2]) or 30
local target = arg[3] or "models"
package.path = here .. "../" .. target .. "/?.lua;" .. package.path

local GameModel = require("GameModel")

local FIXED_DT = 1 / 60
local STEPS_PER_SEC = 60

-- Controller 역할을 하는 자동 조종: Model 상태를 읽어 입력 테이블만 만든다.
local function autopilot(game)
  local px = game.player.x + game.player.w * 0.5
  local bestX, bestD = nil, math.huge
  for _, e in ipairs(game.enemies) do
    if e.alive then
      local d = math.abs(e:centerX() - px)
      if d < bestD then
        bestX, bestD = e:centerX(), d
      end
    end
  end
  local move = 0
  if bestX and bestD > 4 then
    move = bestX > px and 1 or -1
  end
  return { move = move, fire = true }
end

local function aliveCount(game)
  local n = 0
  for _, e in ipairs(game.enemies) do
    if e.alive then
      n = n + 1
    end
  end
  return n
end

local game = GameModel({ width = 600, height = 800, seed = seed })
local totals = {}
local hitTimes = {}

print(string.format("[simulate] seed=%d  seconds=%d  target=%s/", seed, seconds, target))
print(" t(s) | score | lives | enemies | 이번 1초 이벤트")
print("------+-------+-------+---------+------------------------------")

for sec = 1, seconds do
  local counts = {}
  for _ = 1, STEPS_PER_SEC do
    game:update(FIXED_DT, autopilot(game))
  end
  -- 실제 게임에서는 View 가 프레임마다 drain 한다. 여기선 1초마다 모아 본다.
  for _, ev in ipairs(game:drainEvents()) do
    counts[ev.type] = (counts[ev.type] or 0) + 1
    totals[ev.type] = (totals[ev.type] or 0) + 1
    if ev.type == "player_hit" then
      hitTimes[#hitTimes + 1] = sec .. "s"
    end
  end

  local parts = {}
  for _, name in ipairs({ "enemy_destroyed", "player_hit", "formation_cleared", "game_over" }) do
    if counts[name] then
      parts[#parts + 1] = name .. "×" .. counts[name]
    end
  end
  print(string.format(" %4d | %5d | %5d | %7d | %s", sec, game.score, game.lives, aliveCount(game), table.concat(parts, " ")))

  if game.state == "gameover" then
    print("------ GAME OVER ------")
    break
  end
end

print(string.format(
  "\n[결과] score=%d lives=%d state=%s  (총 파괴 %d, 피격 시각: %s)",
  game.score,
  game.lives,
  game.state,
  totals.enemy_destroyed or 0,
  #hitTimes > 0 and table.concat(hitTimes, ", ") or "없음"
))
print("같은 seed 로 다시 돌리면 [결과] 줄이 한 글자도 다르지 않아야 한다 (결정성).")
print("seed 를 바꾸면 적이 쏘는 순서가 바뀌어 피격 시각이 달라진다.")
