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

local function defaultGetHeight()
    if love and love.graphics and love.graphics.getHeight then
        return love.graphics.getHeight()
    end
    return 1
end

local CONTROL_LANE_RATIO = 0.25
local TAP_THRESHOLD_NORM = 0.035

function MouseInput.new(options)
    local self = setmetatable({}, MouseInput)
    self.getPosition = (options and options.getPosition) or defaultGetPosition
    self.isDown = (options and options.isDown) or defaultIsDown
    self.getWidth = (options and options.getWidth) or defaultGetWidth
    self.getHeight = (options and options.getHeight) or defaultGetHeight
    self.prevDown = false
    self.active = false
    self.startXNorm = nil
    self.lastXNorm = nil
    self.moved = false
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

function MouseInput:update()
    local x, y = self.getPosition()
    local width = self.getWidth()
    local height = self.getHeight()
    if width == nil or width <= 0 then
        width = 1
    end
    if height == nil or height <= 0 then
        height = 1
    end

    local xNorm = x / width
    local yNorm = y / height
    if xNorm < 0 then
        xNorm = 0
    elseif xNorm > 1 then
        xNorm = 1
    end
    if yNorm < 0 then
        yNorm = 0
    elseif yNorm > 1 then
        yNorm = 1
    end

    local downNow = self.isDown(1)
    local laneTop = 1 - CONTROL_LANE_RATIO

    self.snapshot.moveAxis = 0
    self.snapshot.paddleTargetNorm = nil
    self.snapshot.paddleDeltaNorm = 0
    self.snapshot.serveAimNorm = xNorm
    self.snapshot.launchPressed = false
    self.snapshot.restartPressed = false
    self.snapshot.pausePressed = false

    if downNow and not self.active and yNorm >= laneTop then
        self.active = true
        self.startXNorm = xNorm
        self.lastXNorm = xNorm
        self.moved = false
    end

    if downNow and self.active then
        self.snapshot.paddleTargetNorm = xNorm
        self.lastXNorm = xNorm

        if math.abs(xNorm - (self.startXNorm or xNorm)) > TAP_THRESHOLD_NORM then
            self.moved = true
        end
    elseif (not downNow) and self.active then
        self.snapshot.launchPressed = not self.moved
        self.active = false
        self.startXNorm = nil
        self.lastXNorm = nil
        self.moved = false
    end

    self.prevDown = downNow
    return self.snapshot
end

return MouseInput