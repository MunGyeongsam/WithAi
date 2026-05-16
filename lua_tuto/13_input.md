# 13. 입력 처리

## 두 가지 입력 방식

```lua
-- 1. 콜백 방식 (이벤트 기반) — "눌렀을 때" 1회 발생
function love.keypressed(key)
    if key == "space" then
        fireBullet()     -- 1회 발사
    end
end

-- 2. 폴링 방식 (매 프레임 확인) — "누르고 있는 동안" 매 프레임
function love.update(dt)
    if love.keyboard.isDown("right") then
        player.x = player.x + speed * dt    -- 지속 이동
    end
end

-- 사용 기준:
-- 콜백: 점프, 발사, 메뉴 선택, 일시정지 (1회성 액션)
-- 폴링: 이동, 조준 (지속 입력)
```

## 키보드

### 콜백

```lua
function love.keypressed(key, scancode, isrepeat)
    -- key: 키 이름 ("a", "space", "return", "escape", ...)
    -- scancode: 물리적 키 위치 (키보드 레이아웃 독립)
    -- isrepeat: 키 반복 (길게 누르면 true)
    
    if key == "escape" then
        love.event.quit()
    end
    
    if key == "space" and not isrepeat then
        shoot()    -- 반복 입력 무시
    end
end

function love.keyreleased(key, scancode)
    -- 키를 뗐을 때
    if key == "lshift" then
        stopSprinting()
    end
end

function love.textinput(text)
    -- 텍스트 입력 (유니코드 지원)
    -- 이름 입력 등에 사용
    playerName = playerName .. text
end
```

### 폴링

```lua
function love.update(dt)
    -- 방향키 이동
    local dx, dy = 0, 0
    if love.keyboard.isDown("up", "w") then dy = dy - 1 end     -- 여러 키 동시 체크
    if love.keyboard.isDown("down", "s") then dy = dy + 1 end
    if love.keyboard.isDown("left", "a") then dx = dx - 1 end
    if love.keyboard.isDown("right", "d") then dx = dx + 1 end
    
    -- 대각선 이동 정규화
    if dx ~= 0 and dy ~= 0 then
        local len = math.sqrt(dx * dx + dy * dy)
        dx = dx / len
        dy = dy / len
    end
    
    player.x = player.x + dx * player.speed * dt
    player.y = player.y + dy * player.speed * dt
end
```

### 주요 키 이름

```
문자:    "a" ~ "z"
숫자:    "0" ~ "9"
기능키:  "f1" ~ "f12"
방향:    "up", "down", "left", "right"
특수:    "space", "return", "escape", "tab", "backspace", "delete"
수식:    "lshift", "rshift", "lctrl", "rctrl", "lalt", "ralt"
기타:    "home", "end", "pageup", "pagedown", "insert"
넘패드:  "kp0" ~ "kp9", "kp+", "kp-", "kp*", "kp/", "kpenter"
```

## 마우스

### 콜백

```lua
function love.mousepressed(x, y, button, istouch, presses)
    -- button: 1=좌클릭, 2=우클릭, 3=중간
    -- presses: 연속 클릭 횟수 (더블클릭 감지)
    
    if button == 1 then
        shoot(x, y)
    elseif button == 2 then
        useSpecial(x, y)
    end
    
    -- 더블클릭
    if button == 1 and presses == 2 then
        interact(x, y)
    end
end

function love.mousereleased(x, y, button, istouch)
    -- 마우스 버튼 뗌
end

function love.mousemoved(x, y, dx, dy, istouch)
    -- 마우스 이동
    -- dx, dy: 이전 위치로부터의 변화량
    crosshair.x = x
    crosshair.y = y
end

function love.wheelmoved(x, y)
    -- 스크롤 휠
    -- y > 0: 위로, y < 0: 아래로
    zoom = zoom + y * 0.1
end
```

### 폴링

```lua
function love.update(dt)
    -- 현재 마우스 위치
    local mx, my = love.mouse.getPosition()
    
    -- 마우스 버튼 상태
    if love.mouse.isDown(1) then
        -- 좌클릭 누르고 있는 동안
        chargeShot(dt)
    end
    
    -- 플레이어가 마우스를 향하도록 회전
    local angle = math.atan2(my - player.y, mx - player.x)
    player.angle = angle
end
```

