local InputAdapter = require("03_game.input.inputAdapter")
local SceneStack = require("01_core.sceneStack")
local VirtualResolution = require("01_core.virtualResolution")
local FixedTimestep = require("01_core.fixedTimestep")
local TitleScene = require("03_game.scenes.titleScene")

local inputAdapter
local sceneStack
local virtual
local fixedStep
local BASE_WIDTH = 540
local BASE_HEIGHT = 1200
function love.load()
    local width, height = love.graphics.getDimensions()
    virtual = VirtualResolution.new(BASE_WIDTH, BASE_HEIGHT)
    inputAdapter = InputAdapter.new()
    sceneStack = SceneStack.new()
    fixedStep = FixedTimestep.new()  -- 1/60 고정 타임스텝
    virtual:resize(width, height)
    sceneStack:push(TitleScene.new(BASE_WIDTH, BASE_HEIGHT))
end

function love.resize(width, height)
    if virtual then
        virtual:resize(width, height)
    end

    if sceneStack then
        sceneStack:resize(BASE_WIDTH, BASE_HEIGHT)
    end
end

function love.update(dt)
    if sceneStack and fixedStep then
        local snapshot = inputAdapter:update()
        sceneStack:setInputSnapshot(snapshot)
        
        -- 고정 타임스텝으로 게임 로직 업데이트
        fixedStep:update(dt, function(fixedDt)
            sceneStack:update(fixedDt)
        end)
    end
end

function love.draw()
    if sceneStack then
        love.graphics.clear(0, 0, 0, 1)
        virtual:beginDraw()
        sceneStack:draw()
        virtual:endDraw()
        
        -- FPS 디버그 표시
        love.graphics.setColor(1, 1, 0, 1)
        love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
        love.graphics.print("dt: " .. string.format("%.4f", love.timer.getDelta()), 10, 30)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function love.keypressed(key, scancode)
    if key == "escape" then
        love.event.quit()
        return
    end

    if sceneStack then
        sceneStack:keypressed(key, scancode)
    end
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    if sceneStack and virtual then
        local vx, vy = virtual:toVirtual(x, y)
        sceneStack:touchpressed(id, vx, vy, dx, dy, pressure)
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if sceneStack and virtual then
        local vx, vy = virtual:toVirtual(x, y)
        sceneStack:mousepressed(vx, vy, button, istouch, presses)
    end
end
