# 14. Box2D 물리 엔진

## love.physics 개요

LÖVE2D에는 Box2D 물리 엔진이 내장되어 있다.
`conf.lua`에서 `t.modules.physics = true`(기본값)이면 사용 가능.

### 핵심 개념

| 용어 | 설명 |
|------|------|
| **World** | 물리 시뮬레이션 공간 (중력 설정) |
| **Body** | 물리 객체 (위치, 속도, 질량) |
| **Shape** | 충돌 형태 (원, 사각형, 다각형) |
| **Fixture** | Body + Shape 결합 (밀도, 마찰, 반발) |

```
World
 └── Body (dynamic/static/kinematic)
      └── Fixture
           └── Shape
```

## 기본 설정

```lua
local world
local ground, ball

function love.load()
    -- 월드 생성 (중력: x=0, y=9.81*64)
    world = love.physics.newWorld(0, 9.81 * 64, true)

    -- 바닥 (static: 움직이지 않음)
    ground = {}
    ground.body = love.physics.newBody(world, 400, 550, "static")
    ground.shape = love.physics.newRectangleShape(700, 20)
    ground.fixture = love.physics.newFixture(ground.body, ground.shape)

    -- 공 (dynamic: 물리 영향 받음)
    ball = {}
    ball.body = love.physics.newBody(world, 400, 100, "dynamic")
    ball.shape = love.physics.newCircleShape(30)
    ball.fixture = love.physics.newFixture(ball.body, ball.shape, 1)  -- 밀도=1
    ball.fixture:setRestitution(0.7)   -- 반발 계수 (0=안 튐, 1=완전탄성)
end

function love.update(dt)
    world:update(dt)
end

function love.draw()
    -- 바닥
    love.graphics.setColor(0.4, 0.4, 0.4)
    love.graphics.polygon("fill", ground.body:getWorldPoints(ground.shape:getPoints()))

    -- 공
    love.graphics.setColor(0.3, 0.8, 1)
    love.graphics.circle("fill", ball.body:getX(), ball.body:getY(), ball.shape:getRadius())

    love.graphics.setColor(1, 1, 1)
end
```

## Body 타입

| 타입 | 물리 영향 | 이동 | 용도 |
|------|:---------:|:----:|------|
| `"static"` | 안 받음 | 안 됨 | 벽, 바닥 |
| `"dynamic"` | 받음 | 됨 | 플레이어, 적, 아이템 |
| `"kinematic"` | 안 받음 | 수동 | 엘리베이터, 움직이는 플랫폼 |

## Fixture 속성

```lua
fixture:setDensity(1.0)        -- 밀도 (질량에 영향)
fixture:setFriction(0.3)       -- 마찰 (0~1)
fixture:setRestitution(0.5)    -- 반발 (0: 안 튐, 1: 완전탄성)
fixture:setSensor(true)        -- 센서 (충돌 감지만, 물리 반응 없음)
```

## 힘과 충격

```lua
function love.update(dt)
    world:update(dt)

    -- 지속적인 힘 (바람 등)
    if love.keyboard.isDown("d") then
        ball.body:applyForce(500, 0)
    end
end

function love.keypressed(key)
    -- 순간적인 충격 (점프)
    if key == "space" then
        ball.body:applyLinearImpulse(0, -300)
    end
end
```

## 충돌 콜백

```lua
function love.load()
    world = love.physics.newWorld(0, 9.81 * 64, true)

    world:setCallbacks(beginContact, endContact, preSolve, postSolve)
end

local function beginContact(a, b, contact)
    -- a, b: Fixture
    print("충돌 시작!")
end

local function endContact(a, b, contact)
    print("충돌 끝!")
end

local function preSolve(a, b, contact)
    -- 충돌 반응 전: contact:setEnabled(false)로 무시 가능
end

local function postSolve(a, b, contact, normal_impulse, tangent_impulse)
    -- 충돌 후: 충격량으로 데미지 계산 등
end
```

### UserData로 오브젝트 식별

```lua
ball.fixture:setUserData({type = "ball", owner = ball})
ground.fixture:setUserData({type = "ground"})

local function beginContact(a, b, contact)
    local data_a = a:getUserData()
    local data_b = b:getUserData()
    if data_a and data_b then
        print(data_a.type .. " hit " .. data_b.type)
    end
end
```

## 조인트

```lua
-- 거리 조인트 (고무줄)
local joint = love.physics.newDistanceJoint(body_a, body_b, x1, y1, x2, y2)

-- 회전 조인트 (경첩)
local joint = love.physics.newRevoluteJoint(body_a, body_b, x, y)

-- 마우스 조인트 (드래그)
local joint = love.physics.newMouseJoint(body, mx, my)
joint:setMaxForce(1000)
```

## 실습: 물리 놀이터

```lua
-- main.lua
local world
local objects = {}
local ground

function love.load()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.15)
    world = love.physics.newWorld(0, 9.81 * 64, true)

    ground = {}
    ground.body = love.physics.newBody(world, 400, 570, "static")
    ground.shape = love.physics.newRectangleShape(750, 20)
    ground.fixture = love.physics.newFixture(ground.body, ground.shape)
    ground.fixture:setFriction(0.5)
end

local function spawnCircle(x, y)
    local o = {}
    o.type = "circle"
    o.body = love.physics.newBody(world, x, y, "dynamic")
    o.radius = math.random(15, 35)
    o.shape = love.physics.newCircleShape(o.radius)
    o.fixture = love.physics.newFixture(o.body, o.shape, 1)
    o.fixture:setRestitution(0.6)
    o.color = {math.random() * 0.5 + 0.5, math.random() * 0.5 + 0.5, math.random() * 0.5 + 0.5}
    objects[#objects + 1] = o
end

local function spawnBox(x, y)
    local o = {}
    o.type = "box"
    o.body = love.physics.newBody(world, x, y, "dynamic")
    o.w = math.random(20, 50)
    o.h = math.random(20, 50)
    o.shape = love.physics.newRectangleShape(o.w, o.h)
    o.fixture = love.physics.newFixture(o.body, o.shape, 1)
    o.fixture:setRestitution(0.3)
    o.fixture:setFriction(0.4)
    o.color = {math.random() * 0.5 + 0.5, math.random() * 0.5 + 0.5, math.random() * 0.5 + 0.5}
    objects[#objects + 1] = o
end

function love.update(dt)
    world:update(dt)
end

function love.draw()
    -- 바닥
    love.graphics.setColor(0.35, 0.35, 0.4)
    love.graphics.polygon("fill", ground.body:getWorldPoints(ground.shape:getPoints()))

    -- 오브젝트
    for _, o in ipairs(objects) do
        love.graphics.setColor(o.color[1], o.color[2], o.color[3])
        if o.type == "circle" then
            love.graphics.circle("fill", o.body:getX(), o.body:getY(), o.radius)
        else
            love.graphics.polygon("fill", o.body:getWorldPoints(o.shape:getPoints()))
        end
    end

    -- HUD
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Left click: circle / Right click: box", 10, 10)
    love.graphics.print("Objects: " .. #objects, 10, 30)
end

function love.mousepressed(x, y, button)
    if button == 1 then spawnCircle(x, y)
    elseif button == 2 then spawnBox(x, y) end
end

function love.keypressed(key)
    if key == "r" then
        for _, o in ipairs(objects) do o.body:destroy() end
        objects = {}
    end
    if key == "escape" then love.event.quit() end
end
```

## 다음 챕터

파티클 시스템으로 시각 효과(폭발, 연기, 불꽃)를 만든다.
