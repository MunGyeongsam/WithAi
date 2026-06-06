local Breakout = require("03_game.breakout")
local ProgressStore = require("03_game.progressStore")
local PauseOverlayScene = require("03_game.scenes.pauseOverlayScene")
local ResultOverlayScene = require("03_game.scenes.resultOverlayScene")

local BreakoutScene = {}
BreakoutScene.__index = BreakoutScene

function BreakoutScene.new(width, height, options)
    local self = setmetatable({}, BreakoutScene)
    self.options = options or {}
    self.game = Breakout.new(width, height, options)
    self.progressStore = self.options.progressStore or ProgressStore.new()
    self.resultOverlayShown = false
    self.lastObservedState = self.game.state
    return self
end

function BreakoutScene:recordProgress(cleared, unlockLevel)
    self.progressStore:recordLevelResult(
        self.game:getModeId(),
        self.game.level,
        self.game.maxLevel,
        self.game.score,
        cleared,
        unlockLevel
    )
end

function BreakoutScene:syncProgress()
    local state = self.game.state
    if state == self.lastObservedState then
        return
    end

    if state == "level_clear" then
        self:recordProgress(true, self.game.level + 1)
    elseif state == "won" then
        self:recordProgress(true, self.game.maxLevel)
    elseif state == "lost" then
        self:recordProgress(false, self.game.level)
    end

    self.lastObservedState = state
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

function BreakoutScene:goBack()
    if not self._stack then
        return
    end

    local LevelSelectScene = require("03_game.scenes.levelSelectScene")
    self._stack:replace(LevelSelectScene.new(self.game.width, self.game.height, {
        modeId = self.game:getModeId(),
        selectedLevel = self.game.level,
        progressStore = self.progressStore,
    }))
end

function BreakoutScene:update(dt)
    self.game:update(dt)
    self:syncProgress()

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

    local gr = love.graphics
    local w = self.game.width
    local h = self.game.height

    gr.setColor(0.12, 0.16, 0.22, 0.72)
    gr.rectangle("fill", w * 0.03, h * 0.03, w * 0.16, h * 0.05, 10, 10)
    gr.rectangle("fill", w * 0.81, h * 0.03, w * 0.16, h * 0.05, 10, 10)

    gr.setColor(0.90, 0.94, 1.0, 0.92)
    gr.printf("BACK", w * 0.03, h * 0.045, w * 0.16, "center")
    gr.printf("PAUSE", w * 0.81, h * 0.045, w * 0.16, "center")
end

function BreakoutScene:resize(width, height)
    self.game:resize(width, height)
end

function BreakoutScene:keypressed(key, scancode)
    if key == "backspace" then
        self:goBack()
        return
    end

    if key == "1" then
        self.game:setMode("classic")
        self.lastObservedState = self.game.state
        self.resultOverlayShown = false
        return
    end

    if key == "2" then
        self.game:setMode("combo_rush")
        self.lastObservedState = self.game.state
        self.resultOverlayShown = false
        return
    end

    if self.game.keypressed then
        self.game:keypressed(key, scancode)
    end
end

function BreakoutScene:touchpressed(_, x, y)
    local w = self.game.width
    local h = self.game.height

    if x >= w * 0.03 and x <= w * 0.19 and y >= h * 0.03 and y <= h * 0.08 then
        self:goBack()
        return
    end

    if x >= w * 0.81 and x <= w * 0.97 and y >= h * 0.03 and y <= h * 0.08 then
        if self._stack and self.game.state == "playing" then
            self._stack:push(PauseOverlayScene.new(self))
        end
    end
end

function BreakoutScene:mousepressed(x, y, button)
    if button == 1 then
        self:touchpressed(nil, x, y)
    end
end

return BreakoutScene