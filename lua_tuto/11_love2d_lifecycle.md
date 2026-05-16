# 11. LÖVE2D 생명주기

## 콜백 기반 구조

LÖVE2D는 **콜백 함수**를 정의하면 엔진이 적절한 타이밍에 호출하는 구조다.

```
Unity 비교:
Awake()       → love.load()
Update()      → love.update(dt)
OnGUI()       → love.draw()
OnDestroy()   → love.quit()
```

## 핵심 콜백 3가지

```lua
function love.load()
    -- 게임 시작 시 1회 호출
    -- 리소스 로딩, 초기화
    player = {x = 400, y = 300, speed = 200}
    enemies = {}
    score = 0
end

function love.update(dt)
    -- 매 프레임 호출
    -- dt = delta time (이전 프레임으로부터 경과 초)
    -- 60fps → dt ≈ 0.0167
    
    -- 이동은 항상 dt를 곱해야 프레임률에 독립적
    if love.keyboard.isDown("right") then
        player.x = player.x + player.speed * dt
    end
end

function love.draw()
    -- 매 프레임, update 후 호출
    -- 여기서만 그리기 함수 사용
    love.graphics.circle("fill", player.x, player.y, 20)
    love.graphics.print("Score: " .. score, 10, 10)
end
```

## 전체 콜백 목록

```lua
-- === 생명주기 ===
function love.load(arg)          -- 시작 시 1회
function love.update(dt)         -- 매 프레임
function love.draw()             -- 매 프레임 (update 후)
function love.quit()             -- 종료 시 (return true면 종료 취소)

-- === 키보드 ===
function love.keypressed(key, scancode, isrepeat)   -- 키 누름
function love.keyreleased(key, scancode)             -- 키 뗌
function love.textinput(text)                        -- 텍스트 입력

-- === 마우스 ===
function love.mousepressed(x, y, button, istouch)   -- 마우스 누름
function love.mousereleased(x, y, button, istouch)   -- 마우스 뗌
function love.mousemoved(x, y, dx, dy, istouch)     -- 마우스 이동
function love.wheelmoved(x, y)                       -- 스크롤

-- === 터치 (모바일) ===
function love.touchpressed(id, x, y, dx, dy, pressure)
function love.touchreleased(id, x, y, dx, dy, pressure)
function love.touchmoved(id, x, y, dx, dy, pressure)

-- === 창 ===
function love.focus(focused)        -- 창 포커스 변경
function love.resize(w, h)          -- 창 크기 변경
function love.visible(visible)      -- 창 표시/숨김

-- === 기타 ===
function love.errhand(msg)          -- 에러 핸들러
function love.run()                 -- 메인 루프 (커스터마이즈 가능)
```

## conf.lua — 설정 파일

```lua
-- conf.lua (main.lua와 같은 폴더에 위치)
-- love.load() 전에 실행된다

function love.conf(t)
    -- 창 설정
    t.window.title = "My Game"
    t.window.width = 800
    t.window.height = 600
    t.window.resizable = true
    t.window.vsync = 1              -- 1: vsync on, 0: off
    
    -- 게임 식별자 (저장 경로에 사용)
    t.identity = "mygame"
    
    -- 사용하지 않는 모듈 비활성화 (로딩 시간 감소)
    t.modules.joystick = false
    t.modules.physics = false
    
    -- Lua/LÖVE 버전
    t.version = "11.5"              -- LÖVE 버전 명시
    
    -- 콘솔 출력 (Windows)
    t.console = true                -- Windows에서 콘솔 창 표시
end
```

## dt (Delta Time) 이해

```lua
-- dt = 이전 프레임 이후 경과된 시간 (초)
-- 60fps → dt ≈ 0.01667
-- 30fps → dt ≈ 0.03333

function love.update(dt)
    -- ❌ 나쁜 예: 프레임률에 종속
    player.x = player.x + 5      -- 60fps: 300/초, 30fps: 150/초

    -- ✅ 좋은 예: 프레임률에 독립적
    player.x = player.x + 300 * dt   -- 항상 300/초
    
    -- dt를 누적하면 타이머로 사용
    timer = timer + dt
    if timer >= 2.0 then
        spawnEnemy()
        timer = timer - 2.0    -- 0으로 리셋 대신 빼기 (정밀도 유지)
    end
end
```

### 고정 시간 스텝 (Fixed Timestep)

