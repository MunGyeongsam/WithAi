# 19. ECS 패턴 입문

> Entity-Component-System: 게임 엔티티를 설계하는 아키텍처 패턴.  
> Unity DOTS/ECS, Overwatch 엔진 등에서 사용.  
> 상속 기반 OOP의 대안으로, 조합(Composition)에 기반한다.

## 왜 ECS인가?

### OOP의 문제: 다이아몬드 상속

```
        Entity
       /      \
  Movable    Damageable
       \      /
       Player         ← C++에서는 다중 상속 문제
                        C#에서는 다중 상속 불가
```

### OOP의 문제: 비대한 기본 클래스

```lua
-- 시간이 지나면 Entity 기본 클래스가 점점 커진다
local Entity = {}
-- x, y, vx, vy, hp, maxHp, damage, armor, speed,
-- sprite, animFrame, animTimer, sounds, particles,
-- ai, target, state, inventory, buffs, debuffs, ...
-- 모든 엔티티가 이 필드를 다 가짐 (메모리 낭비 + 복잡)
```

### ECS 해결: 조합으로 엔티티 구성

```
Entity = 컴포넌트들의 조합 (ID에 불과)

Player = Position + Velocity + Health + PlayerInput + Render
Enemy  = Position + Velocity + Health + AI + Render
Bullet = Position + Velocity + Render + Damage
Item   = Position + Render + Collectable
Cloud  = Position + Velocity + Render  (체력 없음, AI 없음)
```

## ECS 핵심 개념

```
Entity    = ID (숫자). 그 자체로는 데이터 없음.
Component = 순수 데이터 (함수 없음). Entity에 붙이는 속성.
System    = 로직. 특정 컴포넌트 조합을 가진 Entity를 처리.
```

## 간단한 ECS 구현

### Entity Manager

```lua
local ECS = {}
local entities = {}     -- id → {component_name → data}
local nextId = 1

function ECS.createEntity()
    local id = nextId
    nextId = nextId + 1
    entities[id] = {}
    return id
end

function ECS.destroyEntity(id)
    entities[id] = nil
end

function ECS.addComponent(id, name, data)
    if entities[id] then
        entities[id][name] = data
    end
end

function ECS.removeComponent(id, name)
    if entities[id] then
        entities[id][name] = nil
    end
end

function ECS.getComponent(id, name)
    if entities[id] then
        return entities[id][name]
    end
    return nil
end

function ECS.hasComponent(id, name)
    return entities[id] and entities[id][name] ~= nil
end
```

### 쿼리 (특정 컴포넌트 조합 찾기)

```lua
-- "position"과 "velocity" 모두 가진 엔티티 찾기
function ECS.query(...)
    local required = {...}
    local result = {}
    
    for id, components in pairs(entities) do
        local match = true
        for _, name in ipairs(required) do
            if not components[name] then
                match = false
                break
            end
        end
        if match then
            result[#result + 1] = id
        end
    end
    
    return result
end

-- 사용
local movers = ECS.query("position", "velocity")
for _, id in ipairs(movers) do
    local pos = ECS.getComponent(id, "position")
    local vel = ECS.getComponent(id, "velocity")
    pos.x = pos.x + vel.x * dt
    pos.y = pos.y + vel.y * dt
end
```

### 컴포넌트 정의

```lua
-- 컴포넌트 = 순수 데이터 테이블 (메서드 없음!)
-- 팩토리 함수로 기본값과 함께 생성

local Components = {}

function Components.position(x, y)
    return {x = x or 0, y = y or 0}
end

function Components.velocity(vx, vy)
    return {x = vx or 0, y = vy or 0}
end

function Components.health(hp, maxHp)
    maxHp = maxHp or hp
    return {current = hp, max = maxHp}
end

function Components.render(shape, color, radius)
    return {
        shape = shape or "circle",
        color = color or {1, 1, 1},
        radius = radius or 10,
    }
end

function Components.collider(radius, layer)
    return {radius = radius or 10, layer = layer or "default"}
end

function Components.playerInput()
    return {speed = 200}
end

function Components.enemyAI(aiType)
    return {type = aiType or "chase", timer = 0}
end

function Components.damage(amount)
    return {amount = amount or 1}
end
```

### 엔티티 팩토리

```lua
local EntityFactory = {}

function EntityFactory.createPlayer(x, y)
    local id = ECS.createEntity()
    ECS.addComponent(id, "position", Components.position(x, y))
    ECS.addComponent(id, "velocity", Components.velocity(0, 0))
    ECS.addComponent(id, "health", Components.health(100))
    ECS.addComponent(id, "render", Components.render("circle", {0, 1, 0}, 15))
    ECS.addComponent(id, "collider", Components.collider(15, "player"))
    ECS.addComponent(id, "playerInput", Components.playerInput())
    return id
end

function EntityFactory.createEnemy(x, y, aiType)
    local id = ECS.createEntity()
    ECS.addComponent(id, "position", Components.position(x, y))
    ECS.addComponent(id, "velocity", Components.velocity(0, 50))
    ECS.addComponent(id, "health", Components.health(3))
    ECS.addComponent(id, "render", Components.render("circle", {1, 0, 0}, 10))
    ECS.addComponent(id, "collider", Components.collider(10, "enemy"))
    ECS.addComponent(id, "enemyAI", Components.enemyAI(aiType))
    return id
end

function EntityFactory.createBullet(x, y, vx, vy)
    local id = ECS.createEntity()
    ECS.addComponent(id, "position", Components.position(x, y))
    ECS.addComponent(id, "velocity", Components.velocity(vx, vy))
    ECS.addComponent(id, "render", Components.render("circle", {1, 1, 0}, 3))
    ECS.addComponent(id, "collider", Components.collider(3, "bullet"))
    ECS.addComponent(id, "damage", Components.damage(1))
    return id
end
```

