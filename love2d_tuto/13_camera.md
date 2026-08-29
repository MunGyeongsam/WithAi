# 13. 카메라 & 뷰포트

## 카메라 = translate의 역변환

LÖVE2D에 내장 카메라는 없다. `love.graphics.translate()`로 직접 구현한다.

```lua
-- 카메라가 (cam_x, cam_y)를 바라보면,
-- 모든 오브젝트를 (-cam_x, -cam_y)만큼 이동시킨다.
local cam_x, cam_y = 0, 0

function love.draw()
    love.graphics.push()
    love.graphics.translate(-cam_x, -cam_y)

    -- 월드 공간 그리기
    drawWorld()

    love.graphics.pop()

    -- UI는 카메라 영향 밖에서 그린다
    drawHUD()
end
```

## 카메라 모듈

```lua
-- camera.lua
local M = {}
M.__index = M

function M.new(x, y)
    return setmetatable({
        x = x or 0,
        y = y or 0,
        scale = 1,
        rotation = 0,
    }, M)
end

function M:attach()
    love.graphics.push()
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    love.graphics.translate(w / 2, h / 2)
    love.graphics.scale(self.scale)
    love.graphics.rotate(self.rotation)
    love.graphics.translate(-self.x, -self.y)
end

function M:detach()
    love.graphics.pop()
end

function M:lookAt(x, y)
    self.x = x
    self.y = y
end

function M:setZoom(z)
    self.scale = z
end

-- 화면 좌표 → 월드 좌표 변환
function M:screenToWorld(sx, sy)
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    local wx = (sx - w / 2) / self.scale + self.x
    local wy = (sy - h / 2) / self.scale + self.y
    return wx, wy
end

-- 월드 좌표 → 화면 좌표 변환
function M:worldToScreen(wx, wy)
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    local sx = (wx - self.x) * self.scale + w / 2
    local sy = (wy - self.y) * self.scale + h / 2
    return sx, sy
end

return M
```

### 사용

```lua
local Camera = require("camera")
local cam

function love.load()
    cam = Camera.new(400, 300)
end

function love.draw()
    cam:attach()
    drawWorld()
    cam:detach()
    drawHUD()
end
```

## 플레이어 추적

```lua
function love.update(dt)
    updatePlayer(dt)

    -- 즉시 추적
    cam:lookAt(player.x, player.y)
end
```

### 부드러운 추적 (Lerp)

```lua
function love.update(dt)
    updatePlayer(dt)

    local smooth = 1 - math.exp(-5 * dt)
    cam.x = cam.x + (player.x - cam.x) * smooth
    cam.y = cam.y + (player.y - cam.y) * smooth
end
```

### 데드존 (Dead Zone)

플레이어가 화면 중앙 근처에 있으면 카메라를 움직이지 않는다.

```lua
local dead_zone = 50

function love.update(dt)
    local dx = player.x - cam.x
    local dy = player.y - cam.y

    if math.abs(dx) > dead_zone then
        cam.x = cam.x + (dx - dead_zone * (dx > 0 and 1 or -1)) * 5 * dt
    end
    if math.abs(dy) > dead_zone then
        cam.y = cam.y + (dy - dead_zone * (dy > 0 and 1 or -1)) * 5 * dt
    end
end
```

## 카메라 경계 제한 (Clamping)

맵 바깥이 보이지 않도록 카메라를 제한한다.

```lua
local function clampCamera(cam, map_w, map_h)
    local hw = love.graphics.getWidth() / 2 / cam.scale
    local hh = love.graphics.getHeight() / 2 / cam.scale

    cam.x = math.max(hw, math.min(map_w - hw, cam.x))
    cam.y = math.max(hh, math.min(map_h - hh, cam.y))
end
```

## 줌 (확대/축소)

```lua
function love.wheelmoved(x, y)
    if y > 0 then
        cam.scale = math.min(4, cam.scale * 1.1)
    elseif y < 0 then
        cam.scale = math.max(0.25, cam.scale / 1.1)
    end
end
```

