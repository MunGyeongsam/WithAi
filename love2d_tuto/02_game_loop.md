# 02. 게임 루프 & 생명주기

## 콜백 기반 구조

LÖVE2D는 개발자가 **콜백 함수를 정의**하면 엔진이 적절한 시점에 호출한다.

```
┌─────────────────────────────────────────┐
│            LÖVE2D 엔진 (C/SDL2)         │
│                                         │
│  1. conf.lua 실행 (설정)                │
│  2. love.load() 호출 (1회)              │
│  3. 매 프레임 반복:                     │
│     ├─ 이벤트 처리 (입력 등)            │
│     ├─ love.update(dt) 호출             │
│     └─ love.draw() 호출                 │
│  4. 종료 시 love.quit() 호출            │
└─────────────────────────────────────────┘
```

## 핵심 콜백 3가지

```lua
-- main.lua
local player_x, player_y
local speed

function love.load()
    -- 게임 시작 시 1회 호출
    -- 리소스 로딩, 변수 초기화
    player_x = 400
    player_y = 300
    speed = 200
end

function love.update(dt)
    -- 매 프레임 호출 (dt = 이전 프레임으로부터 경과 초)
    -- 게임 로직: 이동, 충돌, AI 등
    if love.keyboard.isDown("d") then
        player_x = player_x + speed * dt
    end
end

function love.draw()
    -- 매 프레임, update 후 호출
    -- 화면 그리기만 담당 — 게임 로직 금지
    love.graphics.circle("fill", player_x, player_y, 20)
end
```

### update와 draw 분리 원칙

| update(dt) | draw() |
|------------|--------|
| 위치 계산 | 도형 그리기 |
| 충돌 검사 | 텍스트 출력 |
| 점수 변경 | 이미지 출력 |
| 상태 전환 | **절대 상태 변경 안 함** |

`draw()`에서 변수를 수정하면 프레임률에 따라 결과가 달라진다.

## dt (Delta Time)

`dt`는 이전 프레임으로부터 경과한 **초** 단위 시간이다.

```
60 FPS → dt ≈ 0.0167 (1/60)
30 FPS → dt ≈ 0.0333 (1/30)
```

```lua
-- ❌ dt 없이 이동 (프레임률에 종속)
function love.update(dt)
    player_x = player_x + 5   -- 60fps: 초당 300px, 30fps: 초당 150px
end

-- ✅ dt를 곱해서 이동 (프레임률 독립)
function love.update(dt)
    player_x = player_x + 200 * dt   -- 항상 초당 200px
end
```

## 전체 콜백 목록

### 생명주기

```lua
function love.load(arg)           -- 시작 시 1회 (arg = 커맨드라인 인자)
function love.update(dt)          -- 매 프레임
function love.draw()              -- 매 프레임 (update 후)
function love.quit()              -- 종료 시 (return true → 종료 취소)
```

### 키보드

```lua
function love.keypressed(key, scancode, isrepeat)
function love.keyreleased(key, scancode)
function love.textinput(text)
```

### 마우스

```lua
function love.mousepressed(x, y, button, istouch)
function love.mousereleased(x, y, button, istouch)
function love.mousemoved(x, y, dx, dy, istouch)
function love.wheelmoved(x, y)
```

### 터치 (모바일)

```lua
function love.touchpressed(id, x, y, dx, dy, pressure)
function love.touchreleased(id, x, y, dx, dy, pressure)
function love.touchmoved(id, x, y, dx, dy, pressure)
```

### 창

```lua
function love.focus(focused)      -- 포커스 변경
function love.resize(w, h)        -- 창 크기 변경
function love.visible(visible)    -- 표시/숨김
```

## love.run() — 메인 루프 커스터마이즈

`love.run()`을 직접 정의하면 메인 루프를 완전히 제어할 수 있다.
보통은 건드리지 않지만, 고정 타임스텝이 필요하면 유용하다.

```lua
-- 기본 love.run()의 축약 구조
function love.run()
    if love.load then love.load(love.arg.parseGameArguments(arg)) end

    local dt = 0
    return function()
        love.event.pump()
        for name, a, b, c, d, e, f in love.event.poll() do
            if name == "quit" then
                if not love.quit or not love.quit() then
                    return a or 0
                end
            end
            love.handlers[name](a, b, c, d, e, f)
        end

        dt = love.timer.step()
        if love.update then love.update(dt) end

        love.graphics.origin()
        love.graphics.clear(love.graphics.getBackgroundColor())
        if love.draw then love.draw() end
        love.graphics.present()
    end
end
```

## 실습: 바운싱 볼

```lua
-- main.lua
local ball_x, ball_y
local vel_x, vel_y
local radius

function love.load()
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    ball_x = w / 2
    ball_y = h / 2
    vel_x = 150
    vel_y = 100
    radius = 20
end

function love.update(dt)
    ball_x = ball_x + vel_x * dt
    ball_y = ball_y + vel_y * dt

    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    if ball_x - radius < 0 or ball_x + radius > w then
        vel_x = -vel_x
    end
    if ball_y - radius < 0 or ball_y + radius > h then
        vel_y = -vel_y
    end
end

function love.draw()
    love.graphics.setColor(0.2, 0.8, 1)
    love.graphics.circle("fill", ball_x, ball_y, radius)
end
```

## 다음 챕터

도형, 색상, 좌표 변환 등 LÖVE2D의 그리기 시스템을 배운다.
