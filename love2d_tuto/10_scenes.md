# 10. 씬 관리 (상태머신)

## 왜 씬 관리가 필요한가

게임은 여러 화면으로 구성된다: 메뉴, 게임플레이, 일시정지, 게임오버.
각 화면마다 update/draw/입력 처리가 다르다.

## 씬 테이블 패턴

```lua
-- scenes/menu.lua
local M = {}

function M.enter()
    -- 씬 진입 시 초기화
end

function M.update(dt)
end

function M.draw()
    love.graphics.printf("MY GAME", 0, 200, 800, "center")
    love.graphics.printf("Press Enter to Start", 0, 300, 800, "center")
end

function M.keypressed(key)
    if key == "return" then
        return "game"   -- 다음 씬 이름 반환
    end
end

function M.exit()
    -- 씬 퇴장 시 정리
end

return M
```

## 씬 매니저

```lua
-- scene_manager.lua
local M = {}

local scenes = {}
local current

function M.register(name, scene)
    scenes[name] = scene
end

function M.switch(name, ...)
    if current and current.exit then
        current.exit()
    end
    current = scenes[name]
    if current and current.enter then
        current.enter(...)
    end
end

function M.update(dt)
    if current and current.update then
        local next_scene = current.update(dt)
        if next_scene then M.switch(next_scene) end
    end
end

function M.draw()
    if current and current.draw then
        current.draw()
    end
end

function M.keypressed(key)
    if current and current.keypressed then
        local next_scene = current.keypressed(key)
        if next_scene then M.switch(next_scene) end
    end
end

function M.mousepressed(x, y, button)
    if current and current.mousepressed then
        local next_scene = current.mousepressed(x, y, button)
        if next_scene then M.switch(next_scene) end
    end
end

return M
```

### main.lua 통합

```lua
-- main.lua
local sm = require("scene_manager")
local menu = require("scenes.menu")
local game = require("scenes.game")
local gameover = require("scenes.gameover")

function love.load()
    sm.register("menu", menu)
    sm.register("game", game)
    sm.register("gameover", gameover)
    sm.switch("menu")
end

function love.update(dt)
    sm.update(dt)
end

function love.draw()
    sm.draw()
end

function love.keypressed(key)
    sm.keypressed(key)
end

function love.mousepressed(x, y, button)
    sm.mousepressed(x, y, button)
end
```

## 씬 스택 (일시정지 오버레이)

일시정지 화면은 게임 화면 **위에** 표시된다. 스택 구조가 적합하다.

```lua
-- scene_stack.lua
local M = {}

local stack = {}

function M.push(scene, ...)
    local top = stack[#stack]
    if top and top.pause then top.pause() end
    stack[#stack + 1] = scene
    if scene.enter then scene.enter(...) end
end

function M.pop()
    local top = stack[#stack]
    if top and top.exit then top.exit() end
    stack[#stack] = nil
    local new_top = stack[#stack]
    if new_top and new_top.resume then new_top.resume() end
end

function M.update(dt)
    local top = stack[#stack]
    if top and top.update then top.update(dt) end
end

function M.draw()
    -- 모든 씬을 아래부터 그림 (투명 오버레이 지원)
    for _, scene in ipairs(stack) do
        if scene.draw then scene.draw() end
    end
end

function M.keypressed(key)
    local top = stack[#stack]
    if top and top.keypressed then top.keypressed(key) end
end

return M
```

### 일시정지 씬

```lua
-- scenes/pause.lua
local stack = require("scene_stack")
local M = {}

function M.draw()
    -- 반투명 배경
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, 800, 600)

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("PAUSED", 0, 250, 800, "center")
    love.graphics.printf("Press Escape to Resume", 0, 300, 800, "center")
end

function M.keypressed(key)
    if key == "escape" then
        stack.pop()
    end
end

return M
```

## 씬 전환 효과 (페이드)

