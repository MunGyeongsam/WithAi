local PauseOverlayScene = {}
PauseOverlayScene.__index = PauseOverlayScene

function PauseOverlayScene.new(ownerScene)
    local self = setmetatable({}, PauseOverlayScene)
    self.ownerScene = ownerScene
    return self
end

function PauseOverlayScene:draw()
    local gr = love.graphics
    local game = self.ownerScene.game
    local width = game.width
    local height = game.height

    gr.setColor(0, 0, 0, 0.42)
    gr.rectangle("fill", 0, 0, width, height)

    gr.setColor(0.95, 0.97, 1.0, 1)
    gr.printf("Paused", 0, height * 0.44, width, "center")

    gr.setColor(0.80, 0.86, 1.0, 0.95)
    gr.printf("Press P, SPACE, or BACKSPACE to resume", 0, height * 0.49, width, "center")
end

function PauseOverlayScene:keypressed(key)
    if key == "p" or key == "space" or key == "backspace" then
        if self._stack then
            self._stack:pop()
        end
    end
end

return PauseOverlayScene
