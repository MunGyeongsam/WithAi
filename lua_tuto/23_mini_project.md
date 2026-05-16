# 23. 미니 프로젝트 — Vector Shooter

> 전체 강좌 내용을 통합하여 간단한 슈팅 게임을 만든다.  
> 이미지 없이 코드만으로 (Zero-Art 스타일).

## 프로젝트 구조

```
mini_shooter/
├── main.lua          -- 진입점
├── conf.lua          -- 설정
├── lib/
│   ├── utils.lua     -- 유틸리티 (Ch.10)
│   └── timer.lua     -- 타이머 (Ch.15)
├── ecs/
│   ├── ecs.lua       -- ECS 코어 (Ch.19)
│   ├── components.lua -- 컴포넌트 (Ch.19)
│   └── factory.lua   -- 엔티티 팩토리 (Ch.16)
├── systems/
│   ├── input.lua     -- 입력 (Ch.13)
│   ├── movement.lua  -- 이동 (Ch.19)
│   ├── collision.lua -- 충돌 (Ch.17)
│   ├── render.lua    -- 렌더링 (Ch.12)
│   ├── health.lua    -- 체력 관리
│   └── spawner.lua   -- 스포너 (Ch.16)
└── scenes/
    ├── menu.lua      -- 메뉴 (Ch.15)
    ├── game.lua      -- 게임
    └── gameover.lua  -- 게임오버
```

## Step 1: conf.lua

```lua
function love.conf(t)
    t.window.title = "Vector Shooter"
    t.window.width = 800
    t.window.height = 600
    t.window.vsync = 1
    t.identity = "vector_shooter"
    t.version = "11.5"
    t.modules.physics = false
    t.modules.joystick = false
end
```

## Step 2: 유틸리티 (lib/utils.lua)

```lua
local M = {}

function M.clamp(value, min, max)
    if value < min then return min end
    if value > max then return max end
    return value
end

function M.distance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx * dx + dy * dy)
end

function M.distanceSq(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return dx * dx + dy * dy
end

function M.normalize(x, y)
    local len = math.sqrt(x * x + y * y)
    if len > 0 then
        return x / len, y / len
    end
    return 0, 0
end

function M.angle(x1, y1, x2, y2)
    return math.atan2(y2 - y1, x2 - x1)
end

function M.lerp(a, b, t)
    return a + (b - a) * t
end

return M
```

## Step 3: ECS 코어 (ecs/ecs.lua)

```lua
local ECS = {}
local entities = {}
local nextId = 1
local toDestroy = {}

function ECS.create()
    local id = nextId
    nextId = nextId + 1
    entities[id] = {}
    return id
end

function ECS.destroy(id)
    toDestroy[#toDestroy + 1] = id
end

function ECS.flushDestroy()
    for i = 1, #toDestroy do
        entities[toDestroy[i]] = nil
    end
    for i = #toDestroy, 1, -1 do
        toDestroy[i] = nil
    end
end

function ECS.add(id, name, data)
    if entities[id] then
        entities[id][name] = data
    end
end

function ECS.get(id, name)
    local e = entities[id]
    return e and e[name]
end

function ECS.has(id, name)
    return entities[id] and entities[id][name] ~= nil
end

function ECS.query(...)
    local required = {...}
    local result = {}
    local n = 0
    for id, comps in pairs(entities) do
        local match = true
        for j = 1, #required do
            if not comps[required[j]] then
                match = false
                break
            end
        end
        if match then
            n = n + 1
            result[n] = id
        end
    end
    return result, n
end

function ECS.reset()
    entities = {}
    nextId = 1
    toDestroy = {}
end

return ECS
```

## Step 4: 컴포넌트 (ecs/components.lua)

```lua
local C = {}

function C.position(x, y)
    return {x = x or 0, y = y or 0}
end

function C.velocity(vx, vy)
    return {x = vx or 0, y = vy or 0}
end

function C.health(hp)
    return {current = hp, max = hp}
end

function C.render(shape, r, g, b, radius)
    return {
        shape = shape or "circle",
        r = r or 1, g = g or 1, b = b or 1,
        radius = radius or 10,
    }
end

function C.collider(radius, layer)
    return {radius = radius or 10, layer = layer or "default"}
end

function C.playerTag()
    return {speed = 250, shootCooldown = 0, shootInterval = 0.15}
end

function C.enemyTag(score)
    return {score = score or 10}
end

function C.bulletTag(damage)
    return {damage = damage or 1}
end

function C.lifetime(seconds)
    return {remaining = seconds}
end

return C
```

## Step 5: 팩토리 (ecs/factory.lua)

