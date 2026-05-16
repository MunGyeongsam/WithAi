# 17. 충돌 처리

## 원-원 충돌 (Circle-Circle)

```lua
-- 가장 간단하고 빠른 충돌 검사
-- 2D 슈팅, 로그라이크에서 가장 많이 사용

local function circleCollision(x1, y1, r1, x2, y2, r2)
    local dx = x2 - x1
    local dy = y2 - y1
    local distSq = dx * dx + dy * dy         -- 제곱 거리 (sqrt 회피)
    local radiusSum = r1 + r2
    return distSq <= radiusSum * radiusSum    -- 제곱 비교
end

-- ⚠️ math.sqrt를 피하기 위해 제곱 거리로 비교!
-- 1000개 엔티티에서 매 프레임 호출되면 sqrt 비용이 크다

-- 사용
if circleCollision(bullet.x, bullet.y, bullet.radius,
                   enemy.x, enemy.y, enemy.radius) then
    enemy.hp = enemy.hp - bullet.damage
    bullet.active = false
end
```

## AABB 충돌 (사각형)

```lua
-- Axis-Aligned Bounding Box
-- 회전하지 않는 사각형 간 충돌

local function aabbCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2
       and x2 < x1 + w1
       and y1 < y2 + h2
       and y2 < y1 + h1
end

-- 사용
if aabbCollision(player.x, player.y, player.w, player.h,
                 item.x, item.y, item.w, item.h) then
    collectItem(item)
end
```

## 점-원 충돌

```lua
local function pointInCircle(px, py, cx, cy, r)
    local dx = px - cx
    local dy = py - cy
    return dx * dx + dy * dy <= r * r
end

-- 마우스 클릭이 적에 닿았는지 확인
function love.mousepressed(mx, my, button)
    for _, enemy in ipairs(enemies) do
        if pointInCircle(mx, my, enemy.x, enemy.y, enemy.radius) then
            enemy.hp = enemy.hp - 1
        end
    end
end
```

## 점-사각형 충돌

```lua
local function pointInRect(px, py, rx, ry, rw, rh)
    return px >= rx and px <= rx + rw
       and py >= ry and py <= ry + rh
end
```

## 선-원 충돌 (레이저/빔)

```lua
-- 선분과 원의 충돌
local function lineCircleCollision(x1, y1, x2, y2, cx, cy, r)
    local dx = x2 - x1
    local dy = y2 - y1
    local fx = x1 - cx
    local fy = y1 - cy
    
    local a = dx * dx + dy * dy
    local b = 2 * (fx * dx + fy * dy)
    local c = fx * fx + fy * fy - r * r
    
    local discriminant = b * b - 4 * a * c
    if discriminant < 0 then return false end
    
    discriminant = math.sqrt(discriminant)
    local t1 = (-b - discriminant) / (2 * a)
    local t2 = (-b + discriminant) / (2 * a)
    
    -- t가 0~1 범위면 선분 내에서 충돌
    return (t1 >= 0 and t1 <= 1) or (t2 >= 0 and t2 <= 1)
        or (t1 < 0 and t2 > 1)  -- 선분이 원 안에 있는 경우
end
```

## 충돌 응답

### 밀어내기 (Separation)

```lua
-- 두 원이 겹쳤을 때 밀어내기
local function separateCircles(e1, e2)
    local dx = e2.x - e1.x
    local dy = e2.y - e1.y
    local dist = math.sqrt(dx * dx + dy * dy)
    local overlap = (e1.radius + e2.radius) - dist
    
    if overlap > 0 and dist > 0 then
        -- 정규화된 방향
        local nx = dx / dist
        local ny = dy / dist
        
        -- 각각 절반씩 밀기
        local half = overlap / 2
        e1.x = e1.x - nx * half
        e1.y = e1.y - ny * half
        e2.x = e2.x + nx * half
        e2.y = e2.y + ny * half
    end
end
```

### 반사 (Reflect)

```lua
-- 벽에 부딪혀 튕기기
local function reflect(vx, vy, nx, ny)
    -- v' = v - 2(v·n)n
    local dot = vx * nx + vy * ny
    return vx - 2 * dot * nx, vy - 2 * dot * ny
end

-- 화면 경계 반사
if bullet.x < 0 or bullet.x > 800 then
    bullet.vx = -bullet.vx
end
if bullet.y < 0 or bullet.y > 600 then
    bullet.vy = -bullet.vy
end
```

## 충돌 매트릭스

