# 12. 타일맵

## 타일맵이란?

화면을 격자로 나누고, 각 칸에 타일(작은 이미지 조각)을 배치하는 방식.
2D 게임의 배경, 지형을 효율적으로 표현한다.

## 2D 배열로 맵 정의

```lua
-- 0: 빈 공간, 1: 벽, 2: 바닥, 3: 아이템
local map = {
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 0, 2, 2, 2, 0, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 3, 0, 1},
    {1, 0, 2, 2, 0, 0, 2, 2, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
}

local tile_size = 64
```

## 기본 렌더링

```lua
local tile_colors = {
    [0] = {0.15, 0.15, 0.2},   -- 빈 공간
    [1] = {0.4, 0.4, 0.45},    -- 벽
    [2] = {0.3, 0.6, 0.3},     -- 바닥
    [3] = {1, 0.85, 0},        -- 아이템
}

function love.draw()
    for row = 1, #map do
        for col = 1, #map[row] do
            local tile = map[row][col]
            local c = tile_colors[tile]
            love.graphics.setColor(c[1], c[2], c[3])
            love.graphics.rectangle(
                "fill",
                (col - 1) * tile_size,
                (row - 1) * tile_size,
                tile_size, tile_size
            )
            -- 격자선
            love.graphics.setColor(0, 0, 0, 0.2)
            love.graphics.rectangle(
                "line",
                (col - 1) * tile_size,
                (row - 1) * tile_size,
                tile_size, tile_size
            )
        end
    end
    love.graphics.setColor(1, 1, 1)
end
```

## 타일셋 이미지 사용

```lua
local tileset, quads
local tile_size = 32

function love.load()
    tileset = love.graphics.newImage("assets/tileset.png")
    tileset:setFilter("nearest", "nearest")

    local tw = tileset:getWidth()
    local th = tileset:getHeight()
    local cols = math.floor(tw / tile_size)

    quads = {}
    -- 타일 ID를 쿼드에 매핑 (0번부터)
    for id = 0, cols * math.floor(th / tile_size) - 1 do
        local col = id % cols
        local row = math.floor(id / cols)
        quads[id] = love.graphics.newQuad(
            col * tile_size, row * tile_size,
            tile_size, tile_size, tw, th
        )
    end
end

function love.draw()
    for row = 1, #map do
        for col = 1, #map[row] do
            local tile = map[row][col]
            if tile > 0 and quads[tile] then
                love.graphics.draw(
                    tileset, quads[tile],
                    (col - 1) * tile_size,
                    (row - 1) * tile_size
                )
            end
        end
    end
end
```

## 타일 충돌

```lua
local function getTile(px, py)
    local col = math.floor(px / tile_size) + 1
    local row = math.floor(py / tile_size) + 1
    if row >= 1 and row <= #map and col >= 1 and col <= #map[1] then
        return map[row][col]
    end
    return 1   -- 맵 바깥 = 벽
end

local function isSolid(tile_id)
    return tile_id == 1
end

-- 플레이어 이동 + 타일 충돌
local function movePlayer(dt)
    local dx, dy = 0, 0
    if love.keyboard.isDown("a") then dx = -1 end
    if love.keyboard.isDown("d") then dx =  1 end
    if love.keyboard.isDown("w") then dy = -1 end
    if love.keyboard.isDown("s") then dy =  1 end

    local new_x = player.x + dx * player.speed * dt
    local new_y = player.y + dy * player.speed * dt

    -- X축 먼저 검사
    if not isSolid(getTile(new_x + player.w * 0.5 * dx + player.w * 0.5, player.y)) then
        player.x = new_x
    end

    -- Y축 검사
    if not isSolid(getTile(player.x, new_y + player.h * 0.5 * dy + player.h * 0.5)) then
        player.y = new_y
    end
end
```

### 더 정확한 AABB 타일 충돌

```lua
local function collidesWithMap(x, y, w, h)
    local left   = math.floor(x / tile_size) + 1
    local right  = math.floor((x + w - 1) / tile_size) + 1
    local top    = math.floor(y / tile_size) + 1
    local bottom = math.floor((y + h - 1) / tile_size) + 1

    for row = top, bottom do
        for col = left, right do
            if row >= 1 and row <= #map and col >= 1 and col <= #map[1] then
                if isSolid(map[row][col]) then
                    return true
                end
            end
        end
    end
    return false
end
```

## 맵 파일에서 로드

간단한 텍스트 파일로 맵을 분리할 수 있다.

