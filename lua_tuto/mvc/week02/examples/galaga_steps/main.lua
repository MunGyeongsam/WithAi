-- main.lua
-- 겔러그(모놀리식). 2주차 "고통 체감"용 **의도적 안티패턴**.
-- 입력·이동·적 패턴·탄막·충돌·렌더·이펙트·상태를 한 파일에 전부 몰아넣었다.
-- ⚠️ 이 구조를 따라 하지 말 것. 3~4주차에 이걸 MVC로 분해한다.
--
-- 조작: ←/→ 이동, Space 발사, R 재시작, Esc 종료.

-- 파일 전역 상태 덩어리(모놀리식의 전형). 모든 게 여기 뒤섞여 산다.
local player
local bullets = {}

-- 매직 넘버가 여기저기 흩어진다. 일부는 여기, 일부는 코드 속에 인라인.
local PLAYER_SPEED = 320
local BULLET_SPEED = 520

local function resetGame()
  player = { x = 300 - 20, y = 740, w = 40, h = 24, cooldown = 0 }
  bullets = {}
end

function love.load()
  love.graphics.setBackgroundColor(0.02, 0.02, 0.06)
  resetGame()
end

-- update: 입력·물리·충돌·연출·상태 전부 뒤섞여 있다. dt 를 그대로 적분(고정 스텝 없음).
function love.update(dt)
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
end

function love.draw()
  love.graphics.setColor(0.4, 0.9, 1)
  love.graphics.rectangle("fill", player.x, player.y, player.w, player.h)

  love.graphics.setColor(1, 1, 0.3)
  for _, b in ipairs(bullets) do
    love.graphics.rectangle("fill", b.x, b.y, b.w, b.h)
  end
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end
