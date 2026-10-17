-- main.lua
-- 겔러그 모놀리식 "완성 버전". 기본판(galaga_monolith)에 **유도 미사일 + 보스 탄막**을 추가했다.
-- 목적: 기능 2개를 끼워 넣을 때 수정이 **몇 곳으로 번지는지(전파)**를 눈으로 보여준다.
-- ⚠️ 각 추가 지점에 전파 마커를 달았다:  [H*]=유도 미사일,  [B*]=보스.
--   기본판과 'diff'를 떠 보면, 작은 기능 2개가 파일 전체에 퍼져 있음을 알 수 있다.
--
-- 조작: ←/→ 이동, Space 일반 발사, X 유도 미사일, R 재시작, Esc 종료.

-- 파일 전역 상태 덩어리.
local player
local bullets = {}
local enemies = {}
local enemyBullets = {}
local particles = {}
local score = 0
local lives = 3
local gameover = false
local won = false -- [B1] 보스 격파 승리 상태

local formationDir = 1
local enemyShootTimer = 0
local screenShake = 0
local flash = 0

local boss = nil -- [B1] 보스 엔티티
local bossSpawned = false -- [B1] 보스 1회 등장 플래그

local PLAYER_SPEED = 320
local BULLET_SPEED = 520
local ENEMY_BULLET_SPEED = 240
local HOMING_SPEED = 440 -- [H1] 유도 미사일 속력
local HOMING_TURN = 0.08 -- [H1] 유도 선회율(0~1)
local BOSS_BULLET_SPEED = 180 -- [B1] 보스 방사 탄 속력
local BOSS_SCORE = 1000 -- [B1] 보스 등장 점수

local function spawnFormation()
  enemies = {}
  for row = 0, 3 do
    for col = 0, 7 do
      enemies[#enemies + 1] = {
        x = 60 + col * 60,
        y = 60 + row * 50,
        w = 36,
        h = 28,
        alive = true,
      }
    end
  end
end

local function resetGame()
  player = { x = 300 - 20, y = 740, w = 40, h = 24, cooldown = 0, missileCd = 0 } -- [H2] 미사일 쿨다운
  bullets = {}
  enemyBullets = {}
  particles = {}
  score = 0
  lives = 3
  gameover = false
  won = false -- [B2]
  boss = nil -- [B2]
  bossSpawned = false -- [B2]
  formationDir = 1
  enemyShootTimer = 0
  screenShake = 0
  flash = 0
  spawnFormation()
end

local function hit(a, b)
  return a.x < b.x + b.w and b.x < a.x + a.w and a.y < b.y + b.h and b.y < a.y + a.h
end

local function explode(x, y)
  for i = 1, 12 do
    local a = math.random() * math.pi * 2
    local s = 40 + math.random() * 120
    particles[#particles + 1] = {
      x = x,
      y = y,
      vx = math.cos(a) * s,
      vy = math.sin(a) * s,
      life = 0.5,
    }
  end
  flash = 0.06
end

-- [H3] 유도 미사일의 목표를 고른다(가장 가까운 적 또는 보스). 로직이 또 길어진다.
local function nearestTarget(x, y)
  local tx, ty, best = nil, nil, math.huge
  for _, e in ipairs(enemies) do
    if e.alive then
      local cx, cy = e.x + e.w * 0.5, e.y + e.h * 0.5
      local d = (cx - x) * (cx - x) + (cy - y) * (cy - y)
      if d < best then
        best, tx, ty = d, cx, cy
      end
    end
  end
  if boss and boss.alive then
    local cx, cy = boss.x + boss.w * 0.5, boss.y + boss.h * 0.5
    local d = (cx - x) * (cx - x) + (cy - y) * (cy - y)
    if d < best then
      tx, ty = cx, cy
    end
  end
  return tx, ty
end

-- [B3] 보스를 등장시킨다. 편대와 별개의 새 엔티티/상태가 끼어든다.
local function spawnBoss()
  boss = {
    x = 240,
    y = 70,
    w = 120,
    h = 60,
    hp = 40,
    maxhp = 40,
    alive = true,
    dir = 1,
    shootTimer = 1.0,
  }
  bossSpawned = true
end

function love.load()
  love.graphics.setBackgroundColor(0.02, 0.02, 0.06)
  math.randomseed(os.time())
  resetGame()
end

