local InputAdapter = {}
InputAdapter.__index = InputAdapter

function InputAdapter.new(options)
    local self = setmetatable({}, InputAdapter)
    self.isDown = (options and options.isDown) or love.keyboard.isDown
    self.prev = {
        launch = false,
        restart = false,
        pause = false,
    }
    self.snapshot = {
        moveAxis = 0,
        launchPressed = false,
        restartPressed = false,
        pausePressed = false,
    }
    return self
end

local function readMoveAxis(isDown)
    local axis = 0
    if isDown("left") or isDown("a") then
        axis = axis - 1
    end
    if isDown("right") or isDown("d") then
        axis = axis + 1
    end
    return axis
end

function InputAdapter:update()
    local launchNow = self.isDown("space")
    local restartNow = self.isDown("r")
    local pauseNow = self.isDown("p")

    self.snapshot.moveAxis = readMoveAxis(self.isDown)
    self.snapshot.launchPressed = launchNow and (not self.prev.launch)
    self.snapshot.restartPressed = restartNow and (not self.prev.restart)
    self.snapshot.pausePressed = pauseNow and (not self.prev.pause)

    self.prev.launch = launchNow
    self.prev.restart = restartNow
    self.prev.pause = pauseNow

    return self.snapshot
end

return InputAdapter
