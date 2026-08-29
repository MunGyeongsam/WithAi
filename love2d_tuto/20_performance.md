# 20. 성능 최적화

## 프레임 예산

60 FPS = **16.7ms**/프레임. 이 예산을 넘기면 프레임이 떨어진다.

```lua
-- 간단한 프레임 시간 표시
function love.draw()
    local stats = love.graphics.getStats()
    love.graphics.print(string.format(
        "FPS: %d | Draw calls: %d | Texture memory: %.1f MB",
        love.timer.getFPS(),
        stats.drawcalls,
        stats.texturememory / 1024 / 1024
    ), 10, 10)
end
```

## love.graphics.getStats()

| 필드 | 설명 |
|------|------|
| `drawcalls` | 이번 프레임 draw 호출 수 |
| `canvasswitches` | 캔버스 전환 횟수 |
| `texturememory` | GPU 텍스처 메모리 (bytes) |
| `images` | 로드된 이미지 수 |
| `canvases` | 캔버스 수 |
| `fonts` | 폰트 수 |

## 프로파일링

```lua
local function profileBlock(name, func)
    local t0 = love.timer.getTime()
    func()
    local elapsed = (love.timer.getTime() - t0) * 1000
    if elapsed > 1.0 then
        print(string.format("[SLOW] %s: %.2fms", name, elapsed))
    end
end

function love.update(dt)
    profileBlock("physics", function() updatePhysics(dt) end)
    profileBlock("ai",      function() updateAI(dt) end)
    profileBlock("spawn",   function() updateSpawner(dt) end)
end
```

## 핫패스 최적화

### 1. 로컬 캐싱

```lua
-- ❌ 매번 글로벌 룩업
function love.update(dt)
    for i = 1, #entities do
        entities[i].x = entities[i].x + math.cos(entities[i].angle) * entities[i].speed * dt
    end
end

-- ✅ 로컬 캐싱
local cos = math.cos
function love.update(dt)
    local ents = entities
    for i = 1, #ents do
        local e = ents[i]
        e.x = e.x + cos(e.angle) * e.speed * dt
    end
end
```

### 2. 테이블 할당 줄이기 (GC 부담 감소)

```lua
-- ❌ 매 프레임 새 테이블
function getDirection(a, b)
    return {x = b.x - a.x, y = b.y - a.y}
end

-- ✅ 다중 반환값
function getDirection(a, b)
    return b.x - a.x, b.y - a.y
end

-- ✅ 기존 테이블 재사용
local tmp_vec = {x = 0, y = 0}
function getDirectionReuse(a, b)
    tmp_vec.x = b.x - a.x
    tmp_vec.y = b.y - a.y
    return tmp_vec
end
```

### 3. 오브젝트 풀링

```lua
-- bullet_pool.lua
local M = {}
local pool = {}
local active = {}

function M.spawn(x, y, vx, vy)
    local b = table.remove(pool) or {x = 0, y = 0, vx = 0, vy = 0, active = false}
    b.x = x
    b.y = y
    b.vx = vx
    b.vy = vy
    b.active = true
    active[#active + 1] = b
    return b
end

function M.update(dt)
    for i = #active, 1, -1 do
        local b = active[i]
        b.x = b.x + b.vx * dt
        b.y = b.y + b.vy * dt

        if b.x < -50 or b.x > 850 or b.y < -50 or b.y > 650 then
            b.active = false
            pool[#pool + 1] = b
            active[i] = active[#active]
            active[#active] = nil
        end
    end
end

function M.draw()
    for i = 1, #active do
        local b = active[i]
        love.graphics.circle("fill", b.x, b.y, 3)
    end
end

function M.getActiveCount()
    return #active
end

return M
```

## 렌더링 최적화

### SpriteBatch

같은 이미지를 여러 번 그릴 때 draw call을 1회로 줄인다.

```lua
local batch, tileset

function love.load()
    tileset = love.graphics.newImage("assets/tileset.png")
    batch = love.graphics.newSpriteBatch(tileset, 1000)
    rebuildBatch()
end

local function rebuildBatch()
    batch:clear()
    for row = 1, #map do
        for col = 1, #map[row] do
            local tile = map[row][col]
            if tile > 0 then
                batch:add(quads[tile], (col - 1) * 32, (row - 1) * 32)
            end
        end
    end
end

function love.draw()
    love.graphics.draw(batch)   -- 1 draw call!
end
```

### 뷰포트 컬링

화면 밖 오브젝트는 그리지 않는다.

```lua
function love.draw()
    local cam_l = cam_x - 400
    local cam_r = cam_x + 400
    local cam_t = cam_y - 300
    local cam_b = cam_y + 300

    for _, e in ipairs(entities) do
        if e.x + e.radius > cam_l and e.x - e.radius < cam_r
        and e.y + e.radius > cam_t and e.y - e.radius < cam_b then
            drawEntity(e)
        end
    end
end
```

## GC 튜닝

```lua
function love.load()
    -- 점진적 GC: 매 프레임 조금씩 수집
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 200)
end

-- 또는 수동 제어
function love.update(dt)
    collectgarbage("step", 1)   -- 매 프레임 1 step
end
```

## 체크리스트

- [ ] FPS가 일정한가? (`love.timer.getFPS()`)
- [ ] Draw call 수가 합리적인가? (100 이하 권장)
- [ ] 매 프레임 새 테이블을 생성하고 있진 않은가?
- [ ] SpriteBatch로 묶을 수 있는 반복 그리기가 있는가?
- [ ] 화면 밖 오브젝트를 그리고 있진 않은가?
- [ ] math, table 등 표준 함수를 로컬 캐싱했는가?
- [ ] 죽은 오브젝트를 풀에 반환하고 있는가?

## 다음 챕터

게임을 .love 파일과 실행 파일로 패키징하여 배포하는 방법을 배운다.
