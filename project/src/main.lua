local InputAdapter = require("03_game.input.inputAdapter")
local SceneStack = require("01_core.sceneStack")
local VirtualResolution = require("01_core.virtualResolution")
local FixedTimestep = require("01_core.fixedTimestep")
local TitleScene = require("03_game.scenes.titleScene")

local inputAdapter
local sceneStack
local virtual
local fixedStep
local BASE_WIDTH = 540
local BASE_HEIGHT = 1200

local spriteDemo = {
    enabled = false,
    image = nil,
    quads = nil,
    frameIndex = 1,
    frameTimer = 0,
    frameDuration = 0.1,
    frameCount = 0,
    frameWidth = 0,
    frameHeight = 0,
    x = 0,
    y = 0,
    scale = 1,
}

local function initSpriteDemo()
    local info = love.filesystem.getInfo("111.jpg")
    if not info then
        return
    end

    local image = love.graphics.newImage("111.jpg")
    image:setFilter("nearest", "nearest")

    local iw, ih = image:getDimensions()
    local frameSize = ih
    local frameCount = math.floor(iw / frameSize)
    if frameCount < 1 then
        frameCount = 1
    end

    local quads = {}
    for i = 1, frameCount do
        quads[i] = love.graphics.newQuad((i - 1) * frameSize, 0, frameSize, frameSize, iw, ih)
    end

    spriteDemo.image = image
    spriteDemo.quads = quads
    spriteDemo.frameCount = frameCount
    spriteDemo.frameWidth = frameSize
    spriteDemo.frameHeight = frameSize
    spriteDemo.x = BASE_WIDTH * 0.5
    spriteDemo.y = BASE_HEIGHT * 0.5

    local targetSize = BASE_WIDTH * 0.4
    spriteDemo.scale = targetSize / frameSize
end

local function updateSpriteDemo(dt)
    if not spriteDemo.enabled or not spriteDemo.quads then
        return
    end

    spriteDemo.frameTimer = spriteDemo.frameTimer + dt
    while spriteDemo.frameTimer >= spriteDemo.frameDuration do
        spriteDemo.frameTimer = spriteDemo.frameTimer - spriteDemo.frameDuration
        spriteDemo.frameIndex = spriteDemo.frameIndex + 1
        if spriteDemo.frameIndex > spriteDemo.frameCount then
            spriteDemo.frameIndex = 1
        end
    end
end

local function drawSpriteDemo()
    if not spriteDemo.enabled or not spriteDemo.image or not spriteDemo.quads then
        return
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(
        spriteDemo.image,
        spriteDemo.quads[spriteDemo.frameIndex],
        spriteDemo.x,
        spriteDemo.y,
        0,
        spriteDemo.scale,
        spriteDemo.scale,
        spriteDemo.frameWidth * 0.5,
        spriteDemo.frameHeight * 0.5
    )
end

function love.load()
    local width, height = love.graphics.getDimensions()
    virtual = VirtualResolution.new(BASE_WIDTH, BASE_HEIGHT)
    inputAdapter = InputAdapter.new()
    sceneStack = SceneStack.new()
    fixedStep = FixedTimestep.new()  -- 1/60 고정 타임스텝
    virtual:resize(width, height)
    sceneStack:push(TitleScene.new(BASE_WIDTH, BASE_HEIGHT))
    initSpriteDemo()
end

function love.resize(width, height)
    if virtual then
        virtual:resize(width, height)
    end

    if sceneStack then
        sceneStack:resize(BASE_WIDTH, BASE_HEIGHT)
    end
end

function love.update(dt)
    if sceneStack and fixedStep then
        local snapshot = inputAdapter:update()
        sceneStack:setInputSnapshot(snapshot)
        
        -- 고정 타임스텝으로 게임 로직 업데이트
        fixedStep:update(dt, function(fixedDt)
            sceneStack:update(fixedDt)
        end)
    end

    updateSpriteDemo(dt)
end

function love.draw()
    if sceneStack then
        love.graphics.clear(0, 0, 0, 1)
        virtual:beginDraw()
        sceneStack:draw()
        drawSpriteDemo()
        virtual:endDraw()
        
        -- FPS 디버그 표시
        love.graphics.setColor(1, 1, 0, 1)
        love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
        love.graphics.print("dt: " .. string.format("%.4f", love.timer.getDelta()), 10, 30)
        if spriteDemo.image then
            love.graphics.print("F2: Toggle 111.jpg sprite animation demo", 10, 50)
        end
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function love.keypressed(key, scancode)
    if key == "escape" then
        love.event.quit()
        return
    end

    if key == "f2" and spriteDemo.image then
        spriteDemo.enabled = not spriteDemo.enabled
    end

    if sceneStack then
        sceneStack:keypressed(key, scancode)
    end
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    if sceneStack and virtual then
        local vx, vy = virtual:toVirtual(x, y)
        sceneStack:touchpressed(id, vx, vy, dx, dy, pressure)
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if sceneStack and virtual then
        local vx, vy = virtual:toVirtual(x, y)
        sceneStack:mousepressed(vx, vy, button, istouch, presses)
    end
end
