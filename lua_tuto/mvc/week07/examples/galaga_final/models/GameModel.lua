-- GameModel.lua
-- 겔러그의 "상태 + 규칙"을 조율한다. love 비의존, 결정적.
-- 5주차: 단계마다 다른 규칙(편대 재생성, 보스 등장·피격·승리)은 진행 단계 State(self.phase)에 맡긴다.
-- 여기에는 모든 단계에 공통인 규칙만 남는다.

local class = require("class")
local Rng = require("rng")
local PlayerModel = require("PlayerModel")
local EnemyModel = require("EnemyModel")
local BulletModel = require("BulletModel")
local homing = require("homing")
local FormationPhase = require("FormationPhase")
local ComboModel = require("ComboModel")

local GameModel = class()

-- 규칙 버전. 같은 시드·입력에서 결과가 달라지는 변경을 하면 올린다(저장된 리플레이가 더는 맞지 않으므로).
-- 1 = 6주차 규칙. 2 = 콤보(점수 배율 → 보스 등장 시점까지 바뀜).
GameModel.RULES_VERSION = 2

-- 규칙 상수(설정). love 와 무관한 월드 수치.
local PLAYER_SPEED = 320
local BULLET_SPEED = 520
local ENEMY_BULLET_SPEED = 240
local FIRE_COOLDOWN = 0.25
local ENEMY_FIRE_INTERVAL = 0.6
local FORMATION_SPEED = 40
local FORMATION_DESCEND = 16
local MISSILE_SPEED = 440
local MISSILE_TURN = 0.08
local MISSILE_COOLDOWN = 0.6

-- AABB 겹침
local function overlaps(a, b)
  return a.x < b.x + b.w and b.x < a.x + a.w and a.y < b.y + b.h and b.y < a.y + a.h
end

--- @param opts table  { width=number, height=number, seed=number }
function GameModel:init(opts)
  opts = opts or {}
  self.width = opts.width or 600
  self.height = opts.height or 800
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
  self.combo = ComboModel()
  self.state = "playing" -- 결과: "playing" | "gameover" | "won"
  self.formationDir = 1
  self.enemyFireTimer = ENEMY_FIRE_INTERVAL
  self.missileCooldown = 0
  self.boss = nil -- BossPhase 가 채운다 (View 가 읽는다)
  self.events = {} -- 스텝마다 쌓이고, 소비자(View)가 drainEvents() 로 비운다
  self:spawnFormation()
  self.phase = nil
  self:changePhase(FormationPhase())
end

--- 진행 단계를 바꾼다. 새 단계의 enter 가 곧바로 호출된다.
function GameModel:changePhase(phase)
  self.phase = phase
  phase:enter(self)
end