```lua
-- transition.lua
local M = {}

local alpha = 0
local target = 0
local speed = 2
local on_midpoint
local triggered = false

function M.fadeOut(callback)
    target = 1
    speed = 3
    on_midpoint = callback
    triggered = false
end

function M.update(dt)
    if target == 1 then
        alpha = math.min(1, alpha + speed * dt)
        if alpha >= 1 and not triggered then
            triggered = true
            if on_midpoint then on_midpoint() end
            target = 0
        end
    else
        alpha = math.max(0, alpha - speed * dt)
    end
end

function M.draw()
    if alpha > 0 then
        love.graphics.setColor(0, 0, 0, alpha)
        love.graphics.rectangle("fill", 0, 0, 800, 600)
        love.graphics.setColor(1, 1, 1)
    end
end

return M
```

## 실습: 3화면 게임 흐름

```lua
-- main.lua (단일 파일 데모)
local scene
local score

-- === Menu Scene ===
local menu = {}
function menu.enter() end
function menu.update(dt) end
function menu.draw()
    love.graphics.setColor(0.2, 0.6, 1)
    love.graphics.printf("SPACE DODGER", 0, 150, 800, "center")
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Press ENTER to start", 0, 300, 800, "center")
end
function menu.keypressed(key)
    if key == "return" then switchScene(game_scene) end
end

-- === Game Scene ===
local game_scene = {}
local player_y, obstacles, spawn_timer
function game_scene.enter()
    score = 0
    player_y = 300
    obstacles = {}
    spawn_timer = 0
end
function game_scene.update(dt)
    if love.keyboard.isDown("w") then player_y = player_y - 200 * dt end
    if love.keyboard.isDown("s") then player_y = player_y + 200 * dt end
    player_y = math.max(20, math.min(580, player_y))

    spawn_timer = spawn_timer + dt
    if spawn_timer > 0.8 then
        spawn_timer = 0
        obstacles[#obstacles + 1] = {x = 820, y = math.random(50, 550)}
    end

    for i = #obstacles, 1, -1 do
        local o = obstacles[i]
        o.x = o.x - 250 * dt
        if o.x < -20 then
            table.remove(obstacles, i)
            score = score + 1
        elseif math.abs(o.x - 80) < 25 and math.abs(o.y - player_y) < 25 then
            switchScene(gameover_scene)
            return
        end
    end
end
function game_scene.draw()
    love.graphics.setColor(0.2, 0.8, 0.4)
    love.graphics.circle("fill", 80, player_y, 15)

    love.graphics.setColor(1, 0.3, 0.3)
    for _, o in ipairs(obstacles) do
        love.graphics.rectangle("fill", o.x - 10, o.y - 10, 20, 20)
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. score, 10, 10)
    love.graphics.print("W/S to move", 10, 30)
end
function game_scene.keypressed(key)
    if key == "escape" then switchScene(menu) end
end

-- === Gameover Scene ===
gameover_scene = {}
function gameover_scene.enter() end
function gameover_scene.update(dt) end
function gameover_scene.draw()
    love.graphics.setColor(1, 0.2, 0.2)
    love.graphics.printf("GAME OVER", 0, 200, 800, "center")
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Score: " .. tostring(score), 0, 280, 800, "center")
    love.graphics.printf("Press ENTER to retry", 0, 340, 800, "center")
end
function gameover_scene.keypressed(key)
    if key == "return" then switchScene(game_scene) end
    if key == "escape" then switchScene(menu) end
end

-- === Scene Manager (inline) ===
function switchScene(new_scene)
    if scene and scene.exit then scene.exit() end
    scene = new_scene
    if scene.enter then scene.enter() end
end

function love.load()
    switchScene(menu)
end

function love.update(dt)
    if scene.update then scene.update(dt) end
end

function love.draw()
    if scene.draw then scene.draw() end
end

function love.keypressed(key)
    if scene.keypressed then scene.keypressed(key) end
end
```

## 다음 챕터

게임 오브젝트 간 충돌을 감지하고 반응하는 방법을 배운다.
