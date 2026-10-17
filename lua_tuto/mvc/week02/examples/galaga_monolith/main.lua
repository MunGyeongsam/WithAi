-- main.lua
-- 겔러그(모놀리식). 2주차 "고통 체감"용 **의도적 안티패턴**.
-- 입력·이동·적 패턴·탄막·충돌·렌더·이펙트·상태를 한 파일에 전부 몰아넣었다.
-- ⚠️ 이 구조를 따라 하지 말 것. 3~4주차에 이걸 MVC로 분해한다.
--
-- 조작: ←/→ 이동, Space 발사, R 재시작, Esc 종료.

-- 파일 전역 상태 덩어리(모놀리식의 전형). 모든 게 여기 뒤섞여 산다.
local player
local bullets = {}
local enemies = {}
local enemyBullets = {}
local particles = {} -- 순수 "보이는 효과"인데 로직 파일에 같이 산다
local score = 0
local lives = 3
local gameover = false

local formationDir = 1 -- 적 편대 좌우 이동 방향
local enemyShootTimer = 0
local screenShake = 0 -- ⚠️ VIEW(연출) 상태가 로직 상태와 한 덩어리
local flash = 0 -- 적 파괴 시 번쩍임(연출)

-- 매직 넘버가 여기저기 흩어진다. 일부는 여기, 일부는 코드 속에 인라인.
local PLAYER_SPEED = 320
local BULLET_SPEED = 520
local ENEMY_BULLET_SPEED = 240

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
  player = { x = 300 - 20, y = 740, w = 40, h = 24, cooldown = 0 }
  bullets = {}
  enemyBullets = {}
  particles = {}
  score = 0
  lives = 3
  gameover = false
  formationDir = 1
  enemyShootTimer = 0
  screenShake = 0
  flash = 0
  spawnFormation()
end

-- 충돌 판정(AABB). 그나마 유일하게 재사용 가능한 순수 함수.
local function hit(a, b)
  return a.x < b.x + b.w and b.x < a.x + a.w and a.y < b.y + b.h and b.y < a.y + a.h
end

-- 적 파괴 시 "연출"을 로직 한복판에서 직접 만든다. ⚠️ Model-View 결합의 핵심 지점.
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
  -- love.audio.play(explosionSfx)  -- 사운드도 여기서 바로 재생(결합). 에셋 없어 주석.
end

function love.load()
  love.graphics.setBackgroundColor(0.02, 0.02, 0.06)
  math.randomseed(os.time()) -- ⚠️ 비결정적 시드. 같은 입력도 결과가 매번 달라짐 → 테스트 불가
  resetGame()
end

-- update: 입력·물리·충돌·연출·상태 전부 뒤섞여 있다. dt 를 그대로 적분(고정 스텝 없음).
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

  -- 플레이어 입력 + 이동
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

  -- 발사(쿨다운). 입력 해석과 총알 생성이 한 곳에.
  player.cooldown = player.cooldown - dt
  if love.keyboard.isDown("space") and player.cooldown <= 0 then
    bullets[#bullets + 1] = { x = player.x + player.w * 0.5 - 2, y = player.y, w = 4, h = 12 }
    player.cooldown = 0.25
  end

  -- 플레이어 총알 이동 + 화면 밖 제거
  for i = #bullets, 1, -1 do
    local b = bullets[i]
    b.y = b.y - BULLET_SPEED * dt
    if b.y + b.h < 0 then
      table.remove(bullets, i)
    end
  end

  -- 적 편대 이동(좌우로 흔들리다 끝에서 한 칸 내려옴)
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
      e.y = e.y + 16 -- 한 칸 하강
    end
  else
    for _, e in ipairs(enemies) do
      e.x = e.x + dx
    end
  end

  -- 적 발사(랜덤). 살아있는 적 중 하나를 골라 아래로 쏜다.
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
      enemyBullets[#enemyBullets + 1] =
        { x = e.x + e.w * 0.5 - 2, y = e.y + e.h, w = 4, h = 12 }
    end
  end

  -- 적 총알 이동 + 화면 밖 제거
  for i = #enemyBullets, 1, -1 do
    local b = enemyBullets[i]
    b.y = b.y + ENEMY_BULLET_SPEED * dt
    if b.y > 800 then
      table.remove(enemyBullets, i)
    end
  end

  -- 충돌: 플레이어 총알 × 적  (판정 + 점수 + 연출 + 사운드가 다 엉킴)
  for bi = #bullets, 1, -1 do
    local b = bullets[bi]
    for _, e in ipairs(enemies) do
      if e.alive and hit(b, e) then
        e.alive = false
        score = score + 100
        explode(e.x + e.w * 0.5, e.y + e.h * 0.5) -- ⚠️ 로직이 연출을 직접 호출
        table.remove(bullets, bi)
        break
      end
    end
  end

  -- 충돌: 적 총알 × 플레이어
  for i = #enemyBullets, 1, -1 do
    if hit(enemyBullets[i], player) then
      table.remove(enemyBullets, i)
      lives = lives - 1
      screenShake = 0.3 -- ⚠️ 또 연출 상태를 로직에서 직접 건드림
      if lives <= 0 then
        gameover = true
      end
    end
  end

  -- 파티클(순수 연출) 업데이트도 로직 루프에 섞여 있다
  for i = #particles, 1, -1 do
    local p = particles[i]
    p.x = p.x + p.vx * dt
    p.y = p.y + p.vy * dt
    p.life = p.life - dt
    if p.life <= 0 then
      table.remove(particles, i)
    end
  end

  -- 전멸 시 다음 편대
  local anyAlive = false
  for _, e in ipairs(enemies) do
    if e.alive then
      anyAlive = true
      break
    end
  end
  if not anyAlive then
    spawnFormation()
  end
end

function love.draw()
  -- 그리기 중에도 screenShake 같은 연출 상태를 읽어 흔든다.
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

  love.graphics.setColor(1, 1, 0.3)
  for _, b in ipairs(bullets) do
    love.graphics.rectangle("fill", b.x, b.y, b.w, b.h)
  end

  love.graphics.setColor(1, 0.4, 0.4)
  for _, e in ipairs(enemies) do
    if e.alive then
      love.graphics.rectangle("fill", e.x, e.y, e.w, e.h)
    end
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
    love.graphics.printf("GAME OVER\nPress R", 0, 380, 600, "center")
  end
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  elseif key == "r" and gameover then
    resetGame()
  end
end
