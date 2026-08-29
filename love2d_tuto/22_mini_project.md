# 22. 미니 프로젝트 — Asteroid Dodge

> 전체 강좌를 통합하여 만드는 세로 스크롤 회피 게임.
> 이미지 없이 도형만으로 완성한다 (Zero-Art).

## 사용되는 챕터 기술

| 기술 | 챕터 |
|------|------|
| 게임 루프, dt | Ch.02 |
| 도형 그리기 | Ch.03 |
| 키보드/마우스 입력 | Ch.04 |
| 가속/감속 이동 | Ch.05 |
| 애니메이션 (깜빡임) | Ch.07 |
| 텍스트/점수 표시 | Ch.08 |
| 씬 관리 | Ch.10 |
| 충돌 처리 | Ch.11 |
| 카메라 흔들기 | Ch.13 |
| 파티클 | Ch.15 |
| 캔버스 (글로우) | Ch.16 |
| 저장/불러오기 | Ch.18 |

## 프로젝트 구조

```
asteroid_dodge/
├── main.lua
├── conf.lua
├── scenes/
│   ├── menu.lua
│   ├── game.lua
│   └── gameover.lua
├── lib/
│   ├── particles.lua
│   └── save.lua
└── README.md
```

## conf.lua

```lua
function love.conf(t)
    t.window.title = "Asteroid Dodge"
    t.window.width = 480
    t.window.height = 720
    t.window.vsync = 1
    t.identity = "asteroid_dodge"
    t.version = "11.5"
    t.modules.physics = false
    t.modules.joystick = false
end
```

## main.lua

```lua
local scene
local scenes = {}

local function switchScene(name, ...)
    if scene and scene.exit then scene.exit() end
    scene = scenes[name]
    if scene and scene.enter then scene.enter(...) end
end

-- 전역 접근용
_G.switchScene = switchScene

function love.load()
    love.graphics.setBackgroundColor(0.02, 0.02, 0.06)
    math.randomseed(os.time())

    scenes.menu     = require("scenes.menu")
    scenes.game     = require("scenes.game")
    scenes.gameover = require("scenes.gameover")

    switchScene("menu")
end

function love.update(dt)
    if scene and scene.update then scene.update(dt) end
end

function love.draw()
    if scene and scene.draw then scene.draw() end
end

function love.keypressed(key)
    if scene and scene.keypressed then scene.keypressed(key) end
end

function love.touchpressed(id, x, y)
    if scene and scene.touchpressed then scene.touchpressed(id, x, y) end
end

function love.touchmoved(id, x, y)
    if scene and scene.touchmoved then scene.touchmoved(id, x, y) end
end

function love.touchreleased(id, x, y)
    if scene and scene.touchreleased then scene.touchreleased(id, x, y) end
end
```

## scenes/menu.lua

```lua
local M = {}

local blink_timer = 0
local show_text = true

function M.enter()
    blink_timer = 0
    show_text = true
end

function M.update(dt)
    blink_timer = blink_timer + dt
    if blink_timer > 0.6 then
        blink_timer = 0
        show_text = not show_text
    end
end

function M.draw()
    love.graphics.setColor(0.8, 0.9, 1)
    love.graphics.printf("ASTEROID DODGE", 0, 200, 480, "center")

    if show_text then
        love.graphics.setColor(0.6, 0.6, 0.8)
        love.graphics.printf("Press ENTER or TAP to start", 0, 400, 480, "center")
    end

    love.graphics.setColor(0.4, 0.4, 0.5)
    love.graphics.printf("WASD / Touch to move\nDodge the asteroids!", 0, 500, 480, "center")
    love.graphics.setColor(1, 1, 1)
end

function M.keypressed(key)
    if key == "return" or key == "space" then
        switchScene("game")
    end
    if key == "escape" then love.event.quit() end
end

function M.touchpressed()
    switchScene("game")
end

return M
```

## scenes/game.lua

