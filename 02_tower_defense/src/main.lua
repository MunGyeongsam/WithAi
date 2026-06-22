-- ============================================================================
-- main.lua — Tower Defense 엔트리 포인트
-- ============================================================================
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
local BASE_HEIGHT = 960

function love.load()
    local width, height = love.graphics.getDimensions()
    virtual = VirtualResolution.new(BASE_WIDTH, BASE_HEIGHT)
    inputAdapter = InputAdapter.new()
    sceneStack = SceneStack.new()
    fixedStep = FixedTimestep.new()
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

        -- FPS
        love.graphics.setColor(1, 1, 0, 1)
        love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function love.mousepressed(x, y, button)
    if inputAdapter and virtual then
        local vx, vy = virtual:toVirtual(x, y)
        inputAdapter:mousepressed(vx, vy, button)
    end
end

function love.mousereleased(x, y, button)
    if inputAdapter and virtual then
        local vx, vy = virtual:toVirtual(x, y)
        inputAdapter:mousereleased(vx, vy, button)
    end
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    if inputAdapter and virtual then
        local vx, vy = virtual:toVirtual(x, y)
        inputAdapter:touchpressed(id, vx, vy)
    end
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    if inputAdapter and virtual then
        local vx, vy = virtual:toVirtual(x, y)
        inputAdapter:touchreleased(id, vx, vy)
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end
