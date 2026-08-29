# 04. 키보드 & 마우스 입력

## 입력 처리 두 가지 방식

| 방식 | 용도 | 예 |
|------|------|----|
| **폴링** (`isDown`) | 매 프레임 연속 확인 | 이동, 조준 |
| **콜백** (`pressed/released`) | 1회성 이벤트 | 점프, 발사, 메뉴 선택 |

## 키보드 — 폴링

```lua
local player_x, player_y
local speed

function love.load()
    player_x = 400
    player_y = 300
    speed = 250
end

function love.update(dt)
    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
        player_y = player_y - speed * dt
    end
    if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
        player_y = player_y + speed * dt
    end
    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        player_x = player_x - speed * dt
    end
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        player_x = player_x + speed * dt
    end
end

function love.draw()
    love.graphics.circle("fill", player_x, player_y, 20)
end
```

## 키보드 — 콜백

```lua
function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        love.event.quit()
    end
    if key == "space" then
        shoot()
    end
end

function love.keyreleased(key, scancode)
    if key == "space" then
        -- 키를 뗐을 때
    end
end
```

### key vs scancode

| 구분 | 예 | 레이아웃 의존 |
|------|-----|:---:|
| `key` | "a", "z", "space" | O (QWERTY/AZERTY에 따라 다름) |
| `scancode` | "a", "z", "space" | X (물리적 위치 고정) |

게임 조작은 보통 `scancode`가 안전하다. 텍스트 입력은 `love.textinput()` 사용.

## 마우스 — 폴링

```lua
function love.update(dt)
    local mx, my = love.mouse.getPosition()
    -- mx, my로 조준 등

    if love.mouse.isDown(1) then   -- 1: 좌클릭, 2: 우클릭
        -- 마우스 누르고 있는 동안
    end
end
```

## 마우스 — 콜백

```lua
local bullets = {}

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        -- 좌클릭: 총알 발사
        bullets[#bullets + 1] = {x = player_x, y = player_y, tx = x, ty = y}
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    -- 마우스 버튼 뗌
end

function love.mousemoved(x, y, dx, dy, istouch)
    -- dx, dy: 이전 위치로부터의 변화량
end

function love.wheelmoved(x, y)
    -- y > 0: 위로 스크롤, y < 0: 아래로 스크롤
end
```

## 마우스 커서

```lua
function love.load()
    love.mouse.setVisible(false)    -- 시스템 커서 숨기기
end

function love.draw()
    -- 커스텀 커서 그리기
    local mx, my = love.mouse.getPosition()
    love.graphics.setColor(1, 0.3, 0.3)
    love.graphics.circle("line", mx, my, 10)
    love.graphics.line(mx - 15, my, mx + 15, my)
    love.graphics.line(mx, my - 15, mx, my + 15)
    love.graphics.setColor(1, 1, 1)
end
```

## 입력 추상화 패턴

실제 게임에서는 입력을 직접 체크하지 않고 추상 레이어를 만든다.

```lua
-- input.lua
local M = {}

local actions = {}

function M.bind(key, action)
    actions[key] = action
end

function M.isAction(action)
    for key, act in pairs(actions) do
        if act == action and love.keyboard.isDown(key) then
            return true
        end
    end
    return false
end

return M
```

```lua
-- main.lua
local input = require("input")

function love.load()
    input.bind("w", "move_up")
    input.bind("up", "move_up")
    input.bind("s", "move_down")
    input.bind("down", "move_down")
end

function love.update(dt)
    if input.isAction("move_up") then
        player_y = player_y - speed * dt
    end
end
```

## 실습: 마우스 따라가는 플레이어

```lua
-- main.lua
local player_x, player_y
local speed

function love.load()
    player_x = 400
    player_y = 300
    speed = 200
end

function love.update(dt)
    local mx, my = love.mouse.getPosition()
    local dx = mx - player_x
    local dy = my - player_y
    local dist = math.sqrt(dx * dx + dy * dy)

    if dist > 5 then
        player_x = player_x + (dx / dist) * speed * dt
        player_y = player_y + (dy / dist) * speed * dt
    end
end

function love.draw()
    local mx, my = love.mouse.getPosition()

    -- 플레이어 → 마우스 선
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.line(player_x, player_y, mx, my)

    -- 플레이어
    love.graphics.setColor(0.2, 0.8, 1)
    love.graphics.circle("fill", player_x, player_y, 15)

    -- 마우스 위치
    love.graphics.setColor(1, 0.3, 0.3)
    love.graphics.circle("line", mx, my, 8)

    love.graphics.setColor(1, 1, 1)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end
```

## 다음 챕터

속도, 가속도, 마찰을 사용한 부드러운 움직임과 화면 경계 처리를 배운다.
