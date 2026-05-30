local Breakout = require("03_game.breakout")
local InputAdapter = require("03_game.input.inputAdapter")
local VirtualResolution = require("01_core.virtualResolution")

local game
local inputAdapter
local virtual
local BASE_WIDTH = 540
local BASE_HEIGHT = 1200

function love.load()
    local width, height = love.graphics.getDimensions()
    virtual = VirtualResolution.new(BASE_WIDTH, BASE_HEIGHT)
    inputAdapter = InputAdapter.new()
    virtual:resize(width, height)
    game = Breakout.new(BASE_WIDTH, BASE_HEIGHT)
end

function love.resize(width, height)
    if virtual then
        virtual:resize(width, height)
    end
end

function love.update(dt)
    if game then
        local snapshot = inputAdapter:update()
        game:setInputSnapshot(snapshot)
        game:update(dt)
    end
end

function love.draw()
    if game then
        love.graphics.clear(0, 0, 0, 1)
        virtual:beginDraw()
        game:draw()
        virtual:endDraw()
    end
end

function love.keypressed(key, scancode)
    if key == "escape" then
        love.event.quit()
        return
    end
end