```lua
local ECS = require("ecs.ecs")
local C = require("ecs.components")

local F = {}

function F.player(x, y)
    local id = ECS.create()
    ECS.add(id, "position", C.position(x, y))
    ECS.add(id, "velocity", C.velocity())
    ECS.add(id, "health", C.health(5))
    ECS.add(id, "render", C.render("triangle", 0, 1, 0.5, 15))
    ECS.add(id, "collider", C.collider(12, "player"))
    ECS.add(id, "playerTag", C.playerTag())
    return id
end

function F.enemy(x, y, speed)
    local id = ECS.create()
    ECS.add(id, "position", C.position(x, y))
    ECS.add(id, "velocity", C.velocity(0, speed or 60))
    ECS.add(id, "health", C.health(2))
    ECS.add(id, "render", C.render("circle", 1, 0.2, 0.2, 12))
    ECS.add(id, "collider", C.collider(12, "enemy"))
    ECS.add(id, "enemyTag", C.enemyTag(10))
    return id
end

function F.bullet(x, y, vx, vy)
    local id = ECS.create()
    ECS.add(id, "position", C.position(x, y))
    ECS.add(id, "velocity", C.velocity(vx, vy))
    ECS.add(id, "render", C.render("circle", 1, 1, 0, 3))
    ECS.add(id, "collider", C.collider(3, "playerBullet"))
    ECS.add(id, "bulletTag", C.bulletTag(1))
    ECS.add(id, "lifetime", C.lifetime(2))
    return id
end

function F.particle(x, y, vx, vy, r, g, b, life)
    local id = ECS.create()
    ECS.add(id, "position", C.position(x, y))
    ECS.add(id, "velocity", C.velocity(vx, vy))
    ECS.add(id, "render", C.render("circle", r, g, b, 2))
    ECS.add(id, "lifetime", C.lifetime(life or 0.5))
    return id
end

return F
```

## Step 6: 시스템들 (systems/)

### systems/input.lua

```lua
local ECS = require("ecs.ecs")
local F = require("ecs.factory")

local M = {}
local sin, cos = math.sin, math.cos

function M.update(dt)
    local ids = ECS.query("playerTag", "position", "velocity")
    for i = 1, #ids do
        local id = ids[i]
        local tag = ECS.get(id, "playerTag")
        local vel = ECS.get(id, "velocity")
        local pos = ECS.get(id, "position")
        
        -- 이동
        local dx, dy = 0, 0
        if love.keyboard.isDown("left", "a") then dx = dx - 1 end
        if love.keyboard.isDown("right", "d") then dx = dx + 1 end
        if love.keyboard.isDown("up", "w") then dy = dy - 1 end
        if love.keyboard.isDown("down", "s") then dy = dy + 1 end
        
        -- 대각선 정규화
        if dx ~= 0 and dy ~= 0 then
            local len = 1.4142135  -- sqrt(2)
            dx = dx / len
            dy = dy / len
        end
        
        vel.x = dx * tag.speed
        vel.y = dy * tag.speed
        
        -- 사격
        tag.shootCooldown = tag.shootCooldown - dt
        if love.keyboard.isDown("space") and tag.shootCooldown <= 0 then
            tag.shootCooldown = tag.shootInterval
            F.bullet(pos.x, pos.y - 20, 0, -500)
        end
    end
end

return M
```

### systems/movement.lua

```lua
local ECS = require("ecs.ecs")
local utils = require("lib.utils")

local M = {}

function M.update(dt)
    local ids = ECS.query("position", "velocity")
    for i = 1, #ids do
        local id = ids[i]
        local pos = ECS.get(id, "position")
        local vel = ECS.get(id, "velocity")
        
        pos.x = pos.x + vel.x * dt
        pos.y = pos.y + vel.y * dt
        
        -- 플레이어는 화면 내로 제한
        if ECS.has(id, "playerTag") then
            pos.x = utils.clamp(pos.x, 20, 780)
            pos.y = utils.clamp(pos.y, 20, 580)
        end
    end
end

return M
```

### systems/collision.lua

