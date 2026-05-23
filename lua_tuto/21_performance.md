# 21. 성능 최적화

> 60 FPS = 매 프레임 약 16.7ms. 이 예산 안에서 모든 것을 처리해야 한다.

## 프로파일링 먼저

```lua
-- 최적화 전에 반드시 측정하라!
-- "추측하지 말고, 측정하라" (Don't guess, measure)

-- 간단한 프로파일러
local function profile(name, func, ...)
    local start = love.timer.getTime()
    local results = {func(...)}
    local elapsed = love.timer.getTime() - start
    print(string.format("[PROFILE] %s: %.4fms", name, elapsed * 1000))
    return unpack(results)
end

-- 사용
profile("updateEnemies", function()
    for i = 1, #enemies do
        updateEnemy(enemies[i], dt)
    end
end)
```

```lua
-- 매 프레임 시간 측정
local frameTimes = {}
local frameIndex = 0
local FRAME_SAMPLE = 60

function love.update(dt)
    frameIndex = frameIndex % FRAME_SAMPLE + 1
    frameTimes[frameIndex] = dt
end

function love.draw()
    -- 평균 프레임 시간
    local sum = 0
    for i = 1, #frameTimes do sum = sum + frameTimes[i] end
    local avg = sum / math.max(#frameTimes, 1)
    
    love.graphics.print(string.format(
        "FPS: %d  Frame: %.2fms  Entities: %d",
        love.timer.getFPS(),
        avg * 1000,
        entityCount
    ), 10, 10)
end
```

## Lua 성능 핵심 원칙

### 1. 로컬 변수 = 빠르다

```lua
-- Lua에서 local 변수 접근은 글로벌보다 30~50% 빠르다

-- ❌ 느림: 전역/모듈 변수 반복 접근
function love.update(dt)
    for i = 1, #entities do
        entities[i].x = entities[i].x + math.sin(entities[i].angle) * entities[i].speed * dt
    end
end

-- ✅ 빠름: 자주 쓰는 값을 로컬로 캐시
local sin = math.sin
local cos = math.cos

function love.update(dt)
    local ents = entities
    local n = #ents
    for i = 1, n do
        local e = ents[i]
        local speed_dt = e.speed * dt
        e.x = e.x + sin(e.angle) * speed_dt
        e.y = e.y + cos(e.angle) * speed_dt
    end
end
```

### 2. 테이블 생성 피하기 (GC 회피)

```lua
-- ❌ 매 프레임 테이블 생성 (GC 유발)
function love.update(dt)
    for _, enemy in ipairs(enemies) do
        local dir = {x = player.x - enemy.x, y = player.y - enemy.y}  -- 매번 새 테이블!
        local pos = normalize(dir)  -- 또 새 테이블!
        enemy.x = enemy.x + pos.x * enemy.speed * dt
    end
end

-- ✅ 테이블 대신 다중 반환값
local function normalize(x, y)
    local len = math.sqrt(x * x + y * y)
    if len > 0 then
        return x / len, y / len
    end
    return 0, 0
end

function love.update(dt)
    local px, py = player.x, player.y
    for i = 1, #enemies do
        local e = enemies[i]
        local dx, dy = normalize(px - e.x, py - e.y)
        e.x = e.x + dx * e.speed * dt
        e.y = e.y + dy * e.speed * dt
    end
end
```

### 3. 문자열 연결 비용

```lua
-- ❌ 루프에서 .. 반복 (O(n²))
local log = ""
for i = 1, 1000 do
    log = log .. "entity " .. i .. "\n"
end

-- ✅ table.concat 사용 (O(n))
local parts = {}
for i = 1, 1000 do
    parts[i] = string.format("entity %d", i)
end
local log = table.concat(parts, "\n")
```

### 4. string.format vs 연결

```lua
-- 단순 연결 2~3개: .. 가 빠름
local msg = "HP: " .. hp        -- 빠름

-- 복잡한 포맷: string.format이 깔끔하고 비슷한 속도
local msg = string.format("Player[%s] HP:%d/%d Pos:(%.1f,%.1f)",
    name, hp, maxHp, x, y)
```

### 5. 클로저 생성 피하기

```lua
-- ❌ 매 프레임 클로저 생성
function love.update(dt)
    table.sort(enemies, function(a, b)   -- 매번 새 함수 객체!
        return a.y < b.y
    end)
end

-- ✅ 한 번 만들어서 재사용
local sortByY = function(a, b) return a.y < b.y end

function love.update(dt)
    table.sort(enemies, sortByY)
end
```

## 오브젝트 풀링 복습

```lua
-- 총알, 파티클 등 빈번한 생성/삭제 대상
-- 16장에서 자세히 다뤘으므로 핵심만 복습

-- 핵심: new 대신 pool에서 가져오고, 삭제 대신 pool에 반환
-- GC 부담을 획기적으로 줄임

-- 풀 크기 지침:
-- 총알: 화면 최대 동시 존재 수의 1.5배
-- 파티클: 동시 최대 수의 2배
-- 적: 웨이브 최대 수의 1.2배
```

## 수학 캐시

```lua
-- sin/cos 테이블 (정밀도가 중요하지 않을 때)
local SIN_TABLE = {}
local COS_TABLE = {}
local TABLE_SIZE = 360

for i = 0, TABLE_SIZE - 1 do
    local rad = (i / TABLE_SIZE) * math.pi * 2
    SIN_TABLE[i] = math.sin(rad)
    COS_TABLE[i] = math.cos(rad)
end

local function fastSin(angleDeg)
    local index = math.floor(angleDeg % 360)
    return SIN_TABLE[index]
end

local function fastCos(angleDeg)
    local index = math.floor(angleDeg % 360)
    return COS_TABLE[index]
end

-- sqrt 회피: 거리 비교 시 제곱 거리 사용
local function distanceSq(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return dx * dx + dy * dy
end

-- 범위 내인지 확인 (sqrt 불필요)
if distanceSq(ax, ay, bx, by) < range * range then
    -- 범위 내
end
```

