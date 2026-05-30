local Hud = {}

local function setColor(r, g, b, a)
    love.graphics.setColor(r / 255, g / 255, b / 255, a or 1)
end

function Hud.draw(game)
    local gr = love.graphics
    local width = game.width
    local theme = game.theme
    local ui = theme and theme.ui or {230, 235, 248}
    local accent = theme and theme.accent or {140, 220, 255}

    setColor(ui[1], ui[2], ui[3])
    gr.print("Score: " .. tostring(game.score), 16, 10)
    gr.print("Level: " .. tostring(game.level) .. "/" .. tostring(game.maxLevel), width * 0.5 - 40, 10)
    gr.print("Lives: " .. tostring(game.lives), width - 90, 10)

    if game.state == "serve" then
        setColor(ui[1], ui[2], ui[3])
        gr.printf("Press SPACE to launch - Level " .. tostring(game.level), 0, game.height * 0.52, width, "center")
    elseif game.state == "level_clear" then
        local t = game.levelClearProgress or 0
        local scale = 1 + 0.12 * math.sin(t * math.pi)
        local alpha = 0.6 + 0.4 * math.sin(t * math.pi)

        gr.push()
        gr.translate(width * 0.5, game.height * 0.52)
        gr.scale(scale, scale)
        setColor(accent[1], accent[2], accent[3], alpha)
        gr.printf("Level Clear! Next Level Incoming...", -width * 0.5, 0, width, "center")
        gr.pop()
    elseif game.state == "won" then
        setColor(130, 230, 150)
        gr.printf("All Levels Clear! Press R to restart", 0, game.height * 0.52, width, "center")
    elseif game.state == "lost" then
        setColor(245, 120, 120)
        gr.printf("Game Over. Press R to restart", 0, game.height * 0.52, width, "center")
    end
end

return Hud