```lua
local ECS = require("ecs.ecs")
local F = require("ecs.factory")

local M = {}
local random = math.random

local function spawnExplosion(x, y, r, g, b)
    for i = 1, 8 do
        local angle = (i / 8) * math.pi * 2
        local speed = 50 + random(100)
        local vx = math.cos(angle) * speed
        local vy = math.sin(angle) * speed
        F.particle(x, y, vx, vy, r, g, b, 0.3 + random() * 0.3)
    end
end

function M.update(dt, gameState)
    -- 총알 vs 적
    local bullets = ECS.query("bulletTag", "position", "collider")
    local enemies = ECS.query("enemyTag", "position", "collider", "health")
    
    for i = 1, #bullets do
        local bid = bullets[i]
        local bpos = ECS.get(bid, "position")
        local bcol = ECS.get(bid, "collider")
        
        for j = 1, #enemies do
            local eid = enemies[j]
            local epos = ECS.get(eid, "position")
            local ecol = ECS.get(eid, "collider")
            
            local dx = epos.x - bpos.x
            local dy = epos.y - bpos.y
            local distSq = dx * dx + dy * dy
            local rSum = bcol.radius + ecol.radius
            
            if distSq <= rSum * rSum then
                -- 충돌!
                local hp = ECS.get(eid, "health")
                local btag = ECS.get(bid, "bulletTag")
                hp.current = hp.current - btag.damage
                
                ECS.destroy(bid)
                
                if hp.current <= 0 then
                    local etag = ECS.get(eid, "enemyTag")
                    gameState.score = gameState.score + etag.score
                    spawnExplosion(epos.x, epos.y, 1, 0.5, 0.1)
                    ECS.destroy(eid)
                end
                break
            end
        end
    end
    
    -- 적 vs 플레이어
    local players = ECS.query("playerTag", "position", "collider", "health")
    for i = 1, #enemies do
        local eid = enemies[i]
        local epos = ECS.get(eid, "position")
        local ecol = ECS.get(eid, "collider")
        if epos and ecol then
            for j = 1, #players do
                local pid = players[j]
                local ppos = ECS.get(pid, "position")
                local pcol = ECS.get(pid, "collider")
                
                local dx = ppos.x - epos.x
                local dy = ppos.y - epos.y
                local distSq = dx * dx + dy * dy
                local rSum = pcol.radius + ecol.radius
                
                if distSq <= rSum * rSum then
                    local php = ECS.get(pid, "health")
                    php.current = php.current - 1
                    spawnExplosion(epos.x, epos.y, 1, 0.2, 0.2)
                    ECS.destroy(eid)
                    break
                end
            end
        end
    end
end

return M
```

### systems/render.lua

```lua
local ECS = require("ecs.ecs")

local M = {}
local setColor = love.graphics.setColor
local circle = love.graphics.circle
local polygon = love.graphics.polygon

function M.draw()
    local ids = ECS.query("position", "render")
    for i = 1, #ids do
        local id = ids[i]
        local pos = ECS.get(id, "position")
        local rend = ECS.get(id, "render")
        
        setColor(rend.r, rend.g, rend.b)
        
        if rend.shape == "circle" then
            circle("fill", pos.x, pos.y, rend.radius)
        elseif rend.shape == "triangle" then
            local r = rend.radius
            polygon("fill",
                pos.x, pos.y - r,           -- top
                pos.x - r * 0.8, pos.y + r, -- bottom-left
                pos.x + r * 0.8, pos.y + r  -- bottom-right
            )
        end
    end
    
    setColor(1, 1, 1)
end

return M
```

### systems/spawner.lua

```lua
local ECS = require("ecs.ecs")
local F = require("ecs.factory")

local M = {}
local timer = 0
local interval = 1.5
local minInterval = 0.3
local elapsed = 0
local random = math.random

function M.init()
    timer = 0
    interval = 1.5
    elapsed = 0
end

function M.update(dt)
    elapsed = elapsed + dt
    timer = timer + dt
    
    -- 시간에 따라 스폰 간격 감소
    local currentInterval = math.max(minInterval, interval - elapsed * 0.005)
    
    if timer >= currentInterval then
        timer = timer - currentInterval
        local x = 50 + random(700)
        local speed = 40 + random(80) + elapsed * 0.5
        F.enemy(x, -20, speed)
    end
end

return M
```

### systems/health.lua (+ lifetime)

```lua
local ECS = require("ecs.ecs")

local M = {}

function M.update(dt, gameState)
    -- 수명 시스템
    local ids = ECS.query("lifetime")
    for i = 1, #ids do
        local id = ids[i]
        local lt = ECS.get(id, "lifetime")
        lt.remaining = lt.remaining - dt
        if lt.remaining <= 0 then
            ECS.destroy(id)
        end
    end
    
    -- 화면 밖 적 제거
    local enemies = ECS.query("enemyTag", "position")
    for i = 1, #enemies do
        local id = enemies[i]
        local pos = ECS.get(id, "position")
        if pos.y > 650 then
            ECS.destroy(id)
        end
    end
    
    -- 플레이어 사망 체크
    local players = ECS.query("playerTag", "health")
    for i = 1, #players do
        local id = players[i]
        local hp = ECS.get(id, "health")
        if hp.current <= 0 then
            gameState.alive = false
        end
    end
end

return M
```

## Step 7: 씬 (scenes/)

