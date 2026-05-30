local TouchInput = {}
TouchInput.__index = TouchInput

local function defaultGetTouches()
    if love and love.touch and love.touch.getTouches then
        return love.touch.getTouches()
    end
    return {}
end

local function defaultGetPosition(id)
    if love and love.touch and love.touch.getPosition then
        return love.touch.getPosition(id)
    end
    return 0, 0
end

local function readMoveAxis(xNorm)
    if xNorm < 0.45 then
        return -1
    end
    if xNorm > 0.55 then
        return 1
    end
    return 0
end

function TouchInput.new(options)
    local self = setmetatable({}, TouchInput)
    self.getTouches = (options and options.getTouches) or defaultGetTouches
    self.getPosition = (options and options.getPosition) or defaultGetPosition
    self.prevDown = false
    self.snapshot = {
        moveAxis = 0,
        paddleTargetNorm = nil,
        launchPressed = false,
        restartPressed = false,
        pausePressed = false,
    }
    return self
end

function TouchInput:update()
    local touches = self.getTouches() or {}
    local touchId = touches[1]

    local isDown = touchId ~= nil
    local moveAxis = 0
    local paddleTargetNorm = nil

    if isDown then
        local xNorm = self.getPosition(touchId)
        if xNorm == nil then
            xNorm = 0.5
        end
        if xNorm < 0 then
            xNorm = 0
        elseif xNorm > 1 then
            xNorm = 1
        end
        moveAxis = readMoveAxis(xNorm)
        paddleTargetNorm = xNorm
    end

    self.snapshot.moveAxis = moveAxis
    self.snapshot.paddleTargetNorm = paddleTargetNorm
    self.snapshot.launchPressed = isDown and (not self.prevDown)
    self.snapshot.restartPressed = false
    self.snapshot.pausePressed = false

    self.prevDown = isDown
    return self.snapshot
end

return TouchInput
