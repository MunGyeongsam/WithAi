# 15. 파티클 시스템

## love.graphics.newParticleSystem

LÖVE2D 내장 파티클 시스템으로 폭발, 연기, 불, 궤적 등을 표현한다.

```lua
local particles

function love.load()
    -- 파티클 이미지 (작은 원)
    local img_data = love.image.newImageData(8, 8)
    img_data:mapPixel(function(x, y)
        local cx, cy = 3.5, 3.5
        local d = math.sqrt((x - cx)^2 + (y - cy)^2) / 3.5
        local a = math.max(0, 1 - d)
        return 1, 1, 1, a
    end)
    local img = love.graphics.newImage(img_data)

    particles = love.graphics.newParticleSystem(img, 200)
    particles:setParticleLifetime(0.5, 1.5)
    particles:setEmissionRate(50)
    particles:setSpeed(50, 150)
    particles:setSpread(math.pi * 2)          -- 전 방향
    particles:setColors(1, 0.8, 0, 1,  1, 0.2, 0, 0)  -- 노랑 → 빨강 → 투명
    particles:setSizes(1.5, 0.5)
    particles:setLinearDamping(2)
end

function love.update(dt)
    particles:setPosition(love.mouse.getPosition())
    particles:update(dt)
end

function love.draw()
    love.graphics.draw(particles)
end
```

## 주요 설정 함수

| 함수 | 설명 |
|------|------|
| `setParticleLifetime(min, max)` | 각 파티클 수명 (초) |
| `setEmissionRate(n)` | 초당 생성 수 |
| `setEmissionArea(mode, w, h)` | 발생 영역 |
| `setSpeed(min, max)` | 초기 속도 |
| `setSpread(angle)` | 방출 각도 범위 |
| `setDirection(angle)` | 방출 방향 |
| `setSizes(s1, s2, ...)` | 수명에 따른 크기 변화 |
| `setColors(r,g,b,a, ...)` | 수명에 따른 색상 변화 |
| `setLinearAcceleration(xmin, ymin, xmax, ymax)` | 가속도 (중력 등) |
| `setLinearDamping(min, max)` | 감속 |
| `setRotation(min, max)` | 회전 |
| `setSpin(min, max)` | 회전 속도 |
| `setTangentialAcceleration(min, max)` | 접선 가속 |
| `setRadialAcceleration(min, max)` | 방사 가속 |

## emit() — 버스트 발사

```lua
-- 연속 발사 대신 한 번에 n개 발사
function explode(x, y)
    particles:setPosition(x, y)
    particles:emit(30)
end
```

## 프리셋 예제

### 불꽃

```lua
local function makeFirePS()
    local img = makeCircleImage(6)
    local ps = love.graphics.newParticleSystem(img, 300)
    ps:setParticleLifetime(0.3, 0.8)
    ps:setEmissionRate(80)
    ps:setSpeed(20, 80)
    ps:setDirection(-math.pi / 2)   -- 위로
    ps:setSpread(0.4)
    ps:setLinearAcceleration(-20, -100, 20, -50)
    ps:setSizes(2, 1, 0.3)
    ps:setColors(
        1, 0.9, 0.3, 1,
        1, 0.4, 0.1, 0.8,
        0.3, 0.1, 0.05, 0
    )
    return ps
end
```

### 연기

```lua
local function makeSmokePS()
    local img = makeCircleImage(8)
    local ps = love.graphics.newParticleSystem(img, 100)
    ps:setParticleLifetime(1, 3)
    ps:setEmissionRate(15)
    ps:setSpeed(10, 30)
    ps:setDirection(-math.pi / 2)
    ps:setSpread(0.5)
    ps:setSizes(1, 3, 4)
    ps:setColors(
        0.5, 0.5, 0.5, 0.4,
        0.3, 0.3, 0.3, 0.1,
        0.2, 0.2, 0.2, 0
    )
    ps:setLinearAcceleration(-10, -20, 10, -5)
    return ps
end
```

### 폭발

```lua
local function makeExplosionPS()
    local img = makeCircleImage(4)
    local ps = love.graphics.newParticleSystem(img, 100)
    ps:setParticleLifetime(0.2, 0.6)
    ps:setEmissionRate(0)   -- emit()으로만 발사
    ps:setSpeed(100, 400)
    ps:setSpread(math.pi * 2)
    ps:setSizes(2, 1, 0)
    ps:setColors(1, 1, 0.5, 1,  1, 0.3, 0, 0.5,  0.2, 0.1, 0.05, 0)
    ps:setLinearDamping(3)
    return ps
end
```

## 파티클 풀 매니저

여러 파티클 시스템을 관리한다.

```lua
-- particles_manager.lua
local M = {}
local systems = {}

function M.add(ps)
    systems[#systems + 1] = ps
end

function M.update(dt)
    for i = #systems, 1, -1 do
        systems[i]:update(dt)
        -- 멈추고 파티클도 없으면 제거
        if systems[i]:getCount() == 0 and systems[i]:isActive() == false then
            table.remove(systems, i)
        end
    end
end

function M.draw()
    love.graphics.setColor(1, 1, 1)
    for _, ps in ipairs(systems) do
        love.graphics.draw(ps)
    end
end

return M
```

## 실습: 불꽃놀이

```lua
-- main.lua
local fireworks = {}

local function makeCircleImage(radius)
    local size = radius * 2
    local data = love.image.newImageData(size, size)
    data:mapPixel(function(x, y)
        local cx, cy = radius - 0.5, radius - 0.5
        local d = math.sqrt((x - cx)^2 + (y - cy)^2) / radius
        local a = math.max(0, 1 - d * d)
        return 1, 1, 1, a
    end)
    return love.graphics.newImage(data)
end

local particle_img

function love.load()
    love.graphics.setBackgroundColor(0.02, 0.02, 0.05)
    particle_img = makeCircleImage(4)
end

local function spawnFirework(x, y)
    local ps = love.graphics.newParticleSystem(particle_img, 80)
    ps:setParticleLifetime(0.5, 1.2)
    ps:setSpeed(80, 250)
    ps:setSpread(math.pi * 2)
    ps:setLinearAcceleration(0, 50, 0, 100)
    ps:setLinearDamping(1.5)
    ps:setSizes(2.5, 1, 0)

    local r = 0.5 + math.random() * 0.5
    local g = 0.5 + math.random() * 0.5
    local b = 0.5 + math.random() * 0.5
    ps:setColors(r, g, b, 1,  r, g, b, 0.5,  r * 0.3, g * 0.3, b * 0.3, 0)

    ps:setPosition(x, y)
    ps:emit(60)
    ps:stop()

    fireworks[#fireworks + 1] = ps
end

function love.update(dt)
    for i = #fireworks, 1, -1 do
        fireworks[i]:update(dt)
        if fireworks[i]:getCount() == 0 then
            table.remove(fireworks, i)
        end
    end
end

function love.draw()
    for _, ps in ipairs(fireworks) do
        love.graphics.draw(ps)
    end

    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.printf("Click to launch fireworks", 0, 570, 800, "center")
    love.graphics.setColor(1, 1, 1)
end

function love.mousepressed(x, y, button)
    if button == 1 then spawnFirework(x, y) end
end

function love.keypressed(key)
    if key == "escape" then love.event.quit() end
end
```

## 다음 챕터

캔버스(오프스크린 렌더 타겟)를 사용하여 후처리 효과와 레이어 합성을 배운다.
