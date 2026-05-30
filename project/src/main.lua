local Breakout = require("03_game.breakout")
local VirtualResolution = require("01_core.virtualResolution")

local game
local virtual
local BASE_WIDTH = 540
local BASE_HEIGHT = 1200

function love.load()
    local width, height = love.graphics.getDimensions()
    virtual = VirtualResolution.new(BASE_WIDTH, BASE_HEIGHT)
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

    if game then
        game:keypressed(key, scancode)
    end
end
