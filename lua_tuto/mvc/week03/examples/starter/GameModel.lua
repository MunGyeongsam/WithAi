-- GameModel.lua  (STARTER — TODO 를 채운다)
-- 겔러그의 "상태 + 규칙" 전체를 조율한다. print / io / love 금지, 결정적.
-- 진행: tests/ 에서 `luajit model_test.lua starter` 를 돌리며 FAIL 을 하나씩 ok 로 바꾼다.
-- 원본: 2주차 galaga_monolith/main.lua 의 love.update 블록들.

local class = require("class")
local Rng = require("rng")
local PlayerModel = require("PlayerModel")
local EnemyModel = require("EnemyModel")
local BulletModel = require("BulletModel")

local GameModel = class()

-- 모놀리식에 흩어져 있던 매직 넘버를 한곳에 모은다.
local PLAYER_SPEED = 320
local BULLET_SPEED = 520
local ENEMY_BULLET_SPEED = 240
local FIRE_COOLDOWN = 0.25
local ENEMY_FIRE_INTERVAL = 0.6
local FORMATION_SPEED = 40
local FORMATION_DESCEND = 16

local function overlaps(a, b)
  return a.x < b.x + b.w and b.x < a.x + a.w and a.y < b.y + b.h and b.y < a.y + a.h
end

--- @param opts table  { width=number, height=number, seed=number }
function GameModel:init(opts)
  opts = opts or {}
  self.width = opts.width or 600
  self.height = opts.height or 800
  -- 디커플링 ③: math.randomseed(os.time()) 대신 주입 RNG
  self.rng = Rng(opts.seed or 1)
  self:reset()
end

function GameModel:reset()
  self.player = PlayerModel(self.width * 0.5 - 20, self.height - 60)
  self.bullets = {}
  self.enemyBullets = {}
  self.enemies = {}
  self.score = 0
  self.lives = 3
  self.state = "playing" -- "playing" | "gameover"
  self.formationDir = 1
  self.enemyFireTimer = ENEMY_FIRE_INTERVAL
  self.events = {}
  self:spawnFormation()
end

--- 4행 × 8열 편대를 만든다. 위치: x = 60 + col*60, y = 60 + row*50
function GameModel:spawnFormation()
  -- TODO: EnemyModel(x, y) 를 self.enemies 에 추가
end

-- 디커플링 ②: 연출을 직접 만들지 않고 "사실"만 기록한다.
function GameModel:_emit(evt)
  self.events[#self.events + 1] = evt
end

--- 쌓인 이벤트를 넘기고 비운다. 프레임당 1회 호출.
function GameModel:drainEvents()
  -- TODO: 현재 목록을 돌려주고 self.events 는 새 빈 목록으로.
  --       (update 안에서 비우면 왜 안 되는지 README 4절 참고)
  return {}
end

--- 매 고정 스텝 1회.
-- @param input table  { move = -1|0|1, fire = boolean }   ← 디커플링 ①
--
-- 이벤트 계약: fire / enemy_destroyed{x,y} / player_hit / game_over / formation_cleared
function GameModel:update(dt, input)
  if self.state == "gameover" then
    return
  end

  -- TODO 1) 플레이어: move → clamp(0, width) → tickCooldown
  -- TODO 2) fire 이고 canFire 면: 총알 생성(BulletModel, vy = -BULLET_SPEED, 4x12, "player"),
  --         resetCooldown(FIRE_COOLDOWN), "fire" 이벤트
  -- TODO 3) 플레이어 총알 이동 + 화면 밖 제거 (뒤에서부터 순회)

  self:_updateFormation(dt)
  self:_updateEnemyFire(dt)

  -- TODO 4) 적 총알 이동 + 화면 밖 제거

  self:_resolveCollisions()
  self:_respawnIfCleared()
end

function GameModel:_updateFormation(dt)
  -- TODO: 살아있는 적의 좌우 끝(minx, maxx)을 구하고,
  --       경계(10, width-10)에 닿으면 방향 반전 + FORMATION_DESCEND 만큼 하강,
  --       아니면 formationDir * FORMATION_SPEED * dt 만큼 수평 이동
end

function GameModel:_updateEnemyFire(dt)
  -- TODO: 타이머가 0 이하가 되면 ENEMY_FIRE_INTERVAL 로 되돌리고,
  --       살아있는 적 중 self.rng:range(n) 으로 하나를 골라 아래로 쏜다.
  --       ⚠️ math.random 을 쓰면 결정성 테스트가 실패한다.
end

function GameModel:_resolveCollisions()
  -- TODO a) 플레이어 총알 × 적: 적 사망, score +100,
  --         "enemy_destroyed"{x=중심x, y=중심y}, 총알 제거
  -- TODO b) 적 총알 × 플레이어: 총알 제거, lives -1, "player_hit",
  --         lives <= 0 이면 state = "gameover" + "game_over"
  --         (판정은 위에 정의된 overlaps(a, b) 사용)
end

function GameModel:_respawnIfCleared()
  -- TODO: 살아있는 적이 없으면 편대를 새로 만들고 "formation_cleared"
end

return GameModel