```lua
-- 물리 시뮬레이션에서 중요
local FIXED_DT = 1/60
local accumulator = 0

function love.update(dt)
    accumulator = accumulator + dt
    
    while accumulator >= FIXED_DT do
        -- 물리 업데이트 (고정 간격)
        updatePhysics(FIXED_DT)
        accumulator = accumulator - FIXED_DT
    end
    
    -- 나머지 로직은 가변 dt 사용
    updateAnimation(dt)
    updateCamera(dt)
end
```

## 게임 루프 커스터마이즈

```lua
-- love.run()을 오버라이드하면 메인 루프를 제어할 수 있다
-- 기본 구현 (참고용):
function love.run()
    if love.load then love.load(love.arg.parseGameArguments(arg), arg) end
    if love.timer then love.timer.step() end
    
    return function()
        -- 이벤트 처리
        if love.event then
            love.event.pump()
            for name, a, b, c, d, e, f in love.event.poll() do
                if name == "quit" then
                    if not love.quit or not love.quit() then
                        return a or 0
                    end
                end
                love.handlers[name](a, b, c, d, e, f)
            end
        end
        
        -- 업데이트
        local dt = love.timer and love.timer.step() or 0
        if love.update then love.update(dt) end
        
        -- 그리기
        if love.graphics and love.graphics.isActive() then
            love.graphics.origin()
            love.graphics.clear(love.graphics.getBackgroundColor())
            if love.draw then love.draw() end
            love.graphics.present()
        end
        
        if love.timer then love.timer.sleep(0.001) end
    end
end
```

## 실전 구조 — 완전한 예제

```lua
-- main.lua
local player
local bullets
local enemies
local score
local gameState    -- "menu", "playing", "gameover"

function love.load()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.2)
    
    player = {
        x = 400, y = 500,
        speed = 300,
        radius = 15,
    }
    bullets = {}
    enemies = {}
    score = 0
    gameState = "playing"
    
    -- 랜덤 시드
    math.randomseed(os.time())
end

function love.update(dt)
    if gameState ~= "playing" then return end
    
    -- 플레이어 이동
    if love.keyboard.isDown("left") then
        player.x = player.x - player.speed * dt
    end
    if love.keyboard.isDown("right") then
        player.x = player.x + player.speed * dt
    end
    
    -- 화면 경계
    player.x = math.max(player.radius, math.min(800 - player.radius, player.x))
    
    -- 총알 업데이트
    for i = #bullets, 1, -1 do
        local b = bullets[i]
        b.y = b.y - 500 * dt
        if b.y < -10 then
            table.remove(bullets, i)
        end
    end
end

function love.draw()
    if gameState == "playing" then
        -- 플레이어
        love.graphics.setColor(0, 1, 0)
        love.graphics.circle("fill", player.x, player.y, player.radius)
        
        -- 총알
        love.graphics.setColor(1, 1, 0)
        for _, b in ipairs(bullets) do
            love.graphics.circle("fill", b.x, b.y, 3)
        end
        
        -- UI
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Score: " .. score, 10, 10)
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    
    if key == "space" and gameState == "playing" then
        bullets[#bullets + 1] = {
            x = player.x,
            y = player.y - player.radius,
        }
    end
end
```

---

## 연습문제

### 연습 11-1: conf.lua 작성
`conf.lua`를 작성하라:
- 창 크기 1024×768
- 타이틀 "My Shooter"
- 물리, 조이스틱 모듈 비활성화
- vsync 활성화

### 연습 11-2: dt 기반 타이머
2초마다 화면에 표시되는 숫자가 1씩 증가하는 프로그램을 작성하라.
`dt`를 누적하여 구현할 것.

### 연습 11-3: 키 입력 처리
`love.keypressed`와 `love.keyboard.isDown`의 차이를 실험하라:
- Space: 누를 때마다 1회 총알 발사 (keypressed)
- 화살표: 누르고 있으면 계속 이동 (isDown)

### 연습 11-4: 상태 전환
위의 실전 예제를 확장하여:
- "menu" 상태: "Press Enter to Start" 표시
- "playing" 상태: 게임 진행
- "gameover" 상태: "Game Over! Press R to restart" 표시
- Enter/R 키로 상태 전환

---

[← 이전: 10. 모듈 시스템](10_modules.md) | [다음: 12. 그리기 →](12_drawing.md)
