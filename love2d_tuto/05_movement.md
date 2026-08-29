# 05. 움직임과 델타 타임

## 기본 공식

```
새 위치 = 현재 위치 + 속도 × dt
새 속도 = 현재 속도 + 가속도 × dt
```

## 등속 이동

```lua
local x, y = 400, 300
local speed = 200   -- px/sec

function love.update(dt)
    if love.keyboard.isDown("d") then
        x = x + speed * dt
    end
end
```

## 가속 / 감속

```lua
local x = 400
local vx = 0
local accel = 600      -- 가속도 (px/sec²)
local friction = 0.92  -- 마찰 (매 프레임 속도에 곱)
local max_speed = 300

function love.update(dt)
    if love.keyboard.isDown("d") then
        vx = vx + accel * dt
    elseif love.keyboard.isDown("a") then
        vx = vx - accel * dt
    end

    -- 마찰 적용
    vx = vx * friction

    -- 최대 속도 제한
    if vx > max_speed then vx = max_speed end
    if vx < -max_speed then vx = -max_speed end

    -- 아주 작은 속도는 0으로 (떨림 방지)
    if math.abs(vx) < 0.5 then vx = 0 end

    x = x + vx * dt
end
```

## 8방향 이동 (대각선 보정)

대각선으로 이동하면 X, Y 동시 가속 → 속도가 √2배 빨라진다.
**정규화**로 해결한다.

```lua
local px, py = 400, 300
local speed = 200

function love.update(dt)
    local dx, dy = 0, 0

    if love.keyboard.isDown("w") then dy = dy - 1 end
    if love.keyboard.isDown("s") then dy = dy + 1 end
    if love.keyboard.isDown("a") then dx = dx - 1 end
    if love.keyboard.isDown("d") then dx = dx + 1 end

    -- 정규화: 방향 벡터의 길이를 1로 맞춤
    local len = math.sqrt(dx * dx + dy * dy)
    if len > 0 then
        dx = dx / len
        dy = dy / len
    end

    px = px + dx * speed * dt
    py = py + dy * speed * dt
end
```

## 화면 경계 처리

### 클램프 (벽에 막힘)

```lua
local radius = 15

function love.update(dt)
    -- 이동 후 경계 제한
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    px = math.max(radius, math.min(w - radius, px))
    py = math.max(radius, math.min(h - radius, py))
end
```

### 랩 (반대편에서 등장)

```lua
function love.update(dt)
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    if px < -radius then px = w + radius end
    if px > w + radius then px = -radius end
    if py < -radius then py = h + radius end
    if py > h + radius then py = -radius end
end
```

### 반사 (바운스)

```lua
function love.update(dt)
    px = px + vx * dt
    py = py + vy * dt

    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    if px - radius < 0 then
        px = radius
        vx = -vx
    elseif px + radius > w then
        px = w - radius
        vx = -vx
    end

    if py - radius < 0 then
        py = radius
        vy = -vy
    elseif py + radius > h then
        py = h - radius
        vy = -vy
    end
end
```

## 보간 (Lerp)

부드러운 따라가기(카메라, 적 AI 등)에 사용한다.

```lua
local function lerp(a, b, t)
    return a + (b - a) * t
end

function love.update(dt)
    local mx, my = love.mouse.getPosition()
    -- 매 프레임 목표 지점의 10% 만큼 이동 → 부드러운 감속
    local smooth = 1 - math.exp(-5 * dt)   -- dt 독립적 smoothing
    px = lerp(px, mx, smooth)
    py = lerp(py, my, smooth)
end
```

> `1 - math.exp(-speed * dt)` 형태가 프레임률에 독립적인 lerp 공식이다.
> 단순히 `lerp(a, b, 0.1)`은 60fps와 30fps에서 다르게 동작한다.

## 실습: 우주선 관성 이동

```lua
-- main.lua
local ship_x, ship_y
local vx, vy
local thrust
local friction
local radius

function love.load()
    love.graphics.setBackgroundColor(0.02, 0.02, 0.08)
    ship_x = 400
    ship_y = 300
    vx = 0
    vy = 0
    thrust = 400
    friction = 0.98
    radius = 12
end

function love.update(dt)
    local dx, dy = 0, 0
    if love.keyboard.isDown("w") then dy = -1 end
    if love.keyboard.isDown("s") then dy =  1 end
    if love.keyboard.isDown("a") then dx = -1 end
    if love.keyboard.isDown("d") then dx =  1 end

    vx = vx + dx * thrust * dt
    vy = vy + dy * thrust * dt

    vx = vx * friction
    vy = vy * friction

    ship_x = ship_x + vx * dt
    ship_y = ship_y + vy * dt

    -- 랩
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    if ship_x < -radius then ship_x = w + radius end
    if ship_x > w + radius then ship_x = -radius end
    if ship_y < -radius then ship_y = h + radius end
    if ship_y > h + radius then ship_y = -radius end
end

function love.draw()
    -- 속도 표시 선
    love.graphics.setColor(0.3, 0.3, 0.5)
    love.graphics.line(ship_x, ship_y, ship_x + vx * 0.3, ship_y + vy * 0.3)

    -- 우주선
    love.graphics.setColor(0.4, 0.9, 1)
    love.graphics.circle("fill", ship_x, ship_y, radius)

    -- HUD
    love.graphics.setColor(1, 1, 1)
    local spd = math.sqrt(vx * vx + vy * vy)
    love.graphics.print(string.format("Speed: %.0f", spd), 10, 10)
    love.graphics.print("WASD to move", 10, 30)
end

function love.keypressed(key)
    if key == "escape" then love.event.quit() end
end
```

## 다음 챕터

이미지 파일을 로드하고 화면에 그리는 방법을 배운다.