function love.update(dt)
  if gameover then
    return
  end

  if screenShake > 0 then
    screenShake = screenShake - dt
  end
  if flash > 0 then
    flash = flash - dt
  end

  -- 플레이어 이동
  if love.keyboard.isDown("left") then
    player.x = player.x - PLAYER_SPEED * dt
  end
  if love.keyboard.isDown("right") then
    player.x = player.x + PLAYER_SPEED * dt
  end
  if player.x < 0 then
    player.x = 0
  elseif player.x > 600 - player.w then
    player.x = 600 - player.w
  end

  -- 일반 발사
  player.cooldown = player.cooldown - dt
  if love.keyboard.isDown("space") and player.cooldown <= 0 then
    -- [H2] 이제 일반 총알도 vx/vy/homing 필드를 가진다(자료구조 전파).
    bullets[#bullets + 1] =
      { x = player.x + player.w * 0.5 - 2, y = player.y, w = 4, h = 12, vx = 0, vy = -BULLET_SPEED, homing = false }
    player.cooldown = 0.25
  end

  -- [H2] 유도 미사일 발사(별도 입력/쿨다운)
  player.missileCd = player.missileCd - dt
  if love.keyboard.isDown("x") and player.missileCd <= 0 then
    bullets[#bullets + 1] =
      { x = player.x + player.w * 0.5 - 3, y = player.y, w = 6, h = 14, vx = 0, vy = -HOMING_SPEED, homing = true }
    player.missileCd = 0.6
  end

  -- 플레이어 총알 이동 ( [H3] 유도 분기가 이 루프를 오염시킨다 )
  for i = #bullets, 1, -1 do
    local b = bullets[i]
    if b.homing then
      local tx, ty = nearestTarget(b.x, b.y)
      if tx then
        local dx, dy = tx - b.x, ty - b.y
        local len = math.sqrt(dx * dx + dy * dy)
        if len > 0 then
          local dvx, dvy = dx / len * HOMING_SPEED, dy / len * HOMING_SPEED
          b.vx = b.vx + (dvx - b.vx) * HOMING_TURN
          b.vy = b.vy + (dvy - b.vy) * HOMING_TURN
          -- 속력 유지(정규화)
          local sl = math.sqrt(b.vx * b.vx + b.vy * b.vy)
          if sl > 0 then
            b.vx, b.vy = b.vx / sl * HOMING_SPEED, b.vy / sl * HOMING_SPEED
          end
        end
      end
    end
    b.x = b.x + b.vx * dt
    b.y = b.y + b.vy * dt
    if b.y + b.h < 0 or b.y > 800 or b.x < -20 or b.x > 620 then
      table.remove(bullets, i)
    end
  end

  -- 적 편대 이동
  local minx, maxx = math.huge, -math.huge
  for _, e in ipairs(enemies) do
    if e.alive then
      minx = math.min(minx, e.x)
      maxx = math.max(maxx, e.x + e.w)
    end
  end
  local dx = formationDir * 40 * dt
  if maxx + dx > 590 or minx + dx < 10 then
    formationDir = -formationDir
    for _, e in ipairs(enemies) do
      e.y = e.y + 16
    end
  else
    for _, e in ipairs(enemies) do
      e.x = e.x + dx
    end
  end

  -- 적 발사(랜덤)
  enemyShootTimer = enemyShootTimer - dt
  if enemyShootTimer <= 0 then
    enemyShootTimer = 0.6
    local alive = {}
    for _, e in ipairs(enemies) do
      if e.alive then
        alive[#alive + 1] = e
      end
    end
    if #alive > 0 then
      local e = alive[math.random(#alive)]
      -- [B5] 이제 적 총알도 vx/vy를 가진다(보스 방사탄과 자료구조 통일 → 전파).
      enemyBullets[#enemyBullets + 1] =
        { x = e.x + e.w * 0.5 - 2, y = e.y + e.h, w = 4, h = 12, vx = 0, vy = ENEMY_BULLET_SPEED }
    end
  end

  -- [B3][B4] 보스 등장/이동/발사
  if not bossSpawned and score >= BOSS_SCORE then
    spawnBoss()
  end
  if boss and boss.alive then
    boss.x = boss.x + boss.dir * 70 * dt
    if boss.x < 10 then
      boss.x, boss.dir = 10, 1
    elseif boss.x > 590 - boss.w then
      boss.x, boss.dir = 590 - boss.w, -1
    end
    boss.shootTimer = boss.shootTimer - dt
    if boss.shootTimer <= 0 then
      boss.shootTimer = 1.2
      local cx, cy = boss.x + boss.w * 0.5, boss.y + boss.h * 0.5
      local n = 18 -- [B5] 원형 방사 탄막
      for k = 0, n - 1 do
        local a = (k / n) * math.pi * 2
        enemyBullets[#enemyBullets + 1] = {
          x = cx,
          y = cy,
          w = 6,
          h = 6,
          vx = math.cos(a) * BOSS_BULLET_SPEED,
          vy = math.sin(a) * BOSS_BULLET_SPEED,
        }
      end
    end
  end

  -- 적 총알 이동 ( [B6] vx 적용 + 좌우 화면 밖 제거로 변경됨 )
  for i = #enemyBullets, 1, -1 do
    local b = enemyBullets[i]
    b.x = b.x + b.vx * dt
    b.y = b.y + b.vy * dt
    if b.y > 800 or b.y < -20 or b.x < -20 or b.x > 620 then
      table.remove(enemyBullets, i)
    end
  end

  -- 충돌: 플레이어 총알 × 적
  for bi = #bullets, 1, -1 do
    local b = bullets[bi]
    for _, e in ipairs(enemies) do
      if e.alive and hit(b, e) then
        e.alive = false
        score = score + 100
        explode(e.x + e.w * 0.5, e.y + e.h * 0.5)
        table.remove(bullets, bi)
        break
      end
    end
  end

  -- [B7] 충돌: 플레이어 총알 × 보스 (HP 다중 피격)
  if boss and boss.alive then
    for bi = #bullets, 1, -1 do
      if hit(bullets[bi], boss) then
        boss.hp = boss.hp - 1
        explode(bullets[bi].x, bullets[bi].y)
        table.remove(bullets, bi)
        if boss.hp <= 0 then
          boss.alive = false
          score = score + 2000
          won = true
          gameover = true
        end
      end
    end
  end

  -- 충돌: 적 총알 × 플레이어
  for i = #enemyBullets, 1, -1 do
    if hit(enemyBullets[i], player) then
      table.remove(enemyBullets, i)
      lives = lives - 1
      screenShake = 0.3
      if lives <= 0 then
        gameover = true
      end
    end
  end

  -- 파티클
  for i = #particles, 1, -1 do
    local p = particles[i]
    p.x = p.x + p.vx * dt
    p.y = p.y + p.vy * dt
    p.life = p.life - dt
    if p.life <= 0 then
      table.remove(particles, i)
    end
  end

  -- 전멸 시 다음 편대 ( [B3] 단, 보스 등장 후엔 편대를 다시 뽑지 않음 )
  local anyAlive = false
  for _, e in ipairs(enemies) do
    if e.alive then
      anyAlive = true
      break
    end
  end
  if not anyAlive and not bossSpawned then
    spawnFormation()
  end
end

function love.draw()
  local ox, oy = 0, 0
  if screenShake > 0 then
    ox = (math.random() - 0.5) * 10
    oy = (math.random() - 0.5) * 10
  end
  love.graphics.push()
  love.graphics.translate(ox, oy)

  if flash > 0 then
    love.graphics.setColor(0.3, 0.3, 0.4)
    love.graphics.rectangle("fill", 0, 0, 600, 800)
  end

  love.graphics.setColor(0.4, 0.9, 1)
  love.graphics.rectangle("fill", player.x, player.y, player.w, player.h)

  -- 총알: [H4] 유도 미사일은 다른 색으로(그리기도 전파)
  for _, b in ipairs(bullets) do
    if b.homing then
      love.graphics.setColor(0.4, 1, 0.6)
    else
      love.graphics.setColor(1, 1, 0.3)
    end
    love.graphics.rectangle("fill", b.x, b.y, b.w, b.h)
  end

  love.graphics.setColor(1, 0.4, 0.4)
  for _, e in ipairs(enemies) do
    if e.alive then
      love.graphics.rectangle("fill", e.x, e.y, e.w, e.h)
    end
  end

  -- [B8] 보스 + HP 바
  if boss and boss.alive then
    love.graphics.setColor(0.9, 0.3, 0.9)
    love.graphics.rectangle("fill", boss.x, boss.y, boss.w, boss.h)
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", 100, 40, 400, 10)
    love.graphics.setColor(1, 0.2, 0.2)
    love.graphics.rectangle("fill", 100, 40, 400 * (boss.hp / boss.maxhp), 10)
  end

  love.graphics.setColor(1, 0.6, 0.2)
  for _, b in ipairs(enemyBullets) do
    love.graphics.rectangle("fill", b.x, b.y, b.w, b.h)
  end

  love.graphics.setColor(1, 0.8, 0.2)
  for _, p in ipairs(particles) do
    love.graphics.rectangle("fill", p.x, p.y, 3, 3)
  end

  love.graphics.pop()

  love.graphics.setColor(1, 1, 1)
  love.graphics.print("SCORE " .. score, 10, 10)
  love.graphics.print("LIVES " .. lives, 500, 10)
  if gameover then
    -- [B9] 승/패 메시지 분기
    local msg = won and "YOU WIN!\nPress R" or "GAME OVER\nPress R"
    love.graphics.printf(msg, 0, 380, 600, "center")
  end
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  elseif key == "r" and gameover then
    resetGame()
  end
end
