-- GameModel.lua
-- 겔러그의 "상태 + 규칙" 전체를 조율한다. love 비의존, 결정적.
-- View/Controller 를 전혀 모른다. 매 프레임 update(dt, input) 만 호출하면 된다.

local class = require("class")
local Rng = require("rng")
local PlayerModel = require("PlayerModel")
local EnemyModel = require("EnemyModel")
local BulletModel = require("BulletModel")

local GameModel = class()

-- 규칙 상수(설정). love 와 무관한 월드 수치.
local PLAYER_SPEED = 320
local BULLET_SPEED = 520
local ENEMY_BULLET_SPEED = 240
local FIRE_COOLDOWN = 0.25
local ENEMY_FIRE_INTERVAL = 0.6
local FORMATION_SPEED = 40
local FORMATION_DESCEND = 16

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
  self.state = "playing" -- "playing" | "gameover"
  self.formationDir = 1
  self.enemyFireTimer = ENEMY_FIRE_INTERVAL
  self.events = {} -- 스텝마다 쌓이고, 소비자(View)가 drainEvents() 로 비운다
  self:spawnFormation()
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
-- @return table  이벤트 배열 (아래 "이벤트 계약" 참고)
function GameModel:drainEvents()
  local out = self.events
  self.events = {}
  return out
end

--- 매 프레임 1스텝. 모든 상태 변경은 여기서만.
-- @param dt    number
-- @param input table  { move = -1|0|1, fire = boolean }
--
-- 이벤트 계약 (GameModel → View):
--   { type = "fire" }
--   { type = "enemy_destroyed", x = number, y = number }
--   { type = "player_hit" }
--   { type = "game_over" }
--   { type = "formation_cleared" }
function GameModel:update(dt, input)
  -- 여기서 events 를 비우면 한 프레임에 스텝이 여러 번 돈 때 앞 스텝 이벤트가 사라진다.
  if self.state == "gameover" then
    return
  end

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

  -- 적 총알 이동/제거
  for i = #self.enemyBullets, 1, -1 do
    local b = self.enemyBullets[i]
    b:update(dt)
    if b:isOffscreen(self.width, self.height) then
      table.remove(self.enemyBullets, i)
    end
  end

  self:_resolveCollisions()
  self:_respawnIfCleared()
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

function GameModel:_resolveCollisions()
  -- 플레이어 총알 × 적
  for bi = #self.bullets, 1, -1 do
    local b = self.bullets[bi]
    for _, e in ipairs(self.enemies) do
      if e.alive and overlaps(b, e) then
        e.alive = false
        self.score = self.score + 100
        self:_emit({ type = "enemy_destroyed", x = e:centerX(), y = e:centerY() })
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
      self:_emit({ type = "player_hit" })
      if self.lives <= 0 then
        self.state = "gameover"
        self:_emit({ type = "game_over" })
      end
    end
  end
end

function GameModel:_respawnIfCleared()
  for _, e in ipairs(self.enemies) do
    if e.alive then
      return
    end
  end
  self.enemies = {}
  self:spawnFormation()
  self:_emit({ type = "formation_cleared" })
end

return GameModel
