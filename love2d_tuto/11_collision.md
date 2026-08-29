# 11. 충돌 처리

## AABB (사각형) 충돌

```lua
local function aabb(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2
       and x2 < x1 + w1
       and y1 < y2 + h2
       and y2 < y1 + h1
end
```

## 원-원 충돌

```lua
local function circleCollision(x1, y1, r1, x2, y2, r2)
    local dx = x2 - x1
    local dy = y2 - y1
    local dist_sq = dx * dx + dy * dy
    local radii = r1 + r2
    return dist_sq <= radii * radii
end
```

## 충돌 반응 — 분리 (Separation)

충돌을 감지한 뒤 겹침을 해소해야 한다.

```lua
local function resolveCircles(a, b)
    local dx = b.x - a.x
    local dy = b.y - a.y
    local dist = math.sqrt(dx * dx + dy * dy)
    local overlap = (a.radius + b.radius) - dist

    if overlap > 0 and dist > 0 then
        local nx = dx / dist
        local ny = dy / dist
        -- 각각 절반씩 밀어냄
        a.x = a.x - nx * overlap * 0.5
        a.y = a.y - ny * overlap * 0.5
        b.x = b.x + nx * overlap * 0.5
        b.y = b.y + ny * overlap * 0.5
    end
end
```

## 충돌 반응 — 반사 (Bounce)

```lua
local function bounceOff(ball, nx, ny)
    -- v' = v - 2(v·n)n
    local dot = ball.vx * nx + ball.vy * ny
    ball.vx = ball.vx - 2 * dot * nx
    ball.vy = ball.vy - 2 * dot * ny
end
```

## N개 엔티티 충돌 검사

```lua
local function checkCollisions(entities)
    local n = #entities
    for i = 1, n - 1 do
        for j = i + 1, n do
            local a = entities[i]
            local b = entities[j]
            if circleCollision(a.x, a.y, a.radius, b.x, b.y, b.radius) then
                onCollision(a, b)
            end
        end
    end
end
```

> O(n²) — 엔티티가 수백 개를 넘으면 공간 분할(그리드, 쿼드트리)이 필요하다.

## 공간 분할 — 그리드

```lua
local Grid = {}
Grid.__index = Grid

function Grid.new(cell_size, width, height)
    local cols = math.ceil(width / cell_size)
    local rows = math.ceil(height / cell_size)
    return setmetatable({
        cell_size = cell_size,
        cols = cols,
        rows = rows,
        cells = {},
    }, Grid)
end

function Grid:clear()
    for i = 1, self.cols * self.rows do
        self.cells[i] = nil
    end
end

function Grid:insert(entity)
    local col = math.floor(entity.x / self.cell_size) + 1
    local row = math.floor(entity.y / self.cell_size) + 1
    col = math.max(1, math.min(self.cols, col))
    row = math.max(1, math.min(self.rows, row))
    local idx = (row - 1) * self.cols + col
    if not self.cells[idx] then self.cells[idx] = {} end
    local cell = self.cells[idx]
    cell[#cell + 1] = entity
end

function Grid:getNeighbors(entity)
    local col = math.floor(entity.x / self.cell_size) + 1
    local row = math.floor(entity.y / self.cell_size) + 1
    local neighbors = {}

    for dr = -1, 1 do
        for dc = -1, 1 do
            local c = col + dc
            local r = row + dr
            if c >= 1 and c <= self.cols and r >= 1 and r <= self.rows then
                local cell = self.cells[(r - 1) * self.cols + c]
                if cell then
                    for _, e in ipairs(cell) do
                        if e ~= entity then
                            neighbors[#neighbors + 1] = e
                        end
                    end
                end
            end
        end
    end
    return neighbors
end
```

## 레이어/카테고리 기반 충돌

모든 조합을 검사하지 않고 의미 있는 쌍만 검사한다.

```lua
local bullets = {}
local enemies = {}

function love.update(dt)
    -- 총알 vs 적 만 검사 (적 vs 적은 무시)
    for i = #bullets, 1, -1 do
        local b = bullets[i]
        for j = #enemies, 1, -1 do
            local e = enemies[j]
            if circleCollision(b.x, b.y, b.radius, e.x, e.y, e.radius) then
                e.hp = e.hp - b.damage
                table.remove(bullets, i)
                if e.hp <= 0 then table.remove(enemies, j) end
                break
            end
        end
    end
end
```

## 실습: 수집 게임

```lua
-- main.lua
local player, coins, score
local player_speed = 250
local coin_radius = 10
local player_radius = 15

function love.load()
    math.randomseed(os.time())
    love.graphics.setBackgroundColor(0.08, 0.08, 0.12)
    player = {x = 400, y = 300}
    coins = {}
    score = 0
    spawnCoins(10)
end

local function spawnCoins(n)
    for i = 1, n do
        coins[#coins + 1] = {
            x = math.random(50, 750),
            y = math.random(50, 550),
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
    if len > 0 then
        dx, dy = dx / len, dy / len
    end
    player.x = player.x + dx * player_speed * dt
    player.y = player.y + dy * player_speed * dt

    -- 경계
    player.x = math.max(player_radius, math.min(800 - player_radius, player.x))
    player.y = math.max(player_radius, math.min(600 - player_radius, player.y))

    -- 수집 검사
    for i = #coins, 1, -1 do
        local c = coins[i]
        if circleCollision(player.x, player.y, player_radius, c.x, c.y, coin_radius) then
            table.remove(coins, i)
            score = score + 1
        end
    end

    if #coins == 0 then
        spawnCoins(10)
    end
end

function love.draw()
    -- 코인
    love.graphics.setColor(1, 0.85, 0)
    for _, c in ipairs(coins) do
        love.graphics.circle("fill", c.x, c.y, coin_radius)
    end

    -- 플레이어
    love.graphics.setColor(0.3, 0.9, 1)
    love.graphics.circle("fill", player.x, player.y, player_radius)

    -- HUD
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. score, 10, 10)
    love.graphics.print("WASD to move", 10, 30)
end

function love.keypressed(key)
    if key == "escape" then love.event.quit() end
end
```

## 다음 챕터

타일맵을 로드하고 화면에 렌더링하는 방법을 배운다.
