local ResultOverlayScene = {}
ResultOverlayScene.__index = ResultOverlayScene

function ResultOverlayScene.new(ownerScene, resultState)
    local self = setmetatable({}, ResultOverlayScene)
    self.ownerScene = ownerScene
    self.resultState = resultState
    return self
end

local function getText(resultState)
    if resultState == "won" then
        return "All Levels Clear!"
    end
    return "Game Over"
end

function ResultOverlayScene:draw()
    local gr = love.graphics
    local game = self.ownerScene.game
    local width = game.width
    local height = game.height

    gr.setColor(0, 0, 0, 0.50)
    gr.rectangle("fill", 0, 0, width, height)

    if self.resultState == "won" then
        gr.setColor(0.55, 0.95, 0.62, 1)
    else
        gr.setColor(0.95, 0.50, 0.50, 1)
    end
    gr.printf(getText(self.resultState), 0, height * 0.44, width, "center")

    gr.setColor(0.95, 0.97, 1.0, 1)
    gr.printf("Score: " .. tostring(game.score), 0, height * 0.49, width, "center")

    gr.setColor(0.80, 0.86, 1.0, 0.95)
    gr.printf("Press R or ENTER to restart", 0, height * 0.54, width, "center")

    gr.setColor(0.64, 0.70, 0.78, 1)
    gr.printf("BACKSPACE: Level Select", 0, height * 0.59, width, "center")
end

function ResultOverlayScene:keypressed(key)
    if key == "r" or key == "return" then
        self.ownerScene.game:reset(self.ownerScene.game.width, self.ownerScene.game.height)
        if self._stack then
            self._stack:pop()
        end
        return
    end

    if key == "backspace" then
        self.ownerScene:goBack()
    end
end

return ResultOverlayScene
