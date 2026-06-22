local InputAdapter = {}
InputAdapter.__index = InputAdapter

local TouchInput = require("03_game.input.touchInput")
local MouseInput = require("03_game.input.mouseInput")

function InputAdapter.new(options)
    local self = setmetatable({}, InputAdapter)
    self.isDown = (options and options.isDown) or love.keyboard.isDown
    self.mouseSource = (options and options.mouseSource) or MouseInput.new()
    self.touchSource = (options and options.touchSource) or TouchInput.new()
    self.prev = {
        launch = false,
        restart = false,
        pause = false,
    }
    self.snapshot = {
        moveAxis = 0,
        paddleTargetNorm = nil,
        paddleDeltaNorm = 0,
        serveAimNorm = nil,
        launchPressed = false,
        restartPressed = false,
        pausePressed = false,
    }
    return self
end

local function readMoveAxis(isDown)
    local leftDown = isDown("left") or isDown("a")
    local rightDown = isDown("right") or isDown("d")

    local axis = 0
    if leftDown then
        axis = axis - 1
    end
    if rightDown then
        axis = axis + 1
    end
    return axis, (leftDown or rightDown)
end

function InputAdapter:update()
    local launchNow = self.isDown("space") or self.isDown("return") or self.isDown("kpenter")
    local restartNow = self.isDown("r")
    local pauseNow = self.isDown("p")

    local keyboardAxis, keyboardMoveActive = readMoveAxis(self.isDown)
    local mouseSnapshot = self.mouseSource:update()
    local touchSnapshot = self.touchSource:update()

    self.snapshot.moveAxis = keyboardAxis
    if (not keyboardMoveActive) and self.snapshot.moveAxis == 0 and touchSnapshot then
        self.snapshot.moveAxis = touchSnapshot.moveAxis or 0
    end

    self.snapshot.paddleTargetNorm = nil
    self.snapshot.paddleDeltaNorm = 0
    if (not keyboardMoveActive) and self.snapshot.moveAxis == 0 then
        local touchDelta = touchSnapshot and (touchSnapshot.paddleDeltaNorm or 0) or 0
        local mouseDelta = mouseSnapshot and (mouseSnapshot.paddleDeltaNorm or 0) or 0

        local touchTarget = touchSnapshot and touchSnapshot.paddleTargetNorm or nil
        local mouseTarget = mouseSnapshot and mouseSnapshot.paddleTargetNorm or nil

        if touchTarget ~= nil then
            self.snapshot.paddleTargetNorm = touchTarget
        elseif mouseTarget ~= nil then
            self.snapshot.paddleTargetNorm = mouseTarget
        end

        if touchDelta ~= 0 then
            self.snapshot.paddleDeltaNorm = touchDelta
        elseif mouseDelta ~= 0 then
            self.snapshot.paddleDeltaNorm = mouseDelta
        end
    end

    self.snapshot.serveAimNorm = nil
    local touchServeAim = touchSnapshot and touchSnapshot.serveAimNorm or nil
    local mouseServeAim = mouseSnapshot and mouseSnapshot.serveAimNorm or nil
    if touchServeAim ~= nil then
        self.snapshot.serveAimNorm = touchServeAim
    elseif mouseServeAim ~= nil then
        self.snapshot.serveAimNorm = mouseServeAim
    end

    self.snapshot.launchPressed = launchNow and (not self.prev.launch)
    if mouseSnapshot and mouseSnapshot.launchPressed then
        self.snapshot.launchPressed = true
    end
    if touchSnapshot and touchSnapshot.launchPressed then
        self.snapshot.launchPressed = true
    end
    self.snapshot.restartPressed = restartNow and (not self.prev.restart)
    self.snapshot.pausePressed = pauseNow and (not self.prev.pause)

    self.prev.launch = launchNow
    self.prev.restart = restartNow
    self.prev.pause = pauseNow

    return self.snapshot
end

return InputAdapter
