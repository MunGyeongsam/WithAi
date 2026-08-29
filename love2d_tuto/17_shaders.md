# 17. 셰이더 (GLSL)

## LÖVE2D 셰이더 개요

셰이더 = GPU에서 실행되는 프로그램. 매 픽셀(또는 매 정점)마다 실행된다.
LÖVE2D는 **GLSL ES** 기반 셰이더를 지원한다.

## 최소 셰이더

```lua
local shader

function love.load()
    shader = love.graphics.newShader([[
        vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
            vec4 pixel = Texel(tex, texture_coords);
            return pixel * color;
        }
    ]])
end

function love.draw()
    love.graphics.setShader(shader)
    love.graphics.rectangle("fill", 100, 100, 200, 200)
    love.graphics.setShader()   -- 셰이더 해제
end
```

### effect 함수 인자

| 인자 | 설명 |
|------|------|
| `color` | `love.graphics.setColor()`에서 설정한 색상 |
| `tex` | 현재 텍스처 (이미지 또는 캔버스) |
| `texture_coords` | UV 좌표 (0~1) |
| `screen_coords` | 화면 픽셀 좌표 |

## uniform — Lua에서 셰이더로 값 전달

```lua
local shader
local time = 0

function love.load()
    shader = love.graphics.newShader([[
        uniform float time;

        vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
            vec4 pixel = Texel(tex, tc);
            float wave = sin(tc.x * 20.0 + time * 5.0) * 0.5 + 0.5;
            return pixel * color * vec4(wave, 1.0 - wave * 0.5, 1.0, 1.0);
        }
    ]])
end

function love.update(dt)
    time = time + dt
    shader:send("time", time)
end

function love.draw()
    love.graphics.setShader(shader)
    love.graphics.rectangle("fill", 100, 100, 600, 400)
    love.graphics.setShader()
end
```

### send 가능한 타입

```lua
shader:send("value", 1.5)                         -- float
shader:send("color", {1.0, 0.5, 0.0, 1.0})       -- vec4
shader:send("resolution", {800, 600})             -- vec2
shader:send("matrix", transform_matrix)           -- mat4
shader:send("flag", true)                         -- bool
shader:send("texture", canvas_or_image)           -- Image
```

## 실용 셰이더 예제

### 그레이스케일

```lua
local grayscale = love.graphics.newShader([[
    vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
        vec4 pixel = Texel(tex, tc);
        float gray = dot(pixel.rgb, vec3(0.299, 0.587, 0.114));
        return vec4(gray, gray, gray, pixel.a) * color;
    }
]])
```

### 색상 반전

```lua
local invert = love.graphics.newShader([[
    vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
        vec4 pixel = Texel(tex, tc);
        return vec4(1.0 - pixel.rgb, pixel.a) * color;
    }
]])
```

### CRT 효과 (스캔라인)

```lua
local crt = love.graphics.newShader([[
    uniform vec2 resolution;

    vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
        vec4 pixel = Texel(tex, tc);
        // 스캔라인
        float scanline = sin(sc.y * 3.14159 * 2.0) * 0.04;
        pixel.rgb -= scanline;
        // 비네팅
        vec2 center = tc - 0.5;
        float vignette = 1.0 - dot(center, center) * 1.5;
        pixel.rgb *= vignette;
        return pixel * color;
    }
]])
```

### 블러 (Box Blur)

```lua
local blur = love.graphics.newShader([[
    uniform vec2 direction;   -- (1/w, 0) 또는 (0, 1/h)

    vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
        vec4 sum = vec4(0.0);
        sum += Texel(tex, tc - 4.0 * direction) * 0.05;
        sum += Texel(tex, tc - 3.0 * direction) * 0.09;
        sum += Texel(tex, tc - 2.0 * direction) * 0.12;
        sum += Texel(tex, tc - 1.0 * direction) * 0.15;
        sum += Texel(tex, tc)                    * 0.18;
        sum += Texel(tex, tc + 1.0 * direction) * 0.15;
        sum += Texel(tex, tc + 2.0 * direction) * 0.12;
        sum += Texel(tex, tc + 3.0 * direction) * 0.09;
        sum += Texel(tex, tc + 4.0 * direction) * 0.05;
        return sum * color;
    }
]])
```

### 외곽선 검출 (Sobel)