## 그리기 최적화

```lua
-- 1. 화면 밖 엔티티는 그리지 않기 (컬링)
function drawEntities()
    local camX, camY = camera:getPos()
    local halfW = love.graphics.getWidth() / 2 + 50   -- 약간의 여유
    local halfH = love.graphics.getHeight() / 2 + 50
    
    for i = 1, #entities do
        local e = entities[i]
        local sx = e.x - camX
        local sy = e.y - camY
        
        if sx > -halfW and sx < halfW and sy > -halfH and sy < halfH then
            drawEntity(e)
        end
    end
end

-- 2. SpriteBatch (같은 이미지를 여러 번 그릴 때)
local batch
function love.load()
    local img = love.graphics.newImage("tile.png")
    batch = love.graphics.newSpriteBatch(img, 1000)
end

function love.draw()
    batch:clear()
    for i = 1, #tiles do
        batch:add(tiles[i].x, tiles[i].y)
    end
    love.graphics.draw(batch)   -- 1회 드로우콜로 1000개 타일
end

-- 3. Canvas 캐싱 (변하지 않는 배경)
local bgCanvas
function love.load()
    bgCanvas = love.graphics.newCanvas(800, 600)
    love.graphics.setCanvas(bgCanvas)
    drawStaticBackground()    -- 한 번만 그림
    love.graphics.setCanvas()
end

function love.draw()
    love.graphics.draw(bgCanvas)   -- 캐시된 배경
    drawDynamicEntities()           -- 동적 요소만 매 프레임
end
```

## per-frame 로그 금지

```lua
-- ❌ 매 프레임 로그 (심각한 성능 저하)
function love.update(dt)
    for _, e in ipairs(entities) do
        print("updating entity: " .. e.name)   -- 매 프레임 1000회!
    end
end

-- ✅ 디버그 플래그로 제한
local DEBUG_ENTITIES = false

function love.update(dt)
    for _, e in ipairs(entities) do
        if DEBUG_ENTITIES then
            print("updating entity: " .. e.name)
        end
    end
end
```

## 최적화 체크리스트

```
□ 프로파일링으로 병목 확인 (추측 X)
□ 핫패스에서 테이블/클로저/문자열 임시 생성 최소화
□ 자주 접근하는 값은 로컬 변수로 캐시
□ 스폰/탄환/파티클은 풀 재사용
□ per-frame 로그 금지 (디버그 플래그로 제한)
□ math.sqrt 대신 제곱 거리 비교
□ 화면 밖 엔티티 컬링
□ 같은 텍스처 다수 그리기 → SpriteBatch
□ 정적 배경 → Canvas 캐싱
□ 수치 변경 후 체감 + FPS 함께 확인
```

---

## 연습문제

### 연습 21-1: 프로파일러 구현
시스템별 실행 시간을 측정하여 화면에 표시하는 프로파일러를 만들어라.
막대 그래프로 각 시스템(input, physics, render 등)의 비용을 시각화할 것.

### 연습 21-2: GC 측정
`collectgarbage("count")`로 메모리 사용량을 매 프레임 표시하라.
1000개 총알을 풀링 없이/풀링으로 생성·삭제하며 메모리 변화를 비교하라.

### 연습 21-3: 최적화 리팩토링
아래 코드의 성능 문제를 모두 찾아 수정하라.

```lua
function love.update(dt)
    for i = 1, #enemies do
        local e = enemies[i]
        local dist = math.sqrt((player.x - e.x)^2 + (player.y - e.y)^2)
        if dist < 100 then
            local dir = {
                x = (player.x - e.x) / dist,
                y = (player.y - e.y) / dist,
            }
            e.x = e.x + dir.x * e.speed * dt
            e.y = e.y + dir.y * e.speed * dt
            print("Enemy " .. e.name .. " chasing player at dist " .. dist)
        end
    end
end
```

### 연습 21-4: 스트레스 테스트
엔티티 수를 100, 500, 1000, 5000으로 늘려가며 FPS 변화를 측정하라.
각 구간에서 병목이 어디인지 (update? draw? collision?) 프로파일링으로 확인하라.

---

[← 이전: 20. 에러 처리](20_error_handling.md) | [다음: 22. C API 개요 →](22_c_api_overview.md)

## 모범 답안

### 21-1
`profile[name] = elapsed_ms`를 프레임마다 갱신하고, draw에서 막대 길이 `elapsed / budget`로 시각화한다.

### 21-2
```lua
local kb = collectgarbage("count")
love.graphics.print(string.format("Mem: %.1f KB", kb), 10, 10)
```
풀링 사용 시 톱니형 메모리 변동과 GC 스파이크가 줄어든다.

### 21-3
개선 포인트:
- `sqrt` 대신 거리 제곱 비교
- 루프 내 테이블 생성 제거 (`dir` 재사용/직접 계산)
- 디버그 `print` 제거 또는 샘플링 로그
- `math` 함수 로컬화

### 21-4
엔티티 수 단계별로 5초 평균 FPS를 기록하고, 시스템별 프로파일 합계로 병목 구간(update/draw/collision)을 분리해서 보고한다.
