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

function TouchInput.new(options)
    local self = setmetatable({}, TouchInput)
    self.getTouches = (options and options.getTouches) or defaultGetTouches
    self.getPosition = (options and options.getPosition) or defaultGetPosition
    self.getWidth = (options and options.getWidth) or defaultGetWidth
    self.getHeight = (options and options.getHeight) or defaultGetHeight
    self.prevDown = false
    self.activeTouchId = nil
    self.activeStartXNorm = nil
    self.activeLastXNorm = nil
    self.activeMoved = false
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

function TouchInput:update()
    local touches = self.getTouches() or {}
    local width = self.getWidth()
    local height = self.getHeight()
    if width == nil or width <= 0 then
        width = 1
    end
    if height == nil or height <= 0 then
        height = 1
    end

    local laneTop = 1 - CONTROL_LANE_RATIO
    local activeTouchId = self.activeTouchId
    local activeXNorm = nil
    local activeIsDown = false

    for i = 1, #touches do
        local touchId = touches[i]
        local x, y = self.getPosition(touchId)
        local xNorm = (x or 0) / width
        local yNorm = (y or 0) / height
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

        if activeTouchId ~= nil and touchId == activeTouchId then
            activeIsDown = true
            activeXNorm = xNorm
            break
        end

        if activeTouchId == nil and yNorm >= laneTop then
            activeTouchId = touchId
            self.activeTouchId = touchId
            self.activeStartXNorm = xNorm
            self.activeLastXNorm = xNorm
            self.activeMoved = false
            activeIsDown = true
            activeXNorm = xNorm
            break
        end
    end

    self.snapshot.moveAxis = 0
    self.snapshot.paddleTargetNorm = nil
    self.snapshot.paddleDeltaNorm = 0
    self.snapshot.serveAimNorm = nil
    self.snapshot.launchPressed = false
    self.snapshot.restartPressed = false
    self.snapshot.pausePressed = false

    if activeIsDown and activeXNorm ~= nil then
        self.snapshot.paddleTargetNorm = activeXNorm
        self.snapshot.paddleDeltaNorm = 0
        self.snapshot.serveAimNorm = activeXNorm
        self.activeLastXNorm = activeXNorm

        if math.abs(activeXNorm - (self.activeStartXNorm or activeXNorm)) > TAP_THRESHOLD_NORM then
            self.activeMoved = true
        end
    elseif self.activeTouchId ~= nil then
        self.snapshot.launchPressed = not self.activeMoved
        self.activeTouchId = nil
        self.activeStartXNorm = nil
        self.activeLastXNorm = nil
        self.activeMoved = false
    end

    self.prevDown = activeIsDown
    return self.snapshot
end

return TouchInput
