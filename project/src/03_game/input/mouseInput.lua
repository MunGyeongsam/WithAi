local MouseInput = {}
MouseInput.__index = MouseInput

local function defaultGetPosition()
    if love and love.mouse and love.mouse.getPosition then
        return love.mouse.getPosition()
    end
    return 0, 0
end

local function defaultIsDown(button)
    if love and love.mouse and love.mouse.isDown then
        return love.mouse.isDown(button)
    end
    return false
end

local function defaultGetWidth()
    if love and love.graphics and love.graphics.getWidth then
        return love.graphics.getWidth()
    end
    return 1
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

function MouseInput.new(options)
    local self = setmetatable({}, MouseInput)
    self.getPosition = (options and options.getPosition) or defaultGetPosition
    self.isDown = (options and options.isDown) or defaultIsDown
    self.getWidth = (options and options.getWidth) or defaultGetWidth
    self.prevDown = false
    self.snapshot = {
        moveAxis = 0,
        paddleTargetNorm = nil,
        serveAimNorm = nil,
        launchPressed = false,
        restartPressed = false,
        pausePressed = false,
    }
    return self
end

function MouseInput:update()
    local x = self.getPosition()
    local width = self.getWidth()
    if width == nil or width <= 0 then
        width = 1
    end

    local xNorm = x / width
    if xNorm < 0 then
        xNorm = 0
    elseif xNorm > 1 then
        xNorm = 1
    end

    local downNow = self.isDown(1)

    local _ = readMoveAxis(xNorm)
    self.snapshot.moveAxis = 0
    self.snapshot.paddleTargetNorm = nil
    self.snapshot.serveAimNorm = xNorm
    self.snapshot.launchPressed = downNow and (not self.prevDown)
    self.snapshot.restartPressed = false
    self.snapshot.pausePressed = false

    self.prevDown = downNow
    return self.snapshot
end

return MouseInput