# 06. 이미지 & 스프라이트

## 이미지 로드

```lua
local img

function love.load()
    img = love.graphics.newImage("assets/player.png")
end

function love.draw()
    love.graphics.draw(img, 100, 100)
end
```

지원 형식: PNG, JPEG, BMP, TGA, GIF(첫 프레임만).
**PNG 권장** (투명도 지원, 무손실).

## draw 함수 전체 시그니처

```lua
love.graphics.draw(drawable, x, y, rotation, scaleX, scaleY, originX, originY)
```

| 인자 | 기본값 | 설명 |
|------|--------|------|
| `x, y` | 0, 0 | 그리기 위치 |
| `rotation` | 0 | 회전 (라디안) |
| `scaleX, scaleY` | 1, 1 | 배율 |
| `originX, originY` | 0, 0 | 회전/스케일 기준점 |

```lua
function love.draw()
    local w = img:getWidth()
    local h = img:getHeight()

    -- 중앙 기준으로 그리기
    love.graphics.draw(img, 400, 300, 0, 1, 1, w / 2, h / 2)

    -- 2배 확대, 45도 회전, 중앙 기준
    love.graphics.draw(img, 600, 300, math.rad(45), 2, 2, w / 2, h / 2)

    -- 좌우 반전 (scaleX = -1)
    love.graphics.draw(img, 200, 300, 0, -1, 1, w / 2, h / 2)
end
```

## Quad — 스프라이트 시트에서 잘라 그리기

스프라이트 시트: 여러 프레임을 한 이미지에 모아놓은 것.

```
┌────┬────┬────┬────┐
│ 0  │ 1  │ 2  │ 3  │   ← 32×32 프레임 4개
└────┴────┴────┴────┘
```

```lua
local sheet, quad

function love.load()
    sheet = love.graphics.newImage("assets/spritesheet.png")

    -- newQuad(x, y, width, height, sheetWidth, sheetHeight)
    quad = love.graphics.newQuad(
        32, 0,       -- 시트 내 좌상단 좌표 (2번째 프레임)
        32, 32,      -- 프레임 크기
        sheet:getWidth(), sheet:getHeight()
    )
end

function love.draw()
    love.graphics.draw(sheet, quad, 400, 300)
end
```

### Quad 배열 생성 유틸리티

```lua
local function makeQuads(sheet, frame_w, frame_h)
    local quads = {}
    local sheet_w = sheet:getWidth()
    local sheet_h = sheet:getHeight()
    local cols = math.floor(sheet_w / frame_w)
    local rows = math.floor(sheet_h / frame_h)

    for row = 0, rows - 1 do
        for col = 0, cols - 1 do
            quads[#quads + 1] = love.graphics.newQuad(
                col * frame_w, row * frame_h,
                frame_w, frame_h,
                sheet_w, sheet_h
            )
        end
    end
    return quads
end
```

## 이미지 필터

```lua
function love.load()
    img = love.graphics.newImage("assets/pixel_art.png")

    -- 픽셀아트에는 "nearest" (도트가 선명하게 유지)
    img:setFilter("nearest", "nearest")

    -- 일반 그래픽에는 "linear" (부드러운 보간, 기본값)
    -- img:setFilter("linear", "linear")
end
```

## 이미지 랩 모드

```lua
-- 이미지가 타일링될 때 동작
img:setWrap("repeat", "repeat")     -- 반복
-- "clamp": 가장자리 색 연장 (기본)
-- "repeat": 타일링
-- "mirroredrepeat": 반복 + 반전
```

## 색상 tint

`setColor()`는 이미지에도 적용된다 (곱셈 블렌딩).

```lua
function love.draw()
    -- 원본 색상 그대로
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(img, 100, 100)

    -- 빨간 tint (피격 효과)
    love.graphics.setColor(1, 0.3, 0.3)
    love.graphics.draw(img, 300, 100)

    -- 반투명
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.draw(img, 500, 100)

    love.graphics.setColor(1, 1, 1)
end
```

## 이미지가 없을 때 — 플레이스홀더

개발 초기에는 이미지 없이 도형으로 대체한다.

```lua
local function drawPlaceholder(x, y, w, h, label)
    love.graphics.setColor(1, 0, 1, 0.5)
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x, y, w, h)
    love.graphics.print(label, x + 2, y + 2)
end
```

## ImageData — 픽셀 단위 조작

```lua
function love.load()
    -- 코드로 이미지 생성
    local data = love.image.newImageData(64, 64)
    data:mapPixel(function(x, y, r, g, b, a)
        -- 체크무늬 패턴
        if (math.floor(x / 8) + math.floor(y / 8)) % 2 == 0 then
            return 0.8, 0.8, 0.8, 1
        else
            return 0.3, 0.3, 0.3, 1
        end
    end)
    img = love.graphics.newImage(data)
    img:setFilter("nearest", "nearest")
end
```

## 실습: 스프라이트 갤러리

```lua
-- main.lua (이미지 파일 없이 동작하는 버전)
local sprites = {}
local selected = 1

function love.load()
    -- 코드로 4개 스프라이트 생성
    local colors = {
        {1, 0.3, 0.3},
        {0.3, 1, 0.3},
        {0.3, 0.3, 1},
        {1, 1, 0.3},
    }
    for i, c in ipairs(colors) do
        local data = love.image.newImageData(32, 32)
        data:mapPixel(function(x, y)
            local cx, cy = 15.5, 15.5
            local dist = math.sqrt((x - cx)^2 + (y - cy)^2)
            if dist < 14 then
                return c[1], c[2], c[3], 1
            end
            return 0, 0, 0, 0
        end)
        sprites[i] = love.graphics.newImage(data)
        sprites[i]:setFilter("nearest", "nearest")
    end
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("LEFT/RIGHT to select, UP/DOWN to scale", 10, 10)

    for i, spr in ipairs(sprites) do
        local x = 100 + (i - 1) * 180
        local scale = (i == selected) and 4 or 2
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(spr, x, 250, 0, scale, scale)

        if i == selected then
            love.graphics.setColor(1, 1, 0)
            love.graphics.rectangle("line", x - 4, 246, 32 * scale + 8, 32 * scale + 8)
        end
    end
    love.graphics.setColor(1, 1, 1)
end

function love.keypressed(key)
    if key == "right" then selected = (selected % #sprites) + 1 end
    if key == "left"  then selected = ((selected - 2) % #sprites) + 1 end
    if key == "escape" then love.event.quit() end
end
```

## 다음 챕터

스프라이트 시트에서 프레임을 순환시켜 애니메이션을 구현한다.
