-- BossPhase.lua  (STARTER)
-- 진행 단계(State) ②: 보스전. 보스 등장·이동·탄막·피격·격파(승리)를 맡는다.
-- 참고: FormationPhase.lua (완성 예시) 와 같은 4개 메서드를 구현한다.
-- 원본: 4주차 galaga_mvc_full/models/GameModel.lua 의 _updateBoss 와 _resolveCollisions 의 "보스" 블록.
-- 검사: tests/phase_test.lua, 그리고 tests/equivalence_test.lua (4주차와 매 스텝 동일해야 한다)

local class = require("class")
local BossModel = require("BossModel")

local BossPhase = class()

local BOSS_HP = 40
local BOSS_REWARD = 2000

BossPhase.name = "boss"

local function overlaps(a, b)
  return a.x < b.x + b.w and b.x < a.x + a.w and a.y < b.y + b.h and b.y < a.y + a.h
end

function BossPhase:enter(game)
  -- TODO: game.boss = BossModel(game.width * 0.5 - 60, 70, BOSS_HP)  +  "boss_appeared" 이벤트
end

function BossPhase:update(game, dt)
  -- TODO: 보스가 살아 있으면 boss:update(dt, game.width, game.enemyBullets)
end

function BossPhase:resolveCollisions(game)
  -- TODO: 플레이어 총알 × 보스 (뒤에서부터 순회)
  --   맞으면: 총알 제거 → "boss_hit"{x,y} → boss:takeDamage(1) 이 true 면
  --           score += BOSS_REWARD, state = "won", "boss_destroyed"{x,y}, break
  --   ⚠️ 순서를 4주차와 똑같이 해야 equivalence_test 가 통과한다.
end

function BossPhase:afterStep(game) end

return BossPhase
