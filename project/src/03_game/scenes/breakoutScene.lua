local Breakout = require("03_game.breakout")
local ProgressStore = require("03_game.progressStore")
local PauseOverlayScene = require("03_game.scenes.pauseOverlayScene")
local ResultOverlayScene = require("03_game.scenes.resultOverlayScene")

local BreakoutScene = {}
BreakoutScene.__index = BreakoutScene

local function pointInRect(px, py, rect)
    return px >= rect.x and px <= rect.x + rect.w and py >= rect.y and py <= rect.y + rect.h
end

local function getServeControlRects(w, h)
    local laneTop = h * 0.75
    local buttonH = math.max(h * 0.085, 56)
    local buttonW = math.min(w * 0.40, 340)
    local gap = math.max(w * 0.04, 24)
    local totalW = buttonW * 2 + gap
    local startX = (w - totalW) * 0.5
    local y = laneTop - buttonH - h * 0.02

    return {
        mode = {
            x = startX,
            y = y,
            w = buttonW,
            h = buttonH,
        },
        launch = {
            x = startX + buttonW + gap,
            y = y,
            w = buttonW,
            h = buttonH,
        },
    }
end

function BreakoutScene.new(width, height, options)
    local self = setmetatable({}, BreakoutScene)
    self.options = options or {}
    self.game = Breakout.new(width, height, options)
    self.progressStore = self.options.progressStore or ProgressStore.new()
    self.resultOverlayShown = false
    self.lastObservedState = self.game.state
    self.serveInputMode = "position"
    self.pendingServeLaunch = false
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
    local activeSnapshot = snapshot
    if snapshot and self.game.state == "serve" then
        activeSnapshot = {
            moveAxis = snapshot.moveAxis or 0,
            paddleTargetNorm = snapshot.paddleTargetNorm,
            paddleDeltaNorm = snapshot.paddleDeltaNorm or 0,
            serveAimNorm = snapshot.serveAimNorm,
            launchPressed = false,
            restartPressed = snapshot.restartPressed or false,
            pausePressed = snapshot.pausePressed or false,
        }

        if self.serveInputMode == "position" then
            activeSnapshot.serveAimNorm = nil
        else
            activeSnapshot.moveAxis = 0
            activeSnapshot.paddleTargetNorm = nil
            activeSnapshot.paddleDeltaNorm = 0
        end

        if self.pendingServeLaunch then
            activeSnapshot.launchPressed = true
            self.pendingServeLaunch = false
        end
    end

    self.game:setInputSnapshot(activeSnapshot)
    if not activeSnapshot then
        return
    end

    if activeSnapshot.pausePressed and self._stack and self.game.state == "playing" then
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

    gr.setColor(0.08, 0.12, 0.18, 0.68)
    gr.rectangle("fill", 0, h * 0.75, w, h * 0.25)
    gr.setColor(0.64, 0.74, 0.86, 0.75)
    gr.rectangle("line", 0, h * 0.75, w, h * 0.25)

    gr.setColor(0.90, 0.95, 1.0, 0.94)
    if self.game.state == "serve" then
        local rects = getServeControlRects(w, h)
        local modeLabel = "MODE: POSITION"
        if self.serveInputMode == "aim" then
            modeLabel = "MODE: AIM"
        end

        local modeFill = {0.12, 0.20, 0.30, 0.86}
        local launchFill = {0.16, 0.25, 0.17, 0.90}
        if self.serveInputMode == "aim" then
            modeFill = {0.19, 0.28, 0.42, 0.94}
        end

        gr.setColor(modeFill)
        gr.rectangle("fill", rects.mode.x, rects.mode.y, rects.mode.w, rects.mode.h, 10, 10)
        gr.setColor(launchFill)
        gr.rectangle("fill", rects.launch.x, rects.launch.y, rects.launch.w, rects.launch.h, 10, 10)

        gr.setColor(0.72, 0.84, 0.96, 0.9)
        gr.rectangle("line", rects.mode.x, rects.mode.y, rects.mode.w, rects.mode.h, 10, 10)
        gr.setColor(0.78, 0.96, 0.80, 0.95)
        gr.rectangle("line", rects.launch.x, rects.launch.y, rects.launch.w, rects.launch.h, 10, 10)

        gr.setColor(0.92, 0.97, 1.0, 0.96)
        gr.printf(modeLabel, rects.mode.x, rects.mode.y + rects.mode.h * 0.30, rects.mode.w, "center")
        gr.printf("LAUNCH", rects.launch.x, rects.launch.y + rects.launch.h * 0.30, rects.launch.w, "center")

        if self.serveInputMode == "position" then
            gr.printf("Serve: drag bottom lane to place paddle", 0, h * 0.865, w, "center")
            gr.printf("Tap MODE for aim setup, then tap LAUNCH", 0, h * 0.9, w, "center")
        else
            gr.printf("Serve: move pointer/touch to set shot angle", 0, h * 0.865, w, "center")
            gr.printf("Tap MODE to adjust paddle again", 0, h * 0.9, w, "center")
        end

        gr.setColor(0.78, 0.84, 0.92, 0.80)
        gr.printf("Keyboard: TAB mode, SPACE/ENTER launch", 0, h * 0.935, w, "center")
    else
        gr.printf("Mobile: drag the bottom lane to move", 0, h * 0.87, w, "center")
    end
end

function BreakoutScene:resize(width, height)
    self.game:resize(width, height)
end

function BreakoutScene:keypressed(key, scancode)
    if self.game.state == "serve" and key == "tab" then
        if self.serveInputMode == "position" then
            self.serveInputMode = "aim"
        else
            self.serveInputMode = "position"
        end
        return
    end

    if self.game.state == "serve" and (key == "space" or key == "return" or key == "kpenter") then
        self.pendingServeLaunch = true
        return
    end

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

    if self.game.state == "serve" then
        local rects = getServeControlRects(w, h)
        if pointInRect(x, y, rects.mode) then
            if self.serveInputMode == "position" then
                self.serveInputMode = "aim"
            else
                self.serveInputMode = "position"
            end
            return
        end

        if pointInRect(x, y, rects.launch) then
            self.pendingServeLaunch = true
            return
        end
    end

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