### scenes/menu.lua

```lua
local M = {}

function M.enter() end

function M.update(dt) end

function M.draw()
    love.graphics.setColor(0.2, 1, 0.5)
    love.graphics.printf("VECTOR SHOOTER", 0, 200, 800, "center")
    
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.printf("Press ENTER to start", 0, 280, 800, "center")
    love.graphics.printf("WASD to move, SPACE to shoot", 0, 320, 800, "center")
    
    love.graphics.setColor(1, 1, 1)
end

function M.keypressed(key)
    if key == "return" then
        return "game"
    end
end

return M
```

### scenes/game.lua

```lua
local ECS = require("ecs.ecs")
local F = require("ecs.factory")
local inputSys = require("systems.input")
local moveSys = require("systems.movement")
local collSys = require("systems.collision")
local renderSys = require("systems.render")
local spawnerSys = require("systems.spawner")
local healthSys = require("systems.health")

local M = {}
local gameState

function M.enter()
    ECS.reset()
    gameState = {score = 0, alive = true}
    F.player(400, 500)
    spawnerSys.init()
end

function M.update(dt)
    if not gameState.alive then return "gameover", gameState end
    
    inputSys.update(dt)
    spawnerSys.update(dt)
    moveSys.update(dt)
    collSys.update(dt, gameState)
    healthSys.update(dt, gameState)
    ECS.flushDestroy()
end

function M.draw()
    renderSys.draw()
    
    -- HUD
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. gameState.score, 10, 10)
    
    -- 플레이어 HP 표시
    local players = ECS.query("playerTag", "health")
    if #players > 0 then
        local hp = ECS.get(players[1], "health")
        love.graphics.print(string.format("HP: %d/%d", hp.current, hp.max), 10, 30)
    end
    
    love.graphics.print(string.format("FPS: %d", love.timer.getFPS()), 720, 10)
end

function M.keypressed(key)
    if key == "escape" then
        return "menu"
    end
end

return M
```

### scenes/gameover.lua

```lua
local M = {}
local finalScore = 0

function M.enter(data)
    if data then
        finalScore = data.score or 0
    end
end

function M.update(dt) end

function M.draw()
    love.graphics.setColor(1, 0.2, 0.2)
    love.graphics.printf("GAME OVER", 0, 200, 800, "center")
    
    love.graphics.setColor(1, 1, 0)
    love.graphics.printf("Score: " .. finalScore, 0, 260, 800, "center")
    
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.printf("Press R to restart", 0, 320, 800, "center")
    love.graphics.printf("Press ESC for menu", 0, 350, 800, "center")
    
    love.graphics.setColor(1, 1, 1)
end

function M.keypressed(key)
    if key == "r" then return "game" end
    if key == "escape" then return "menu" end
end

return M
```

## Step 8: main.lua (모든 것을 연결)

```lua
-- main.lua
local scenes = {}
local currentScene
local currentSceneName

local function switchScene(name, data)
    if currentScene and currentScene.exit then
        currentScene.exit()
    end
    currentScene = scenes[name]
    currentSceneName = name
    if currentScene and currentScene.enter then
        currentScene.enter(data)
    end
end

function love.load()
    love.graphics.setBackgroundColor(0.05, 0.05, 0.12)
    math.randomseed(os.time())
    
    scenes.menu = require("scenes.menu")
    scenes.game = require("scenes.game")
    scenes.gameover = require("scenes.gameover")
    
    switchScene("menu")
end

function love.update(dt)
    if currentScene and currentScene.update then
        local nextScene, data = currentScene.update(dt)
        if nextScene then
            switchScene(nextScene, data)
        end
    end
end

function love.draw()
    if currentScene and currentScene.draw then
        currentScene.draw()
    end
end

function love.keypressed(key, ...)
    if currentScene and currentScene.keypressed then
        local nextScene, data = currentScene.keypressed(key, ...)
        if nextScene then
            switchScene(nextScene, data)
        end
    end
end
```

## 확장 아이디어

이 미니 프로젝트를 기반으로 확장해보라:

1. **파워업 아이템**: 속도 증가, 연사 증가, 체력 회복
2. **적 종류 추가**: 추적형, 사선 이동, 탄환 발사 적
3. **보스**: 코루틴 기반 보스 패턴 (18장)
4. **파티클 강화**: 글로우 효과, 트레일 (12장 벡터 아트)
5. **점수 저장**: love.filesystem (14장)
6. **사운드**: 절차적 효과음 (14장)
7. **화면 쉐이크**: 피격 시 카메라 흔들림

---

[← 이전: 22. C API 개요](22_c_api_overview.md) | [목차로 돌아가기 →](README.md)