```lua
local M = {}

local player
local asteroids
local particles
local score
local speed_mult
local shake
local alive
local spawn_timer
local difficulty_timer

-- 파티클 이미지 (원)
local particle_img

local function makeParticleImage()
    local data = love.image.newImageData(6, 6)
    data:mapPixel(function(x, y)
        local d = math.sqrt((x - 2.5)^2 + (y - 2.5)^2) / 2.5
        return 1, 1, 1, math.max(0, 1 - d)
    end)
    return love.graphics.newImage(data)
end

local explosion_systems = {}

local function spawnExplosion(x, y)
    local ps = love.graphics.newParticleSystem(particle_img, 40)
    ps:setParticleLifetime(0.3, 0.7)
    ps:setSpeed(80, 200)
    ps:setSpread(math.pi * 2)
    ps:setSizes(2, 0.5)
    ps:setColors(1, 0.8, 0.2, 1,  1, 0.3, 0.1, 0)
    ps:setLinearDamping(2)
    ps:setPosition(x, y)
    ps:emit(25)
    ps:stop()
    explosion_systems[#explosion_systems + 1] = ps
end

function M.enter()
    particle_img = particle_img or makeParticleImage()
    player = {x = 240, y = 600, radius = 12, vx = 0}
    asteroids = {}
    explosion_systems = {}
    score = 0
    speed_mult = 1.0
    shake = 0
    alive = true
    spawn_timer = 0
    difficulty_timer = 0
end

local function spawnAsteroid()
    asteroids[#asteroids + 1] = {
        x = math.random(30, 450),
        y = -30,
        radius = math.random(10, 25),
        speed = math.random(150, 250) * speed_mult,
        rot = math.random() * math.pi * 2,
        rot_speed = (math.random() - 0.5) * 4,
    }
end

function M.update(dt)
    if not alive then return end

    score = score + dt * 10 * speed_mult
    difficulty_timer = difficulty_timer + dt
    if difficulty_timer > 5 then
        difficulty_timer = 0
        speed_mult = speed_mult + 0.1
    end

    -- 입력
    local target_vx = 0
    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then target_vx = -350 end
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then target_vx = 350 end

    local smooth = 1 - math.exp(-10 * dt)
    player.vx = player.vx + (target_vx - player.vx) * smooth
    player.x = player.x + player.vx * dt
    player.x = math.max(player.radius, math.min(480 - player.radius, player.x))

    -- 스폰
    spawn_timer = spawn_timer + dt
    local spawn_interval = math.max(0.2, 0.6 - speed_mult * 0.05)
    if spawn_timer > spawn_interval then
        spawn_timer = 0
        spawnAsteroid()
    end

    -- 소행성 업데이트
    for i = #asteroids, 1, -1 do
        local a = asteroids[i]
        a.y = a.y + a.speed * dt
        a.rot = a.rot + a.rot_speed * dt

        if a.y > 750 then
            table.remove(asteroids, i)
        else
            -- 충돌
            local dx = player.x - a.x
            local dy = player.y - a.y
            if dx * dx + dy * dy < (player.radius + a.radius)^2 then
                alive = false
                shake = 12
                spawnExplosion(player.x, player.y)
            end
        end
    end

    -- 흔들기 감쇠
    shake = math.max(0, shake - 20 * dt)

    -- 파티클
    for i = #explosion_systems, 1, -1 do
        explosion_systems[i]:update(dt)
        if explosion_systems[i]:getCount() == 0 then
            table.remove(explosion_systems, i)
        end
    end

    if not alive then
        -- 잠시 후 게임오버
        -- (간단히 즉시 전환)
        switchScene("gameover", math.floor(score))
    end
end

function M.draw()
    local ox = (math.random() - 0.5) * 2 * shake
    local oy = (math.random() - 0.5) * 2 * shake
    love.graphics.push()
    love.graphics.translate(ox, oy)

    -- 소행성
    for _, a in ipairs(asteroids) do
        love.graphics.push()
        love.graphics.translate(a.x, a.y)
        love.graphics.rotate(a.rot)
        love.graphics.setColor(0.5, 0.45, 0.4)
        love.graphics.circle("fill", 0, 0, a.radius, 7)
        love.graphics.setColor(0.7, 0.6, 0.5)
        love.graphics.circle("line", 0, 0, a.radius, 7)
        love.graphics.pop()
    end

    -- 플레이어
    if alive then
        love.graphics.setColor(0.3, 0.85, 1)
        love.graphics.circle("fill", player.x, player.y, player.radius)
        love.graphics.setColor(0.5, 0.95, 1)
        love.graphics.circle("line", player.x, player.y, player.radius + 2)
    end

    -- 파티클
    love.graphics.setColor(1, 1, 1)
    for _, ps in ipairs(explosion_systems) do
        love.graphics.draw(ps)
    end

    love.graphics.pop()

    -- HUD
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(string.format("Score: %d", math.floor(score)), 10, 10)
    love.graphics.print(string.format("Speed: x%.1f", speed_mult), 10, 30)
end

function M.keypressed(key)
    if key == "escape" then switchScene("menu") end
end

-- 터치 지원 (좌/우 영역)
function M.touchpressed(id, x, y)
    if x < 240 then
        player.vx = -350
    else
        player.vx = 350
    end
end

function M.touchreleased()
    player.vx = 0
end

return M
```

## scenes/gameover.lua

```lua
local M = {}

local final_score = 0
local high_score = 0
local SAVE_FILE = "highscore.txt"

local function loadHighScore()
    local content = love.filesystem.read(SAVE_FILE)
    if content then return tonumber(content) or 0 end
    return 0
end

local function saveHighScore(score)
    love.filesystem.write(SAVE_FILE, tostring(score))
end

function M.enter(score)
    final_score = score or 0
    high_score = loadHighScore()
    if final_score > high_score then
        high_score = final_score
        saveHighScore(high_score)
    end
end

function M.update(dt) end

function M.draw()
    love.graphics.setColor(1, 0.3, 0.3)
    love.graphics.printf("GAME OVER", 0, 200, 480, "center")

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Score: " .. final_score, 0, 300, 480, "center")

    love.graphics.setColor(1, 0.85, 0)
    love.graphics.printf("Best: " .. high_score, 0, 340, 480, "center")

    love.graphics.setColor(0.6, 0.6, 0.8)
    love.graphics.printf("ENTER / TAP to retry\nESC for menu", 0, 450, 480, "center")
    love.graphics.setColor(1, 1, 1)
end

function M.keypressed(key)
    if key == "return" or key == "space" then switchScene("game") end
    if key == "escape" then switchScene("menu") end
end

function M.touchpressed()
    switchScene("game")
end

return M
```

## 확장 아이디어

- [ ] 파워업 아이템 (쉴드, 슬로우 타임)
- [ ] 소행성 파괴 (총알 발사)
- [ ] 배경 별 파티클 (시차 스크롤)
- [ ] 셰이더 (CRT 효과, 글로우)
- [ ] 사운드 (충돌, BGM)
- [ ] 모바일 빌드 (.apk)

## 마무리

이 프로젝트를 기반으로 자유롭게 확장하면서 LÖVE2D 실력을 키우자.
강좌에서 배운 기법을 하나씩 적용해보는 것이 가장 좋은 학습법이다.