### 시스템 정의

```lua
local Systems = {}

-- 이동 시스템: position + velocity 가진 엔티티 처리
function Systems.movement(dt)
    local movers = ECS.query("position", "velocity")
    for _, id in ipairs(movers) do
        local pos = ECS.getComponent(id, "position")
        local vel = ECS.getComponent(id, "velocity")
        pos.x = pos.x + vel.x * dt
        pos.y = pos.y + vel.y * dt
    end
end

-- 플레이어 입력 시스템
function Systems.playerInput(dt)
    local players = ECS.query("playerInput", "velocity")
    for _, id in ipairs(players) do
        local input = ECS.getComponent(id, "playerInput")
        local vel = ECS.getComponent(id, "velocity")
        
        vel.x = 0
        vel.y = 0
        if love.keyboard.isDown("left") then vel.x = -input.speed end
        if love.keyboard.isDown("right") then vel.x = input.speed end
        if love.keyboard.isDown("up") then vel.y = -input.speed end
        if love.keyboard.isDown("down") then vel.y = input.speed end
    end
end

-- 렌더 시스템
function Systems.render()
    local drawables = ECS.query("position", "render")
    for _, id in ipairs(drawables) do
        local pos = ECS.getComponent(id, "position")
        local rend = ECS.getComponent(id, "render")
        
        love.graphics.setColor(rend.color)
        if rend.shape == "circle" then
            love.graphics.circle("fill", pos.x, pos.y, rend.radius)
        end
    end
    love.graphics.setColor(1, 1, 1)
end

-- AI 시스템
function Systems.enemyAI(dt, playerPos)
    local aiEntities = ECS.query("enemyAI", "position", "velocity")
    for _, id in ipairs(aiEntities) do
        local ai = ECS.getComponent(id, "enemyAI")
        local pos = ECS.getComponent(id, "position")
        local vel = ECS.getComponent(id, "velocity")
        
        if ai.type == "chase" and playerPos then
            local dx = playerPos.x - pos.x
            local dy = playerPos.y - pos.y
            local dist = math.sqrt(dx * dx + dy * dy)
            if dist > 0 then
                vel.x = (dx / dist) * 50
                vel.y = (dy / dist) * 50
            end
        end
    end
end
```

### 메인 루프에서 시스템 실행

```lua
function love.update(dt)
    Systems.playerInput(dt)
    Systems.enemyAI(dt, playerPos)
    Systems.movement(dt)
    -- Systems.collision(dt)
    -- Systems.health(dt)
    -- Systems.cleanup(dt)
end

function love.draw()
    Systems.render()
    -- Systems.debugDraw()
end
```

## ECS의 장점

```lua
-- 1. 조합의 자유도
-- 새로운 적 타입 = 컴포넌트 조합만 변경
local ghost = ECS.createEntity()
ECS.addComponent(ghost, "position", Components.position(100, 100))
ECS.addComponent(ghost, "render", Components.render("circle", {0.5, 0.5, 1}, 12))
-- velocity 없음 → 이동 시스템에 영향 안 받음
-- health 없음 → 무적

-- 2. 런타임에 동적 조합 변경
-- 적이 아이스 디버프를 받으면:
ECS.addComponent(enemyId, "frozen", {duration = 3.0})
-- frozen 시스템이 velocity를 0으로 만듦

-- 3. 시스템 추가가 기존 코드에 영향 없음
-- 새 시스템: 화면 밖 엔티티 제거
function Systems.outOfBounds()
    local entities = ECS.query("position")
    for _, id in ipairs(entities) do
        local pos = ECS.getComponent(id, "position")
        if pos.y > 700 or pos.y < -100 then
            ECS.destroyEntity(id)
        end
    end
end
-- 기존 시스템 수정 없이 추가만 하면 됨!
```

## OOP vs ECS 선택 기준

```
상황                          추천
──────────────────────────────────────
프로토타입, 빠른 개발         OOP
엔티티 타입 5개 이하          OOP
엔티티 타입이 계속 늘어남     ECS
같은 동작을 여러 타입이 공유  ECS
런타임에 동적으로 기능 추가   ECS
1000+ 엔티티 성능 중요        ECS (캐시 친화적 구조 가능)
```

---

## 연습문제

### 연습 19-1: ECS 미니게임
위의 ECS 프레임워크를 사용하여:
- 플레이어 1개 (WASD 이동)
- 적 10개 (플레이어 추적)
- Space로 총알 발사
- 총알-적 충돌 시 적 제거

### 연습 19-2: 컴포넌트 추가
새 컴포넌트를 추가하라:
- `lifetime(seconds)`: 시간이 지나면 자동 소멸
- `spawner(interval, factory)`: 일정 간격으로 엔티티 생성
- `invincible(duration)`: 일시적 무적

### 연습 19-3: 시스템 순서
시스템 실행 순서가 왜 중요한지 실험하라:
- `movement → collision` vs `collision → movement`
- 결과가 어떻게 다른지 확인

### 연습 19-4: ECS 확장
쿼리 성능을 개선하라:
- 현재: 매번 전체 엔티티 순회
- 개선: 컴포넌트별 엔티티 목록 캐시 (addComponent/removeComponent 시 갱신)

---

[← 이전: 18. 코루틴](18_coroutines_for_games.md) | [다음: 20. 에러 처리 →](20_error_handling.md)
