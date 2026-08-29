# 08. 텍스트 & 폰트

## 기본 텍스트 출력

```lua
function love.draw()
    love.graphics.print("Hello!", 10, 10)
    love.graphics.print("Score: " .. tostring(score), 10, 30)

    -- printf: 정렬 + 줄바꿈 폭 지정
    love.graphics.printf("가운데 정렬 텍스트", 0, 300, 800, "center")
    love.graphics.printf("오른쪽 정렬", 0, 330, 800, "right")
end
```

### print vs printf

| 함수 | 줄바꿈 | 정렬 | 용도 |
|------|:------:|:----:|------|
| `print(text, x, y)` | 수동 | 왼쪽 | 디버그, HUD |
| `printf(text, x, y, limit, align)` | 자동 | 선택 | UI, 대화창 |

## 커스텀 폰트

```lua
local font_small, font_big, font_pixel

function love.load()
    -- TTF 파일 로드
    font_small = love.graphics.newFont("assets/fonts/NotoSans.ttf", 14)
    font_big   = love.graphics.newFont("assets/fonts/NotoSans.ttf", 36)

    -- 픽셀 폰트 (nearest 필터 자동 적용)
    font_pixel = love.graphics.newFont("assets/fonts/pixel.ttf", 16)
    font_pixel:setFilter("nearest", "nearest")
end

function love.draw()
    love.graphics.setFont(font_big)
    love.graphics.print("GAME OVER", 250, 200)

    love.graphics.setFont(font_small)
    love.graphics.print("Press R to restart", 300, 260)
end
```

### 기본 폰트

```lua
-- 크기만 지정 (내장 폰트 사용)
local default14 = love.graphics.newFont(14)
local default24 = love.graphics.newFont(24)
```

## 폰트 크기 & 측정

```lua
local font = love.graphics.newFont(20)

local text = "Hello, World!"
local text_w = font:getWidth(text)
local text_h = font:getHeight()
local line_h = font:getLineHeight()

-- 화면 중앙에 텍스트 배치
function love.draw()
    love.graphics.setFont(font)
    local w = love.graphics.getWidth()
    love.graphics.print(text, (w - text_w) / 2, 300)
end
```

## 색상이 있는 텍스트

```lua
function love.draw()
    love.graphics.setColor(1, 0, 0)
    love.graphics.print("빨강", 10, 10)

    love.graphics.setColor(0, 1, 0)
    love.graphics.print("초록", 10, 30)

    love.graphics.setColor(1, 1, 1)   -- 복원
end
```

### 한 줄에 여러 색상 (coloredtext)

```lua
function love.draw()
    love.graphics.print(
        {
            {1, 0, 0}, "HP: ",
            {0, 1, 0}, "100",
            {1, 1, 1}, " / ",
            {0.5, 0.5, 0.5}, "100",
        },
        10, 10
    )
end
```

## 텍스트 효과

### 그림자

```lua
local function drawTextShadow(text, x, y, shadow_offset)
    shadow_offset = shadow_offset or 2
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.print(text, x + shadow_offset, y + shadow_offset)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(text, x, y)
end
```

### 외곽선

```lua
local function drawTextOutline(text, x, y, outline_color, text_color)
    outline_color = outline_color or {0, 0, 0}
    text_color = text_color or {1, 1, 1}

    love.graphics.setColor(outline_color)
    for ox = -1, 1 do
        for oy = -1, 1 do
            if ox ~= 0 or oy ~= 0 then
                love.graphics.print(text, x + ox, y + oy)
            end
        end
    end

    love.graphics.setColor(text_color)
    love.graphics.print(text, x, y)
end
```

### 흔들리는 텍스트

```lua
local time = 0

function love.update(dt)
    time = time + dt
end

function love.draw()
    local text = "WAVE EFFECT"
    local font = love.graphics.getFont()
    local x_start = 300

    for i = 1, #text do
        local ch = text:sub(i, i)
        local offset_y = math.sin(time * 5 + i * 0.5) * 5
        love.graphics.print(ch, x_start, 300 + offset_y)
        x_start = x_start + font:getWidth(ch)
    end
end
```

## Text 객체 (LÖVE 11.x)

자주 그리는 텍스트는 `Text` 객체로 만들면 성능이 좋다.

```lua
local text_obj

function love.load()
    local font = love.graphics.newFont(24)
    text_obj = love.graphics.newText(font, "Score: 0")
end

function updateScore(score)
    text_obj:set("Score: " .. tostring(score))
end

function love.draw()
    love.graphics.draw(text_obj, 10, 10)
end
```

## 실습: 타이핑 효과

```lua
-- main.lua
local full_text
local visible_chars
local timer
local char_delay
local font

function love.load()
    font = love.graphics.newFont(20)
    love.graphics.setFont(font)

    full_text = "LÖVE2D에서 텍스트를 다루는 방법을 배웁니다.\n"
             .. "한 글자씩 나타나는 타이핑 효과입니다.\n"
             .. "Space를 누르면 즉시 완성됩니다."
    visible_chars = 0
    timer = 0
    char_delay = 0.04
end

function love.update(dt)
    if visible_chars < #full_text then
        timer = timer + dt
        if timer >= char_delay then
            timer = timer - char_delay
            -- UTF-8 바이트 건너뛰기 (한글 등 멀티바이트 대응)
            visible_chars = visible_chars + 1
            local byte = full_text:byte(visible_chars)
            if byte and byte >= 0x80 then
                while visible_chars < #full_text do
                    visible_chars = visible_chars + 1
                    byte = full_text:byte(visible_chars)
                    if not byte or byte < 0x80 or byte >= 0xC0 then
                        visible_chars = visible_chars - 1
                        break
                    end
                end
            end
        end
    end
end

function love.draw()
    local display = full_text:sub(1, visible_chars)
    love.graphics.printf(display, 50, 200, 700, "left")

    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.print("Space: skip  /  R: restart", 50, 500)
    love.graphics.setColor(1, 1, 1)
end

function love.keypressed(key)
    if key == "space" then visible_chars = #full_text end
    if key == "r" then visible_chars = 0; timer = 0 end
    if key == "escape" then love.event.quit() end
end
```

## 다음 챕터

사운드와 음악을 로드하고 재생하는 방법을 배운다.
