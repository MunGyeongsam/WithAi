local Breakout = require("03_game.breakout")

local game

function love.load()
    love.graphics.setBackgroundColor(18 / 255, 24 / 255, 38 / 255)
    local width, height = love.graphics.getDimensions()
    game = Breakout.new(width, height)
end

function love.resize(width, height)
    if game and game.resize then
        game:resize(width, height)
    end
end

function love.update(dt)
    if game then
        game:update(dt)
    end
end

function love.draw()
    if game then
        game:draw()
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