```lua
local outline = love.graphics.newShader([[
    uniform vec2 step;   -- vec2(1.0/width, 1.0/height)

    vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
        float tl = dot(Texel(tex, tc + vec2(-step.x, -step.y)).rgb, vec3(0.333));
        float t  = dot(Texel(tex, tc + vec2(0, -step.y)).rgb, vec3(0.333));
        float tr = dot(Texel(tex, tc + vec2(step.x, -step.y)).rgb, vec3(0.333));
        float l  = dot(Texel(tex, tc + vec2(-step.x, 0)).rgb, vec3(0.333));
        float r  = dot(Texel(tex, tc + vec2(step.x, 0)).rgb, vec3(0.333));
        float bl = dot(Texel(tex, tc + vec2(-step.x, step.y)).rgb, vec3(0.333));
        float b  = dot(Texel(tex, tc + vec2(0, step.y)).rgb, vec3(0.333));
        float br = dot(Texel(tex, tc + vec2(step.x, step.y)).rgb, vec3(0.333));

        float gx = -tl - 2.0*l - bl + tr + 2.0*r + br;
        float gy = -tl - 2.0*t - tr + bl + 2.0*b + br;
        float edge = sqrt(gx*gx + gy*gy);

        return vec4(edge, edge, edge, 1.0) * color;
    }
]])
```

## 셰이더 + 캔버스 조합

```lua
local canvas, shader

function love.load()
    canvas = love.graphics.newCanvas()
    shader = love.graphics.newShader(...)
end

function love.draw()
    -- 씬을 캔버스에 그리기
    love.graphics.setCanvas(canvas)
    love.graphics.clear()
    drawScene()
    love.graphics.setCanvas()

    -- 셰이더를 통해 캔버스를 화면에 그리기
    love.graphics.setShader(shader)
    love.graphics.draw(canvas)
    love.graphics.setShader()
end
```

## 실습: 실시간 셰이더 전환

```lua
-- main.lua
local canvas
local shaders = {}
local current_idx = 1
local time = 0

function love.load()
    canvas = love.graphics.newCanvas()

    shaders[1] = {name = "Normal", shader = nil}
    shaders[2] = {name = "Grayscale", shader = love.graphics.newShader([[
        vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
            vec4 p = Texel(tex, tc);
            float g = dot(p.rgb, vec3(0.299, 0.587, 0.114));
            return vec4(g, g, g, p.a) * color;
        }
    ]])}
    shaders[3] = {name = "Wave", shader = love.graphics.newShader([[
        uniform float time;
        vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
            tc.x += sin(tc.y * 20.0 + time * 3.0) * 0.01;
            tc.y += cos(tc.x * 20.0 + time * 3.0) * 0.01;
            return Texel(tex, tc) * color;
        }
    ]])}
    shaders[4] = {name = "Pixelate", shader = love.graphics.newShader([[
        uniform float pixel_size;
        vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
            vec2 p = floor(tc * pixel_size) / pixel_size;
            return Texel(tex, p) * color;
        }
    ]])}
end

function love.update(dt)
    time = time + dt
    local s = shaders[current_idx].shader
    if s and s:hasUniform("time") then s:send("time", time) end
    if s and s:hasUniform("pixel_size") then s:send("pixel_size", 80.0) end
end

function love.draw()
    -- 씬을 캔버스에
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0.1, 0.1, 0.2)

    -- 장식 도형들
    for i = 1, 12 do
        local angle = time * 0.5 + i * math.pi * 2 / 12
        local x = 400 + math.cos(angle) * 150
        local y = 300 + math.sin(angle) * 150
        love.graphics.setColor(i / 12, 0.5, 1 - i / 12)
        love.graphics.circle("fill", x, y, 20 + math.sin(time + i) * 5)
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.setCanvas()

    -- 셰이더 적용
    local s = shaders[current_idx].shader
    if s then love.graphics.setShader(s) end
    love.graphics.draw(canvas)
    love.graphics.setShader()

    -- HUD
    love.graphics.print("Shader: " .. shaders[current_idx].name, 10, 10)
    love.graphics.print("LEFT/RIGHT to switch", 10, 30)
end

function love.keypressed(key)
    if key == "right" then current_idx = (current_idx % #shaders) + 1 end
    if key == "left"  then current_idx = ((current_idx - 2) % #shaders) + 1 end
    if key == "escape" then love.event.quit() end
end
```

## 다음 챕터

게임 데이터를 파일에 저장하고 불러오는 방법을 배운다.
