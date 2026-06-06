local SpriteDemo = {}
SpriteDemo.__index = SpriteDemo

function SpriteDemo.new(config)
    local cfg = config or {}
    local self = setmetatable({}, SpriteDemo)
    self.imagePath = cfg.imagePath or "111.jpg"
    self.baseWidth = cfg.baseWidth or 540
    self.baseHeight = cfg.baseHeight or 1200
    self.enabled = cfg.enabled or false
    self.rowFrameCounts = cfg.rowFrameCounts or { 8, 8, 5 }

    self.image = nil
    self.quads = nil
    self.frameIndex = 1
    self.frameTimer = 0
    self.frameDuration = cfg.frameDuration or 0.1
    self.frameCount = 0
    self.frameWidth = 0
    self.frameHeight = 0
    self.x = self.baseWidth * 0.5
    self.y = self.baseHeight * 0.5
    self.scale = 1

    return self
end

local function sumRowFrames(rowFrameCounts)
    local total = 0
    for i = 1, #rowFrameCounts do
        total = total + rowFrameCounts[i]
    end
    return total
end

function SpriteDemo:load()
    local info = love.filesystem.getInfo(self.imagePath)
    if not info then
        return false
    end

    local image = love.graphics.newImage(self.imagePath)
    image:setFilter("nearest", "nearest")

    local iw, ih = image:getDimensions()
    local rowCount = #self.rowFrameCounts
    if rowCount < 1 then
        rowCount = 1
    end

    local maxFramesInRow = 1
    for i = 1, #self.rowFrameCounts do
        if self.rowFrameCounts[i] > maxFramesInRow then
            maxFramesInRow = self.rowFrameCounts[i]
        end
    end

    local frameWidth = math.floor(iw / maxFramesInRow)
    local frameHeight = math.floor(ih / rowCount)
    if frameWidth < 1 then
        frameWidth = iw
    end
    if frameHeight < 1 then
        frameHeight = ih
    end

    local quads = {}
    for row = 1, rowCount do
        local framesInRow = self.rowFrameCounts[row] or 0
        for col = 1, framesInRow do
            local x = (col - 1) * frameWidth
            local y = (row - 1) * frameHeight
            quads[#quads + 1] = love.graphics.newQuad(x, y, frameWidth, frameHeight, iw, ih)
        end
    end

    local frameCount = sumRowFrames(self.rowFrameCounts)

    self.image = image
    self.quads = quads
    self.frameCount = frameCount
    self.frameWidth = frameWidth
    self.frameHeight = frameHeight

    local targetSize = self.baseWidth * 0.4
    self.scale = targetSize / frameWidth

    return true
end

function SpriteDemo:isAvailable()
    return self.image ~= nil and self.quads ~= nil and #self.quads > 0 and self.frameCount > 0
end

function SpriteDemo:toggle()
    if self:isAvailable() then
        self.enabled = not self.enabled
    end
end

function SpriteDemo:update(dt)
    if not self.enabled or not self:isAvailable() then
        return
    end

    self.frameTimer = self.frameTimer + dt
    while self.frameTimer >= self.frameDuration do
        self.frameTimer = self.frameTimer - self.frameDuration
        self.frameIndex = self.frameIndex + 1
        if self.frameIndex > self.frameCount then
            self.frameIndex = 1
        end
    end
end

function SpriteDemo:draw()
    if not self.enabled or not self:isAvailable() then
        return
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(
        self.image,
        self.quads[self.frameIndex],
        self.x,
        self.y,
        0,
        self.scale,
        self.scale,
        self.frameWidth * 0.5,
        self.frameHeight * 0.5
    )
end

return SpriteDemo