```lua
-- 어떤 타입 간 충돌을 검사할지 정의
local CollisionMatrix = {
    -- {그룹A, 그룹B, 핸들러}
    {"playerBullets", "enemies", onBulletHitEnemy},
    {"enemyBullets", "players", onBulletHitPlayer},
    {"players", "items", onPlayerCollectItem},
    {"players", "enemies", onPlayerTouchEnemy},
}

function checkAllCollisions(groups)
    for _, rule in ipairs(CollisionMatrix) do
        local groupA = groups[rule[1]]
        local groupB = groups[rule[2]]
        local handler = rule[3]
        
        if groupA and groupB then
            for i = #groupA, 1, -1 do
                for j = #groupB, 1, -1 do
                    local a = groupA[i]
                    local b = groupB[j]
                    if a.active and b.active then
                        if circleCollision(a.x, a.y, a.radius,
                                          b.x, b.y, b.radius) then
                            handler(a, b)
                        end
                    end
                end
            end
        end
    end
end

-- 핸들러
local function onBulletHitEnemy(bullet, enemy)
    enemy.hp = enemy.hp - bullet.damage
    bullet.active = false
    
    if enemy.hp <= 0 then
        enemy.active = false
        addScore(enemy.score)
        spawnExplosion(enemy.x, enemy.y)
    end
end
```

## 최적화: 브로드 페이즈 + 내로우 페이즈

```lua
-- 1단계 (브로드 페이즈): 대략적인 후보 걸러내기
--    → 공간 분할 (16장 Grid), AABB 바운딩 박스
--
-- 2단계 (내로우 페이즈): 정밀 충돌 검사
--    → 원-원, 폴리곤 등

function checkCollisionsOptimized(bullets, enemies)
    Grid.clear()
    for i = 1, #enemies do
        Grid.insert(enemies[i])
    end
    
    for i = 1, #bullets do
        local b = bullets[i]
        if b.active then
            -- 브로드 페이즈: 근처 적만 가져오기
            local nearby = Grid.getNearby(b.x, b.y)
            
            -- 내로우 페이즈: 정밀 검사
            for j = 1, #nearby do
                local e = nearby[j]
                if e.active and circleCollision(
                    b.x, b.y, b.radius,
                    e.x, e.y, e.radius
                ) then
                    onBulletHitEnemy(b, e)
                    break    -- 하나 맞으면 총알 소멸
                end
            end
        end
    end
end
```

## 디버그 시각화

```lua
-- 충돌 영역을 화면에 표시 (디버깅용)
local debugDraw = false

function drawCollisionDebug()
    if not debugDraw then return end
    
    love.graphics.setColor(0, 1, 0, 0.3)
    for _, e in ipairs(entities) do
        if e.active then
            love.graphics.circle("line", e.x, e.y, e.radius)
        end
    end
    
    -- AABB 표시
    love.graphics.setColor(1, 0, 0, 0.3)
    for _, e in ipairs(entities) do
        if e.active then
            love.graphics.rectangle("line",
                e.x - e.radius, e.y - e.radius,
                e.radius * 2, e.radius * 2
            )
        end
    end
    
    love.graphics.setColor(1, 1, 1)
end

function love.keypressed(key)
    if key == "f1" then
        debugDraw = not debugDraw
    end
end
```

---

## 연습문제

### 연습 17-1: 완전한 충돌 시스템
다음 충돌을 모두 구현하라:
- 플레이어 총알 ↔ 적 (적 체력 감소, 총알 소멸)
- 적 ↔ 플레이어 (플레이어 체력 감소, 적 밀어내기)
- 플레이어 ↔ 아이템 (아이템 획득, 아이템 소멸)

### 연습 17-2: 벽 반사 총알
화면 경계에서 3번까지 반사하는 총알을 구현하라. 반사 횟수를 초과하면 소멸.

### 연습 17-3: 충돌 시각화
F1 키로 토글되는 디버그 오버레이를 만들어라:
- 모든 엔티티의 충돌 원 표시 (색상으로 타입 구분)
- 충돌 발생 시 충돌 지점에 빨간 점 표시 (0.5초간)
- 화면에 검사 횟수/충돌 횟수 표시

### 연습 17-4: 공간 분할 비교
적 500마리 + 총알 100발 상황에서:
1. 전수 검사 (O(n*m))
2. 그리드 공간 분할
두 방식의 초당 충돌 검사 횟수를 비교하라. (`love.timer.getTime()`으로 측정)

---

[← 이전: 16. 엔티티 관리](16_entity_management.md) | [다음: 18. 코루틴 활용 →](18_coroutines_for_games.md)
