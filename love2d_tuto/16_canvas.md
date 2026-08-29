# 16. 캔버스 & 렌더 타겟

## Canvas란?

Canvas = 오프스크린 렌더 타겟. 화면이 아닌 **텍스처에** 그린 뒤, 그 텍스처를 다시 화면에 그린다.

용도:
- 후처리 효과 (블러, 글로우)
- 레이어 합성 (배경, 게임, UI 분리)
- 저해상도 렌더링 (픽셀아트 확대)
- 미니맵
- 라이팅

## 기본 사용

```lua
local canvas

function love.load()
    canvas = love.graphics.newCanvas(800, 600)
end

function love.draw()
    -- 캔버스에 그리기
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0, 0, 0)   -- 투명으로 초기화
    love.graphics.setColor(1, 0, 0)
    love.graphics.circle("fill", 400, 300, 100)
    love.graphics.setCanvas()   -- 기본 화면으로 복원

    -- 캔버스를 화면에 그리기
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(canvas)
end
```

## 저해상도 렌더링 (픽셀아트)

```lua
local game_canvas
local game_w, game_h = 320, 240   -- 게임 해상도
local scale

function love.load()
    game_canvas = love.graphics.newCanvas(game_w, game_h)
    game_canvas:setFilter("nearest", "nearest")   -- 픽셀 선명하게

    local win_w = love.graphics.getWidth()
    local win_h = love.graphics.getHeight()
    scale = math.min(win_w / game_w, win_h / game_h)
end

function love.draw()
    -- 저해상도 캔버스에 그리기
    love.graphics.setCanvas(game_canvas)
    love.graphics.clear(0.1, 0.1, 0.15)

    -- 게임 화면 (320×240 기준 좌표)
    love.graphics.setColor(0.3, 0.8, 1)
    love.graphics.circle("fill", 160, 120, 20)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("320x240 canvas", 10, 10)

    love.graphics.setCanvas()

    -- 화면에 확대해서 그리기
    love.graphics.setColor(1, 1, 1)
    local win_w = love.graphics.getWidth()
    local win_h = love.graphics.getHeight()
    local ox = (win_w - game_w * scale) / 2
    local oy = (win_h - game_h * scale) / 2
    love.graphics.draw(game_canvas, ox, oy, 0, scale, scale)
end
```

## 레이어 합성

```lua
local layer_bg, layer_game, layer_ui

function love.load()
    layer_bg   = love.graphics.newCanvas()
    layer_game = love.graphics.newCanvas()
    layer_ui   = love.graphics.newCanvas()
end

function love.draw()
    -- 배경 레이어
    love.graphics.setCanvas(layer_bg)
    love.graphics.clear()
    drawBackground()
    love.graphics.setCanvas()

    -- 게임 레이어
    love.graphics.setCanvas(layer_game)
    love.graphics.clear(0, 0, 0, 0)
    drawEntities()
    love.graphics.setCanvas()

    -- UI 레이어
    love.graphics.setCanvas(layer_ui)
    love.graphics.clear(0, 0, 0, 0)
    drawUI()
    love.graphics.setCanvas()

    -- 순서대로 합성
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(layer_bg)
    love.graphics.draw(layer_game)
    love.graphics.draw(layer_ui)
end
```

## 글로우 효과 (간이 블룸)

밝은 부분을 별도 캔버스에 그리고, 확대(블러 대체)해서 덧씌운다.

```lua
local scene_canvas, glow_canvas

function love.load()
    scene_canvas = love.graphics.newCanvas()
    glow_canvas  = love.graphics.newCanvas(200, 150)  -- 저해상도 = 간이 블러
end

function love.draw()
    -- 1. 씬 그리기
    love.graphics.setCanvas(scene_canvas)
    love.graphics.clear(0, 0, 0)
    drawScene()
    love.graphics.setCanvas()

    -- 2. 글로우 대상만 저해상도 캔버스에 그리기
    love.graphics.setCanvas(glow_canvas)
    love.graphics.clear(0, 0, 0, 0)
    drawGlowObjects()
    love.graphics.setCanvas()

    -- 3. 합성
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(scene_canvas)

    -- 글로우 캔버스를 확대해서 덧씌우기 (additive blend)
    love.graphics.setBlendMode("add")
    love.graphics.setColor(1, 1, 1, 0.6)
    love.graphics.draw(glow_canvas, 0, 0, 0, 4, 4)
    love.graphics.setBlendMode("alpha")
    love.graphics.setColor(1, 1, 1)
end
```

## 블렌드 모드

```lua
love.graphics.setBlendMode("alpha")      -- 기본 (알파 블렌딩)
love.graphics.setBlendMode("add")        -- 가산 (발광 효과)
love.graphics.setBlendMode("multiply")   -- 곱셈 (그림자, 디머)
love.graphics.setBlendMode("replace")    -- 덮어쓰기
```

## 스텐실

특정 영역만 그리기/숨기기.

```lua
function love.draw()
    -- 원 모양 마스크
    love.graphics.stencil(function()
        love.graphics.circle("fill", 400, 300, 100)
    end, "replace", 1)

    love.graphics.setStencilTest("greater", 0)

    -- 이 그리기는 원 안에서만 보임
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", 0, 0, 800, 600)

    love.graphics.setStencilTest()
    love.graphics.setColor(1, 1, 1)
end
```

## 실습: 손전등 효과

```lua
-- main.lua
local scene_canvas, light_canvas
local mx, my = 400, 300
local objects = {}

function love.load()
    love.graphics.setBackgroundColor(0, 0, 0)
    scene_canvas = love.graphics.newCanvas()
    light_canvas = love.graphics.newCanvas()

    math.randomseed(os.time())
    for i = 1, 30 do
        objects[i] = {
            x = math.random(50, 750),
            y = math.random(50, 550),
            r = math.random(15, 40),
            color = {math.random() * 0.5 + 0.5, math.random() * 0.5 + 0.5, math.random() * 0.5 + 0.5},
        }
    end
end

function love.update(dt)
    mx, my = love.mouse.getPosition()
end

function love.draw()
    -- 씬 그리기
    love.graphics.setCanvas(scene_canvas)
    love.graphics.clear(0.05, 0.05, 0.08)
    for _, o in ipairs(objects) do
        love.graphics.setColor(o.color[1], o.color[2], o.color[3])
        love.graphics.circle("fill", o.x, o.y, o.r)
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Move mouse to illuminate", 10, 10)
    love.graphics.setCanvas()

    -- 라이트 마스크
    love.graphics.setCanvas(light_canvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.setBlendMode("replace")
    -- 방사형 그라데이션 (간이 구현)
    local radius = 150
    for i = radius, 1, -2 do
        local a = (i / radius)
        love.graphics.setColor(1, 1, 1, 1 - a * a)
        love.graphics.circle("fill", mx, my, i)
    end
    love.graphics.setBlendMode("alpha")
    love.graphics.setCanvas()

    -- 합성: 씬 × 라이트
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(scene_canvas)
    love.graphics.setBlendMode("multiply", "premultiplied")
    love.graphics.draw(light_canvas)
    love.graphics.setBlendMode("alpha")
end

function love.keypressed(key)
    if key == "escape" then love.event.quit() end
end
```

## 다음 챕터

GLSL 셰이더로 GPU에서 직접 픽셀을 조작하는 고급 시각 효과를 배운다.
