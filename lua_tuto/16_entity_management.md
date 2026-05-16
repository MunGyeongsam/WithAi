# 16. 엔티티 관리

## 엔티티 배열 패턴

```lua
-- 가장 기본적인 패턴: 테이블 배열로 엔티티 관리
local entities = {}

local function spawnEnemy(x, y)
    entities[#entities + 1] = {
        x = x,
        y = y,
        vx = 0,
        vy = 50,
        hp = 3,
        radius = 10,
        type = "enemy",
        active = true,
    }
end

function love.update(dt)
    for i = #entities, 1, -1 do     -- ⚠️ 역순 순회 (삭제 시 안전)
        local e = entities[i]
        if e.active then
            e.x = e.x + e.vx * dt
            e.y = e.y + e.vy * dt
            
            -- 화면 밖이면 제거
            if e.y > 700 then
                e.active = false
            end
        end
        
        if not e.active then
            table.remove(entities, i)    -- 역순이라 안전
        end
    end
end
```

### 왜 역순 순회인가?

```lua
-- ❌ 정순 순회 + 제거 = 버그!
local t = {"a", "b", "c", "d"}
for i = 1, #t do
    if t[i] == "b" then
        table.remove(t, i)
    end
end
-- "c"가 i=2로 이동하지만 i는 3으로 넘어감 → "c" 건너뜀!

-- ✅ 역순 순회 + 제거 = 안전
for i = #t, 1, -1 do
    if t[i] == "b" then
        table.remove(t, i)    -- 뒤쪽만 영향, 이미 처리한 부분
    end
end
```

## 타입별 분리 관리

```lua
-- 대량 엔티티 시 타입별 분리가 효율적
local entities = {
    players = {},
    enemies = {},
    bullets = {},
    items = {},
}

-- 타입별 업데이트 (충돌 검사 범위 축소)
function love.update(dt)
    updatePlayers(entities.players, dt)
    updateEnemies(entities.enemies, dt)
    updateBullets(entities.bullets, dt)
    
    -- 총알-적 충돌 (교차 검사만)
    checkCollisions(entities.bullets, entities.enemies)
end
```

## 엔티티 팩토리 패턴

```lua
-- 엔티티 생성을 데이터 기반으로
local EnemyData = {
    slime = {
        hp = 3, speed = 30, radius = 8,
        color = {0, 1, 0},
        score = 10,
    },
    bat = {
        hp = 1, speed = 80, radius = 6,
        color = {0.5, 0, 1},
        score = 20,
    },
    goblin = {
        hp = 5, speed = 50, radius = 12,
        color = {0, 0.5, 0},
        score = 30,
    },
}

local function createEnemy(typeName, x, y)
    local data = EnemyData[typeName]
    if not data then
        error("Unknown enemy type: " .. tostring(typeName))
    end
    
    return {
        type = typeName,
        x = x,
        y = y,
        vx = 0,
        vy = data.speed,
        hp = data.hp,
        maxHp = data.hp,
        radius = data.radius,
        color = data.color,
        score = data.score,
        active = true,
    }
end

-- 사용
local enemy = createEnemy("bat", 400, 0)
entities.enemies[#entities.enemies + 1] = enemy
```

## 오브젝트 풀링

```lua
-- 총알, 파티클 등 대량 생성/삭제되는 엔티티에 필수
local BulletPool = {
    pool = {},         -- 사용 가능한 객체
    active = {},       -- 활성 객체
    activeCount = 0,
}

-- 풀에서 가져오기
function BulletPool.spawn(x, y, vx, vy)
    local bullet
    local poolSize = #BulletPool.pool
    
    if poolSize > 0 then
        -- 풀에서 재사용
        bullet = BulletPool.pool[poolSize]
        BulletPool.pool[poolSize] = nil
    else
        -- 풀이 비었으면 새로 생성
        bullet = {}
    end
    
    -- 초기화
    bullet.x = x
    bullet.y = y
    bullet.vx = vx
    bullet.vy = vy
    bullet.active = true
    bullet.life = 3.0    -- 3초 수명
    
    BulletPool.activeCount = BulletPool.activeCount + 1
    BulletPool.active[BulletPool.activeCount] = bullet
    
    return bullet
end

-- 풀에 반환
function BulletPool.despawn(index)
    local bullet = BulletPool.active[index]
    bullet.active = false
    
    -- swap-remove로 O(1) 삭제
    BulletPool.active[index] = BulletPool.active[BulletPool.activeCount]
    BulletPool.active[BulletPool.activeCount] = nil
    BulletPool.activeCount = BulletPool.activeCount - 1
    
    -- 풀에 반환
    BulletPool.pool[#BulletPool.pool + 1] = bullet
end

-- 전체 업데이트
function BulletPool.update(dt)
    -- ⚠️ swap-remove를 쓰므로 역순 순회
    for i = BulletPool.activeCount, 1, -1 do
        local b = BulletPool.active[i]
        b.x = b.x + b.vx * dt
        b.y = b.y + b.vy * dt
        b.life = b.life - dt
        
        if b.life <= 0 or b.y < -50 or b.y > 650 then
            BulletPool.despawn(i)
        end
    end
end

function BulletPool.draw()
    love.graphics.setColor(1, 1, 0)
    for i = 1, BulletPool.activeCount do
        local b = BulletPool.active[i]
        love.graphics.circle("fill", b.x, b.y, 3)
    end
end
```

