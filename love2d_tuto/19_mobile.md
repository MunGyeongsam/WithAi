# 19. 터치 입력 & 모바일

## 터치 콜백

```lua
function love.touchpressed(id, x, y, dx, dy, pressure)
    -- id: 고유 터치 식별자 (멀티터치 구분)
    -- x, y: 터치 위치
    -- pressure: 압력 (0~1, 지원 기기에서만)
end

function love.touchreleased(id, x, y, dx, dy, pressure)
end

function love.touchmoved(id, x, y, dx, dy, pressure)
    -- dx, dy: 이전 위치로부터의 변화량
end
```

## 활성 터치 목록

```lua
function love.update(dt)
    local touches = love.touch.getTouches()
    for _, id in ipairs(touches) do
        local x, y = love.touch.getPosition(id)
        -- 각 터치 위치 처리
    end
end
```

## 마우스와 터치 통합

데스크톱(마우스)과 모바일(터치)을 동시 지원하려면 추상 레이어를 만든다.

```lua
-- input_unified.lua
local M = {}

local pointers = {}   -- {[id] = {x, y, pressed, just_pressed, just_released}}

function M.getPointers()
    return pointers
end

function M.getFirstPointer()
    for _, p in pairs(pointers) do
        if p.pressed then return p end
    end
    return nil
end

-- 콜백 연결 (main.lua에서 호출)
function M.touchpressed(id, x, y)
    pointers[id] = {x = x, y = y, pressed = true, just_pressed = true, just_released = false}
end

function M.touchmoved(id, x, y)
    if pointers[id] then
        pointers[id].x = x
        pointers[id].y = y
    end
end

function M.touchreleased(id, x, y)
    if pointers[id] then
        pointers[id].pressed = false
        pointers[id].just_released = true
    end
end

function M.mousepressed(x, y, button)
    if button == 1 then
        pointers["mouse"] = {x = x, y = y, pressed = true, just_pressed = true, just_released = false}
    end
end

function M.mousemoved(x, y)
    if pointers["mouse"] and pointers["mouse"].pressed then
        pointers["mouse"].x = x
        pointers["mouse"].y = y
    end
end

function M.mousereleased(x, y, button)
    if button == 1 and pointers["mouse"] then
        pointers["mouse"].pressed = false
        pointers["mouse"].just_released = true
    end
end

function M.endFrame()
    for id, p in pairs(pointers) do
        p.just_pressed = false
        if p.just_released then
            pointers[id] = nil
        end
    end
end

return M
```

## 가상 조이스틱

```lua
-- virtual_joystick.lua
local M = {}
M.__index = M

function M.new(x, y, radius)
    return setmetatable({
        base_x = x,
        base_y = y,
        radius = radius,
        knob_x = x,
        knob_y = y,
        active_id = nil,
        dx = 0,
        dy = 0,
    }, M)
end

function M:touchpressed(id, tx, ty)
    local dist = math.sqrt((tx - self.base_x)^2 + (ty - self.base_y)^2)
    if dist < self.radius * 1.5 and not self.active_id then
        self.active_id = id
        self:updateKnob(tx, ty)
    end
end

function M:touchmoved(id, tx, ty)
    if id == self.active_id then
        self:updateKnob(tx, ty)
    end
end

function M:touchreleased(id)
    if id == self.active_id then
        self.active_id = nil
        self.knob_x = self.base_x
        self.knob_y = self.base_y
        self.dx = 0
        self.dy = 0
    end
end

function M:updateKnob(tx, ty)
    local dx = tx - self.base_x
    local dy = ty - self.base_y
    local dist = math.sqrt(dx * dx + dy * dy)
    if dist > self.radius then
        dx = dx / dist * self.radius
        dy = dy / dist * self.radius
    end
    self.knob_x = self.base_x + dx
    self.knob_y = self.base_y + dy
    self.dx = dx / self.radius
    self.dy = dy / self.radius
end

function M:draw()
    -- 베이스
    love.graphics.setColor(1, 1, 1, 0.2)
    love.graphics.circle("fill", self.base_x, self.base_y, self.radius)
    love.graphics.setColor(1, 1, 1, 0.4)
    love.graphics.circle("line", self.base_x, self.base_y, self.radius)
    -- 노브
    love.graphics.setColor(1, 1, 1, 0.6)
    love.graphics.circle("fill", self.knob_x, self.knob_y, self.radius * 0.4)
    love.graphics.setColor(1, 1, 1)
end

return M
```

## 화면 비율 대응

모바일 기기마다 해상도와 비율이 다르다. 가상 해상도를 사용한다.

