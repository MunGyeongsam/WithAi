local ModeSelectScene = require("03_game.scenes.modeSelectScene")

local TitleScene = {}
TitleScene.__index = TitleScene

function TitleScene.new(width, height, options)
    local self = setmetatable({}, TitleScene)
    self.width = width
    self.height = height
    self.options = options or {}
    self.nextSceneFactory = self.options.nextSceneFactory or function(w, h)
        return ModeSelectScene.new(w, h)
    end
    return self
end

function TitleScene:resize(width, height)
    self.width = width
    self.height = height
end

function TitleScene:startNext()
    if not self._stack then
        return
    end
    self._stack:replace(self.nextSceneFactory(self.width, self.height))
end

function TitleScene:keypressed(key)
    if key == "return" or key == "space" then
        self:startNext()
    end
end

function TitleScene:draw()
    local gr = love.graphics
    gr.setColor(0.08, 0.1, 0.16, 1)
    gr.rectangle("fill", 0, 0, self.width, self.height)

    gr.setColor(0.88, 0.93, 0.98, 1)
    gr.printf("VERTICAL BREAKOUT", 0, self.height * 0.30, self.width, "center")

    gr.setColor(0.65, 0.78, 0.92, 1)
    gr.printf("Classic and Combo Rush", 0, self.height * 0.36, self.width, "center")

    gr.setColor(0.95, 0.9, 0.72, 1)
    gr.printf("Press SPACE or ENTER", 0, self.height * 0.62, self.width, "center")
end

return TitleScene