```lua
-- maps/level1.lua
return {
    width = 10,
    height = 7,
    tile_size = 64,
    data = {
        {1,1,1,1,1,1,1,1,1,1},
        {1,0,0,0,0,0,0,0,0,1},
        {1,0,0,2,2,2,0,0,0,1},
        {1,0,0,0,0,0,0,3,0,1},
        {1,0,2,2,0,0,2,2,0,1},
        {1,0,0,0,0,0,0,0,0,1},
        {1,1,1,1,1,1,1,1,1,1},
    },
    spawn = {x = 2, y = 2},   -- 플레이어 시작 위치 (타일 좌표)
}
```

```lua
local level = require("maps.level1")
local map = level.data
local tile_size = level.tile_size
```

## 실습: 미니 던전 탐험

```lua
-- main.lua
local map = {
    {1,1,1,1,1,1,1,1,1,1,1,1},
    {1,0,0,0,1,0,0,0,0,0,0,1},
    {1,0,0,0,1,0,0,3,0,0,0,1},
    {1,0,0,0,0,0,0,0,0,1,0,1},
    {1,1,1,0,1,1,1,0,0,1,0,1},
    {1,0,0,0,0,0,1,0,0,0,0,1},
    {1,0,3,0,0,0,0,0,0,0,3,1},
    {1,0,0,0,1,0,0,0,1,1,1,1},
    {1,1,1,1,1,1,1,1,1,1,1,1},
}

local tile_size = 64
local player = {x = 1.5 * tile_size, y = 1.5 * tile_size, size = 20, speed = 180}
local items_collected = 0
local total_items = 0

function love.load()
    love.graphics.setBackgroundColor(0.05, 0.05, 0.08)
    -- 아이템 수 세기
    for r = 1, #map do
        for c = 1, #map[r] do
            if map[r][c] == 3 then total_items = total_items + 1 end
        end
    end
end

local function isSolid(col, row)
    if row < 1 or row > #map or col < 1 or col > #map[1] then return true end
    return map[row][col] == 1
end

function love.update(dt)
    local dx, dy = 0, 0
    if love.keyboard.isDown("w") then dy = -1 end
    if love.keyboard.isDown("s") then dy =  1 end
    if love.keyboard.isDown("a") then dx = -1 end
    if love.keyboard.isDown("d") then dx =  1 end

    local nx = player.x + dx * player.speed * dt
    local ny = player.y + dy * player.speed * dt
    local r = player.size * 0.5

    -- X축
    local col_x = math.floor((nx + dx * r) / tile_size) + 1
    local row_y = math.floor(player.y / tile_size) + 1
    if not isSolid(col_x, row_y) then player.x = nx end

    -- Y축
    local col_x2 = math.floor(player.x / tile_size) + 1
    local row_y2 = math.floor((ny + dy * r) / tile_size) + 1
    if not isSolid(col_x2, row_y2) then player.y = ny end

    -- 아이템 수집
    local pc = math.floor(player.x / tile_size) + 1
    local pr = math.floor(player.y / tile_size) + 1
    if pr >= 1 and pr <= #map and pc >= 1 and pc <= #map[1] then
        if map[pr][pc] == 3 then
            map[pr][pc] = 0
            items_collected = items_collected + 1
        end
    end
end

function love.draw()
    for row = 1, #map do
        for col = 1, #map[row] do
            local tile = map[row][col]
            local x = (col - 1) * tile_size
            local y = (row - 1) * tile_size

            if tile == 1 then
                love.graphics.setColor(0.35, 0.35, 0.4)
                love.graphics.rectangle("fill", x, y, tile_size, tile_size)
            elseif tile == 3 then
                love.graphics.setColor(1, 0.85, 0)
                love.graphics.circle("fill", x + tile_size / 2, y + tile_size / 2, 8)
            end
        end
    end

    -- 플레이어
    love.graphics.setColor(0.3, 0.85, 1)
    love.graphics.circle("fill", player.x, player.y, player.size * 0.5)

    -- HUD
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(string.format("Items: %d/%d", items_collected, total_items), 10, 10)
    if items_collected >= total_items then
        love.graphics.printf("ALL COLLECTED!", 0, 300, 800, "center")
    end
end

function love.keypressed(key)
    if key == "escape" then love.event.quit() end
end
```

## 다음 챕터

카메라를 구현하여 맵이 화면보다 클 때 스크롤하는 방법을 배운다.
