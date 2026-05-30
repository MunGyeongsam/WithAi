local Breakout = require("03_game.breakout")
local PauseOverlayScene = require("03_game.scenes.pauseOverlayScene")
local ResultOverlayScene = require("03_game.scenes.resultOverlayScene")

local BreakoutScene = {}
BreakoutScene.__index = BreakoutScene

function BreakoutScene.new(width, height)
    local self = setmetatable({}, BreakoutScene)
    self.game = Breakout.new(width, height)
    self.resultOverlayShown = false
    return self
end

function BreakoutScene:setInputSnapshot(snapshot)
    self.game:setInputSnapshot(snapshot)
    if not snapshot then
        return
    end

    if snapshot.pausePressed and self._stack and self.game.state == "playing" then
        self._stack:push(PauseOverlayScene.new(self))
    end
end

function BreakoutScene:update(dt)
    self.game:update(dt)

    if not self._stack then
        return
    end

    if self.game.state == "won" or self.game.state == "lost" then
        if not self.resultOverlayShown then
            self.resultOverlayShown = true
            self._stack:push(ResultOverlayScene.new(self, self.game.state))
        end
    else
        self.resultOverlayShown = false
    end
end

function BreakoutScene:draw()
    self.game:draw()
end

function BreakoutScene:resize(width, height)
    self.game:resize(width, height)
end

function BreakoutScene:keypressed(key, scancode)
    if self.game.keypressed then
        self.game:keypressed(key, scancode)
    end
end

return BreakoutScene