## 화면 흔들기 (Screen Shake)

```lua
local shake_amount = 0
local shake_decay = 5

local function startShake(amount)
    shake_amount = amount
end

function love.update(dt)
    shake_amount = math.max(0, shake_amount - shake_decay * dt)
end

function love.draw()
    local ox = (math.random() - 0.5) * 2 * shake_amount
    local oy = (math.random() - 0.5) * 2 * shake_amount

    love.graphics.push()
    love.graphics.translate(-cam.x + ox, -cam.y + oy)
    drawWorld()
    love.graphics.pop()
end
```

## 실습: 스크롤 맵 탐험

```lua
-- main.lua
local cam_x, cam_y = 0, 0
local player = {x = 200, y = 200, speed = 200, radius = 12}
local map_w, map_h = 2000, 1500
local trees = {}
local shake = 0

function love.load()
    love.graphics.setBackgroundColor(0.15, 0.35, 0.15)
    math.randomseed(os.time())
    for i = 1, 80 do
        trees[i] = {
            x = math.random(50, map_w - 50),
            y = math.random(50, map_h - 50),
            size = math.random(15, 35),
        }
    end
end

function love.update(dt)
    local dx, dy = 0, 0
    if love.keyboard.isDown("w") then dy = -1 end
    if love.keyboard.isDown("s") then dy =  1 end
    if love.keyboard.isDown("a") then dx = -1 end
    if love.keyboard.isDown("d") then dx =  1 end
    local len = math.sqrt(dx * dx + dy * dy)
    if len > 0 then dx, dy = dx / len, dy / len end

    player.x = player.x + dx * player.speed * dt
    player.y = player.y + dy * player.speed * dt
    player.x = math.max(0, math.min(map_w, player.x))
    player.y = math.max(0, math.min(map_h, player.y))

    -- 부드러운 카메라 추적
    local smooth = 1 - math.exp(-4 * dt)
    cam_x = cam_x + (player.x - cam_x) * smooth
    cam_y = cam_y + (player.y - cam_y) * smooth

    -- 카메라 경계
    local hw = love.graphics.getWidth() / 2
    local hh = love.graphics.getHeight() / 2
    cam_x = math.max(hw, math.min(map_w - hw, cam_x))
    cam_y = math.max(hh, math.min(map_h - hh, cam_y))

    -- 흔들기 감쇠
    shake = math.max(0, shake - 8 * dt)
end

function love.draw()
    local ox = (math.random() - 0.5) * 2 * shake
    local oy = (math.random() - 0.5) * 2 * shake

    love.graphics.push()
    local hw = love.graphics.getWidth() / 2
    local hh = love.graphics.getHeight() / 2
    love.graphics.translate(hw - cam_x + ox, hh - cam_y + oy)

    -- 맵 경계
    love.graphics.setColor(0.1, 0.25, 0.1)
    love.graphics.rectangle("fill", 0, 0, map_w, map_h)
    love.graphics.setColor(0.6, 0.4, 0.2)
    love.graphics.rectangle("line", 0, 0, map_w, map_h)

    -- 나무
    for _, t in ipairs(trees) do
        love.graphics.setColor(0.2, 0.5, 0.15)
        love.graphics.circle("fill", t.x, t.y, t.size)
        love.graphics.setColor(0.1, 0.35, 0.1)
        love.graphics.circle("line", t.x, t.y, t.size)
    end

    -- 플레이어
    love.graphics.setColor(0.3, 0.8, 1)
    love.graphics.circle("fill", player.x, player.y, player.radius)

    love.graphics.pop()

    -- HUD (카메라 밖)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(string.format("Pos: %.0f, %.0f", player.x, player.y), 10, 10)
    love.graphics.print("WASD: move / Space: shake", 10, 30)
end

function love.keypressed(key)
    if key == "space" then shake = 8 end
    if key == "escape" then love.event.quit() end
end
```

## 다음 챕터

LÖVE2D 내장 Box2D 물리 엔진을 사용하여 현실적인 물리 시뮬레이션을 구현한다.
