local VirtualResolution = {}
VirtualResolution.__index = VirtualResolution

function VirtualResolution.new(baseWidth, baseHeight)
    local self = setmetatable({}, VirtualResolution)
    self.baseWidth = baseWidth
    self.baseHeight = baseHeight
    self.scale = 1
    self.offsetX = 0
    self.offsetY = 0
    return self
end

function VirtualResolution:resize(screenWidth, screenHeight)
    local sx = screenWidth / self.baseWidth
    local sy = screenHeight / self.baseHeight
    self.scale = math.min(sx, sy)
    if self.scale <= 0 then
        self.scale = 1
    end

    local viewportWidth = self.baseWidth * self.scale
    local viewportHeight = self.baseHeight * self.scale

    self.offsetX = math.floor((screenWidth - viewportWidth) * 0.5)
    self.offsetY = math.floor((screenHeight - viewportHeight) * 0.5)
end

function VirtualResolution:beginDraw()
    local gr = love.graphics
    gr.push()
    gr.translate(self.offsetX, self.offsetY)
    gr.scale(self.scale, self.scale)
end

function VirtualResolution:endDraw()
    love.graphics.pop()
end

function VirtualResolution:toVirtual(screenX, screenY)
    local x = (screenX - self.offsetX) / self.scale
    local y = (screenY - self.offsetY) / self.scale
    return x, y
end

return VirtualResolution