### 커서 제어

```lua
function love.load()
    -- 마우스 커서 숨기기
    love.mouse.setVisible(false)
    
    -- 마우스 가두기 (FPS 스타일)
    love.mouse.setGrabbed(true)
    
    -- 상대 모드 (마우스 이동량만 받기)
    love.mouse.setRelativeMode(true)
end
```

## 게임패드 / 조이스틱

```lua
function love.gamepadpressed(joystick, button)
    if button == "a" then
        jump()
    elseif button == "start" then
        togglePause()
    end
end

function love.update(dt)
    local joysticks = love.joystick.getJoysticks()
    if #joysticks > 0 then
        local joy = joysticks[1]
        
        -- 아날로그 스틱 (왼쪽)
        local lx = joy:getGamepadAxis("leftx")   -- -1 ~ 1
        local ly = joy:getGamepadAxis("lefty")
        
        -- 데드존 처리
        if math.abs(lx) < 0.2 then lx = 0 end
        if math.abs(ly) < 0.2 then ly = 0 end
        
        player.x = player.x + lx * speed * dt
        player.y = player.y + ly * speed * dt
    end
end
```

## 입력 추상화 패턴

```lua
-- 키보드/마우스/게임패드를 통합하는 입력 레이어
local Input = {}

local bindings = {
    moveLeft  = {"key:a", "key:left", "axis:leftx:-"},
    moveRight = {"key:d", "key:right", "axis:leftx:+"},
    moveUp    = {"key:w", "key:up", "axis:lefty:-"},
    moveDown  = {"key:s", "key:down", "axis:lefty:+"},
    fire      = {"key:space", "mouse:1", "button:a"},
    pause     = {"key:escape", "button:start"},
}

function Input.isDown(action)
    local binds = bindings[action]
    if not binds then return false end
    
    for _, bind in ipairs(binds) do
        local device, key = bind:match("(%w+):(.+)")
        if device == "key" and love.keyboard.isDown(key) then
            return true
        elseif device == "mouse" and love.mouse.isDown(tonumber(key)) then
            return true
        end
    end
    return false
end

-- 사용
function love.update(dt)
    if Input.isDown("moveRight") then
        player.x = player.x + speed * dt
    end
end
```

## 입력 버퍼링 (격투 게임 스타일)

```lua
-- 입력을 저장했다가 일정 시간 내에 사용
local InputBuffer = {
    buffer = {},
    bufferTime = 0.15,   -- 150ms 버퍼
}

function InputBuffer.add(action)
    InputBuffer.buffer[#InputBuffer.buffer + 1] = {
        action = action,
        time = love.timer.getTime(),
    }
end

function InputBuffer.consume(action)
    local now = love.timer.getTime()
    for i = #InputBuffer.buffer, 1, -1 do
        local entry = InputBuffer.buffer[i]
        if entry.action == action and now - entry.time < InputBuffer.bufferTime then
            table.remove(InputBuffer.buffer, i)
            return true
        end
    end
    return false
end

-- 사용
function love.keypressed(key)
    if key == "space" then
        InputBuffer.add("jump")
    end
end

function love.update(dt)
    -- 착지 시 버퍼에 점프 입력이 있으면 즉시 점프
    if player.onGround and InputBuffer.consume("jump") then
        player.vy = -jumpForce
    end
end
```

---

## 연습문제

### 연습 13-1: WASD + 마우스 조준
WASD로 이동하고, 마우스 방향을 향하는 삼각형 "캐릭터"를 구현하라.

### 연습 13-2: 차징 공격
마우스 좌클릭을 누르고 있으면 차지 게이지가 올라가고, 놓으면 차지 량에 비례한 크기의 원을 발사하는 시스템을 구현하라.

### 연습 13-3: 키 리바인딩
위의 입력 추상화 패턴을 확장하여, 런타임에 키 바인딩을 변경할 수 있게 만들어라.
"Press any key to bind..." 방식.

### 연습 13-4: 대각선 정규화
8방향 이동에서 대각선 이동 속도가 직선 이동 속도와 같도록 정규화하는 코드를 작성하고, 정규화 전후의 이동 속도 차이를 수치로 확인하라.

---

[← 이전: 12. 그리기](12_drawing.md) | [다음: 14. 오디오 & 리소스 →](14_audio_and_assets.md)
