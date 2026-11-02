-- BossPhase.lua
-- 진행 단계(State) ②: 보스전. 보스 등장·이동·탄막·피격·격파(승리)를 맡는다.
-- 남은 편대는 계속 움직이고 쏘지만(공통 규칙), 전멸해도 새 편대는 나오지 않는다.

local class = require("class")
local BossModel = require("BossModel")

local BossPhase = class()

local BOSS_HP = 40
local BOSS_REWARD = 2000

BossPhase.name = "boss"

-- AABB 겹침
local function overlaps(a, b)
  return a.x < b.x + b.w and b.x < a.x + a.w and a.y < b.y + b.h and b.y < a.y + a.h
end

function BossPhase:enter(game)
  game.boss = BossModel(game.width * 0.5 - 60, 70, BOSS_HP)
  game:_emit({ type = "boss_appeared" })
end

function BossPhase:update(game, dt)
  local boss = game.boss
  if boss and boss.alive then
    boss:update(dt, game.width, game.enemyBullets)
  end
end

function BossPhase:resolveCollisions(game)
  local boss = game.boss
  if not (boss and boss.alive) then
    return
  end
  for bi = #game.bullets, 1, -1 do
    local b = game.bullets[bi]
    if overlaps(b, boss) then
      table.remove(game.bullets, bi)
      game:_emit({ type = "boss_hit", x = b.x, y = b.y })
      if boss:takeDamage(1) then
        game.score = game.score + BOSS_REWARD
        game.state = "won"
        game:_emit({ type = "boss_destroyed", x = boss:centerX(), y = boss:centerY() })
        break
      end
    end
  end
end

function BossPhase:afterStep(game) end

return BossPhase