```lua
local VIRTUAL_W = 480
local VIRTUAL_H = 800   -- 세로 모바일 기준
local scale_x, scale_y, offset_x, offset_y

function love.load()
    updateScale()
end

function love.resize(w, h)
    updateScale()
end

local function updateScale()
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    local s = math.min(w / VIRTUAL_W, h / VIRTUAL_H)
    scale_x = s
    scale_y = s
    offset_x = (w - VIRTUAL_W * s) / 2
    offset_y = (h - VIRTUAL_H * s) / 2
end

-- 화면 터치 좌표 → 가상 좌표 변환
local function screenToVirtual(sx, sy)
    local vx = (sx - offset_x) / scale_x
    local vy = (sy - offset_y) / scale_y
    return vx, vy
end

function love.draw()
    love.graphics.push()
    love.graphics.translate(offset_x, offset_y)
    love.graphics.scale(scale_x, scale_y)

    -- 가상 해상도 기준으로 그리기 (480×800)
    drawGame()

    love.graphics.pop()
end
```

## conf.lua 모바일 설정

```lua
function love.conf(t)
    t.window.title = "Mobile Game"
    t.window.width = 480
    t.window.height = 800
    t.window.resizable = true

    -- 모바일 빌드 시
    t.window.fullscreen = true
    t.window.fullscreentype = "desktop"

    -- 세로 고정 (Android)
    t.window.usedpiscale = true
end
```

## Safe Area (노치 대응)

```lua
function love.load()
    -- LÖVE 11.4+ 에서 safe area 확인
    if love.window.getSafeArea then
        local x, y, w, h = love.window.getSafeArea()
        -- UI 요소를 safe area 안에 배치
    end
end
```

## 실습: 터치 이동 + 버튼

```lua
-- main.lua
local player = {x = 240, y = 600, speed = 300, radius = 20}
local joystick_radius = 60
local joy_base = {x = 100, y = 700}
local joy_knob = {x = 100, y = 700}
local joy_id = nil
local joy_dx, joy_dy = 0, 0

function love.load()
    love.graphics.setBackgroundColor(0.08, 0.08, 0.12)
end

function love.update(dt)
    player.x = player.x + joy_dx * player.speed * dt
    player.y = player.y + joy_dy * player.speed * dt
    player.x = math.max(player.radius, math.min(480 - player.radius, player.x))
    player.y = math.max(player.radius, math.min(800 - player.radius, player.y))
end

function love.draw()
    -- 플레이어
    love.graphics.setColor(0.3, 0.85, 1)
    love.graphics.circle("fill", player.x, player.y, player.radius)

    -- 조이스틱
    love.graphics.setColor(1, 1, 1, 0.2)
    love.graphics.circle("fill", joy_base.x, joy_base.y, joystick_radius)
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.circle("fill", joy_knob.x, joy_knob.y, 25)

    -- HUD
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Touch left side: joystick", 10, 10)
    love.graphics.print("Or use WASD", 10, 30)
end

function love.touchpressed(id, x, y)
    if x < 240 and not joy_id then
        joy_id = id
        updateJoystick(x, y)
    end
end

function love.touchmoved(id, x, y)
    if id == joy_id then updateJoystick(x, y) end
end

function love.touchreleased(id)
    if id == joy_id then
        joy_id = nil
        joy_knob.x = joy_base.x
        joy_knob.y = joy_base.y
        joy_dx, joy_dy = 0, 0
    end
end

local function updateJoystick(tx, ty)
    local dx = tx - joy_base.x
    local dy = ty - joy_base.y
    local dist = math.sqrt(dx * dx + dy * dy)
    if dist > joystick_radius then
        dx = dx / dist * joystick_radius
        dy = dy / dist * joystick_radius
    end
    joy_knob.x = joy_base.x + dx
    joy_knob.y = joy_base.y + dy
    joy_dx = dx / joystick_radius
    joy_dy = dy / joystick_radius
end

-- 키보드 폴백 (데스크톱 테스트)
function love.update(dt)
    local kdx, kdy = 0, 0
    if love.keyboard.isDown("a") then kdx = -1 end
    if love.keyboard.isDown("d") then kdx =  1 end
    if love.keyboard.isDown("w") then kdy = -1 end
    if love.keyboard.isDown("s") then kdy =  1 end
    local final_dx = joy_dx + kdx
    local final_dy = joy_dy + kdy
    player.x = player.x + final_dx * player.speed * dt
    player.y = player.y + final_dy * player.speed * dt
    player.x = math.max(player.radius, math.min(480 - player.radius, player.x))
    player.y = math.max(player.radius, math.min(800 - player.radius, player.y))
end

function love.keypressed(key)
    if key == "escape" then love.event.quit() end
end
```

## 다음 챕터

게임 성능을 측정하고 최적화하는 기법을 배운다.
