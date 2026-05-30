local InputAdapter = require("03_game.input.inputAdapter")
local SceneStack = require("01_core.sceneStack")
local VirtualResolution = require("01_core.virtualResolution")
local BreakoutScene = require("03_game.breakoutScene")

local inputAdapter
local sceneStack
local virtual
local BASE_WIDTH = 540
local BASE_HEIGHT = 1200

function love.load()
    local width, height = love.graphics.getDimensions()
    virtual = VirtualResolution.new(BASE_WIDTH, BASE_HEIGHT)
    inputAdapter = InputAdapter.new()
    sceneStack = SceneStack.new()
    virtual:resize(width, height)
    sceneStack:push(BreakoutScene.new(BASE_WIDTH, BASE_HEIGHT))
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
    if sceneStack then
        local snapshot = inputAdapter:update()
        sceneStack:setInputSnapshot(snapshot)
        sceneStack:update(dt)
    end
end

function love.draw()
    if sceneStack then
        love.graphics.clear(0, 0, 0, 1)
        virtual:beginDraw()
        sceneStack:draw()
        virtual:endDraw()
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