## 엔티티 ID 시스템

```lua
-- 엔티티를 ID로 참조하면 dangling reference 문제를 피할 수 있다
local EntityManager = {
    entities = {},
    nextId = 1,
}

function EntityManager.create(data)
    local id = EntityManager.nextId
    EntityManager.nextId = id + 1
    
    data.id = id
    data.active = true
    EntityManager.entities[id] = data
    
    return id
end

function EntityManager.get(id)
    return EntityManager.entities[id]
end

function EntityManager.destroy(id)
    local entity = EntityManager.entities[id]
    if entity then
        entity.active = false
        EntityManager.entities[id] = nil
    end
end

function EntityManager.forEach(callback)
    for id, entity in pairs(EntityManager.entities) do
        if entity.active then
            callback(id, entity)
        end
    end
end

-- 사용
local playerId = EntityManager.create({x = 400, y = 500, type = "player"})
local enemyId = EntityManager.create({x = 200, y = 100, type = "enemy"})

EntityManager.forEach(function(id, e)
    print(id, e.type, e.x, e.y)
end)

EntityManager.destroy(enemyId)
-- enemyId로 다시 접근하면 nil (안전)
```

## 공간 분할 (기초)

```lua
-- 대량 엔티티의 충돌 검사 최적화
-- 간단한 그리드 기반 공간 분할

local Grid = {
    cellSize = 64,
    cells = {},
}

function Grid.clear()
    Grid.cells = {}
end

function Grid.getKey(x, y)
    local cx = math.floor(x / Grid.cellSize)
    local cy = math.floor(y / Grid.cellSize)
    return cx .. "," .. cy
end

function Grid.insert(entity)
    local key = Grid.getKey(entity.x, entity.y)
    if not Grid.cells[key] then
        Grid.cells[key] = {}
    end
    local cell = Grid.cells[key]
    cell[#cell + 1] = entity
end

function Grid.getNearby(x, y)
    local result = {}
    local cx = math.floor(x / Grid.cellSize)
    local cy = math.floor(y / Grid.cellSize)
    
    -- 자기 셀 + 8방향 이웃
    for dx = -1, 1 do
        for dy = -1, 1 do
            local key = (cx + dx) .. "," .. (cy + dy)
            local cell = Grid.cells[key]
            if cell then
                for i = 1, #cell do
                    result[#result + 1] = cell[i]
                end
            end
        end
    end
    return result
end

-- 매 프레임 사용
function love.update(dt)
    Grid.clear()
    
    -- 모든 엔티티를 그리드에 삽입
    for _, enemy in ipairs(enemies) do
        Grid.insert(enemy)
    end
    
    -- 각 총알에 대해 근처 적만 충돌 검사
    for _, bullet in ipairs(bullets) do
        local nearby = Grid.getNearby(bullet.x, bullet.y)
        for _, enemy in ipairs(nearby) do
            if checkCollision(bullet, enemy) then
                -- 충돌 처리
            end
        end
    end
end
```

---

## 연습문제

### 연습 16-1: 엔티티 관리자
위의 패턴들을 조합하여 완전한 엔티티 관리 시스템을 구현하라:
- 팩토리로 적 생성
- 풀링으로 총알 관리
- 역순 순회로 안전한 제거

### 연습 16-2: 스폰 패턴
다양한 적 스폰 패턴을 구현하라:
- 랜덤 위치에서 하나씩
- 화면 상단에서 일렬로 5마리
- V자 형태로 7마리
- 원형으로 8마리

### 연습 16-3: 풀 성능 비교
1000개 총알을 매 프레임 생성/삭제하는 코드를 작성하고:
1. `table.remove`로 삭제하는 버전
2. swap-remove로 삭제하는 버전
3. 오브젝트 풀을 사용하는 버전
세 버전의 체감 차이를 FPS로 확인하라.

### 연습 16-4: 공간 분할
그리드 공간 분할을 시각화하라:
- 그리드 선을 화면에 그리기
- 각 셀의 엔티티 수 표시
- 충돌 검사 대상 셀을 다른 색으로 표시

---

[← 이전: 15. 게임 루프](15_game_loop_pattern.md) | [다음: 17. 충돌 처리 →](17_collision.md)
