# 07. 스프라이트 애니메이션

## 기본 원리

스프라이트 시트의 프레임을 일정 간격으로 전환한다.

```
시간 ───────────────────────────→
프레임: [0] [1] [2] [3] [0] [1] [2] [3] ...
```

## 수동 애니메이션

```lua
local sheet, quads
local frame, timer
local frame_duration

function love.load()
    sheet = love.graphics.newImage("assets/walk.png")
    sheet:setFilter("nearest", "nearest")

    local fw, fh = 32, 32
    local sw, sh = sheet:getWidth(), sheet:getHeight()
    local cols = math.floor(sw / fw)

    quads = {}
    for i = 0, cols - 1 do
        quads[#quads + 1] = love.graphics.newQuad(
            i * fw, 0, fw, fh, sw, sh
        )
    end

    frame = 1
    timer = 0
    frame_duration = 0.1   -- 10 FPS 애니메이션
end

function love.update(dt)
    timer = timer + dt
    if timer >= frame_duration then
        timer = timer - frame_duration
        frame = (frame % #quads) + 1
    end
end

function love.draw()
    love.graphics.draw(sheet, quads[frame], 400, 300, 0, 4, 4)
end
```

## 애니메이션 모듈

재사용 가능한 애니메이션 객체를 만든다.

```lua
-- anim.lua
local Anim = {}
Anim.__index = Anim

function Anim.new(sheet, frame_w, frame_h, row, count, duration)
    local sw, sh = sheet:getWidth(), sheet:getHeight()
    local quads = {}
    for i = 0, count - 1 do
        quads[#quads + 1] = love.graphics.newQuad(
            i * frame_w, row * frame_h,
            frame_w, frame_h, sw, sh
        )
    end

    return setmetatable({
        sheet = sheet,
        quads = quads,
        frame = 1,
        timer = 0,
        duration = duration or 0.1,
        playing = true,
        looping = true,
    }, Anim)
end

function Anim:update(dt)
    if not self.playing then return end

    self.timer = self.timer + dt
    if self.timer >= self.duration then
        self.timer = self.timer - self.duration
        self.frame = self.frame + 1
        if self.frame > #self.quads then
            if self.looping then
                self.frame = 1
            else
                self.frame = #self.quads
                self.playing = false
            end
        end
    end
end

function Anim:draw(x, y, r, sx, sy, ox, oy)
    love.graphics.draw(
        self.sheet, self.quads[self.frame],
        x, y, r or 0, sx or 1, sy or 1, ox or 0, oy or 0
    )
end

function Anim:reset()
    self.frame = 1
    self.timer = 0
    self.playing = true
end

function Anim:setLooping(loop)
    self.looping = loop
end

return Anim
```

### 사용

```lua
local Anim = require("anim")
local walk_anim

function love.load()
    local sheet = love.graphics.newImage("assets/character.png")
    sheet:setFilter("nearest", "nearest")
    walk_anim = Anim.new(sheet, 32, 32, 0, 4, 0.12)
end

function love.update(dt)
    walk_anim:update(dt)
end

function love.draw()
    walk_anim:draw(400, 300, 0, 3, 3, 16, 16)
end
```

## 여러 애니메이션 전환

```lua
local anims = {}
local current_anim

function love.load()
    local sheet = love.graphics.newImage("assets/character.png")
    sheet:setFilter("nearest", "nearest")

    anims.idle  = Anim.new(sheet, 32, 32, 0, 2, 0.5)
    anims.walk  = Anim.new(sheet, 32, 32, 1, 4, 0.1)
    anims.jump  = Anim.new(sheet, 32, 32, 2, 2, 0.15)

    current_anim = anims.idle
end

local function switchAnim(name)
    if current_anim ~= anims[name] then
        current_anim = anims[name]
        current_anim:reset()
    end
end

function love.update(dt)
    if love.keyboard.isDown("d") or love.keyboard.isDown("a") then
        switchAnim("walk")
    else
        switchAnim("idle")
    end
    current_anim:update(dt)
end
```

## 이미지 없이 테스트 — 색상 프레임

```lua
-- 이미지 파일 없이 애니메이션 원리를 테스트
local frames = {}
local frame_count = 6
local frame_idx = 1
local timer = 0
local duration = 0.15

function love.load()
    for i = 1, frame_count do
        local hue = (i - 1) / frame_count
        -- 간단한 HSV → RGB
        local r = math.abs(hue * 6 - 3) - 1
        local g = 2 - math.abs(hue * 6 - 2)
        local b = 2 - math.abs(hue * 6 - 4)
        r = math.max(0, math.min(1, r))
        g = math.max(0, math.min(1, g))
        b = math.max(0, math.min(1, b))
        frames[i] = {r, g, b}
    end
end

function love.update(dt)
    timer = timer + dt
    if timer >= duration then
        timer = timer - duration
        frame_idx = (frame_idx % frame_count) + 1
    end
end

function love.draw()
    local c = frames[frame_idx]
    love.graphics.setColor(c[1], c[2], c[3])
    love.graphics.circle("fill", 400, 300, 60)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print(string.format("Frame: %d/%d", frame_idx, frame_count), 10, 10)
    love.graphics.print(string.format("Duration: %.2fs", duration), 10, 30)
    love.graphics.print("UP/DOWN to change speed", 10, 50)
end

function love.keypressed(key)
    if key == "up"   then duration = math.max(0.02, duration - 0.02) end
    if key == "down" then duration = duration + 0.02 end
    if key == "escape" then love.event.quit() end
end
```

## 다음 챕터

텍스트와 폰트를 화면에 출력하고 스타일링하는 방법을 배운다.