function GameModel:spawnFormation()
  for row = 0, 3 do
    for col = 0, 7 do
      self.enemies[#self.enemies + 1] = EnemyModel(60 + col * 60, 60 + row * 50)
    end
  end
end

function GameModel:_emit(evt)
  self.events[#self.events + 1] = evt
end

--- 쌓인 이벤트를 넘기고 비운다. 프레임당 1회(모든 고정 스텝이 끝난 뒤) 호출한다.
function GameModel:drainEvents()
  local out = self.events
  self.events = {}
  return out
end

--- 고정 스텝 1회. 모든 상태 변경은 여기서(그리고 여기서 부르는 단계 State 에서)만.
-- @param input table  { move = -1|0|1, fire = boolean, missile = boolean }
--
-- 이벤트 계약 (GameModel → View):
--   { type = "fire" }
--   { type = "enemy_destroyed", x = number, y = number }
--   { type = "player_hit" }
--   { type = "game_over" }
--   { type = "formation_cleared" }
--   { type = "boss_appeared" }
--   { type = "boss_hit", x = number, y = number }
--   { type = "boss_destroyed", x = number, y = number }
--   { type = "combo", count = number, mult = number }   (격추로 콤보가 2 이상이 될 때, enemy_destroyed 바로 뒤)
function GameModel:update(dt, input)
  if self.state ~= "playing" then
    return
  end
  self.combo:tick(dt)

  local move = input.move or 0
  local fire = input.fire or false

  -- 플레이어
  self.player:move(dt, move, PLAYER_SPEED)
  self.player:clamp(0, self.width)
  self.player:tickCooldown(dt)
  if fire and self.player:canFire() then
    local p = self.player
    self.bullets[#self.bullets + 1] =
      BulletModel(p.x + p.w * 0.5 - 2, p.y, 0, -BULLET_SPEED, 4, 12, "player")
    self.player:resetCooldown(FIRE_COOLDOWN)
    self:_emit({ type = "fire" })
  end

  -- 유도 미사일 발사(별도 쿨다운). 기존 BulletModel 을 kind="missile" 로 재사용한다.
  self.missileCooldown = self.missileCooldown - dt
  if input.missile and self.missileCooldown <= 0 then
    local p = self.player
    self.bullets[#self.bullets + 1] =
      BulletModel(p.x + p.w * 0.5 - 3, p.y, 0, -MISSILE_SPEED, 6, 14, "missile")
    self.missileCooldown = MISSILE_COOLDOWN
    self:_emit({ type = "fire" })
  end
  self:_steerMissiles()

  -- 플레이어 총알 이동/제거
  for i = #self.bullets, 1, -1 do
    local b = self.bullets[i]
    b:update(dt)
    if b:isOffscreen(self.width, self.height) then
      table.remove(self.bullets, i)
    end
  end

  self:_updateFormation(dt)
  self:_updateEnemyFire(dt)
  self.phase:update(self, dt)

  -- 적 총알 이동/제거
  for i = #self.enemyBullets, 1, -1 do
    local b = self.enemyBullets[i]
    b:update(dt)
    if b:isOffscreen(self.width, self.height) then
      table.remove(self.enemyBullets, i)
    end
  end

  self:_resolveCollisions()
  self.phase:resolveCollisions(self)
  self.phase:afterStep(self)
end

function GameModel:_updateFormation(dt)
  local minx, maxx = math.huge, -math.huge
  for _, e in ipairs(self.enemies) do
    if e.alive then
      minx = math.min(minx, e.x)
      maxx = math.max(maxx, e.x + e.w)
    end
  end
  if minx == math.huge then
    return
  end
  local dx = self.formationDir * FORMATION_SPEED * dt
  if maxx + dx > self.width - 10 or minx + dx < 10 then
    self.formationDir = -self.formationDir
    for _, e in ipairs(self.enemies) do
      e.y = e.y + FORMATION_DESCEND
    end
  else
    for _, e in ipairs(self.enemies) do
      e.x = e.x + dx
    end
  end
end

function GameModel:_updateEnemyFire(dt)
  self.enemyFireTimer = self.enemyFireTimer - dt
  if self.enemyFireTimer > 0 then
    return
  end
  self.enemyFireTimer = ENEMY_FIRE_INTERVAL

  local alive = {}
  for _, e in ipairs(self.enemies) do
    if e.alive then
      alive[#alive + 1] = e
    end
  end
  if #alive == 0 then
    return
  end
  local e = alive[self.rng:range(#alive)]
  self.enemyBullets[#self.enemyBullets + 1] =
    BulletModel(e:centerX() - 2, e.y + e.h, 0, ENEMY_BULLET_SPEED, 4, 12, "enemy")
end

-- 모든 단계에 공통인 충돌. 단계 고유 충돌(보스)은 phase:resolveCollisions 가 맡는다.
function GameModel:_resolveCollisions()
  -- 플레이어 총알 × 적
  for bi = #self.bullets, 1, -1 do
    local b = self.bullets[bi]
    for _, e in ipairs(self.enemies) do
      if e.alive and overlaps(b, e) then
        e.alive = false
        local mult = self.combo:hit()
        self.score = self.score + 100 * mult
        self:_emit({ type = "enemy_destroyed", x = e:centerX(), y = e:centerY() })
        if self.combo.count >= 2 then
          self:_emit({ type = "combo", count = self.combo.count, mult = mult })
        end
        table.remove(self.bullets, bi)
        break
      end
    end
  end

  -- 적 총알 × 플레이어
  for i = #self.enemyBullets, 1, -1 do
    if overlaps(self.enemyBullets[i], self.player) then
      table.remove(self.enemyBullets, i)
      self.lives = self.lives - 1
      self.combo:reset()
      self:_emit({ type = "player_hit" })
      if self.lives <= 0 then
        self.state = "gameover"
        self:_emit({ type = "game_over" })
      end
    end
  end
end

-- 살아있는 적·보스 중 가장 가까운 쪽으로 미사일을 꺾는다.
-- 7주차: 예전에는 스텝마다 목표 목록 테이블(적 수만큼)을 만들어 homing.nearest 에 넘겼다.
-- bench 에서 Model 할당의 약 90%였다. 목록 없이 바로 고른다(거리식·동률 순서는 homing.nearest 와 같다).
function GameModel:_nearestTarget(x, y)
  local bestX, bestY, bestD = nil, nil, math.huge
  for _, e in ipairs(self.enemies) do
    if e.alive then
      local tx, ty = e:centerX(), e:centerY()
      local dx, dy = tx - x, ty - y
      local d = dx * dx + dy * dy
      if d < bestD then
        bestX, bestY, bestD = tx, ty, d
      end
    end
  end
  local boss = self.boss
  if boss and boss.alive then
    local tx, ty = boss:centerX(), boss:centerY()
    local dx, dy = tx - x, ty - y
    if dx * dx + dy * dy < bestD then
      bestX, bestY = tx, ty
    end
  end
  return bestX, bestY
end

function GameModel:_steerMissiles()
  for i = 1, #self.bullets do
    local b = self.bullets[i]
    if b.kind == "missile" then
      local tx, ty = self:_nearestTarget(b.x, b.y)
      if tx then
        homing.steer(b, tx, ty, MISSILE_SPEED, MISSILE_TURN)
      end
    end
  end
end

return GameModel
